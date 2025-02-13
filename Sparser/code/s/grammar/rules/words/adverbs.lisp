;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1993-1995,2011-2017 David D. McDonald  -- all rights reserved
;;; extensions copyright (c) 2008-2010 BBNT Solutions LLC. All Rights Reserved
;;; 
;;;     File:  "adverbs"
;;;   Module:  "grammar;rules:words:"
;;;  Version:  March 2017

;; initiated 5/16/93 v2.3. Populated 1/11/94. Added to 1/12,1/13
;; 0.1 (5/26) redid the bracket label as 'adverb'
;; 0.2 (1/30/95) redid the adverb-adverbs as 'phrase' rather than 'adverb'
;;      to block triggering vg-mining of the segments they start
;; 0.3 (4/12) redone as 'define-adverb', etc.
;; 0.4 (10/13) redefined Define-adverb and moved it to [syntax;adverbs]
;;     (4/24/08) added more words. Moved in the category and def form
;;      from rules/syntax/adverbs to make this file more in the style
;;      of words/quantifies1, largely to keep "despite" from being spanned
;;      as a head noun because the 'adverb' aspect isn't introducing
;;      an edge. 
;;     (2/3/10) removed "few" since it should really be taken as a quantifier
;;     (2/10) Gave "too" and "very" ].adverb brackets: "a very small ..."
;; 1.0 (9/16/11) Very thorough make over now that methods are available.
;;     (3/2/12) Accommodate to adverbs coming in from Comlex. 
;; 1.1 (12/4/12) added .[adverb to the default to match what was done in
;;      morphology1 (now rules/brackets/assignments). 
;; 1.2 (12/15/12) Reworked it extensively so the category for the adverb
;;      is used in the cfr rather than 'adverbial' and we make an instance 
;;      of the category to serve as the referent, along with a shadow
;;      instance to use in the methods. (1/9/13) Moving out all
;;      the words per se to dossiers;modified so they can go through more
;;      specific definitions rather than the old two-step dance that had
;;      so much inconsistency.
;; 2.0 (5/22/13) Made-over as a call to define-function-term and made being
;;      sentential adverbs the marked case. 6/9/14 added the other arguments
;;      to define-function-term. 4/20/15 removing "not", which is to specific
;;      in action to treat as an adverb.

(in-package :sparser)

;; For list of adverbs of diverse sorts see dossiers/modifiers.lisp
;; For the method used by adverbs see rules/syntax/adverbs.lisp

(defun define-adverb (string &key super-category documentation
                                  rule-label discriminator)
  "The string can be a single word or a polyword. The super-category
   defaults to adverb. If you supply a value for the super-category
   it should be the symbol that names the category, not the actual 
   category. The same applies to rule-label, though discriminator 
   is an arbitrary distinguishing symbol that gets concatenated in
   forming the name of the category this creates.
     Note that this is a function, not a macro, so all areguments 
   are evaluated -- symbols need to be quoted."
  
  (define-function-term string 'adverb
    :super-category (or super-category
                        (super-category-for-POS :adverb))
    :rule-label rule-label
    :discriminator discriminator
    :tree-families '(pre-verb-adverb post-verb-adverb
                     pre-adj-adverb pre-adv-adverb sentence-adverb)
    :documentation documentation))
