;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1993-2005,2011-2020 David D. McDonald  -- all rights reserved
;;;
;;;     File:  "rules"
;;;   Module:  "model;core:titles:"
;;;  version:  October 2020

;; initiated 6/15/93, starting over from scratch. 3/17/05 These are
;; interacting with rules made automatically from the etf schemas,
;; so selectively commenting them out while sorting out the issues.
;; 1/22/11 Addresing the intereaction with the schemas to keep these
;; rules because references have to happen before they're created
;; haphadardly by order of ETF definition. Added case of 'to-title'
;; 0.1 (2/21/11) Reworked as marker categories. 
;;     (7/17/13) added age rule. 10/6/13 Reorganized country case in 
;;     sorting out possessive. 

(in-package :sparser)

;;;--------------------------
;;; preposition combinations
;;;--------------------------
;; These combinations are occasionally also made by the realization
;; rules on, e.g., job-events

(define-marker-category as-title ;; needed by 'retire' additional rule 
  :realization (:tree-family transparent-pp
                :mapping ((pp . as-title)
                          (preposition . "as")
                          (complement . title))))

(define-marker-category in-title
  :realization (:tree-family transparent-pp
                :mapping ((pp . in-title)
                          (preposition . "in")
                          (complement . title))))
#+ignore
(define-marker-category to-title
  :realization (:tree-family transparent-pp
                :mapping ((pp . to-title)
                          (preposition . "to")
                          (complement . title))))


;;;-----
;;; age
;;;-----

;;--- unclear where this would go in a category's rspec
;;    But that category in in the object2 file
(def-cfr title (age title)
  :form np
  :referent (:instantiate-individual age+title
             :with (age left-edge
                    title right-edge)))


;;;-------------------
;;; (usually) country
;;;-------------------

(def-form-rule (possessive title)
  :form np
  :head :right-edge
  ;;/// N.b. doesn't work in *iraqi-girl* because of timing
  ;; where the title has been swallowed before the country
  ;; could see it.  A heuristic might be entitled to lift
  ;; up the left edge on the grounds that it must compose
  ;; so it's only a question of which edge it composes
  ;; with -- a peek would get this rule and look for a
  ;; title.
  :referent (:head right-edge
             :function sort-out-passessive+title left-edge right-edge))

(defun sort-out-passessive+title (possessive title)
  (push-debug `(,possessive ,title)) ;;(break "check args")
  (flet ((title->person ()
           (let* ((title-edge (right-edge-for-referent))
                  (person (convert-title-to-person title title-edge)))
             (revise-parent-edge :category category::person)
             person)))
    (cond
     ((itypep possessive 'pronoun) ;; "his driver"
      ;; the pronoun wasn't dererenced for some reason
      (setq title (title->person))) ;; return value for the edge

     ((itypep possessive 'person)
      ;; pronoun was derefenced
      (let ((role-person (title->person)))
        ;; the relation between the person from the pronoun
        ;; and this role-person is just based on the title
        ;; -- anonymously unless it passes through a method
        ;; somewhere -- Can we formulate a generic form?
        (define-or-find-individual 'plays-role-for
          :role title :for possessive)
        (setf title role-person)))

     ((itypep possessive 'country) ;; "Iran's prime minister"
      (unless (itypep title 'modified-title)
        (let ((title-mod (convert-to-modified-title title 'locale)))
          (setq title title-mod)
          (revise-right-edge-into-rule :referent title-mod)))
      (setq title (bind-dli-variable 'locale possessive title)))

     ((itypep possessive 'interlocutor) ;; "our professors"
      ;; What's worth doing? -- dropping the possessive.
      ;; /// See if it's relatively easy to get it deferenced
      title)

     ((itypep possessive 'title-modifier) ;; 'the [group's leaders]'
      ;; the title-modifier function of "group" is found by taking up
      ;; its usual function and extending the grammar of titles
      ;; For now drop in on the floor
      title)

     ((itypep possessive 'name-word)
      ;; "the Taliban's former deputy minister of communication"
      ;; Treat it the same way as a country
      title)

     (t (when *break-on-unexpected-cases*
          (push-debug `(,possessive ,title))
          (error "New type for possessive: ~a~%  ~a"
                 (if (individual-p possessive)
                   (itype-of possessive) 
                   (type-of possessive))
                 possessive))))
    title))

(define-category plays-role-for
  :specializes title
  :instantiates self
  ;; This should be the top of a set of generated categories
  ;; based on the the title. For now we just stash it and
  ;; index on it.  "college" needs two of these?
  :binds ((role . title)
          (for . person))
  :index (:key role person))
          


;;;-----------------------
;;; then, now, (former ?)
;;;-----------------------

(def-cfr title (calculated-time title)
  :form np
  :referent (:head right-edge
             :function massage-deictic-time-in-title left-edge right-edge))

(defun massage-deictic-time-in-title (time title)
  "Provides a place to dereference the time or to provide a 
   more noticable data structure to do it on a second pass."
  ;;(push-debug `(,time ,title))
  (if (itypep title 'qualified-title)
    (then
      (setq title (bind-dli-variable 'time time title))
      title)
    (let ((new-title ;; make it one
           (define-or-find-individual 'qualified-title
             :title title  :qualifier time)))
      new-title)))


;;;----------------------------------
;;; titles as standing in for people
;;;----------------------------------

(define-segment-finished-action title :convert-to-person?
  consider-converting-title-to-person)

(defun consider-converting-title-to-person (edge)
  ;; Called from check-segment-finished-hook, so we're still
  ;; within an active segment and can use those gofers.
  ;; If it's plural or incorporates a possessive, then we can assume
  ;; that it denotes a person/s who has that role. ///This ignores
  ;; the possibility of generic references to the class, but we can
  ;; take that up later.
  (let ((referent (edge-referent edge)))
    (when (title-is-plural?)
      (convert-title-to-person referent edge))))


(defun title-is-plural? ()
  ;; other things to consider adopting are in make-cn-rules/aux
  (let ((word (head-word-of-segment)))
    (etypecase word
      (word (eq (word-morphology word) :ends-in-s))
      (polyword nil))))


(defun convert-title-to-person (title title-edge)
  ;; called from consider-converting-title-to-person
  ;; and sort-out-possessive+title
  ;;(push-debug `(,title ,title-edge))
  (let ((person (define-or-find-individual 'title-based-person
                  :role title)))
    (make-completed-unary-edge
     (edge-starts-at title-edge) ;; starting vector
     (edge-ends-at title-edge)  ;; ending vector
     :convert-title-to-person  ;; rule
     title-edge  ;; daughter
     category::person ;; category
     category::np  ;; form
     person)  ;; referent

    ;; return value for routines that use the person
    person))
