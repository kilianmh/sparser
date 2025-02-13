;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 2014-2021 David D. McDonald  -- all rights reserved
;;;
;;;     File:  "loader"
;;;   Module:  "model;core:mid-level:"
;;;  version:  October 2021

;; Initiated 12/3/15

(in-package :sparser)


(gload "mid-level;subcat-patterns")

(gload "mid-level;attributes") ;; used in object

(gload "mid-level;ontology") ;; includes object as used in blocks world
(gload "mid-level;events")

#+mumble(gload "mid-level;interlocutor")

(gload "mid-level;discourse")

(gload "mid-level;relations")

;; moved to dossiers/verbs.lisp
#+ignore(gload "mid-level;verbs")

(gload "mid-level;things")
(gload "mid-level;organisms")
(gload "mid-level;groups")
(gload "mid-level;certain")

(gload "mid-level;cars")
(gload "mid-level;internet")
(gload "mid-level;document-parts")

(gload "mid-level;grammatical-objects")
