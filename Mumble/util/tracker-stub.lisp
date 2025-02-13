;;; -*- Syntax: Common-lisp; Mode: LISP -*-

;;;  MUMBLE-86:  util/tracker-stub.lisp

;;; Copyright (C) 1985, 1986, 1987, 1988  David D. McDonald
;;;   and the Mumble Development Group.  All rights
;;;   reserved. Permission is granted to use and copy
;;;   this file of the Mumble-86 system for
;;;   non-commercial purposes.
;;; Copyright (c) 2006 BBNT Solutions LLC. All Rights Reserved
;;; Copyright (C) 2017 David D. McDonald. All Rights Reserved


(in-package :mumble)

;;this is a stub for the Tracker system, which was part of the original mumble.
;;since it is not currently being used and since some of its utility functions
;;caused interference, I cut it out of this version and replaced it with a
;;rather simple tracing facility.  


(defparameter *tracker* :off)

(defun landmark (title &rest args)
  (when (eq *tracker* :on) 
    (format t "~&~a: " title)
     (dolist (arg args)
       (format t "~a " arg))))


(defun turn-on-tracker ()
  (setq *tracker* :on))

(defun turn-off-tracker ()
  (setq *tracker* :off))


(defun begin-tracker-run ()
  nil)

(defun end-tracker-run ()
  nil)
