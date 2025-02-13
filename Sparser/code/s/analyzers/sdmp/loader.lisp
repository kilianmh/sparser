;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:(SPARSER COMMON-LISP) -*-
;;; Copyright (c) 2013,2020-2021 David D. McDonald all rights reserved
;;; Copyright (c) 2007 BBNT Solutions LLC. All Rights Reserved

;;;      File: "loader"
;;;    Module: "analyzers;SDM&P:

;;;   Version: December 2021

;; Initiated 2/9/07. Bumped scan to 1 to completely revamp it 1/21/13. Added
;; [form-march] 1/23/13. Added [reify-individuals] 2/28/13 and also broke out
;; [gofers] and [heuristics] for flexibility in salvaging more of the original
;; code developed for JTC/TRS.  3/9/13 added [note-text-relations] and [text-relations]
;; Distributed text-relations to relation-class, text-relation-form, and
;; text-relation-indexing 3/12/13. [analyze..] 3/14. 4/1 moved analyze-text-relations
;; to rules. 4/22/13 added [document-handling] for the grok passes

(in-package :sparser)

(lload "do-SDM&P;gofers")
(lload "do-SDM&P;heuristics")
(lload "do-SDM&P;reify-individuals")
(lload "do-SDM&P;scan")
(lload "do-SDM&P;form-march")

(lload "do-SDM&P;note-classes")
(lload "do-SDM&P;edge-classes")
(lload "do-SDM&P;note-aux")
(lload "do-SDM&P;note")
(lload "do-SDM&P;note-cleaner")

;; package to distinguish text-relations
(or (boundp '*text-relationships-package*)
    (defconstant *text-relationships-package*
      (or (find-package :text-relationships)
          (make-package :text-relationships
                        ::nicknames '(:tr)
                        :use nil))))
(lload "do-SDM&P;text-relations")
(lload "do-SDM&P;text-relation-class")
(lload "do-SDM&P;text-relation-form")
(lload "do-SDM&P;text-relation-indexing")
(lload "do-SDM&P;note-text-relations")

(lload "do-SDM&P;document-handling")

(lload "do-SDM&P;traces")

