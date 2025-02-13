;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; Copyright (c) 2006-2010 BBNT Solutions LLC. All Rights Reserved
;;; Copyright (c) 2011-2013  David D. McDonald  -- all rights reserved
;;;
;;;     File: /grammar/rules/words/one-offs/treebank-reader.lisp
;;;  version: March 2013

;; (2/9/11) Wrapped the mapcar for the top-level calls into a function that
;;  has to be called. The 'pp' function it creates conflicts with the 'pp'
;;  abbreviation for invoking the parser when loaded into a case-insensitive
;;  lisp such as Clozure Found another mispatch in accessor and changed the
;;  struct's prefix to #: notation. (3/7/13) added treebank-smoke-test just
;;  to see what blows up.  (3/12/13) renamed incident-count when text-relations
;; wanted it as a generic function.

(in-package :sparser)

(defvar *CONSTITUENT-PATTERNS*)
(defvar *MERGE-NUMBERS*)
(defvar *NONTERMINAL-TAG-COUNT*)
(defvar *NT-TAGS-TO-PATTERNS*)
(defvar *POS-TAG-COUNT*)
(defvar *TAG-COUNT*)
(defvar *WORD-COUNT*)
(defvar *WORD-TOKEN-COUNT*)
(defvar SYMBOL-TO-NONTERMINAL-TAG)
(defvar SYMBOL-TO-POS-TAGS)
(defvar SYMBOLS-TO-TAGS)
(defvar SYMBOLS-TO-WORDS)

;   In WRITE-WORDS-BY-POS: Unused lexical variable S
;Compiler warnings for "/Users/rusty/sparser/Sparser/code/s/grammar/rules/words/one-offs/treebank-reader.lisp" :

;; These solve a problem about populating the chart by hiding
;; the multi-type characters of the symbols from Sparser's tokenizer
;; The values have to be a single character type so that the tokenizer
;; will treat them as a single token rather than split them, which
;; leads to getting the wrong chart terminals and all sorts of subtle
;; bugs -- see extract-terminals-loop in sparser-interface

(defconstant *possessive-marker* (intern "POSSESSIVE" (find-package :sparser)))

(defconstant *LRB* 'lrb) ;; open & close parentheses
(defconstant *RRB* 'rrb)

(defconstant *open-quote* 'openQuote)
(defconstant *close-quote* 'closeQuote)

(export '(*possessive-marker*
          *LRB*
          *RRB*
          *open-quote*
          *close-quote*
          ))


;;;------
;;; util
;;;------

(defun take (n list)
  (loop repeat n
      collect (pop list)))


;;;-----------------------
;;; readtable for TB sexp
;;;-----------------------

(defparameter *my-readtable* (copy-readtable))

(defun period-reader (stream char)
  (declare (ignore stream char))
  'period)

(defun comma-reader (stream char)
  (declare (ignore stream char))
  'comma)

(defun backquote-reader (stream char)
  (declare (ignore char))
  (let ((c (peek-char nil stream)))
    (if (eql c #\`)
          (then
        (read-char stream)
        (let ((d (peek-char nil stream)))
          (if (eql d #\))
                'open-quote
            'open-quote-tag)))
      'open-quote)))

(defun quote-reader (stream char)
  (declare (ignore char))
  (let ((c (peek-char nil stream)))
    (if (eql c #\')
          (then (read-char stream) 'close-quote)
      'single-quote))) ;; appostrophe ??

(defun colon-reader (stream char)
  (declare (ignore char))
  (let ((c (peek-char nil stream)))
    (if (eql c #\space)
          'colon-tag
      'colon)))

(defun semicolon-reader (stream char)
  (declare (ignore stream char))
  'semicolon)

(defun sharpsign-reader (stream char)
  (declare (ignore char))
  (let ((c (peek-char nil stream)))
    (if (eql c #\space)
      'sharpsign-tag
      'sharpsign)))

(defparameter period 'period)
(defparameter comma 'comma)
(defparameter open-quote 'open-quote)
(defparameter open-quote-tag 'open-quote-tag)
(defparameter close-quote 'close-quote)
(defparameter single-quote 'single-quote)
(defparameter colon-tag 'colon-tag)
(defparameter colon 'colon)
(defparameter semicolon 'semicolon)
(defparameter sharpsign 'sharpsign)
(defparameter sharpsign-tag 'sharpsign-tag)


(defun set-macro-characters ()
  (set-macro-character #\. #'period-reader nil *my-readtable*)
  (set-macro-character #\, #'comma-reader nil *my-readtable*)
  (set-macro-character #\` #'backquote-reader nil *my-readtable*)
  (set-macro-character #\' #'quote-reader nil *my-readtable*)
  (set-macro-character #\: #'colon-reader nil *my-readtable*)
  (set-macro-character #\; #'semicolon-reader nil *my-readtable*)
  (set-macro-character #\# #'sharpsign-reader nil *my-readtable*))

(set-macro-characters)

(defvar *current-readtable* *readtable*)

(defvar *readtable-stack* nil)

(defun my-rt () (setq *readtable* *my-readtable*))

(defun old-rt () (setq *readtable* *current-readtable*))

(defmacro with-readtable-bound (rt &body body)
  `(let ((body-result nil))
     (push *readtable* *readtable-stack*)
     (setf *readtable* ,rt)
     (unwind-protect
         (setf body-result (progn ,@body))
       (progn
         (setf *readtable* (pop *readtable-stack*))
         body-result))))


;;;---------
;;; objects
;;;---------

(defstruct (immediate-constituent-pattern
            (:conc-name #:icp-)
            (:print-function
             (lambda (icp stream depth)
               (declare (ignore depth))
               (format stream "#<icp ~a => ~a>"
                       (icp-tag icp)
                       (icp-constituents icp)))))
  tag ;; symbol for now, rep. of the NT latter
  constituents
  freq
  count ;; ///
  over-terminals?
  )



;;;---------------------------------
;;; harness for going through files
;;;---------------------------------

(defun harness (full-filename)
  (time
   (with-open-file (stream full-filename
                    :direction :input
                    :if-does-not-exist :error)
     (with-readtable-bound *my-readtable*
        (clear-treebank-tables)
        (let ((eof? nil)
              (sexp nil)
              ;;(count 0)
              )
          (loop while (not eof?) do
               (setq sexp (read stream nil :eof))
               (if (eq sexp :eof) (setq eof? t))
             ;;(format t " ~a" (incf count))
               (eval sexp)))))))


(defun create-top-level-call (tag)
  (let ((form `(defmacro ,tag (&rest constituents)
                 ;;(funcall #constituent-reader constituents ',tag)
                 (constituent-reader constituents ',tag))))
    (eval form)))

(defun setup-toplevel-calls ()
  (mapcar #'create-top-level-call
          '(S
            SINV
            SBAR
            SBARQ
            SQ
            FRAG
            UCP
            DATE
            NP
            PRN
            VP
            PP
            ADVP
            ADJP
            X
            INTJ)))



;;;---------------------------
;;; reading parser or TB sexp
;;;---------------------------

(defun constituent-reader (constituents toplevel-tag)
  (declare (ignore toplevel-tag))
  (dolist (c constituents)
    ;(format t "reader: c = ~a" c)
    (analyze-constituent c)))

(defparameter *what-to-do* :read-through)

(defun analyze-constituent (constituent)
  (case *what-to-do*
    (:read-through
     (constituent-walker constituent))
    (:otherwise
     (format t "Unknown value for *what-to-do*: ~a" *what-to-do*))))

(defun constituent-walker (c)
  (unless (symbolp (car c))
    (break "Constituent does not start with a symbol:~%~a" c))
  (let ((tag (car c))
        (rest (cdr c)))
    ;;(format t "~%walker: tag = ~a" tag)
    (notice-tag tag)
    ;;(format t "~%walker: rest = ~a" rest)
    (if (consp (car rest))
      (then
        (notice-nonterminal-tag tag rest)
        (notice-immediate-constituent-pattern tag rest)
        (constituent-reader rest tag))
      (let ((token (second c)))
       (unless token
         (break "Expected a pname. c = ~a" c))
       ;;(format t "~%walker: word = ~a" token)
       (when (and (numberp token)
                  *merge-numbers*)
         (setq token 'number))
       (notice-pos-tag tag token)
       (notice-word token tag)))))

(defparameter *merge-numbers* t)


;;;-----------------
;;; data collection
;;;-----------------

(defun clear-treebank-tables ()
  (setq *nonterminal-tag-count* 0)
  (clrhash symbol-to-nonterminal-tag)
  (setq *constituent-patterns* 0)
  (clrhash *NT-tags-to-patterns*)
  (setq *pos-tag-count* 0)
  (clrhash symbol-to-pos-tags)
  (setq *tag-count* 0)
  (clrhash symbols-to-tags)
  (setq *word-count* 0)
  (setq *word-token-count* 0)
  (clrhash symbols-to-words)
  #+ccl(gc))


;;(clear-pattern-counts)
;;  Clearing the index table frees the objects for gc so we don't
;;  have to include this operatin in clear-treebank-tables
;;  /// In other modes these objects will be permanent and the
;;      table read in from data

(defvar *constituent-patterns* 0) ;; count of unique instances

(defparameter *NT-tags-to-patterns* (make-hash-table :test #'equal))

(defun notice-immediate-constituent-pattern (tag constituents)
  (let ((constituent-tags (toplevel-tags constituents))
        (tag-table (gethash tag *NT-tags-to-patterns*)))
    (if tag-table
      (let ((icp (gethash constituent-tags tag-table)))
        (if icp
          (incf (icp-freq icp))
          (else
            ;;(format t "~&~a added ~a" tag constituent-tags)
            (setf (gethash constituent-tags tag-table)
                  (define-constituent-pattern tag constituent-tags)))))
      (let ((tag-table (make-hash-table :test #'equal)))
        (setf (gethash constituent-tags tag-table)
              (define-constituent-pattern tag constituent-tags))
        ;;(format t "~&-- ~a added ~a" tag constituent-tags)
        (setf (gethash tag *NT-tags-to-patterns*) tag-table)))
    constituent-tags))


(defvar *sorted-icp* '())

(defun order-icp-by-frequency ()
  (let ((icps '()))
    (maphash #'(lambda (tag table)
                 (declare (ignore tag))
                 (maphash #'(lambda (constituents icp-object)
                              (declare (ignore constituents))
                              (push icp-object icps))
                          table))
             *NT-tags-to-patterns*)
    (length (setq *sorted-icp*
              (sort icps #'> :key #'icp-freq)))))


(defun icp-incident-count ()
  (let ((count 0))
    (maphash #'(lambda (tag table)
                 (declare (ignore tag))
                 (maphash #'(lambda (constituents icp)
                              (declare (ignore constituents))
                              (setq count (+ count
                                             (icp-freq icp))))
                          table))
             *NT-tags-to-patterns*)

    count))


(defun icp-by-percentage (percent)
  (let* ((total (icp-incident-count))
         (target (round (* total percent)))
         (accumulated 0)
         (icp-count 0))
    (loop
      until (>= accumulated target)
        for icp in *sorted-icp*
        do
          (incf icp-count)
          (setq accumulated
            (+ accumulated
               (icp-freq icp))))
    icp-count))




(defun write-icp (full-filename)
  (order-icp-by-frequency)
  (with-open-file (s full-filename
                   :direction :output
                   :if-exists :supersede
                   :if-does-not-exist :create)
    (let ((count 0))
      (dolist (icp *sorted-icp*)
        (format s "~%~a/~a  ~a"
                (incf count)
                (icp-freq icp)
                icp)))))


(defun clear-pattern-counts ()
  (maphash #'(lambda (non-terminal pattern-table)
               (declare (ignore non-terminal))
               (maphash #'(lambda (constituent-list icp)
                            (declare (ignore constituent-list))
                            (setf (icp-freq icp) 0))
                        pattern-table))
           *NT-tags-to-patterns*))


(defun get-icp (nt constituents)
  (let ((icp-table (gethash nt *NT-tags-to-patterns*)))
    (when icp-table
      (gethash constituents icp-table))))


(defmacro def-constituent-pattern (tag immediate-constituents)
  `(define-constituent-pattern ',tag ',immediate-constituents))


(defun define-constituent-pattern (tag immediate-constituents)
  (let ((icp (make-immediate-constituent-pattern
              :tag tag
              :constituents immediate-constituents
              :freq 1))) ;; gets stored in the *NT-tags-to-patterns*
    ;; table, which is an index by non-terminal
    (incf *constituent-patterns*)
    icp))



(defun sort-cp (tag)
  (unless (gethash tag *NT-tags-to-patterns*)
    (break "~a is not a know non-terminal with constituents" tag))
  (let ((icp-list '()))
    (maphash #'(lambda (key icp)
                 (declare (ignore key))
                 (push icp icp-list))
             (gethash tag *NT-tags-to-patterns*))
    (sort icp-list #'> :key #'icp-freq)))

;;/// wip through the list and fill the 'count' field of the icp
;; according to where the icp falls

(defun write-icp (tag full-filename)
  (let ((sorted (sort-cp tag)))
    (with-open-file (stream full-filename
                     :direction :output
                     :if-exists :overwrite
                     :if-does-not-exist :create)
      (dolist (icp sorted)
        (format stream "~&~a  ~a" (icp-freq icp) icp)))))



(defun toplevel-tags (constituents)
  (flet ((get-tag (sexp)
           (check-type (car sexp) symbol "a valid tag")
           (car sexp)))
    (let ((list '()))
      (dolist (c constituents)
        (push (get-tag c) list))
      (nreverse list))))

(defun ic-patterns-for (tag)
  (let ((table (gethash tag *NT-tags-to-patterns*)))
    (if (null table)
      (format t "~a has no entries in the immediate-constituent table." tag)
      (let ((patterns '()))
        (maphash #'(lambda (key value) (declare (ignore value))
                     (push key patterns))
                 table)
        patterns))))



(defvar *nonterminal-tag-count* 0)

(defparameter symbol-to-nonterminal-tag (make-hash-table))

(defun notice-nonterminal-tag (tag immediate-constituents)
  (unless (gethash tag symbol-to-nonterminal-tag)
    (setf (gethash tag symbol-to-nonterminal-tag) immediate-constituents)
    (incf *nonterminal-tag-count*)))

(defun non-terminal-tags ()
  (let ((list '()))
    (maphash #'(lambda (key value)
                 (declare (ignore value))
                 (push key list))
             symbol-to-nonterminal-tag)
    list))

(defun read-terminal-tags-from-file (full-filename)
  (with-open-file (stream full-filename
                    :direction :input
                    :if-does-not-exist :error)
    (declare (ignore stream))
    (let ((eof? nil))
      (declare (ignore eof?))
      (break "stub"))))

(defparameter *pos-tags*
  '(CLOSE-QUOTE COLON-TAG COMMA
    DT CD EX FW IN JJ JJR JJS LS
    MD NN NNP NNPS NNS POS
    OPEN-QUOTE-TAG PDT PERIOD
    PRP PRP$ RB RBR RBS RP
    SHARPSIGN-TAG SYM TO UH
    VB VBD VBG VBN VBP VBZ
    WDT WP WP$ WRB))


(defvar *pos-tag-count* 0)

(defparameter symbol-to-pos-tags (make-hash-table))

(defun notice-pos-tag (tag-symbol word-symbol)
  "Collects all instances of a given POS tag on a table indexed
   by the tag symbol. Doesn't do any lumping of tags, 'words' are
   still just lowercase symbols."
  (let ((entry (gethash tag-symbol symbol-to-pos-tags)))
    (cond
      (entry (unless (memq word-symbol entry)
               (rplacd entry (cons word-symbol (cdr entry)))))
      (t
       (setf (gethash tag-symbol symbol-to-pos-tags) `(,word-symbol))
       (incf *pos-tag-count*)))))


(defun pos-tags ()
  (let ((list '()))
    (maphash #'(lambda (key value)
                 (declare (ignore value))
                 (push key list))
             symbol-to-pos-tags)
    list))


(defvar *tag-count* 0)

(defparameter symbols-to-tags (make-hash-table ))

(defun notice-tag (symbol)
  (unless (gethash symbol symbols-to-tags)
    (setf (gethash symbol symbols-to-tags) symbol)
    (incf *tag-count*)))


(defvar *word-count* 0) ;; unique pnames

(defvar *word-token-count* 0)

(defparameter symbols-to-words (make-hash-table))

(defun notice-word (symbol tag)
  ;;(format t "~&word = ~a" symbol)
  (incf *word-token-count*)
  (let ((entry (gethash symbol symbols-to-words)))
    (if entry
      (let ((tag-entry (assoc tag entry :test #'eq)))
        (if tag-entry
          (rplacd tag-entry (1+ (cdr tag-entry)))
          (setf (gethash symbol symbols-to-words)
            (cons `(,tag . 1) entry))))
      (else
       (setf (gethash symbol symbols-to-words)
             `( (,tag . 1) ))
       (incf *word-count*)))))

(defun pos-info (w)
  (gethash w symbols-to-words))

(defun word-table-to-list (&optional (table symbols-to-words))
  (let ( list )
    (maphash #'(lambda (k v)
                 (declare (ignore v))
                 (push k list))
             table)
    list))

(defun sort-word-pos-by-frequency (alist)
  ;; highest to lowest
  (sort alist #'> :key #'cdr))

(defun sort-words-by-pos-frequency ()
  (maphash
   #'(lambda (key value)
       (let ((sorted (sort-word-pos-by-frequency value)))
         (setf (gethash key symbols-to-words) sorted)))
   symbols-to-words))

(defun word-total-token-count (w)
  (let ((total 0))
    (dolist (pair (pos-info w))
      (setq total (+ (cdr pair) total)))
    total))

(defun sort-words-by-token-count (&optional (table symbols-to-words))
  (let* ((words (word-table-to-list table))
         (entries (mapcar #'(lambda (w)
                              (cons (define-word/expr (symbol-name w))
                                    (word-total-token-count w)))
                          words)))
    ;; use routine from the standard frequency code
    (sort-frequency-list entries)))


(defvar *proper-nouns* '())

(defvar *everything-else* '())

(defun proper-vs-common (&optional (word-table symbols-to-words))
  (let ((other '()) (always-proper '()))
    (maphash
     #'(lambda (word pos-pairs)
         (let ((other? nil))
           (dolist (pair pos-pairs)
             ;;(when (not (proper-noun? pos-pairs) - better factoring?
             (when (not (or (eq (car pair) 'NNP)
                            (eq (car pair) 'NNPS)))
               (setq other? (car pair))))
           (if other?
               (push word other)
             (push word always-proper))))
     word-table)
    (setq *proper-nouns* always-proper
          *everything-else* other)
    (values (length always-proper)
            (length other))))


(defun study-word-pos ()
  (let ((singles '())(doubles '())(more '()))
    (maphash
     #'(lambda (key value)
         (cond
          ((= (length value) 1)
           (push key singles))
          ((= (length value) 2)
           (push key doubles))
          (t
           (push key more))))
     symbols-to-words)
    (format t "~a singles, ~a doubles, ~a rest"
            (length singles) (length doubles) (length more))))


(defvar *word-list* '())

(defun words-to-list ()
  (maphash #'(lambda (key value)
               (declare (ignore value))
               (push key *word-list*))
           symbols-to-words))

(defun write-words (list-of-words full-filename)
  (with-open-file (s full-filename
                          :direction :output
                  :if-exists :supersede
                  :if-does-not-exist :create)
    (let ((count 0))
      (dolist (word list-of-words)
        (format s "~&(defword ~a/~a  \"~a\"  ~a)"
                (incf count)
                ( ) ;;//// frequency of word
                (string-downcase (symbol-name word))
                (pos-info word))))))

(defun write-words-by-pos (full-filename)
  (with-open-file (s full-filename
                          :direction :output
                  :if-exists :supersede
                  :if-does-not-exist :create)
    (declare (ignore s))
    (dolist (tag-symbol *pos-tags*)
      (let ((entry (gethash tag-symbol symbol-to-pos-tags)))
        (when entry
          ;;(write-pos-entry tag-symbol entry s)
          )))))
#|  /// This is where everything left off
(defun write-pos-entry (tag-symbol list-of-words s)
  (let ((tag-name (string-downcase (symbol-name tag-symbol)))
        (words (


(defun write-word-data (word-symbol pos s)

        (write-word-data word s)))))  |#

;;;------------------------------------------
;;; Read out treebank s-exp as regular texts
;;;------------------------------------------

(defun tb-to-text-file-reader (full-tb-filename &optional (verbose nil))
  (with-open-file (stream full-tb-filename
                   :direction :input
                   :if-does-not-exist :error)
    (with-readtable-bound *my-readtable*
      (let ((eof? nil)
            (sexp nil))
        (loop while (not eof?) do
              (setq sexp (read stream nil :eof))
              (when verbose
                (format t "~s~%" sexp))
              (when (eq sexp :eof) (return))
              (readout-tb-terminals sexp *standard-output* verbose))))))

(defparameter *word-seg-errors* nil)
(defparameter *sparser-errors* nil)
(defparameter *tb-nps-total* 0)
(defparameter *tb-nps-correct* 0)
(defparameter *sexps-total* 0)
(defparameter *sexps-correct* 0)


(defun tb-segmentation-tester (full-tb-filename &optional (verbose nil))
  (with-open-file (stream full-tb-filename
                   :direction :input
                   :if-does-not-exist :error)
    (setf *word-seg-errors* nil
          *sparser-errors* nil
          *tb-nps-total* 0
          *tb-nps-correct* 0
          *sexps-total* 0
          *sexps-correct* 0)
    (with-readtable-bound *my-readtable*
      (let ((eof? nil)
            (sexp nil)
            (*break-on-new-bracket-situations* nil))
        (loop while (not eof?) do
              (setq sexp (read stream nil :eof))
              (when verbose
                (format t "~s~%" sexp))
              (when (eq sexp :eof) (return))
              (test-np-segmentation-for-sexp sexp))))
    (format t "~%-----------------~%| TB NP Results |~%-----------------~%")
    (format t "S-Exps attempted: ~A~%S-Exps tested: ~A~%S-Exps fully correct: ~A~%NPs tested: ~A~%NPs correct: ~A~%Word segmentation errors: ~A~%  ~S~%~%Sparser errors: ~A~%  ~S~%~%"
            *sexps-total* (- *sexps-total* (length *word-seg-errors*) (length *sparser-errors*))
            *sexps-correct* *tb-nps-total* *tb-nps-correct* (length *word-seg-errors*)
            *word-seg-errors* (length *sparser-errors*) *sparser-errors*)
    ))

(defun get-bracketing-from-string (str)
  (format t "Sparser scan: ~s~%" str)
  (handler-case
      (progn
        (with-readtable-bound *current-readtable*
          (analyze-text-from-string str))
        (readout-bracketing))
    (error (e)
      (list :error
            (type-of e)
            (handler-case
                (cond ((typep e 'type-error)
                       (format nil "Type error: ~A expected to be ~A."
                              (type-error-datum e) (type-error-expected-type e)))
                      (t
                       (apply #'format nil
                              (simple-condition-format-control e)
                              (simple-condition-format-arguments e))))
              (error (e2)
                e2))
            str))))


;; (treebank-smoke-test "/Users/ddm/sift/nlp/Grok/corpus/treebank-sentence-strings.txt")
(defun treebank-smoke-test (full-tb-filename)
  (with-open-file (stream full-tb-filename
                     :direction :input
                     :if-does-not-exist :error)
    (flet ((smoke-test (string)
             (handler-case
                 (with-readtable-bound *current-readtable*
                   (analyze-text-from-string string))
                (error (e)
                  
                  (list :error
                        (type-of e)
                        (handler-case
                            (cond ((typep e 'type-error)
                                   (format nil "Type error: ~A expected to be ~A."
                                           (type-error-datum e) (type-error-expected-type e)))
                                  (t
                                   (apply #'format nil
                                          (simple-condition-format-control e)
                                          (simple-condition-format-arguments e))))
                          (error (e2)
                                 e2))
                        string)))))
      (with-readtable-bound *my-readtable*
        (let ((eof? nil)
              (sexp nil)
              (*break-on-new-bracket-situations* nil)
              (*display-word-stream* nil) ;; could make these sensitive to verbose
              (*readout-segments-inline-with-text* nil)
              (*record-bracketing-progress* nil))
          (loop while (not eof?) do
            (setq sexp (read stream nil :eof))
            ;(when verbose
            ;  (format t "~s~%" sexp))
            (when (eq sexp :eof) (return))
            (smoke-test sexp)))))))



(defun get-segments (l &aux ans)
  ;; Return a list of (<start-index> <end-index> <contents>) entries.
  (let ((word-index 0))
    (dolist (elt l ans)
      (cond ((consp elt)
             (push (list word-index (+ word-index (length elt)) elt) ans)
             (incf word-index (length elt)))
            (t
             (incf word-index 1))))))


(defun test-np-segmentation-for-sexp (sexp)
  (let* ((tb-str (readout-tb-terminals sexp nil nil))
         (tb-segmented (readout-tb-np-segmentation sexp nil nil))
         (tb-segs (get-segments tb-segmented))
         (tb-flat (flatten tb-segmented))
         (sparser-segmented (get-bracketing-from-string tb-str))
         (sparser-segs (get-segments sparser-segmented))
         (sparser-flat (flatten sparser-segmented))
         (missing-segs (set-difference tb-segs sparser-segs :test 'equal))
         (n-nps-correct (- (length tb-segs) (length missing-segs))))
    (incf *sexps-total*)
    (format t "~%Sentence: ~S~%TB-seg: ~S~%SP-Seg: ~S~%" tb-str tb-segmented sparser-segmented)
    (cond ((equal (car sparser-segmented) :error)
           (format t "Not comparing: Sparser error.~%")
           (push sparser-segmented *sparser-errors*))
          ((not (equal tb-flat sparser-flat))
           (format t "Not comparing: word segmentation error.~%")
           (push (list tb-flat sparser-flat) *word-seg-errors*))
          (t
           (incf *tb-nps-total* (length tb-segs))
           (incf *tb-nps-correct* n-nps-correct)
           (cond
            (missing-segs
             (format t "Missing segments (~A):~%  ~S~%"
                     (length missing-segs) missing-segs))
            (t
             (format t "No missing segments.~%")
             (incf *sexps-correct*)))))
    (format t "~%")))

(defparameter *tb-no-space-before*
  '(close-quote single-quote comma period ? ! -rrb- -rcb- -rsb-
    colon semicolon))
(defparameter *tb-no-space-after*
  '(open-quote -LRB- -LCB- -LSB-))

(defun stringify-token (token)
  (case token
    (-LRB- "(")
    (-rrb- ")")
    ;; [sfriedman:20130108.1302CST]
    ;; http://www.cis.upenn.edu/~treebank/tokenization.html
    ;; This website says that -lcb-/-rcb- should actually be [ and ], but
    ;; there are enough errors in the treebank that we need to change it here.
    (-lcb- "[")
    (-rcb- "]")
    (-lsb- "[")
    (-rsb- "]")
    (comma ",")
    (colon ":")
    (semicolon ";")
    (period ".")
    (open-quote "\"")
    (close-quote "\"")
    (single-quote "'")
    (i "I")
    (otherwise
     (if (symbolp token)
         (symbol-name token)
       (format nil "~s" token)))))

(defun stringify-tokens (tokens &optional (cap nil) (append t) &aux strings ans)
  (dolist (token tokens)
    (let ((str (stringify-token token)))
      (when (and (numberp token)
                 (equal (car strings) ",")
                 (< (length str) 3))
        (setf str (format nil "~a~a" (make-string (- 3 (length str)) :initial-element #\0) str)))
      (dolist (substr (sparserize-string str))
        ;; (format t "Str: ~A - Substr: ~A~%" str substr)
        (push substr strings))))
  (cond (append
         (setf ans (apply #'string-append (reverse strings)))
         (case cap
           (:downcase (string-downcase ans))
           (:capitalize (string-capitalize ans))
           (otherwise ans)))
        (t
         (mapcar #'(lambda (x)
                     (case cap
                       (:downcase (string-downcase x))
                       (:capitalize (string-capitalize x))
                       (otherwise x)))
                 (reverse strings)))))

(defun readout-tb-terminals (sexp &optional (out *standard-output*) (verbose nil))
  "Walk tb sentence sexp to its terminals and write them out."
  (let ((first? t)
       tokens  prior-token prior-tag)
    (flet ((push-word (token all-tokens tag)
             (when verbose
               (format t "~&~a ~a~%" all-tokens tag))
             (unless (or first?
                         (and (eql token 'N)
                              (eql tag 'RB))
                         (and (eql token 'NA)
                              (eql tag 'TO))
                         (and (eql token '%)
                              (eql prior-tag 'CD))
                         (and (eql token '%)
                              (eql prior-tag 'QP))
                         (and (eql tag 'CD)
                              (eql prior-tag '$))
                         (memq token *tb-no-space-before*)
                         (memq prior-token *tb-no-space-after*))
               (push " " tokens))
             (cond
               ((or first?
                    (eq tag 'NNP)
                    (eq tag 'NNPS)) ;; what else?
                (let ((capd (stringify-tokens all-tokens :capitalize)))
                  (when (and (eq tag 'NNPS)
                             (equal (elt capd (1- (length capd))) '#\S))
                    (setf capd (format nil "~As" (subseq capd 0 (1- (length capd))))))
                  (push capd tokens)))
               ((eq tag 'POS) (push "'s" tokens))
               ;;((eq tag 'CD)
               ;;(push-debug `(,token))
               ;;(break "the CD token is of type ~a" (type-of token))
               ;;(push (stringify-tokens all-tokens :downcase) tokens))
               (t (push (stringify-tokens all-tokens :downcase) tokens)))
             (setq prior-token token
                   prior-tag tag)
             (when first? (setq first? nil))))
      (labels
          ((walk (l)
             (when (consp l)
               (cond ((consp (cadr l))
                      (dolist (k (cdr l))
                        (walk k)))
                     ((or (symbolp (cadr l))
                          (numberp (cadr l)))
                      (push-word (cadr l) (cdr l) (car l)))
                     (t (push-debug l)
                        (break "new case"))))))
        (dolist (s sexp)
          (walk s))
        (let ((str (apply #'string-append (nreverse tokens))))
          (when out
            (format out "~s~%" str))
          str)))))

(defun sparserize-string (str)
  (let ((strs (split str '(#\Space #\' #\/ #\%) t)))
    (apply #'append (mapcar #'split-alphanumeric
                            (remove-if #'(lambda (s)
                                           (member s '(" " "") :test 'equal))
                                       strs)))))

(defun split-alphanumeric (str &aux (last-string-start 0) strings)
  (do ((i 0 (1+ i)))
      ((= i (1- (length str))))
    (unless (eql (alpha-char-p (elt str i))
                 (alpha-char-p (elt str (1+ i))))
      (push (subseq str last-string-start (1+ i)) strings)
      (setf last-string-start (1+ i))))
  (push (subseq str last-string-start (length str)) strings)
  (reverse strings))



(defun readout-tb-np-segmentation (sexp &optional (out *standard-output*) (verbose nil))
  "Walk tb sentence sexp to its terminals and write them out."
  (let (;; (first? t) prior-token prior-tag
        np-tokens in-np top-tokens)
    (flet ((push-word (token all-tokens tag)
             (when verbose
               (format t "~&~a ~a~%" all-tokens tag))
             (let ((str (cond
                         ;;((or first?
                         ;;     (eq tag 'NNP)
                         ;;     (eq tag 'NNPS)) ;; what else?
                         ;; (when first? (setq first? nil))
                         ;; (stringify-tokens all-tokens :downcase))
                         ((and (eql token 'N)
                               (eql tag 'RB))
                          ;; Tack it to the previous.
                          (list
                           (if in-np
                             (string-append (pop np-tokens) (stringify-tokens all-tokens :downcase))
                             (string-append (pop top-tokens) (stringify-tokens all-tokens :downcase)))))
                         ((eq tag 'POS)
                          (list "'s"))
                         (t
                          (stringify-tokens all-tokens :downcase nil)))))
               (dolist (substr1 str)
                 (dolist (substr2 (split substr1 '(#\' #\-) t))
                   (if in-np
                       (push substr2 np-tokens)
                     (push substr2 top-tokens)))))
             ;;(setq prior-token token
             ;;      prior-tag tag)
             )
           )
      (labels
          ((walk (l)
             (when (consp l)
               (let ((local-np nil))
                 (when (and (not in-np)
                            (eql (car l) 'NP)
                            (or (not (tree-member 'NP (cdr l)))
                                (every #'(lambda (child)
                                           (member (car child) '(NP NNP NNPS)))
                                       (cdr l))))
                   ;; this is a "leaf" NP that contains no other NP.
                   (setf np-tokens nil
                         in-np t
                         local-np t))
                 (cond ((consp (cadr l))
                        (dolist (k (cdr l))
                          (walk k)))
                       ((or (symbolp (cadr l))
                            (numberp (cadr l)))
                        (push-word (cadr l) (cdr l) (car l)))
                       (t (push-debug l)
                          (break "new case")))
                 (when local-np
                   ;; we just finished walking inside of a NP.
                   (push (remove "" (nreverse np-tokens) :test 'equal) top-tokens)
                   (setf in-np nil)
                   )))))
        (dolist (s sexp)
          (walk s))
        (let ((segmentation (remove "" (nreverse top-tokens) :test 'equal)))
          (when out
            (format out "~s~%" segmentation))
          segmentation)))))

(defun split (string &optional (ws '(#\Space)) (preserve nil))
  (flet ((is-ws (char) (member char ws)))
    (nreverse
     (let ((list nil) (start 0) (words 0) end)
       (loop
         (setf end (position-if #'is-ws string :start start))
         (push (subseq string start end) list)
         (incf words)
         (unless end (return list))
         (when preserve
           (push (subseq string end (1+ end)) list))
         (setf start (1+ end)))))))

(defun tree-member (elt tree)
  (let ((tree-elt (car tree)))
    (or (equal elt tree-elt)
        (when (consp tree-elt)
          (tree-member elt tree-elt))
        (when (cdr tree)
          (tree-member elt (cdr tree))))))

(defun tb-to-text-file-reader/char-level (full-tb-filename)
  (with-open-file (stream full-tb-filename
                  :direction :input
                  :if-does-not-exist :error)
    (let (c
          ;; (paren-counter 0)
          ;; sexp  tokens  accumuator
          )
      (loop
           (setq c (read-char stream nil :eof))
         (when (eq c :eof) (return))
         (cond
)))))





