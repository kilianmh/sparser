;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:(SPARSER COMMON-LISP) -*-
;;; Copyright (c) 2013,2019 David D. McDonald all rights reserved
;;;
;;;      File: "text-relations"
;;;    Module: "analyzers;SDM&P:
;;;   Version: September 2019

;; Initiated 3/9/13. Distributed to other files for easier development
;; 3/12/13. 10/2/13 Added note-entity, 

(in-package :sparser)

;;;-----------------------------------
;;; interning the text-relation types
;;;-----------------------------------

(defvar *tr-names-to-objects* (make-hash-table)
  "Interning table for text-relation types")

(defvar *all-text-relationships* nil
  "A simple list of the text-relation objects that have been
   defined. Useful for re-initializing.")

(defun canonical-tr-name (symbol)
  "The package was created in objects/doc/loader.lisp"
  (intern (symbol-name symbol)
          (find-package :text-relationships)))

(defun index-text-relation-type (tr-name tr)
  (pushnew tr *all-text-relationships*)
  (setf (gethash tr-name *tr-names-to-objects*) tr))

(defun text-relation-named (symbol)
  (let ((tr-name (canonical-tr-name symbol)))
    (gethash tr-name *tr-names-to-objects*)))

;;--- clear
(defun initialize-text-relationships ()
  ;; zero the indexes -- ought to reclaim the instances instead
  ;; of just forgetting wher we stored them
  (dolist (tr *all-text-relationships*)
    (let ((table (when (slot-boundp tr 'table)
                   (tr-table tr))))
      (when table ;; abstract ones don't have instances
        (clrhash table)))))


(defun tr-class-name (tr)
  "What name do we use for the class for instances"
  (intern (string-append (if (symbolp tr)
                           tr ;; for superc's which come in as symbols
                           (name tr)) ;; a tr 
                         "-" '#:tr-instance)
          (find-package :sparser)))


;;;--------
;;; driver
;;;--------

#|  note is called by
/Users/ddm/sparser/Sparser/code/s/analyzers/sdmp/note-text-relations.lisp
  note-in-segment-adgacences
  note-what-the-head-is
  note-immediate-relations-to-head |#

#+ignore ;; Use note instead
(defun note-entity (item)
  (add-to-container item (sentence)))


(defun note-relation (relation-name &rest args)
  ;; Called from  individual relations (analyzer/sdmp/note-text-relations.lisp)
  ;; such as note-in-segment-adgacences
  (let ((tr (text-relation-named relation-name)))
    (unless tr (error "No text-relation named ~a" relation-name))
    (let ((i (or (find-text-relation-instance tr args)
                 (make-text-relation-instance tr args))))
      (push-debug `(,i))
      (incf (incident-count i))
      (set-text-relation-instance-print-args tr i)
      ;; 'do' its superc's
      ;; count > threshold, reify it.
      ;; stash it on the section
      (add-text-relation-to-article tr i)
      i)))
;;//// we need the relationship from the word/s
;; to the relations they're in


(defun set-text-relation-instance-print-args (tr i)
  (case (name tr)
    (text-relationships::head
     (let ((pname (pname (head-word i))))
       (setf (tri-print-args-value i)
             (format nil "\"~a\"" pname))))
    (text-relationships::classifier-head
     (let ((class-pname (pname (classifier-of-head i)))
           (head-pname (pname (classified-head i))))
       (setf (tri-print-args-value i)
             (format nil "\"~a\" : \"~a\""
                     class-pname head-pname))))
    (text-relationships::modifier-head
     (let ((modifier-pname (pname (modifier-of-head i)))
           (head-pname (pname (modified-head i))))
       (setf (tri-print-args-value i)
             (format nil "\"~a\" : \"~a\""
                     modifier-pname head-pname))))
    (text-relationships::adjacent
     (let ((left-pname (pname (left-side i)))
           (right-pname (pname (right-side i))))
        (setf (tri-print-args-value i)
             (format nil "\"~a\" : \"~a\""
                     left-pname right-pname))))
    (otherwise
     (push-debug `(,tr ,i))
     (error "No provision for printing ~a yet" tr))))



