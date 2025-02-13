;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 2013 David D. McDonald  -- all rights reserved
;;;
;;;     File:  "initialization"
;;;   Module:  "objects/doc/"
;;;  version:  October 2013

;; Initiated 10/3/13 to consolitate calls to initialize document
;; elements into a single place.

;; OBSOLETE -- goes with Grok-era document model

(in-package :sparser)


(defun initialize-document-element-resources ()
  (declare (special *recognize-sections-within-articles*
                    *note-text-relations*))
  (when *recognize-sections-within-articles*
    (initialize-article-resource)
    (initialize-section-resource)
    (initialize-paragraph-resource)
    (initialize-sentence-resource))
  (when *note-text-relations*
    (initialize-text-relationships)))
