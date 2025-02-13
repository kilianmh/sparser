;;; -*- Syntax: Common-lisp; Mode: LISP; Package: MUMBLE -*-

;;; MUMBLE-86:  message-level>accessory-types

;;; Copyright (C) 1985, 1986, 1987, 1988 -- 2000  David D. McDonald
;;;   and the Mumble Development Group.  All rights
;;;   reserved. Permission is granted to use and copy
;;;   this file of the Mumble-86 system for
;;;   non-commercial purposes.
;;; Copyright (c) 2006 BBNT Solutions LLC. All Rights Reserved
;;; Copyright (c) 2016 David D. McDonald  -- all rights reserved

;;7/9/00 Added in-focus.

(in-package :mumble)


(define-accessory-type :unmarked
   ())

(define-accessory-type :question
   ())

(define-accessory-type :perfect
   ())

(define-accessory-type :progressive
   ())

(define-accessory-type :passive
   ())

(define-accessory-type :command
   ())

(define-accessory-type :negate
   ())

(define-accessory-type :number
   (singular plural))

(define-accessory-type :person
   (first second third))

(define-accessory-type :gender
   (masculine feminine neuter))

(define-accessory-type :determiner-policy
   (indefinite-first-mention_definite-subsequent-mentions
    always-definite
    no-determiner
    anonymous-individual
    known-individual
    kind))

(define-accessory-type :proper-name
   ())

(define-accessory-type :reducible
   ())

(define-accessory-type :in-focus
  ())

(define-accessory-type :antecedent
  ())

;;; The possible values for this are a symbol which will be convErted
;;; to a label in process-conjunction-accessory
(define-accessory-type :conjunction   ((label)) )

;;; Possible values are past, present, and any modal verb.
(define-accessory-type :tense-modal
   (past present (modal)))

;;; Possible values are specifications
(define-accessory-type :wh
   ((specification)) )

(define-accessory-type :wh-adj
   ((specification)) )

(define-accessory-type :given
   ((specification)) )

(define-accessory-type :purpose-clause-object
   ((specification)) )




(define-accessory-type :aspect
   (gerund past-participle))
