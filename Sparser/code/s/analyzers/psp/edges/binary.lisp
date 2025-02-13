;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:(SPARSER LISP) -*-
;;; copyright (c) 1992-1994,2014-2017 David D. McDonald  -- all rights reserved
;;;
;;;      File:   "binary"
;;;    Module:   "analyzers;psp:edges:"
;;;   Version:   February 2017

;; initiated in August 1990
;; 0.1 (3/5/91  v1.8.1)  Changed the return value of Make-default-binary-edge
;;      to be Nil if the edge was aborted by the referent calculation.
;;     (3/8/93 v2.3) added a trace message
;; 0.2 (4/7) Added a check for a null ev on the left-edge, indicating that
;;      the chart wrapped and we're consuming edges still in use.
;; 0.3 (5/15) pulled the capacity for the reference calculation to abort the edge
;; 1.0 (9/6/94) put it back in
;; 1.1 (10/25/14) added edge-form-adjustment. Cleaned up chunk form 2/6/15

;; 5/25/2015 added call to place-referent-in-lattice around computation of edge-referent field
;;  initial work to produce a lattice of descriptions
;;  the places where this call is put were determined by the methods where (complete edge) was also called


(in-package :sparser)


(defun make-completed-binary-edge (left-edge
                                   right-edge
                                   rule)
  ;; called from create-edge-for-rule-completion/rightwards &
  ;; /leftwards, which only do the specialized record keeping that
  ;; avoids the same edge being made twice, once from each direction

  (save-ns-rule? left-edge right-edge rule)
  (if (cfr-completion rule)
    (do-explicit-rule-completion left-edge right-edge rule)
    (make-default-binary-edge    left-edge right-edge rule)))



(defun make-default-binary-edge (left-edge right-edge rule)
  (declare (special *current-chunk* category::n-bar))
  (let ((edge (next-edge-from-resource))
        (category (cfr-category rule)))

    (when (deactivated? left-edge) ;; it's the earlier of the two edges
      (error "The edge-resource is completely full~
            ~%This parse cannot be completed. You must enlarge~
             ~%the size of the resource to parse this text.~%"))
    
    (setf (edge-category  edge) category)
    (setf (edge-starts-at edge) (edge-starts-at left-edge))
    (setf (edge-ends-at   edge) (edge-ends-at right-edge))

    (setf (edge-rule edge) rule)
    (setf (edge-left-daughter  edge) left-edge)
    (setf (edge-right-daughter edge) right-edge)
   
    (setf (edge-form edge)
          (cond
           ((and *current-chunk*
                 (eq (chunk-end-pos *current-chunk*)
                     (pos-edge-ends-at right-edge))
                 (eq (car (chunk-forms *current-chunk*)) 'ng))
            ;; adjust form based on chunk being created
            ;; if the right edge is at the head end of the *current-chunk*, 
            ;;then use the category of the *current-chunk*
            category::n-bar)

          ((edge-form-adjustment left-edge right-edge
                                    (cfr-form rule)))
          (t (cfr-form rule))))

    (let ((referent (catch :abort-edge
                      (referent-from-rule left-edge
                                          right-edge
                                          edge
                                          rule))))
      (if (eq referent :abort-edge)
        (then
         (break "Rule aborted")
          ;; This function feeds its value to a check routine like
          ;; Check-one-one, which in turn returns the edge as its
          ;; value. If we return nil from here, then that nil will
          ;; be passed through as the value of the call to the
          ;; check routine, which should suffice for the parsing
          ;; routines not to see an edge here even though the
          ;; rule went through
          nil )

        (else
          (set-edge-referent edge
                (place-referent-in-lattice referent edge))
          
          (set-used-by left-edge  edge)
          (set-used-by right-edge edge)

          (knit-edge-into-positions edge
                                    (edge-starts-at left-edge)
                                    (edge-ends-at right-edge))

          (complete edge)
          (assess-edge-label category edge)

          (tr :completed-default-binary-edge
              edge left-edge right-edge rule)

          edge )))))


;;--- recording no-space (NS) rules

(defparameter *NS-rules* nil)

(defun save-ns-rule? (left-edge right-edge rule)
  (when *NS-rules*
    (let ((mid-pos (pos-edge-ends-at left-edge)))
      (when (and (not (pos-preceding-whitespace mid-pos))
                 (eq right-edge (lexical-edge-at mid-pos))
                 (eq left-edge (lexical-edge-at (pos-edge-starts-at left-edge)))
                 (not (is-basic-collection? (edge-referent right-edge))))
        (when (not (consp *ns-rules*))
          (setq *ns-rules* nil))
        (if (assoc rule *NS-rules*)
            (pushnew (list (retrieve-surface-string left-edge)
                           (retrieve-surface-string right-edge))
                     (cdr (assoc rule *NS-rules*))
                     :test #'equalp)
            (push (list rule (list (retrieve-surface-string left-edge)
                                   (retrieve-surface-string right-edge)))
                  *ns-rules*))))))
