;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1992,1993  David D. McDonald  -- all rights reserved
;;;
;;;     File:  "loops"
;;;   Module:  "drivers;chart:all edges"
;;;  version:  2.6 August 1993

;; initiated  12/6/92 v2.3, added edge processing 12/14,15
;; 2.1 (3/8/93) tweeked the checking routines to appreciate multiple
;;      completions.
;;     (3/11) fixed a typo
;; 2.2 (4/6) Added switched forms of the edge-checking protocol so that
;;      kconses can be used in the edge-vectors
;; 2.3 (5/5) Debugged interaction with edge-driven fsas
;; 2.4 (5/14) added redundancy checking when looking right
;; 2.5 (8/25) added check to stop dotted edges looking leftwards since
;;      they can only combine to their right.
;; 2.6 (8/27) fixing an omission in that check, fixed fencepost error
;;      where edges build by text-final fsa weren't checked.
;;     (8/30) fixed another bug, this time took out a short cut that didn't
;;      appreciate the possibility of scans internal to fsas

(in-package :sparser)


(defun initiate-all-edges-protocol ()
  ;; prime the pump by scanning p0
  (tr :starting-ae)
  (tr :ae/scan (aref *the-chart* *next-chart-position-to-scan*))
  (ae/after-scan (scan-next-position)))

(defun aE/dispatch (position &optional caller)
  (tr :ae/dispatch position)
  (let ((status (pos-assessed? position)))
    (if status
      (ecase status
        (:pre-terminals-done-from-fsa
         ;; it's been scanned and its edges introduced, but no word-level
         ;; actions have been taken or fsas run.
         (ae/after-scan position))
        (:pre-terminals-installed
         (process-edges-over-word&continue
          (preterminal-edges position)
          (pos-terminal position)
          (chart-position-after position)))
        (:edge-fsas-done
         ;; these fsas are done within a fn that makes its own calls to
         ;; the next states
         (break "Dispatch from ~A~
               ~%  position ~A has the status ~A, which should be ~
               impossible.~
               ~%  Check threading."
                caller (pos-token-index position) status))
        (:edges-done
         (ae/scan&continue (chart-position-after position)))
        (:completed&traversed
         (ae/do-edges (pos-terminal position)
                      (chart-position-after position) position))
        (:word-fsas-done
         (ae/compete-traverse&continue (pos-terminal position) position))
        (:scanned (ae/after-scan position)))
      (else
        (ae/scan&continue position)))))


(defun aE/scan&continue (next-position)
  (tr :ae/scan next-position)
  (let ((position-scanned (scan-next-position)))
    (setf (pos-assessed? next-position) :scanned)

    (unless (eq position-scanned next-position)
      (break "scan may be out of sync:~
              ~%  Next position is ~A~
              ~%     scan returned ~A" next-position position-scanned))
    (ae/after-scan next-position)))


(defun aE/after-scan (position)
  ;; we know it's been scanned in, but nothing else should have
  ;; happened to it yet.
  (let ((word (pos-terminal position)))
    (tr :ae/word-scanned word)

    (when (eq word word::end-of-source)
      (terminate-chart-level-process))

    (let ((position-after-fsa
           (do-word-level-fsas word position)))
      (if position-after-fsa
        (then
          (do-pending-edges position) ;; added because it fixed a bug in edges fsa case
          (AE/dispatch position-after-fsa))
        (ae/compete-traverse&continue word position)))))



(defun aE/compete-traverse&continue (word position)
  (tr :ae/complete word position)
  (let ((next-position (chart-position-after position)))
    (complete-word/hugin word position next-position)
    (word-traversal-hook word position next-position)

    (setf (pos-assessed? position) :completed&traversed)
    (ae/do-edges word position next-position)))



(defun aE/do-edges (word position next-position)
  (let ((edges-over-word
         ;; have to check for case where this position was already seen
         ;; from an edge-initiated fsa and so already has its preterminals
         ;; introduced. The only other way an edge could have been installed
         ;; up to this point is from a word-initiated fsa, but those should
         ;; be admonished to never just respan the one word.
         (if (ev-top-node (pos-starts-here position))
           (preterminal-edges position)
           (install-terminal-edges word position next-position))))

    (tr :ae/install-preterminals word edges-over-word)
    (if edges-over-word
      (process-edges-over-word&continue edges-over-word
                                        position
                                        next-position)
      (else
        (setf (pos-assessed? position) :edges-done)
        (ae/dispatch next-position)))))


(defun process-edges-over-word&continue (edges-over-word position next-position)
  (let ((position-after-fsa
         (do-edge-level-fsas edges-over-word position)))
    (if position-after-fsa
      (then
        (do-pending-edges position)
        (ae/dispatch position-after-fsa))
      (else
        (do-pending-edges position)
        (ae/dispatch next-position)))))


(defun do-pending-edges (position)
  ;; n.b. this isn't tail recursive -- it will return to its caller.
  (let ((index-of-next-edge-to-check *edge-just-checked*)
        (switchover-index *length-of-edge-resource*)
        edge )
    (tr :ae/do-pending-edges position)

    (loop
      (incf index-of-next-edge-to-check)
      (when (= index-of-next-edge-to-check
               switchover-index)
        (setq index-of-next-edge-to-check 0))

      (when (= index-of-next-edge-to-check
               *position-of-next-available-edge-in-resource*)
        (return))

      (setq edge (edge# index-of-next-edge-to-check))
      (check-edge-against-all-neighbors edge))

    (setq *edge-just-checked* (1- index-of-next-edge-to-check))
    (setf (pos-assessed? position) :edges-done)))



(defun check-edge-against-all-neighbors (edge)
  (tr :ae/check-against-neighbors edge)
  (check-left-against-all-neighbors edge)
  (check-right-against-all-neighbors edge))


;;;-----------------------------------
;;; the switches on the actual checks
;;;-----------------------------------

(defun check-left-against-all-neighbors (edge)
  (declare (ignore edge))
  (error "No value for this switched function.~
          ~%Call Establish-type-of-edge-vector-to-use"))

(defun check-right-against-all-neighbors (edge)
  (declare (ignore edge))
  (error "No value for this switched function.~
          ~%Call Establish-type-of-edge-vector-to-use"))


;;;--------------------------------------
;;; The actual checks -- vector versions
;;;--------------------------------------

(defun check-left-against-all-neighbors/vector (edge)
  (unless (edge-of-dotted-intermediary edge)
    (let* ((left-vector
            (pos-ends-here (ev-position (edge-starts-at edge))))
           (left-count (ev-number-of-edges left-vector))
           (left-edges (ev-edge-vector left-vector))        
           left-neighbor rule )
      
      (when (= left-count 0)
        (tr :no-neighbors-to-the-left edge))
      
      (dotimes (i left-count)
        (setq left-neighbor (elt left-edges i))
        (tr :ae/checking-left-neighbor edge left-neighbor)
        (setq rule (multiply-edges left-neighbor edge))
        (if rule
          (then
            (if (listp rule)
              (dolist (r rule)
                (make-completed-binary-edge left-neighbor edge r))
              (make-completed-binary-edge left-neighbor edge rule)))
          (else
            (tr :multiply-failed left-neighbor edge)))))))


(defun check-right-against-all-neighbors/vector (edge)
  (let* ((right-vector
          (pos-starts-here (ev-position (edge-ends-at edge))))
         (right-count (ev-number-of-edges right-vector))
         (right-edges (ev-edge-vector right-vector))
         right-neighbor rule )
    
    (when (= right-count 0)
      (tr :no-neighbors-to-the-right edge))
    
    (dotimes (i right-count)
      (setq right-neighbor (elt right-edges i))
      (unless (edge-of-dotted-intermediary right-neighbor)
        (tr :ae/checking-right-neighbor edge right-neighbor)
        
        (if (edge-used-in right-neighbor)
          (break "write the Vector version of the redundancy-checking code")
          (else
            (setq rule (multiply-edges edge right-neighbor))
            (if rule
              (then
                (if (listp rule)
                  (dolist (r rule)
                    (make-completed-binary-edge  edge right-neighbor r))
                  (make-completed-binary-edge edge right-neighbor rule)))
              (else
                (tr :multiply-failed edge right-neighbor)))))))))


;;;----------------
;;; kcons versions
;;;----------------

(defun check-left-against-all-neighbors/kcons (edge)
  (unless (edge-of-dotted-intermediary edge)
    (let* ((left-vector
            (pos-ends-here (ev-position (edge-starts-at edge))))
           (left-edges (ev-edge-vector left-vector))  
           rule )
      
      (when (null left-edges)
        (tr :no-neighbors-to-the-left edge))
      
      (dolist (left-neighbor left-edges)
        (tr :ae/checking-left-neighbor edge left-neighbor)
        (setq rule (multiply-edges left-neighbor edge))
        (if rule
          (then
            (if (listp rule)
              (dolist (r rule)
                (make-completed-binary-edge left-neighbor edge r))
              (make-completed-binary-edge left-neighbor edge rule)))
          (else
            (tr :multiply-failed left-neighbor edge)))))))


(defun check-right-against-all-neighbors/kcons (edge)
  (let* ((right-vector
          (pos-starts-here (ev-position (edge-ends-at edge))))
         (right-edges (ev-edge-vector right-vector))
         rule )
    
    (when (null right-edges)
      (tr :no-neighbors-to-the-right edge))
    
    (dolist (right-neighbor right-edges)
      (unless (edge-of-dotted-intermediary right-neighbor)
        (tr :ae/checking-right-neighbor edge right-neighbor)
        (setq rule (multiply-edges edge right-neighbor))
        (if rule
          (if (edge-used-in right-neighbor)
            (then
              ;; check that completing this rule/s wouldn't be redundant
              ;; with an earlier completion over the same edges
              (if (listp rule)
                (dolist (r rule)
                  (unless (already-completed/right rule edge right-neighbor)
                    (make-completed-binary-edge  edge right-neighbor r)))
                (else
                  (unless (already-completed/right rule edge right-neighbor)
                    (make-completed-binary-edge  edge right-neighbor rule)))))
            (else
              (if (listp rule)
                (dolist (r rule)
                  (make-completed-binary-edge  edge right-neighbor r))
                (make-completed-binary-edge edge right-neighbor rule))))
          (else
            (tr :multiply-failed edge right-neighbor)))))))



;;;---------------------
;;; redundancy checking
;;;---------------------

(defun already-completed/right (rule left-edge right-edge)
  ;; the right-edge is used-in some parent edge/s
  ;; Check that the left edge and indicated rule aren't among those
  ;; parent/s
  (let ((parent/s (edge-used-in right-edge)))
    (if (consp parent/s)
      (then
        (dolist (e parent/s)
          (when (completion-matches/left? e rule left-edge)
            (return-from already-completed/right t)))
        nil)
      (else
        (completion-matches/left? parent/s rule left-edge)))))


(defun completion-matches/left? (edge rule left-edge)
  ;; was this edge created using this rule and have the 'left-edge'
  ;; as its left-daughter?
  (if (eq (edge-rule edge) rule)
    (if (eq (edge-left-daughter edge) left-edge)
      t
      nil)
    nil))
