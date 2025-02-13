;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1993-1997,2010-2013,2016  David D. McDonald  -- all rights reserved
;;; extensions copyright (c) 2007-2010 BBNT Solutions LLC. All Rights Reserved
;;;
;;;     File:  "scan"
;;;   Module:  "drivers;chart:psp:"
;;;  Version:  October 2016

;; initiated 4/23/93 v2.3
;; putting in fsas 5/7
;; 0.1 (5/15) added call to caps-fsa before other word-fsas
;;     (5/21) tweeked state in Figure-out-what-to-do...
;; 0.2 (6/14) added Scan-next-segment as initializing common resumption
;;      point for the higher processes
;; 0.3 (6/30) moved code from Check-for-]-on-position to the adjudication routine
;;      it calls.
;; 0.4 (9/14) added edge-fsas and a trace
;; 0.5 (12/10) moved the point where PNF is called to within word-actions
;; 0.6 (12/17) moved it back after interaction between PNF demands and
;;      section-marker demands was appreciated. (12/22) fixed a detail in that.
;;     (1/5/94) tweeking another detail involving full articles and paragraphs
;; 0.7 (4/23) added :preterminals-installed to Figure-out...
;; 1.0 (5/5) added a final step in the fsa because some .[ were being ignored
;;      and subdivided the status data more throughly to help w/ distinctions
;; 1.1 (5/12) hacked Scan-next-segment to appreciate prescanned segments
;; 2.0 (5/12) distributing the moments when brackets are introduced.
;; 2.1 (5/23) after much tweeking it looks stable. n.b. calls to check the
;;      brackets were redefined.
;; 2.2 (5/24) redesigned word-fsa dispatch because of edges being introduced from
;;      PNF and then again through regular path
;; 2.3 (6/13) added hook for invisible-markup. 6/14 another case in Check-PNF
;; 2.4 (10/24) found another case in resuming after a segment ended by a bracket
;;      from an edge.  (10/26) added reset of *forest-level* flag
;; 2.5 (1/1/95) fixed a bug where a capitalized word doesn't get its fsas run
;;      in the case where pnf returns nil.
;; 2.6 (5/4) changed check-word-level-fsa-trigger to look for an edge that's
;;      already there because of a prior, broken-up PNF scan.
;; 2.7 (5/12) simple patch to Edge-already-on-position for :mult-inital case
;; 2.8 (7/12) added more network-flow traces, put a trap into initiate routine
;;      to catch dropouts.
;; 3.0 (7/17/96) Patched the no-space fsa into the scan
;; 3.1 (8/17/97) began modifications to create a switch settings and gating
;;      that would enable a run with just segmentation in place (no pnf, no
;;      markup, etc.)
;;     (2/6/07) Eliminated an ecase. (3/2) Fixed bug in return from no-space
;;      scan. (7/14/08) Made "hugin" lowercase in anticipation of lower-casing
;;      all functions.
;;     (6/2/10) Annotating the trace calls so threading is easier to follow
;; 3.2 (6/2/10) Added a call to scan-next-position in word-level-actions when the
;;      following position hasn't already been scanned. This is the point where
;;      the call start to have arguments for both positions around the word, and
;;      the downstream code invoked by, e.g. the word-traversal-hook, expect
;;      that position-after to have a word in it already.
;;     (12/15/10) Capitalization change on lots of trace calls.
;;     (1/30/13) Look at whether there's an active document stream before complaining
;;      that we're not a p0.
;;     (2/8/13) Adding more status information now that we have the whole history
;;      to use to make continuation decisions -- see set-status
;;     (4/3/13) Another case to comment out in end-of-source-check.

(in-package :sparser)

;;;------------------
;;; (re-) initiators
;;;------------------

(defun inititate-top-edges-protocol ()
  ;; called from Lookup-the-kind-of-chart-processing-to-do
  (declare (special *current-document-stream*))
  (tr :inititate-top-edges-protocol)  ;; "[scan] Inititate-top-edges-protocol"
  (setq *left-segment-boundary* nil)
  (let* ((p0 (scan-next-position))  ;; status = :scanned
         (ss (pos-terminal p0)))

    (unless (= (pos-token-index p0) 0)
      (unless *current-document-stream*
        (break "~%~%!!!!!!!!!!!!!!!!~%~
                Inititate-top-edges-protocol called at a position other ~
                than zero~%There has probably been a gap in the state space~
                ~%and we've fallen through to the Chart-driver.")))

    ;; source-start doesn't have leading brackets, so we can move
    ;; directly to the next point in the state-space
    (check-word-level-fsa-trigger ss p0)))



(defun scan-next-segment (position)
  ;; point of resumption from everywhere above the segment level
  (tr :scan-next-segment position)  ;; "[scan] scan-next-segment ~A"
  (setq *forest-level* nil)
  (when *left-segment-boundary*
    ;; we've come in from some place that didn't do this bit of cleanup
    ;; /// trap it
    (no-further-action-on-segment))

  (cond (*prescanned-segment-pending*
         (resume-prescanned-segment position))

        (*segment-ended-because-of-boundary-from-form-label*
         (setq *segment-ended-because-of-boundary-from-form-label* nil)
         (case (pos-assessed? position)
           (:]-from-edge-after-checked
            (let ((edge (ev-top-node (pos-starts-here position))))
              (check-fsa-edge-for-leading-[-bracket edge position)))
           (:]-from-edge-before-checked
            (scan-next-pos position))
           (otherwise
            (check-edge-fsa-trigger (all-preterminals-at position)
                                    position
                                    (pos-terminal position)
                                    (chart-position-after position)))))
         (t
          (figure-out-where-to-start-on-next-pos position))))



;;;----------------------------------
;;; Main line of the control network
;;;----------------------------------

(defun scan-next-pos (position)
  (tr :scan-next-pos position)  ;; "[scan] scan-next-pos ~A"
  (unless (pos-terminal position)
    (scan-next-position)) ;; This is where the word gets echoed, status = :scanned
  (continue-scan-next-pos position))

(defun continue-scan-next-pos (position)
  ;; This should repair the problem where we're resuming the
  ;; scan on this position and it has a word that's scanned
  ;; from word-level-actions, having missed all the earlier steps
  (let ((word (pos-terminal position)))
    (introduce-leading-brackets word position)
    ;;  has trace "[scan] introduce-leading-brackets \"~A\""
    (check-for-]-from-word-after word position)))



(defun check-for-]-from-word-after (word position-before)
  (tr :check-for-]-from-word-after word position-before)
  ;;  "[scan] check-for-]-from-word-after p~A \"~A\""
  (trailing-hidden-markup-check position-before)
  (trailing-hidden-annotation-check position-before)
  (let ((] (]-on-position-because-of-word? position-before word)))
    (set-status :]-from-word-after-checked
                position-before) ;; <<< status
    (if ]
      (then
        (tr :]-noted ] position-before) ;; "There is a ~A on p~A"
        (if *left-segment-boundary*
          (then
            (if (bracket-ends-the-segment? ] position-before)
              (pts)
              (check-for-[-from-word-after word position-before)))
          (else
            (tr :]-ignored/no-left-boundary-yet ] word position-before)
            ;;   "Ignoring the ~A at p~A in front of ~A~
            ;; ~%   because the left-boundary of the next segment ~
            ;;      hasn't been established yet."
            (check-for-[-from-word-after word position-before))))
      (else
        (tr :no-brackets-in-front-of position-before) ;; "There is no close bracket at p~A"
        (check-for-[-from-word-after word position-before)))))



(defun check-for-[-from-word-after (word position-before)
  (tr :check-for-[-from-word-after word position-before)
  ;;   "[scan] check-for-[-from-word-after p~A \"~A\""
  (end-of-source-check word position-before)
  (let (([ ([-on-position-because-of-word? position-before word)))
    (set-status :[-from-word-after-checked
                position-before) ;; <<< status
    (when [
      (adjudicate-new-open-bracket [ position-before))
    (leading-hidden-markup-check position-before)
    (check-for-polywords word position-before)))


(defun check-for-polywords (word position-before)
  (tr :check-for-polywords word position-before)
  ;; "[scan] check-for-polywords starting with \"~a\" at p~a"
  (set-status :polywords-check
              position-before)
  ;; Compare to set of variations looked for in do-word-level-fsas
  ;; because this may well miss caitalized pw's
  (if (word-rules word)
    (let ((pw-cfr (initiates-polyword word position-before)))
      (if pw-cfr
        (let ((position-reached
               (do-polyword-fsa word pw-cfr position-before)))
          (if position-reached
            (adjudicate-result-of-word-fsa
             word position-before position-reached)
            (check-for/initiate-scan-patterns word position-before)))
        (else
          (tr :pw-word-does-not-initiate-polywords word)
          (check-for/initiate-scan-patterns word position-before))))
    (else
      (tr :pw-no-rule-set-on word)
      (check-for/initiate-scan-patterns word position-before))))


(defun check-for/initiate-scan-patterns (word position-before)
  (tr :check-for/initiate-scan-patterns position-before)
  ;;  "[scan] check-for/initiate-scan-patterns: p~A
  (set-status :no-space-patterns
              position-before) ;; <<< status
  (if (no-space-before-word? position-before)
    (then
      (tr :no-space-at position-before)
      ;;  [scan] no whitespace at p~A. Initiating scan-pattern check."

      ;; Run the pre-check for defined patterns
      (let ((state/s (scan-pattern-starting-pair position-before word))
            (position-before-that (chart-position-before position-before)))
        ;; This routine returns nil if there is no no-space scan-pattern
        ;; that starts with the word before this position and this word.
        (if state/s
          ;; Fire up the full defined pattern recognition machinery
          ;; and see if it succeeds
          (let ((pos-reached
                 (initiate-scan-pattern-driver state/s position-before)))
            (if pos-reached
              (adjudicate-after-scan-pattern-has-succeeded
               position-before-that word pos-reached)
              (else
               (check-for-uniform-no-space-sequence position-before word))))
          (else
           ;; full pattern pre-check didn't succeed
           (check-for-uniform-no-space-sequence position-before word)))))
    (else
     ;; There's a space before the word
     (check-word-level-fsa-trigger word position-before))))


(defun check-for-uniform-no-space-sequence (position-before word)
  (tr :check-for-uniform-no-space-sequence position-before)
  (if *uniformly-scan-all-no-space-token-sequences*
    (let ((uniform-pos-reached
           (collect-no-space-sequence-into-word position-before)))
      (if uniform-pos-reached
        (adjudicate-after-scan-pattern-has-succeeded
         position-before word uniform-pos-reached)
        (else
         ;; The uniform scan ran into a case like a bracket
         ;; where is couldn't apply.
         (check-word-level-fsa-trigger word position-before))))
    (else
     ;; not allowed to try the uniform scan
     (check-word-level-fsa-trigger word position-before))))



(defun check-word-level-fsa-trigger (word position-before)
  ;; every capitalized word has to be sent to PNF, and only if PNF
  ;; decides that it isn't part of a name does it then also get sent
  ;; to the regular path for word-triggered fsas. (Note that PNF
  ;; may run those fsas itself.)  If PNF is turned off (its ignored
  ;; flag is up) then we continue to the state that its continuation
  ;; would have taken us to if PNF had returned the state 'pnf-preempted'.
  (tr :check-word-level-fsa-trigger position-before)
  ;;  "[scan] check-word-level-fsa-trigger ~A"
  ;;/// shouldn't polywords get a shot before PNF does? Suppose we
  ;; predefine "New York" or reify "bird flu" ?
  (set-status :word-level-fsa-triggers
              position-before) ;; <<< status
  (if (ev-top-node (pos-starts-here position-before))
    (edge-already-on-position position-before)

    (case (pos-capitalization position-before)
      (:lower-case  (cwlft-cont word position-before))
      (:punctuation (cwlft-cont word position-before))
      (:digits      (cwlft-cont word position-before))
      (:spaces      (cwlft-cont word position-before))
      (otherwise ;; i.e. we have a capitalized word
       (if *ignore-capitalization*
         (then (tr :pnf/preempted)
               (set-status :pnf-preempted
                           position-before)
               (cwlft-cont word position-before))
         (check-PNF-and-continue word position-before))))))


(defun cwlft-cont (word position-before)
  ;; "check-word-level-fsa-trigger" continued
  ;; This is the path if we don't go through PNF
  (tr :cwlft-cont position-before)  ;; "[scan] cwlft-cont ~A"
  (let ((where-fsa-ended (do-word-level-fsas word position-before))) ;; <<< status
    ;;     that sets status to :word-fsas-done
    ;; That call does the polywords and anything else we might have
    ;; defined as an fsa on the word.
    (if where-fsa-ended
      (adjudicate-result-of-word-fsa word position-before where-fsa-ended)
      (word-level-actions word position-before))))



(defun check-PNF-and-continue (word position-before)
  (tr :check-PNF-and-continue position-before)
  ;;   "[scan] Check-PNF-and-continue ~A"
  (let ((where-caps-fsa-ended (pnf position-before))) ;; <<< status
    ;;    That can set status to :PNF-checked or :pnf-preempted
    (if where-caps-fsa-ended
      ;; since the embedded scan by PNF won't act on any ] on the
      ;; position where it happens to end, we have to.
      (adjudicate-after-pnf position-before where-caps-fsa-ended)
      (continuation-after-pnf-returned-nil word position-before))))



(defun word-level-actions (word position-before)
  (tr :word-level-actions word) ;; "[scan] word-level-actions ~A"
  (set-status :word-level-actions
              position-before) ;; <<< status
  (tr :actions-on-word word position-before) ;; "Doing word-level actions on \"~A\" at p~A"
  (let ((position-after (chart-position-after position-before)))
    (unless (pos-terminal position-after)
      ;; We need this because the routines called from these hooks presume that
      ;; there is a word at the position after. But since we initiate the entire
      ;; parse by starting in 'the middle', this is where many of the words
      ;; are going to enter the chart rather than via scan-next-pos
      (tr :scan-from-word-level-actions position-after)
      ;;   "[scan] No word at p~a yet. Calling scan-next-position"
      (scan-next-position)
      (set-status :scanned-from-word-actions
                  position-after))
    (complete-word/hugin word position-before position-after) ;; status => :word-completed
    (word-traversal-hook word position-before position-after)
    (introduce-terminal-edges word position-before position-after)))



(defun edge-already-on-position (position-before)
  ;; Called from check-word-level-fsa-trigger when that top-node
  ;; check comes up non-nil
  (let ((edge
         (ev-top-node (pos-starts-here position-before))))
    (tr :edge-already-on-position edge)
    ;; There can already be an edge here because we've already been
    ;; through this stretch once during, e.g., a PNF scan that was
    ;; broken up by 'of' or the like.

    (when (eq edge :multiple-initial-edges)
      ;; ///// this should probably be clever, but when all this is
      ;; doing is deciding where to jump to in the scan fsa, then
      ;; maybe its enough.
      (setq edge (highest-edge (pos-starts-here position-before))))

    (if (eq (pos-edge-ends-at edge)
            (chart-position-after position-before))
      ;; is it only one word long?  Then we don't want to go through
      ;; 'introduce-terminals' again, but we probably don't want to
      ;; to start as far back as checking (non-PNF) fsas.
      (word-level-actions-except-terminals (pos-terminal position-before)
                                           position-before)

      ;; Otherwise we want to pick up again at wherever this
      ;; edge ends and act like we've just introduced it.
      (check-fsa-edge-for-brackets position-before
                                   edge
                                   (pos-edge-ends-at edge)))))



(defun word-level-actions-except-terminals (word position-before)
  (set-status :word-level-actions-no-terminals
              position-before) ;; <<< status
  (tr :word-level-actions-except-terminals position-before)
  (let ((position-after (chart-position-after position-before)))
    (complete-word/hugin word position-before position-after)
    (word-traversal-hook word position-before position-after)

    (if (preterminal-edge-at? position-before)
      ;; if there are any preterminal edges here, check them for
      ;; (non-pnf) brackets and fsas
      (check-preterminal-edges (all-preterminals-at position-before)
                               word position-before position-after)
      (introduce-right-side-brackets word position-after))))




(defun introduce-terminal-edges (word position-before position-after)
  (tr :introduce-terminal-edges word) ;; "[scan] introduce-terminal-edges ~A"
  (let ((edges
         ;;  sets status to :preterminals-installed
         (install-terminal-edges word position-before position-after)))
    (if edges
      (then
        (check-preterminal-edges
         edges word position-before position-after))
      (introduce-right-side-brackets word position-after))))



(defun check-preterminal-edges (edges word position-before position-after)
  (tr :check-preterminal-edges position-before) ;; "[scan] Check-preterminal-edges ~A"
  (let ((label (introduce-leading-brackets-from-edge-form-labels
                edges position-before)))
    (if label
      (check-for-]-from-edge-after edges word
                                   position-before position-after
                                   label)
      (check-edge-fsa-trigger
       edges position-before word position-after))))




(defun introduce-leading-brackets-from-edge-form-labels (edges
                                                         position-before)
  (tr :introduce-leading-brackets-from-edge-form-labels position-before)
  (let ( label label-has-bracket-assignments? )
    (dolist (edge edges)
      (unless (edge-over-literal? edge)
        (setq label (edge-form edge))
        (when label
          (when (introduce-leading-brackets label position-before)
            ;; this scheme loses labels if more than one has bracketing,
            ;; but that's ok for a start if not in general
            (setq label-has-bracket-assignments? label)))))
    label-has-bracket-assignments? ))


(defun introduce-trailing-brackets-from-edge-form-labels (edges
                                                         position-after)
  (tr :introduce-trailing-brackets-from-edge-form-labels position-after)
  (let ( label label-has-bracket-assignments? )
    (dolist (edge edges)
      (unless (edge-over-literal? edge)
        (setq label (edge-form edge))
        (when label
          (when (introduce-trailing-brackets label position-after)
            (setq label-has-bracket-assignments? label)))))
    label-has-bracket-assignments? ))




(defun check-for-]-from-edge-after (edges word
                                    position-before position-after
                                    label )
  ;; we only get here via the main thread when some edge did introduce
  ;; bracketing, so we get its label as an argument
  (tr :check-for-]-from-edge-after position-before)
  (let ((] (]-on-position-because-of-word? position-before label)))
    (set-status :]-from-edge-after-checked
                position-before)
    (if ]   ;; this is copied from the same code for words
      (then (tr :]-noted ] position-before)
            (if *left-segment-boundary*
              (if (bracket-ends-the-segment? ] position-before)
                (pts t)  ;;the extra arg sets a flag
                (check-edge-fsa-trigger
                 edges position-before word position-after))
              (else
                (tr :]-ignored/no-left-boundary-yet
                    ] word position-before)
                (check-edge-fsa-trigger
                 edges position-before word position-after))))
      (else
        (check-edge-fsa-trigger
         edges position-before word position-after)))))



(defun check-edge-fsa-trigger (edges position-before word position-after)
  (tr :check-edge-fsa-trigger position-before)
  (set-status :edge-fsa-checked
              position-before) ;; <<< status
  (let ((position-after-edge-fsa
         (do-edge-level-fsas edges position-before)))
    (if position-after-edge-fsa
      (adjudicate-after-edge-fsa position-after-edge-fsa)
      (introduce-right-side-brackets word position-after))))



(defun introduce-right-side-brackets (word position-after)
  (tr :introduce-right-side-brackets word)
  ;;  "[scan] introduce-right-side-brackets: ~a"
  (introduce-trailing-brackets word position-after)
  (check-for-]-from-prior-word position-after word))


(defun check-for-]-from-prior-word (position-after prior-word)
  (tr :check-for-]-from-prior-word position-after)
  ;; "[scan] check-for-]-from-prior-word: p~A"
  (let ((] (]-on-position-because-of-word?
            position-after prior-word)))
    (set-status :]-from-prior-word-checked
                position-after)
    (if ]
      (then
        (tr :]-noted ] position-after)
        (if *left-segment-boundary*
          (if (bracket-ends-the-segment? ] position-after)
            (pts)
            (check-for-[-from-prior-word position-after prior-word))
          (else
            (tr :]-ignored/no-left-boundary-yet
                ] (pos-terminal position-after) position-after)
            (check-for-[-from-prior-word position-after prior-word))))
      (else
        (tr :no-brackets-in-front-of position-after)
        (check-for-[-from-prior-word position-after prior-word)))))



(defun check-for-[-from-prior-word (position-after prior-word)
  (tr :check-for-[-from-prior-word position-after)
  (let (([ ([-on-position-because-of-word? position-after prior-word)))
    (set-status :[-from-prior-word-checked position-after)
    (if [
      (adjudicate-new-open-bracket [ position-after)
      (let ((edges (all-preterminals-at
                    (chart-position-before position-after))))
        (when edges
          (let ((label (introduce-trailing-brackets-from-edge-form-labels
                        edges position-after)))
            (when label  ;; there probably something to see
              (setq [ ([-on-position-because-of-word? position-after
                                                      label))
              (when [
                (adjudicate-new-open-bracket [
                                             position-after)))))))
    (scan-next-pos position-after)))





;;;----------------------------------------------------------
;;; calls from the interior of routines in the main sequence
;;;----------------------------------------------------------

(defun leading-hidden-markup-check (position)
  ;; Called from Introduce-right-side-brackets. We're looking
  ;; for markup that would be stored in the markup field of
  ;; the edge vector starting at this position.
  (tr :leading-hidden-markup-check position)
  (when (leading-hidden-markup-on-position? position)
    (establish-hidden-section position)))

(defun trailing-hidden-markup-check (position)
  ;; Called from Check-for-]-from-word-after.  We're looking for
  ;; markup that would be stored in the markup field of the
  ;; edge vector ending at this position.
  (tr :trailing-hidden-markup-check position)
  (when (trailing-hidden-markup-on-position? position)
    (terminate-hidden-section position)))


(defun trailing-hidden-annotation-check (position-before)
  ;; Called from Check-for-]-from-word-after.
  ;; We're looking for annotation that would have been picked up
  ;; at the next-terminal level and stashed on the plist of the
  ;; edge-vector ending at this position. It is intended to
  ;; apply to the word that we finished processing on the
  ;; last pass through the word-level -- we're called just before
  ;; the check on the vector of the 'position-before' the -next-
  ;; word for the possibility of ending the segment.
  (tr :trailing-hidden-annotation-check position-before)
  (when (ev-plist
         (pos-ends-here position-before))
    (trailing-annotation-hook position-before)))



(defun end-of-source-check (word position-before)
  (tr :end-of-source-check word position-before)
  (when (eq word *end-of-source*)
    ;; At the segment level we know we've finished parsing the last
    ;; segment because we've just checked for a bracket ending the
    ;; ongoing segment and if the current word is indeed end-of-source
    ;; it will have introduced such a bracket and had us move to pts
    ;; before this function is entered

    (if (eq *rightmost-quiescent-position* position-before)
      ;; we have to make this check to ensure that all the forest level
      ;; parsing is also finished.  ///?? treetop level too ???
      (then
       ;; [sfriedman:20130211.2000CST]
       ;; Section representation has changed, so this is no longer valid.
       ;; (do-the-last-things-in-an-analysis position-before)
       (terminate-chart-level-process))

      (if *do-forest-level*
        (then
         (setq *where-the-last-segment-ended* position-before)
         (move-to-forest-level position-before :eos-reached))
        (else
         ;; Also invalid -- amoung other things it knows about
         ;; the old paragraph structures
         ;; (do-the-last-things-in-an-analysis position-before)
         (terminate-chart-level-process))))))

