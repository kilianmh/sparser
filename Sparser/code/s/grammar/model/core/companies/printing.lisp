;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1994-1996,2013,2021  David D. McDonald  -- all rights reserved
;;;
;;;     File:  "printing"
;;;   Module:  "model;core:companies:"
;;;  version:  September 2021

;; broken out 11/23/94 v2.3.  Pulled in routines for co-names 4/12/95
;; 4/19 tweeked them, added string/company.  5/22 made adjustments for changes
;; in where the sequence may be depending on the type (actually the source) of
;; the name. 1/13/96 fixed stupid omission in string routine.
;; 2/13/13 Added guard in string/company for possibility that string-for
;;  returned the empty string.

(in-package :sparser)

;;;---------------------
;;; printing companies
;;;---------------------

(defun string/company (c)
  (let ((name (value-of 'name c)))
    (if name
      (let* ((sequence (sequence-from-company-name name))
             (item-list (value-of 'items sequence))
             (length (length item-list))
             (full-string "")
             name-item  string )

        (dotimes (i length)
          (setq name-item (elt item-list i))

          (setq string (string-for name-item))
          (unless (string-equal string "") ;; generic-co-word 
            (unless (capital-letter (elt string 0))
              (setq string (string-capitalize string))))

          (setq full-string
                (concatenate 'string  full-string " " string)))
        (subseq full-string 1))
      "")))


(define-special-printing-routine-for-category  company
  :full ((let ((name (value-of 'name obj)))
           (if name
             (then
               (write-string "#<company " stream)
               (write-string (string/company obj) stream)
               (format stream " ~A>"
                       (indiv-uid obj)))
               
             (format stream "#<company  ~A>"
                     (indiv-uid obj)))))

  :short ((let ((name (value-of 'name obj)))
           (if name
             (then
               (write-string "#<" stream)
               (write-string (string/company obj) stream)
               (format stream " ~A>" (indiv-uid obj)))
               
             (format stream "#<company  ~A>"
                     (indiv-uid obj))))))



;;;------------------------
;;; printing company names
;;;------------------------

(defun princ-company-name (name stream)
  (let ((first-name (value-of 'first-word name)))
    (princ-name-word first-name stream)))

(defun princ-name-word (nw stream)
  (let ((word (value-of 'name nw)))
    (princ-word word stream)))


