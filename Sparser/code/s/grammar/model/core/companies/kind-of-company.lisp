;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 1993-1996,2013-2016  David D. McDonald  -- all rights reserved
;;; extensions copyright (c) 2009 BBNT Solutions LLC. All Rights Reserved
;;;
;;;     File:  "kind of company"
;;;   Module:  "model;core:companies:"
;;;  version:  April 2016

;; initiated 5/23/93 v2.3, added some rules 6/14
;; 0.1 (1/20/94) redid them as subtypes rather than individuals by analogy
;;      with ordinals
;; 0.2 (3/15) changed the rdata to go to company at the NP level
;;     (7/22) extended the autodef with examples
;; 0.3 (5/22) providing for interaction with capitalized name-word equivalents
;;     (7/26) added variation for phrases
;; 0.4 (11/18) Changed kind-of-company NPs to have the 'company-descriptor' label
;;      rather than 'company' so as to allow it to be easily combined with a
;;      concrete category in a subsidiary/parent relationship w/o over-generating
;; 0.5 (3/29/96) changed the eft used by define-kind-of-company-phrase
;; 0.6 (9/21/09) Commented out the n-bar mapping in uses of np-common-noun/definite
;;      where that option has (debatably) been removed.
;;     (7/15/13) Weird, very old-fashioned def form. We're not taking advantage
;;      of it to create specializations of named-enties using these categories.
;;      For now just added bracket information

(in-package :sparser)

;;;-----------------
;;; parent category
;;;-----------------

;;---- single word

(define-category  kind-of-company
  :instantiates self
  :specializes named-type
  :index (:permanent :key name)
  :realization (:tree-family np-common-noun
                :mapping ((np . company-descriptor)
                          ;;(n-bar . :self)
                          (np-head . :self))
                :common-noun name ))


(define-autodef-data 'kind-of-company
  :display-string "a word for a type of organization"
  :form 'define-kind-of-company
  :dossier "dossiers;kinds of companies"
  :description "A single word that names a specific type of organization"
  :examples "\"bank\" \"institute\" \"commission\""
  :module *kinds-of-companies* )


;;---- classifier - head pair

(define-category  kind-of-company/phrase
  :instantiates self
  :specializes named-type
  :binds ((base)
          (modifier))
  :index (:permanent :sequential-keys base modifier))
;; The mapping in the realization will vary with the different
;; cases, all based on the tree family 'modifier-creates-subtype'.
;; It's all handled by the defining function that the autodef uses.


(define-autodef-data 'kind-of-company/phrase
  :display-string "a phrase for a type of organization"
  :description "A phrase that names a specific type of organization by adding modifiers to a head"
  :examples "\"law firm\" \"holding company\" \"bank holding company\""
  :dossier "dossiers;kinds of companies"
  :module *kinds-of-companies* 
  :form 'define-kind-of-company-phrase   ;; called by autodef
  :write-fn 'save-kind-of-company/phrase ;; called by rtd save routine
  )


(defun define-kind-of-company-phrase (multi-word-string)
  ;; Called from Autodefine-word.
  (declare (ignore multi-word-string))
  (break "stub -- function has flit")
  #+ignore
  (define-by-filling-out-an-etf
    :tree-family 'modifier-creates-individual
    :category 'kind-of-company/phrase
    :phrase-text multi-word-string
    )
  :self-contained )


(defun save-kind-of-company/phrase (stream-to-standard-dossier
                                    tree-family
                                    mapping)
  (declare (ignore stream-to-standard-dossier tree-family mapping)
           (special *rdt/result-category*))
  (let ((category-name (symbol-name (cat-symbol *rdt/result-category*))))
    (declare (ignore category-name))
    (break "stub -- function isn't around anymore")
    #+ignore
    (save-definition-of-a-category
     stream-to-standard-dossier
     category-name             ;; the one being defined
     'kind-of-company/phrase   ;; the name of supercategory
     '(:permanent :sequential-keys base modifier)  ;; indexing spec
     (etf-name tree-family)   ;; the name of the tree family
     )))



;;;------------------------------------------
;;; definition form for instances (subtypes)
;;;------------------------------------------

;; cf. define-kind-of-subsidiary
(defun define-kind-of-company (string &key abbrev)
  (let* ((word (define-word/expr string))
         (plural (plural-version word))
         (name (intern string *category-package*))
         (cat (or (category-named name)
                  (define-category/expr name
                    `(:specializes ,category::kind-of-company
                      :instantiates ,`(,category::company ,name))))))
    (declare (special category::collection
                      category::company
                      category::kind-of-company
                      category::np-head))

    (assign-brackets-as-a-common-noun word)
    (assign-brackets-as-a-common-noun plural)

    (let ((nw (find-individual 'name-word :name word)))
      (when nw
        ;; This will be the case when working interactively and
        ;; adding this koc because you see it in a name and want
        ;; to extend the grammar. As part of the name the first time
        ;; through a name-word object will have been made for it,
        ;; and since the rule for the nw is on the capitalized
        ;; version of the word, it will take precedence over this
        ;; koc definition when PNF is instantiating the initial
        ;; edges. We counteract it by making the nw 'silent'
        ;; by flushing its rule.
        (make-name-word-silent nw))

      (when (word-capitalization-variants word)
        (dolist (caps-word (word-capitalization-variants word))
          (when (setq nw (find-individual 'name-word :name caps-word))
            (make-name-word-silent nw)))))

    (setf (get-rules cat)
          (list (define-cfr category::kind-of-company `(,word)
                  :form category::np-head
                  :referent cat)
                (define-cfr category::kind-of-company `(,plural)
                  :form category::np-head
                  :referent `(:head ,cat :subtype ,category::collection))))

    (when abbrev
      (dolist (abbreviation abbrev)
        (define-abbreviation string abbreviation)))

    cat))
