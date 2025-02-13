;;; -*- Mode: Lisp; Syntax: Common-lisp; -*-
;;; Copyright (c) 2015-2016 David D. McDonald  All Rights Reserved
;;;
;;;      File:  "experiments"
;;;    Module:  grammar/model/sl/blocks-world/
;;;   version:  March 2016

;; Initiated 10/7/15. 

(in-package :mumble)

#| general-np-bundle-driver  derivation-tree  accessory-type
 make-adjunction-node  feature-driven-prepocessing  realize-dtn
 phrase-structure-execution  process-negate-accessory
 add-further-specification  define-word-stream-action-type
 instantiate-lexicalized-phrase
|#


;;;--------------------------
;;; Prebuilt phrases (trees)
;;;--------------------------

;; "build a staircase   (say (build-a-staircase))

(defun build-a-staircase ()
  "Constructs the derivation tree strictly from resources,
   not as the realization of some actually represented source."
  (let* ((staircase
          (make-dtn 
           :resource (get-lexicalized-phrase 'staircase)
           :referent 'build-staircase))
         (a-staircase ;; singular and kind set the determiner
          ;; see interface/bundles/operators-over-specifications.lisp
          (kind (singular staircase)))
         (build
          (make-dtn :resource (get-lexicalized-phrase 'build))))
    ;; connect them
    (make-complement-node 'o a-staircase build) ;; bind argument
    (make-complement-node 's (mumble-value 'first-person-plural 'pronoun) build)
    (command build) ;; hack that removes subject
    build))


;; "let's X"   (say (ex-let-us (build-a-staircase)))

(defun ex-let-us (dtn-for-eventuality)
  ;; Doing this one differently. The question is what is 
  ;; the best syntatic sugar. This version open-codes much
  ;; of what's in create-lexicalized-phrase as it wasn't clear
  ;; how to push the pronoun through that function as it's
  ;; presently written. 
  (let* ((let-phrase  ;; s v o c
         (get-lexicalized-phrase 'let))
         (1st-plural ;; the word
          (mumble-value 'first-person-plural ;; see gramar/pronouns.lisp
                        'pronoun)))
    (let* ((dtn (make-instance 'derivation-tree-node
                  :referent 'let-us
                  :resource let-phrase)))
      ;; (make-complement-node 'o pn-lexicalized-phrase dtn)
      (make-complement-node 'o 1st-plural dtn)
      (make-complement-node 'c dtn-for-eventuality dtn)
      (command dtn)
      dtn)))


;;--- the big red block (SHRDLU favorite)
;; (say (the-big-red-block))
(defun the-big-red-block ()
  (let ((block (noun "block"))
        (big (adjective "big"))
        (red (adjective "red")))
    (let ((dtn (make-dtn :resource block)))
      (make-adjunction-node red dtn)
      ;; it's a push list, so the adjectives, etc. 
      ;; need to be listed in reverse order
      (make-adjunction-node big dtn)
      dtn)))


;; "put a block on the table"  (say (put-block-on-table))

(defun put-something-somewhere (thing location)
  (let ((dtn (make-instance 'derivation-tree-node
               :referent 'put-thing-place
               ;; put: s, o1, o2
               :resource (verb "put" 'svo1o2))))
    (command dtn)
    (make-complement-node 'o1 thing dtn)
    (make-complement-node 'o2 location dtn)
    dtn))

(defun a-block ()
  (let ((dtn (make-instance 'derivation-tree-node
               :referent 'a-block
               :resource (noun "block"))))
    (initially-indefinite dtn)
    dtn))

(defun the-table ()
  (let ((dtn (make-instance 'derivation-tree-node
               :referent 'a-table
               :resource (noun "table"))))
    (always-definite dtn)
    dtn))
       
(defun on-something (something)
  (let ((dtn (make-dtn :resource (prep "on")
                       :referent 'on-something)))
    (make-complement-node 'prep-object something dtn)
    dtn))

(defun put-block-on-table ()
  (let ((thing (a-block))
        (location (on-something (the-table))))
    (put-something-somewhere thing location)))



        


