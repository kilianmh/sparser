;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1992-2000,2011-2016 David D. McDonald  -- all rights reserved
;;; extensions copyright (c) 2008 BBNT Solutions LLC. All Rights Reserved
;;;
;;;     File:  "loader"
;;;   Module:  "model;core:time:"
;;;  version:  September2016

;; mature recognition grammar 9/91 v1.9
;; 1.0 (12/7/92 v2.3) bumped everything to move it to the new semantics
;; Started complete rebuild 7/8/93 (trashing the recognition grammar)
;; 1.1 (9/19/93) started uncommenting the files as they were done
;; 1.2 (4/27/94) added [amounts] and  uncommented [age1]
;; 1.3 (5/24) moved the dossiers out to that loader
;;     (10/20) refurbished the files that had been commented out
;; 1.4 (9/27/99) Started reworking the design for psi so removed
;;      day-in-month and month-in-year and bumped dates to 2.
;; 1.5 (7/7/00) Bumped fiscal to 2 to rework them for psi. 7/8 bumped
;;      year. (8/27/08) Added time-of-day. (4/6/11) bumped phrases to 2.
;;     (6/12/13) added in seasons and citations. 
;; 1.6 (5/25/14 Added sequences. As psi are moot, and they are needed
;;      in orde1r to index real dates, turned day-in-month1 and month-
;;      in-year back on and dates2 off. 5/27/14 Put dates2 back for 
;;      the class. Commented out anaphors1. Added index.
;;     (5/31/14) Moving relative-moments late, exposing interval.
;;     (6/1/14) Pulling out methods to load after dossiers with their
;;      prepositoins. 

(in-package :sparser)

(gload "time;object")
(gload "time;interval")
(gload "time;units")
(gload "time;weekdays")
(gload "time;months")
(gload "time;years")
(gload "time;time-of-day")
(gload "time;day-in-month")
(gload "time;month-in-year")
(gload "time;dates")

(gload "time;seasons")
(gload "time;season-year")

(gload "time;relative moments")
(gload "time;amounts")
(gload "time;phrases")
(gload "time;anaphors")
(gload "time;anchor")
(gload "time;age")
(gload "time;fiscal")

;;(gload "time;adjuncts") no longer here -- look in kinds/temporally-localized.lisp

(gload "time;sequences")
(gload "time;index")

(gload "time;citations")

(defun late-time-files ()
  (gload "time;time-methods"))



