;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1999-2000,2012  David D. McDonald  -- all rights reserved
;;;
;;;     File:  "np rules"
;;;   Module:  "model;core:kinds:"
;;;  version:  April 2012

;; initiated on 12/26/99. Wrapped two forms into one 2/21/00 because
;; that's the way they're supposed to be done. 4/22/12 Added the other
;; terms in the tree-family mapping to avoid gratuitous construction
;; of a form rule.

(in-package :sparser)

#+ignore
(define-realization  kind
  (:tree-family np-common-noun/definite  ;; "the rabbit"
    :mapping ((np . :self)
              (np-head . :self)))

  (:tree-family np-common-noun/indefinite  ;; "a rabbit"
   :mapping ((np . :self)
             (n-bar . :self)
             (np-head . :self))))

