;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1990=1991  Content Technologies Inc.
;;; copyright (c) 1992-1993,2011-2015,2020 David D. McDonald  -- all rights reserved
;;;
;;;      File:   "define"
;;;    Module:   "objects;rules:cfr:"
;;;   Version:   June 2020

;; ChangeLog:
;;  1.1 (12/17, v1.6)  moved in duplication-checking code from
;;       Def-cfr/expr.
;;  1.2 (1/8 v1.7)  Got a more informative return value in the replace
;;       dotted-rule case of Define-cfr.
;;  1.3 (7/16 v1.8.6)  Got it to consistently return a single object
;;       when there's a redefinition
;;  1.4 (7/30 v1.8.6)  Tweeked the polyword definition to fix a typo
;;       and improve the plist.  Moved the polyword stuff to [polyword]
;;  1.5 (8/12 v1.9)  Tightened the multiple-def. cases, which had been
;;       generating mulitple rules for redefinitions of the same unary
;;       rule over a single word.
;;  1.6 (2/10/92 v2.2) Added note-file-location and Note-grammar-module
;;       to Construct-cfr.
;;  1.7 (2/20 v2.2) Added a "source" parameter that is passed through
;;       to Note-grammar-module so the different kinds of rules can be
;;       distinguished.
;;  5.0 (9/4 v2.3) Reworked it for parsimony and simplified the treatment
;;       of polywords.
;;  5.1 (12/21) put in provision for allowing duplicates
;;  5.2 (3/9/93) changed update on known rule to use a subroutine
;;      (8/17) changed the subroutine's arguments and made it do the return
;;       value
;;  5.3 (8/27) renamed the calls that handle possible duplication and
;;       made the threading more obvious
;;  5.4 (11/22/11) adding a stipulated schema
;;  5.5 (1/17/15) Modifed call to changes-to-known-rule to make it easier
;;       to really make a new rule. 


(in-package :sparser)

;; Could this be merged with define-cfr/resolved?  The principal difference
;; is the identity of the source.

(defun define-cfr (lhs rhs &key form referent schema (source :define-cfr))
  "Takes only objects as its arguments. Any decoding should be done
   through forms that feed through Def-cfr/expr."
  (let ((cfr (if (null (cdr rhs)) ;; unary rule
               (lookup-unary-rule lhs rhs)
               (lookup-semantic-rule/rhs rhs))))
    (if cfr
      (if (redefinition-of-rule cfr lhs rhs form)
        (changes-to-known-rule cfr lhs rhs form referent source)
        (or (duplication-check cfr lhs rhs form referent source)
            (construct-cfr lhs rhs form referent source schema)))
      (construct-cfr lhs rhs form referent source schema))))
