;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: CLIC -*-
;;; Copyright (c) 2020 Smart Information Flow Technologies

(in-package :sparser)

;;;--------------------
;;; get the json files
;;;--------------------

#| These don't work. The merging ties me in knots right now so I'm leaving
   it for someone else to fix -- ddm 3/17/20  |#

(defun json-base ()
  (let ((base (asdf:system-relative-pathname :r3 "corpus/covid/2020-03-13/")))
    base))

(defun json-directory (&key base ((:dir dir-string) "biorxiv_medrxiv/biorxiv_medrxiv/"))          
  (let ((dir-path (merge-pathnames dir-string base)))
    (unless (probe-file dir-path) (error "extension to directory is wrong" dir-path))
    dir-path))

#| There's a good design for file handling in r3/code/evaluation/doc-support.
I was trying to copy that.  Also, since no one is going to be able to remember
these file names, it would be nice to collect whole directories of pathnames
and have some sort of "do the next one" set up

[MDM 3/17/20]  Okay, see what you think of this setup...

You can collect the files into the hopper using, e.g.:
(sparser::collect-json-directory :dir "biorxiv_medrxiv")

Then "do the next one" using using:
(sparser::do-next-json)

Or peek at what's on deck using:
(sparser::peek-next-json)

Or do the remaining ones using:
(sparser::do-remaining-json)

Or do the next N using:
(sparser::do-remaining-json :n N)

And once you know what function you want to run on each s-expression,
reassign *default-json-processing-fn* (directly below this) to something
else that takes two arguments:  (1) the s-expression (2) the file's pathname
|#

(defparameter *default-json-processing-fn* 'sample-processing-fn) ;; Replace me!
(defvar *json-files-to-read* nil)  ;; The file path hopper

(defun collect-json-directory (&key (dir "biorxiv_medrxiv"))
  (declare (type string dir))  ;; To appease compiler complaints
  (let* ((double-dir (format nil "~a/~a/" dir dir)) ;; May want to make more flexible
         (dir-path (json-directory :base (json-base) :dir double-dir))
         (wild-path (merge-pathnames "*.json" dir-path))
         (file-paths (directory wild-path)))
    (cond ((not file-paths)
           (warn "No json files found in location ~a." dir-path))
          (t
           (format t "~%Loading ~d file pathnames into the hopper.~%To process the next one, call (sparser::do-next-json)~%To see what the next is, call (sparser::peek-next-json)~%To do the rest, call (sparser::do-remaining-json)~%To do a batch of n using (sparser::do-remaining-json :n n)~%Remaining list stored in sparser::*json-files-to-read*.~%"
                   (length file-paths))
           (setf *json-files-to-read* file-paths)
           :done))))

(defun do-next-json (&key (do-fn *default-json-processing-fn*))
  (let ((next-file (pop *json-files-to-read*)))
    (cond ((not (probe-file next-file))
           (error "probe-file returned nil for file path ~s" next-file))
          (t
           (format t "~%~% Processing file: ~s~%" next-file)
           (let ((sexp (cl-json:decode-json-from-source next-file)))
             (cond ((null sexp)
                    (warn "The json file looks empty."))
                   ((not (fboundp do-fn))
                    (error "~a (value for keyword :do-fn) is not fbound." do-fn))
                   (t
                    (let ((fn-obj (symbol-function do-fn)))
                      (declare (type function fn-obj))
                      (funcall fn-obj sexp next-file)))))))))

(defun peek-next-json ()
  (declare (type list *json-files-to-read*))
  (let ((next-file (car *json-files-to-read*)))
    (cond ((not next-file)
           (format t "The reading list is empty." next-file))
          (t (format t "The next json path is:~%  ~s~%  It is followed by ~a more" next-file (- (length *json-files-to-read*) 1))
             next-file))))

(defun do-remaining-json (&key (do-fn *default-json-processing-fn*)
                            (n nil))
  (declare (type list *json-files-to-read*))
  (do* ((i n (and i (typep i 'fixnum) (- i 1))))
       ((or (and i (typep i 'fixnum) (< i 1))
            (null *json-files-to-read*)) :done)
    (do-next-json :do-fn do-fn)))

;; Whatever *default-json-processing-fn* is assigned to above should take
;; these two arguments
(defun sample-processing-fn (sexp filepath)
  (declare (ignorable filepath))
  (declare (type cons sexp))
  (format t "Nom nom, processing s-expression of length ~a." (length sexp)))


;;;------------------------------------------------
;;; example of output from decode-json-from-source
;;;------------------------------------------------


#| The sample is produced by this call.
   The filename was pulled from the commit email
sp> (probe-file "/Users/ddm/ws/R3/r3/trunk/corpus/covid/2020-03-13/biorxiv_medrxiv/biorxiv_medrxiv/0015023cc06b5362d332b3baf348d11567ca2fbb.json")
#P"/Users/ddm/ws/R3/r3/trunk/corpus/covid/2020-03-13/biorxiv_medrxiv/biorxiv_medrxiv/0015023cc06b5362d332b3baf348d11567ca2fbb.json"
sp> (json:decode-json-from-source *)  |#

(defparameter json-sexp
 '((:paper--id . "0015023cc06b5362d332b3baf348d11567ca2fbb")
 (:metadata
  (:title
   . "The RNA pseudoknots in foot-and-mouth disease virus are dispensable for genome replication but essential for the production of infectious virus. 2 3")
  (:authors
   ((:first . "Joseph") (:middle "C") (:last . "Ward") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Lidia") (:middle) (:last . "Lasecka-Dykes") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Chris") (:middle) (:last . "Neil") (:suffix . "") (:affiliation)
    (:email . ""))
   ((:first . "Oluwapelumi") (:middle) (:last . "Adeyemi") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Sarah") (:middle) (:last . "") (:suffix . "") (:affiliation)
    (:email . ""))
   ((:first . "") (:middle) (:last . "Gold") (:suffix . "") (:affiliation)
    (:email . ""))
   ((:first . "Niall") (:middle) (:last . "Mclean") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Caroline") (:middle) (:last . "Wright") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Morgan") (:middle "R") (:last . "Herod") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "David") (:middle) (:last . "Kealy") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Emma") (:middle) (:last . "") (:suffix . "") (:affiliation)
    (:email . ""))
   ((:first . "Warner") (:middle) (:last . "") (:suffix . "") (:affiliation)
    (:email . ""))
   ((:first . "Donald") (:middle "P") (:last . "King") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Tobias") (:middle "J") (:last . "Tuthill") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "David") (:middle "J") (:last . "Rowlands") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Nicola") (:middle "J") (:last . "") (:suffix . "")
    (:affiliation) (:email . ""))
   ((:first . "Stonehouse") (:middle) (:last . "A#") (:suffix . "")
    (:affiliation) (:email . ""))))
 (:abstract
  ((:text
    . "word count: 194 22 Text word count: 5168 23 24 25 author/funder. All rights reserved. No reuse allowed without permission. Abstract 27 The positive stranded RNA genomes of picornaviruses comprise a single large open reading 28 frame flanked by 5′ and 3′ untranslated regions (UTRs). Foot-and-mouth disease virus (FMDV) 29 has an unusually large 5′ UTR (1.3 kb) containing five structural domains. These include the 30 internal ribosome entry site (IRES), which facilitates initiation of translation, and the cis-acting 31 replication element (cre). Less well characterised structures are a 5′ terminal 360 nucleotide 32 stem-loop, a variable length poly-C-tract of approximately 100-200 nucleotides and a series of 33 two to four tandemly repeated pseudoknots (PKs). We investigated the structures of the PKs 34 by selective 2′ hydroxyl acetylation analysed by primer extension (SHAPE) analysis and 35 determined their contribution to genome replication by mutation and deletion experiments. 36 SHAPE and mutation experiments confirmed the importance of the previously predicted PK 37 structures for their function. Deletion experiments showed that although PKs are not essential 38")
   (:cite--spans) (:ref--spans) (:section . "Abstract"))
  ((:text
    . "for replication, they provide genomes with a competitive advantage. However, although 39 replicons and full-length genomes lacking all PKs were replication competent, no infectious 40 virus was rescued from genomes containing less than one PK copy. This is consistent with our 41 earlier report describing the presence of putative packaging signals in the PK region. 42 43 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "Abstract")))
 (:body--text
  ((:text
    . "VP3, and VP0 (which is further processed to VP2 and VP4 during virus assembly) (6). The P2 64 and P3 regions encode the non-structural proteins 2B and 2C and 3A, 3B (1-3) (VPg), 3C pro and 4 structural protein-coding region is replaced by reporter genes, allow the study of genome 68 replication without the requirement for high containment (9, 10) ( figure 1A ).")
   (:cite--spans)
   (:ref--spans
    ((:start . 351) (:end . 360) (:text . "figure 1A")
     (:ref--id . "FIGREF50")))
   (:section . ""))
  ((:text
    . "The FMDV 5′ UTR is the largest known picornavirus UTR, comprising approximately 1300 71 nucleotides and containing several highly structured regions. The first 360 nucleotides at the 5′ 72 end are predicted to fold into a single large stem loop termed the S-fragment, followed by a The PKs were originally predicted in 1987 and consist of two to four tandem repeats of a ~48 86 nucleotide region containing a small stem loop and downstream interaction site (figure 1B) 87 (12). Due to the sequence similarity between the PKs (figure 1C), it is speculated that they 88 were formed by duplication events during viral replication, probably involving recombination. 89 Between two and four PKs are present in different virus isolates but no strain has been 90 identified with less than two PKs, emphasising their potential importance in the viral life cycle 91 (19, 20) . The presence of PKs has been reported in the 5′ UTR of other picornaviruses such as 92 author/funder. All rights reserved. No reuse allowed without permission. can occur in the absence of PKs at least one is required for wild-type (wt) replication. 104 Furthermore, competition experiments showed that extra copies of PKs conferred a replicative 105 advantage to genomes. Although replicons and full-length genomes lacking PKs were 106 replication-competent, no infectious virus was rescued from genomes containing less than one 107 PK copy. This is consistent with our earlier report describing the presence of putative 108 packaging signals in the PK region (22). 109 110 author/funder. All rights reserved. No reuse allowed without permission. Plasmid construction. 117 The FMDV replicon plasmids, pRep-ptGFP, and the replication-defective polymerase mutant 118 control, 3D-GNN, have already been described (10).")
   (:cite--spans ((:start . 469) (:end . 471) (:text . "87") (:ref--id))
    ((:start . 662) (:end . 664) (:text . "89") (:ref--id))
    ((:start . 857) (:end . 861) (:text . "(19,") (:ref--id))
    ((:start . 862) (:end . 865) (:text . "20)") (:ref--id))
    ((:start . 1117) (:end . 1120) (:text . "104") (:ref--id))
    ((:start . 1637) (:end . 1640) (:text . "117") (:ref--id)))
   (:ref--spans) (:section . "70"))
  ((:text
    . "To introduce mutations into the PK region, the pRep-ptGFP replicon plasmid was digested 121 with SpeI and KpnI and the resulting fragment inserted into a sub-cloning vector (pBluescript) 122 to create the pBluescript PK. PKs 3 and 4 were removed by digestion with HindIII and AatII 123 before insertion of a synthetic DNA sequence with PK 3 and 4 deleted. PKs 2, 3 and 4 were 124 deleted by PCR amplification using ΔPK 234 Forward primer and FMDV 1331-1311 reverse 125 primer, the resultant product was digested with HindIII and AatII and ligated into the 126 pBluescript PK vector. Complete PK deletion was achieved by introduction of an AflII site at 127 the 3′ end of the poly-C tract by PCR mutagenesis to create the sub-cloning vector, pBluescript 128 C11, which was then used to remove all the PKs by PCR mutagenesis using ΔPK 1234 forward 129 primer and FMDV 1331-1311 reverse primer. The modified PK sequences were removed from 130 the sub-cloning vectors and inserted into the pRep-ptGFP plasmid using NheI-HF and KpnI-131 HF.")
   (:cite--spans) (:ref--spans) (:section . "120"))
  ((:text
    . "132 133 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "120"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint 7 Mutations to disrupt and reform PK structure were introduced using synthetic DNA by 134 digestion with AflII and AatII and ligation into a similarly digested pBluescript PK vector.")
   (:cite--spans) (:ref--spans) (:section . "120"))
  ((:text
    . "Mutations were then introduced into the replicon plasmid as described above.")
   (:cite--spans) (:ref--spans) (:section . "135"))
  ((:text
    . "To assess the effects of truncation of the poly-C-tract on replication the entire sequence was 137 removed. This was performed by PCR mutagenesis using primers C0 SpeI, and FMDV 1331- In vitro transcription. 143 In vitro transcription reactions for replicon assays were performed as described previously (28).")
   (:cite--spans ((:start . 208) (:end . 211) (:text . "143") (:ref--id)))
   (:ref--spans) (:section . "136"))
  ((:text
    . "Transcription reactions to produce large amounts of RNA for SHAPE analysis were performed 145 with purified linear DNA as described above, and 1 μg of linearised DNA was then used in a 146 HiScribe T7 synthesis kit (NEB), before DNase treatment and purification using a PureLink FastQ files were quality checked using FastQC with poor quality reads filtered using the 225 Sickle algorithm. Host cell reads were removed using FastQ Screen algorithm and FMDV 226 reads assembled de novo into contigs using IDBA-UD (35). Contigs that matched the FMDV 227 library (identified using Basic Local ALighnment Search Tool (BLAST)) were assembled 228 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans ((:start . 368) (:end . 371) (:text . "225") (:ref--id)))
   (:ref--spans) (:section . "144"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint into consensus sequences using SeqMan Pro software in the DNA STAR Lasergene 13 229 package (DNA STAR) (36). The SHAPE data largely agreed with the predicted structures with the stems of PK 1, 2 and 3, interacting nucleotides showed little to no reactivity, suggesting NMIA could not interact with 300 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "144"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint 14 these nucleotides either due to the predicted base pairing or steric hindrance (figure 2B). The")
   (:cite--spans) (:ref--spans) (:section . "144"))
  ((:text
    . "NMIA reactivity for the interacting nucleotides in the stem-loops with downstream residues of 302 PK 1, 2 and 3 again largely agreed with the predicted structure, although the SHAPE data 303 suggests that there might be fewer interactions than previously predicted. However, differences 304 here could be due to heterogeneity in the formation of PKs in this experiment. The evidence 305 for loop-downstream interaction was weaker for PK4. The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint")
   (:cite--spans ((:start . 187) (:end . 190) (:text . "303") (:ref--id)))
   (:ref--spans) (:section . "301"))
  ((:text
    . "orientation. 351 Since removal of all four PKs resulted in a significant decrease in replication, the minimal 352 requirements to maintain wt levels of replication were investigated. As near wt level of 353 replication was observed when only one PK was present, all further mutagenesis was 354 performed in a C11 replicon plasmid containing only PK 1. In addition, the orientation of PK 1 was reversed by \"flipping\" the nucleotide sequence to 367 potentially facilitate hybridisation of the loop with upstream rather than downstream sequences.")
   (:cite--spans ((:start . 13) (:end . 16) (:text . "351") (:ref--id)))
   (:ref--spans)
   (:section
    . "Function of the PKs in replication is dependent on downstream interactions and 350"))
  ((:text
    . "Changing the orientation of the PK reduced replicon replication to a similar level seen in the replication decreased until at passage three there is a 2.5 fold reduction compared to that of 398 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "368"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint passage 0 (figure 5B). Therefore, it appears that replicons with a single PK are at a competitive 399 disadvantage compared to those with two or more. The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint 20 of infectious virus despite being able to replicate after transfection into cells, is consistent with 448 a requirement for RNA structure within the PK region being required for virus assembly. The 5′ UTR of FMDV is unique amongst picornaviruses due to its large size and the presence 454 of multiple RNA elements, some of which still have unknown function. One of these features 455 is a series of repeated PKs varying in number from 2-4, depending on virus strain. In this study, 456 we sequentially deleted or mutated the PKs to help understand their role in the viral life cycle. 457 We also confirmed the predicted PK structures by SHAPE mapping, although there may be Although all viruses isolated to date contain at least two PKs, replicons or viruses containing a 464 single PK were still replication competent. However, replicons with more than a single PK 465 were found to have a competitive advantage over replicons with a single PK when sequentially 466 passaged. Replicons lacking all PKs displayed poor passaging potential even when co-467 transfected with yeast tRNA, reinforcing the observation of a significant impact in replication.")
   (:cite--spans ((:start . 920) (:end . 923) (:text . "456") (:ref--id))
    ((:start . 1022) (:end . 1025) (:text . "457") (:ref--id)))
   (:ref--spans) (:section . "368"))
  ((:text
    . "Moreover, viruses recovered from genomes with reduced numbers of PKs were slower growing 469 and produced smaller plaques. In addition, these differences were more pronounced in more PKs is functionally competent as no differences was seen between replicons congaing a single 472 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "468"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint 21 copy of PK1 or PK4. This observation is consistent with a previous report of deletion of PK1, 473 along with the Poly-C-tract, with no adverse effect in viral replication (37). This also supports 474 our findings that the truncation of the Poly-C-tract to create the C11 construct had no effect on 475 replicon replication in the cell lines tested. As has been described with Mengo virus, it is 476 possible that the role of the poly-C-tract is essential in other aspects of the viral lifecycle which 477 cannot be recapitulated in a standard tissue culture system (39).")
   (:cite--spans ((:start . 443) (:end . 446) (:text . "475") (:ref--id)))
   (:ref--spans) (:section . "468"))
  ((:text
    . "The presence of at least two PKs in all viral isolates sequenced so far suggests that multiple 480 PKs confer a competitive advantage in replication. Here we showed by sequential passage that 481 replicons containing at least two PKs were maintained at a level similar to wt, but replicons 482 containing only one PK showed a persistent decline. It is unclear why some viral isolates 483 contain two, three or four PKs is still unknown, but this may be stochastic variation or may 484 reflect subtle effects of host range or geographical localisation. The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "479"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint Significance is shown comparing the replication of C11 PK disrupt and C11 PK restore (Aii). Significance shown is compared to wt replicon. Error bars are calculated by SEM, n = 3, * P 673 < 0.05, **** P < 0.0001. 674 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "479"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint 33 675 author/funder. All rights reserved. No reuse allowed without permission.")
   (:cite--spans) (:ref--spans) (:section . "479"))
  ((:text
    . "The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint ")
   (:cite--spans) (:ref--spans) (:section . "479")))
 (:bib--entries
  (:+bibref0+ (:ref--id . "b0")
   (:title
    . "Genetic economy in 598 picornaviruses: Foot-and-mouth disease virus replication exploits alternative precursor 599 cleavage pathways")
   (:authors ((:first . "T") (:middle) (:last . "Jackson") (:suffix . ""))
    ((:first . "T") (:middle "J") (:last . "Tuthill") (:suffix . ""))
    ((:first . "D") (:middle "J") (:last . "Rowlands") (:suffix . ""))
    ((:first . "N") (:middle "J") (:last . "Stonehouse") (:suffix . "")))
   (:year . 2017) (:venue . "PLOS Pathog") (:volume . "13") (:issn . "")
   (:pages . "") (:other--ids))
  (:+bibref2+ (:ref--id . "b2")
   (:title
    . "A universal protocol to 602 generate consensus level genome sequences for foot-and-mouth disease virus and other 603 positive-sense polyadenylated RNA viruses using the Illumina MiSeq")
   (:authors
    ((:first . "N") (:middle "D") (:last . "Sanderson") (:suffix . ""))
    ((:first . "N") (:middle "J") (:last . "Knowles") (:suffix . ""))
    ((:first . "D") (:middle "P") (:last . "King") (:suffix . ""))
    ((:first . "E") (:middle "M") (:last . "Cottam") (:suffix . "")))
   (:year . 2014) (:venue . "BMC Genomics") (:volume . "604") (:issn . "")
   (:pages . "") (:other--ids))
  (:+bibref3+ (:ref--id . "b3")
   (:title
    . "Library preparation for highly accurate population 606 sequencing of RNA viruses")
   (:authors ((:first . "A") (:middle) (:last . "Acevedo") (:suffix . ""))
    ((:first . "R") (:middle) (:last . "Andino") (:suffix . "")))
   (:year . 2014) (:venue . "Nat Protoc") (:volume . "9") (:issn . "")
   (:pages . "1760--1769") (:other--ids))
  (:+bibref4+ (:ref--id . "b4")
   (:title
    . "IDBA-UD: a de novo assembler for 608 single-cell and metagenomic sequencing data with highly uneven depth")
   (:authors ((:first . "Y") (:middle) (:last . "Peng") (:suffix . ""))
    ((:first . "Hcm") (:middle) (:last . "Leung") (:suffix . ""))
    ((:first . "S") (:middle "M") (:last . "Yiu") (:suffix . ""))
    ((:first . "Fyl") (:middle) (:last . "Chin") (:suffix . "")))
   (:year . 2012) (:venue . "") (:volume . "") (:issn . "") (:pages . "")
   (:other--ids))
  (:+bibref6+ (:ref--id . "b6")
   (:title . "Basic local alignment 611 search tool")
   (:authors ((:first . "S") (:middle "F") (:last . "Altschul") (:suffix . ""))
    ((:first . "W") (:middle) (:last . "Gish") (:suffix . ""))
    ((:first . "W") (:middle) (:last . "Miller") (:suffix . ""))
    ((:first . "E") (:middle "W") (:last . "Myers") (:suffix . ""))
    ((:first . "D") (:middle "J") (:last . "Lipman") (:suffix . "")))
   (:year . 1990) (:venue . "J Mol Biol") (:volume . "215") (:issn . "")
   (:pages . "403--410") (:other--ids))
  (:+bibref7+ (:ref--id . "b7")
   (:title
    . "Genetically engineered foot-and-613 mouth disease viruses with poly(C) tracts of two nucleotides are virulent in mice")
   (:authors ((:first . "E") (:middle) (:last . "Rieder") (:suffix . ""))
    ((:first . "T") (:middle) (:last . "Bunch") (:suffix . ""))
    ((:first . "F") (:middle) (:last . "Brown") (:suffix . ""))
    ((:first . "P") (:middle "W") (:last . "Mason") (:suffix . "")))
   (:year . 1993) (:venue . "J 614 Virol") (:volume . "67") (:issn . "")
   (:pages . "5139--5184") (:other--ids))
  (:+bibref9+ (:ref--id . "b9")
   (:title
    . "Both cis and trans Activities of Foot-and-Mouth Disease Virus 617 3D Polymerase Are Essential for Viral RNA Replication")
   (:authors
    ((:first . "N") (:middle "J") (:last . "Stonehouse") (:suffix . "")))
   (:year . 2016) (:venue . "J Virol") (:volume . "90") (:issn . "")
   (:pages . "6864--6883") (:other--ids))
  (:+bibref10+ (:ref--id . "b10")
   (:title
    . "Mutational analysis of the 619 mengovirus poly(C) tract and surrounding heteropolymeric sequences")
   (:authors ((:first . "L") (:middle) (:last . "Martin") (:suffix . ""))
    ((:first . "G") (:middle) (:last . "Duke") (:suffix . ""))
    ((:first . "J") (:middle) (:last . "Osorio") (:suffix . ""))
    ((:first . "D") (:middle) (:last . "Hall") (:suffix . ""))
    ((:first . "A") (:middle) (:last . "Palmenberg") (:suffix . "")))
   (:year . 1996) (:venue . "J Virol") (:volume . "620") (:issn . "")
   (:pages . "2027--2031") (:other--ids))
  (:+bibref11+ (:ref--id . "b11")
   (:title
    . "No reuse allowed without permission. The copyright holder for this preprint (which was not peer-reviewed) is the")
   (:authors) (:year) (:venue . "") (:volume . "") (:issn . "") (:pages . "")
   (:other--ids (:+doi+ "10.1101/2020.01.10.901801")))
  (:+bibref12+ (:ref--id . "b12")
   (:title
    . "Figure 3. The poly-C-tract is dispensable and only one PK is required for wt replication")
   (:authors) (:year) (:venue . "") (:volume . "") (:issn . "") (:pages . "")
   (:other--ids))
  (:+bibref13+ (:ref--id . "b13")
   (:title
    . "A replicon 650 with entire poly-C-tract removed (C0) was transfected alongside wt, 3D-GNN and C11 651 replicons into BHK-21 cells (B). Replicons with sequentially deleted PKs (ΔPK 34, ΔPK 234 652 and C11 ΔPK 1234) were assayed for replication in BHK")
   (:authors ((:first . "3d") (:middle) (:last . "Wt") (:suffix . ""))) (:year)
   (:venue . "") (:volume . "") (:issn . "") (:pages . "") (:other--ids))
  (:+bibref14+ (:ref--id . "b14")
   (:title
    . "All replication assays were measured by counting the number of GFP 655 author/funder. All rights reserved. No reuse allowed without permission. The copyright holder for this preprint (which was not peer-reviewed) is the")
   (:authors) (:year)
   (:venue
    . "Replication of replicon with PK 4 as the sole remaining PK (C11 PK 4)")
   (:volume . "") (:issn . "") (:pages . "")
   (:other--ids (:+doi+ "10.1101/2020.01.10.901801")))
  (:+bibref15+ (:ref--id . "b15")
   (:title . "Error bars shown are calculated by SEM, n = 3") (:authors)
   (:year) (:venue . "") (:volume . "") (:issn . "") (:pages . "")
   (:other--ids))
  (:+bibref17+ (:ref--id . "b17")
   (:title
    . "No reuse allowed without permission. The copyright holder for this preprint (which was not peer-reviewed) is the")
   (:authors) (:year) (:venue . "") (:volume . "") (:issn . "") (:pages . "")
   (:other--ids (:+doi+ "10.1101/2020.01.10.901801"))))
 (:ref--entries
  (:+figref0+
   (:text
    . "and-mouth disease virus (FMDV) is a single stranded positive sense RNA virus of the 45 genus Aphthovirus in the family Picornaviridae. It occurs as seven, antigenically diverse 46 serotypes; A, O, C, Asia 1, South African Territories (SAT) 1, 2 and 3. It is the causative agent 47 of foot-and-mouth disease (FMD), a highly contagious disease of cloven-hooved animals 48 affecting most notably cattle, pigs, sheep and goats in addition to wild species such as the 49 African buffalo. Disease outbreaks have serious economic implications resulting from trade 50 restrictions, reduced productivity and the slaughter of infected and at-risk animals (1). The 51 2001 outbreak in the UK caused economic losses of over £8 billion to the tourism and 52 agricultural sectors. Inactivated virus vaccines are used in countries in which FMD is endemic, 53 but these are often strain-specific and provide little cross protection between serotypes (2). 54 Antigenic variation together with the relatively short duration of immunity following 55 vaccination combine to complicate control of the disease (3). In addition, the carrier state, in 56 which asymptomatically infected animals continue to shed virus, contributes to the spread of 57 FMDV (4). An improved understanding of the viral life cycle may be important for the 58 development of improved vaccines and other control measures. 59 60 The FMDV genome (approximately 8.4 kb) consists of a single open reading frame flanked by 61 5′ and 3′ untranslated regions (UTRs) (figure 1A) (5). The translated region encodes both 62 structural and non-structural proteins. The P1 region encodes the capsid structural proteins VP1, 63")
   (:latex) (:type . "figure"))
  (:+figref1+
   (:text
    . "73 large poly-C tract of variable length (which can be up to 200 nt), a region containing two to 74 four tandemly repeated pseudoknots (PKs), the cis acting replication element (cre) and the 75 internal ribosome entry site (IRES) (5, 11, 12). Of these five structural domains, functions have 76 been ascribed to only two, the cre and IRES. The cre region is involved in uridylation of the 77 RNA primer peptide, VPg (also known as 3B), and the IRES determines the initiation of 78 translation of the viral polyprotein (13, 14). The roles of the S-fragment, the poly-C tract and 79 the PKs in viral replication are not fully elucidated, however recent studies have shown that 80 truncations to the S-fragment can play key roles in the innate immune response to viral 81 infection (15-17). It has also recently been reported that viruses containing a deletion within 82 the pseudoknot region showed an attenuated phenotype in bovine cell lines while remaining 83 unchanged in porcine, suggesting a role for the pseudoknots in viral tropism (18).")
   (:latex) (:type . "figure"))
  (:+figref3+
   (:text
    . "138 1311 as forward and reverse primers respectively. The PCR product was digested with SpeI 139 and KpnI before ligation into a NheI and KpnI digested wt pRep ptGFP replicon. Sequences of 140 all primers are available upon request.141 142")
   (:latex) (:type . "figure"))
  (:+figref5+
   (:text
    . "prepared as above and a sample (12 pmol) was heated to 95 o C for 2 minutes before 151 cooling on ice. RNA folding buffer (100 mM HEPES, 66 mM MgCl2 and 100 mM NaCl) and 152 RNase Out (Invitrogen) was added to the RNA and incubated at 37 o C for 30 minutes. Once 153 folded, RNA was treated with NMIA compound at a final concentration of 5 mM or DMSO as 154 a negative control for 50 minutes at 37 o C. Following incubation, labelled RNA was ethanol 155 precipitated and resuspended in 10 μl 0.5 x TE buffer.")
   (:latex) (:type . "figure"))
  (:+figref6+
   (:text
    . "10 minutes in a thermocycler. A reverse transcription master mix containing 4 μl first 161 strand buffer, 1 μl 100 mM DTT, 0.5 μl RNase Out, 1 μl Supsercript III (Invitrogen), 1 μl 10 162 mM PCR dNTP mix (Promega) and 0.5 μl RNase free water, was then added to the 163 RNA/primer complex and extension carried out by incubation at 52 o C for 30 minutes.")
   (:latex) (:type . "figure"))
  (:+figref7+
   (:text
    . ", cDNA:RNA hybrids were disassociated by incubation with 1 μl 4M NaOH at 166 95 o C for 3 minutes before neutralisation with 2 μl 2M HCl. Extended cDNA was ethanol 167 precipitated and resuspended in 40 μl deionized formamide (Thermo Fisher). Sequencing 168 ladders were made similarly using 6 pmol of RNA with the inclusion of 1 μl 10 mM ddCTP in 169 the reverse transcription mix and using a differentially labelled fluorescent primer (either Hex 170 or FAM). 20 μl of sequencing ladder was combined with NMIA or DMSO samples and 171 dispatched on dry ice for capillary electrophoresis (Dundee DNA seq).")
   (:latex) (:type . "figure"))
  (:+figref8+
   (:text
    . "was analysed using QuShape and reactivity overlaid onto the RNA 174 structure using VARNA (29, 30).")
   (:latex) (:type . "figure"))
  (:+figref9+
   (:text
    . "in all cell lines was assessed in 24-well plates with 0.5 µg/cm 2 of RNA 178 using Lipofectin transfection reagent (Life Technologies) as previously described (28). For 179 complementation assays, BHK-21 cells seeded into 24-well plates were allowed to adhere for 180 16 hours before transfection with 1 µg of replicon RNA using Lipofectin. Each transfection 181 was performed in duplicate and experiments were biologically repeated. Replicon replication by live cell imaging using an IncuCyte Zoom Dual colour FLR, an automated 183 phase-contrast and fluorescence microscope within a humidifying incubator. At hourly 184 intervals up to 24 hours post transfection, images of each well were taken and used to count 185 the number of ptGFP positive cells per well.")
   (:latex) (:type . "figure"))
  (:+figref10+
   (:text
    . "competition assays was performed by co-transfecting BHK-21 cells with in vitro 188 transcribed replicon RNA and harvesting total cell RNA at 8 hours post transfection using 189 TRIzol reagent (Thermo Fisher Scientific). The harvested RNA was then purified using the 190 Direct-zol RNA MiniPrep kit (Zymo Research) with on-column DNase I treatment and eluted 191 in DEPC treated water. The purified passaged RNA (1 µg) was transfected onto the naïve BHKhere are based on plasmid T7S3 which encodes a full length infectious copy 196 of FMDV O1 Kaufbeuren (31). The reporter was removed from replicons by digestion with 197 PsiI and XmaI restriction enzymes and replaced with the corresponding fragment from pT7S3 198 encoding the capsid proteins. Full length viral RNA was transcribed using a T7 MEGAscript 199 kit (Thermo Fisher Scientific), DNase treated using TurboDNase (Thermo Fisher Scientific) 200 and purified using a MEGAclear Transcription Clean-Up kit (Thermo Fisher Scientific). 201 RNA quality and concentration were determined by denaturing agarose gel electrophoresis 202 and Qubit RNA BR Assay Kit (Thermo Fisher Scientific).")
   (:latex) (:type . "figure"))
  (:+figref11+
   (:text
    . "-transfection cell lysates were freeze-thawed and clarified by centrifugation.208    Clarified lysate was blind passaged onto naïve BHK-21 cells, this was continued for five 209 rounds of passaging.210 211 Sequencing of recovered virus. 212 Recovered viruses at passage 4, were sequenced using an Illumina Miseq (illumine) using a 213 modified version of a previously described PCR-free protocol ((32, 33)). Total RNA was 214 extracted from clarified passage 4 lysates using TRizol reagent (Thermo Fisher Scientific) 215 and residual genomic DNA removed using DNA-free DNA removal Kit (Thermo Fisher 216 Scientific). RNA was precipitated using 3 M sodium acetate and ethanol, 10 ul of purified 217 RNA (containing 1 pg to 5 µg) of RNA was used in a reverse transcription reaction as 218 previously described (33, 34). Following reverse transcription cDNA was purified and 219 quantified using a Qubit ds DNA HS Assay kit (Thermo Fisher Scientific) and a cDNA 220 library prepared using Nextera XT DNA Sample Preparation Kit (Illumina). Sequencing was 221 carried out on the MiSeq platform using MiSeq Reagent Kit v2 (300 cycles) chemistry 222 (Illumina).")
   (:latex) (:type . "figure"))
  (:+figref13+
   (:text
    . "of recovered virus. 232 Confluent BHK-21 cell monolayers were infected with 10-fold serial dilutions of virus stock, 233 overlaid with Eagle overlay media supplemented with 5 % tryptose phosphate broth solution 234 (Sigma Aldrich), penicillin (100 units/ml and streptomycin (100 µg/ml) (Sigma Aldrich) and 235 0.6 % Indubiose (MP Biomedicals) and incubated for 48 hours at 37 o C. Cells were fixed and 236 stained with 1 % (w/v) methylene blue in 10 % (v/v) ethanol and 4 % formaldehyde in PBS. 237 238 Fixed plaques were scanned and images measured using a GNU Image Manipulation 239 Program IMP (GIMP, available at https://www.gimp.org). For each plaque, horizontal and 240 vertical diameter in pixels was taken and an average of these two values was calculated. All 241 plaques per well were measured. 242 243 Cell killing assays. 244 Virus titre was determined by plaque assays. BHK-21 cells were seeded with 3 x10 4 245 cells/well in 96 well plates and allowed to settle overnight. Cell monolayers were inoculated 246 with each rescued virus at MOI of 0.01 PFU for 1 hour, inoculum was removed and 150 µl of 247 fresh GMEM (supplemented with 1 % FCS) was added to each well. Appearance of CPE was 248 monitored every 30 minutes using the IncuCyte S3.")
   (:latex) (:type . "figure"))
  (:+figref14+
   (:text
    . "protein 3A, and a goat anti-Mouse IgG (H+L) highly cross-adsorbed 254 secondary antibody, Alexa Fluor 488 (Life Technologies). Each transcript was transfected in 255 triplicate and the experiment biologically repeated three times. BHK-21 cells were seeded 256 into T25 flasks 16 hours prior to transfection with 10 µg RNA. The transfection mix was left 257 on the cells for 1 hour before the media was changed to VGM (Glasgow Minimum Essential 258 Medium (Sigma-Aldrich), 1% Foetal Bovine Serum -Brazil origin (Life Science Production) 259 and 5% Tryptose Phosphate Broth (Sigma-Aldrich).")
   (:latex) (:type . "figure"))
  (:+figref15+
   (:text
    . "After a further 3 hours, cells were dissociated using trypsin-EDTA 0.05% phenol red (Life261 Technologies), pelleted at 200 g for 3 minutes and fixed in 4% paraformaldehyde for 40 262 minutes. Cells were then transferred to a 96-well u-bottom plate and pelleted; this and all 263 subsequent pelleting steps were done at 300 xg for 5 minutes. Cells were resuspended in 0.5% 264 BSA in PBS blocking buffer (Melford), pelleted and resuspended in 1/1000 2C2 antibody and 265 left shaking at 500 rpm at 4 o C for 14 hours in an Eppendorf Thermomixer C plate shaker. The 266 cells were pelleted and subsequently resuspended in blocking buffer three times to wash, 267 resuspended in 1/200 anti-mouse fluorescent secondary antibody and rotated at 500 rpm at 268 24 o C for 1 hour before washing a final three times. Cells were then resuspended in 500 µl PBS 269 and data were collected on the LSR Fortessa (BD Biosciences) using BD FACSDivaTM 270 software. Data were exported as flow cytometry standard (FCS) files, and were analysed in 271 FlowJo 10 using the gating strategy shown in Figure 7.")
   (:latex) (:type . "figure"))
  (:+figref16+
   (:text
    . "of PKs was initially predicted in 1987 by computational and visual analysis of 279 the 5′ UTR sequence (12). The prediction of the presence of multiple PKs was strengthened by 280 the observation that variation in the length of this region between different virus isolates 281 equated to the gain or loss of PK-length sequence units. However, the definitive demonstration 282 of PK structure remains a challenge. Here, we used selective 2′ hydroxyl acylation analysed by 283 primer extension (SHAPE) to investigate the secondary structure of the PK region.")
   (:latex) (:type . "figure"))
  (:+figref17+
   (:text
    . "representing FMDV UTRs were folded prior to treatment with NMIA, a 286 compound that forms 2′-O-adducts when interacting with non-paired nucleotides, or DMSO as 287 a negative control. Labelled RNAs were purified and used as templates in reverse transcription 288 reactions using fluorescently labelled primers. Elongation of the reverse transcription products 289 terminates at adducts, resulting in cDNA fragments of different lengths, which were analysed 290 by gel electrophoresis alongside a sequencing ladder to identify sites of NMIA interaction. The 291 whole PK region was surprisingly reactive suggesting that it was largely single stranded or 292 highly flexible (figure 2A). To investigate if the SHAPE data agreed with the predicted 293structure, the NMIA reactivity was overlaid onto the previous PK structure prediction (12).")
   (:latex) (:type . "figure"))
  (:+figref19+
   (:text
    . "296 being unreactive, suggestive of base-pairing. Formation of the stem of PK4 was less convincing, 297 although the stem nucleotides still had relatively low reactivity in agreement with the other PK 298 models. For all the PKs, the nucleotides in the loop regions and the predicted downstream299")
   (:latex) (:type . "figure"))
  (:+figref20+
   (:text
    . "the NMIA reactivities with the original predicted structure the SHAPE data were 308 compatible to the PK models and potentially shed new light on the requirements of the loop 309 interactions.")
   (:latex) (:type . "figure"))
  (:+figref21+
   (:text
    . "PK is sufficient for efficient replication.312    The replicon system was based on the O1K FMDV sequence which includes four similar but 313 non-identical PKs (figure 1). The PKs were sequentially deleted from the 3′ side (i.e. PK 4-PK 314 1), and replication of the resulting modified replicons assessed.")
   (:latex) (:type . "figure"))
  (:+figref22+
   (:text
    . "complete removal of all PKs, an AflII site was inserted into the ptGFP replicon 317 plasmid which resulted in reduction of the poly-C-tract to 11 cytosine residues. This C11 318 replicon was investigated alongside a wt replicon and one with lethal polymerase mutations 319 (3D-GNN). These controls were used to confirm that truncation of the poly-C tract had no 320 measurable effect on replication the two cell lines tested, as previously reported (37) (figure 321 3A). For completeness, we further removed the entire poly-C-tract (C0) and showed that this 322 had no observable negative effect on replication of the replicon (figure 3B). The C11 construct 323 was then used as the \"backbone\" for removal of all four PKs.")
   (:latex) (:type . "figure"))
  (:+figref23+
   (:text
    . "measuring ptGFP reporter expression, in parallel with transfection of a wt and 327 3D-GNN replicon, where the 3D-GNN replicon is used to monitor ptGFP expression resulting 328 from translation of input RNA in the absence of replication. Reporter expression was recorded 329 using an IncuCyte Zoom automatic fluorescent microscope and is shown at 8 hours post-")
   (:latex) (:type . "figure"))
  (:+figref25+
   (:text
    . "∆PK 234 respectively) replicated at similar levels to the wt replicon (figure 3C-D). 334 However, a replicon containing no PKs (C11 ∆PK 1234) showed a significant (~ 4 fold) 335 reduction in replication in BHK-21 cells compared to the wt C11 replicon. A larger reduction 336 in replication (28 fold) was seen in the MDBK cell line, supporting previous publications on 337 the potential role in host cell tropism (18). Replication of the C11 ∆PK 1234 replicon in MDBK 338 cells was however still significantly above that of the 3D-GNN negative control. These data 339 suggest that although the PKs are not essential for replication at least one PK is required for wt 340 levels of replication. 341 342In the experiments above PK1 was the sole remaining PK and we therefore investigated 343 whether other PKs could similarly support wt replication. We deleted all the PKs to create the 344 C11 construct and re-inserted PK4 as the only PK (C11 PK4). Near wt levels of replication 345 were observed following transfection into both cell types suggesting that there is no functional 346 difference between PK1 and PK4 (figure 3E).")
   (:latex) (:type . "figure"))
  (:+figref27+
   (:text
    . "to interrupt base pairing and abrogate formation of the PK structure were 357 made in the loop of PK 1 and the corresponding downstream nucleotides. The substitutions 358 (shown in red) created a GAGA motif both in the loop and downstream regions and reduced 359 the replication of the mutated replicon (C11 PK disrupt) equivalent to that of the replicon 360 containing no PKs, thereby supporting the predicted structure (figure 4A). Base pairing 361 potential was then restored by mutation of the relevant nucleotides in the loop and downstream 362 region to GGGG and CCCC respectively. Restoring the interaction using an alternate sequence 363 increased replication significantly compared to the disrupted PK replicon (~ 4 fold), although 364 this was still slightly below that of the wt (~ 0.7 fold decrease) (figure 4A).")
   (:latex) (:type . "figure"))
  (:+figref29+
   (:text
    . "369absence of PKs (figure 4B). This suggests that the role of the PKs in genome replication is 370 dependent on both sequence, structure and orientation.")
   (:latex) (:type . "figure"))
  (:+figref30+
   (:text
    . "studies above suggested that removal of up to three of the four PKs present in the 375 wt sequence had no clear effect on replicon replication, although deletion of all four was 376 significantly detrimental. To investigate whether multiple PKs conferred more subtle 377 advantages for replication than were evident from single round transfection experiments we 378 carried out sequential passages of replicon RNA following transfection of the PK deleted forms 379 in competition with a wt replicon. Different reporter genes (ptGFP or mCherry) were used to 380 distinguish the competing replicons.")
   (:latex) (:type . "figure"))
  (:+figref31+
   (:text
    . "ptGFP; wt, ∆PK 34, ∆PK 234 and C11 ∆PK 1234 were co-transfected into 383 BHK-21 cells together with either a wt mCherry replicon or yeast tRNA as a control. The 384 replication of each of the co-transfected replicons was compared by observing ptGFP and 385 mCherry expression over three sequential passages. Passaging was achieved by harvesting total 386 RNA using Trizol-reagent 8 hours post-transfection. Harvested RNA was purified and then re-387 transfected into naïve BHK-21 cells.")
   (:latex) (:type . "figure"))
  (:+figref32+
   (:text
    . "transfection of the wt, ∆PK 34 or ∆PK 234 with yeast tRNA as controls showed no 390 differences in replication as expected (Figure 5A). Likewise, when PK mutants were co-391 transfected with a wt replicon after three passages, the number of green fluorescent cells 392 produced by the ∆PK 34 replicon was comparable to that of the wt, suggesting no competitive 393 advantage of four PKs over two. For both, there was a reduction in replication after the first 394 passage but recovery to near that of the original transfection by the third passage. However, 395 when co-transfected with the wt replicon, the ∆PK 234 replicon showed a similar drop in 396 replication in passage two, but showed no subsequent recovery following each passage and397")
   (:latex) (:type . "figure"))
  (:+figref33+
   (:text
    . "transfection with the wt mCherry replicon reduced the replication of the C11 ∆PK 1234 402 replicon to background levels as seen when comparing to the yeast tRNA control. By passage 403 two the ptGFP signal of the C11 ∆PK 1234 was no longer detectable, suggesting that this 404 replicon has been out competed (figure 5C). Although the initial replication of C11 ∆PK 1234 405 was greater when co-transfected with yeast tRNA than when in competition with wt mCherry 406 replicon, the ptGFP signal was reduced at passage two and was at background level by passage 407 three (figure 5C). Replication of the mCherry wt replicon was not influenced by co-transfection 408 with the ptGFP constructs (figure 5D), as expected. Together these data suggest that the minor 409 replicative advantage conferred by multiple PKs are quickly compounded over multiple 410 replication cycles to provide a replicative advantage.")
   (:latex) (:type . "figure"))
  (:+figref34+
   (:text
    . "a PK is essential for the production of infectious virus413    As replicons lacking all PKs could replicate and replicons with reduced numbers of PKs414 appeared to be at a competitive disadvantage compared to the wt construct, we investigated the 415 consequences of PK manipulation on the complete viral life cycle. The ∆PK 34, ∆PK 234 and 416 C11 ∆PK 1234 mutations were introduced into an FMDV infectious clone by replacement of 417 sequence encoding ptGFP with that encoding the O1K structural proteins. RNA transcripts 418 were transfected into BHK-21 cells alongside a wt O1K viral transcript and blind passaged 5 419 times by transferring the cell supernatant at 24 hours post transfection onto naïve BHK-21 cells.")
   (:latex) (:type . "figure"))
  (:+figref36+
   (:text
    . "427 rate of CPE (figure 6A) and plaque size (figure 6B-C) of ∆PK 34 and ∆PK 234 when compared 428 to the wt O1K virus. Rate of CPE was monitored by infecting BHK-21 cells with a known MOI 429 (0.01) of recovered virus, cells were then monitored for signs of CPE (shown as a decrease in 430 cell confluency) as measured by an automated imaging platform (Incucyte Zoom). Both ∆PK 431 34 and ∆PK 234 showed delayed onset of CPE with ∆PK 34 being the slowest, initial CPE 432 occurring at approximately 39 hours and 29 hours post infection respectively, compared to the 433 22 hours seen in the wt control. This mirrored plaque assay data where ∆PK 34 displayed a 434 significantly smaller plaque phenotype when compared to the wt control (average of 13.8 pixels 435 compared to 37.4), the slower rate of CPE seen in ∆PK 234 made a small, but not significant 436 difference (average 31.9 pixels).")
   (:latex) (:type . "figure"))
  (:+figref37+
   (:text
    . "∆PK 1234 produced no infectious virus the ability of the full-length genome lacking 439 PKs to replicate was investigated. BHK-21 cells were transfected with the same RNA 440 transcripts as above alongside additional controls, mock-transfected and transfected with wt 441 and treated with 3 mM GuHCl (a replication inhibitor) as negative controls. Six hours post-442 transfection, cells were harvested, fixed and labelled with an anti-3A antibody and fluorescent 443 secondary antibody. Cells were then analysed using flow cytometry and anti-3A antibody 444 signal used as an indirect measure of genome replication (figure 7). The results were similar to 445 those of the replicon experiments and showed that all the modified virus genomes were able to 446 undergo robust replication. The inability of the C11 ∆PK 1234 genome to support production 447 author/funder. All rights reserved. No reuse allowed without permission.")
   (:latex) (:type . "figure"))
  (:+figref39+
   (:text
    . "458fewer strong interactions maintaining the PKs than was previously predicted. This may indicate 459 high conformational flexibility of this region of the genome. SHAPE mapping was also 460 supported by mutation of predicted key interactions between nucleotides in the loop and 461 downstream, disruption of which reduced replication to that of the C11 ∆PK 1234 replicon.")
   (:latex) (:type . "figure"))
  (:+figref41+
   (:text
    . "470 relevant cells lines (i.e. in MDBK cells compared to BHK 21 cells). It is likely that each of the 471")
   (:latex) (:type . "figure"))
  (:+figref42+
   (:text
    . "although removal of all four PKs resulted in a significant decrease in replicon and 487 viral genome replication, replication was not abolished, showing that PKs are not essential to 488 support genome replication. However, deletion of all PKs from an infectious clone completely 489 abolished the ability to recover infectious virus. This suggests that the genome lacking all PKs 490 is defective in a function associated with virion assembly and is compatible with our evidence 491 for the presence of a packaging signal in a similar location on the genome to PK1 (22). It is 492 possible that structural flexibility at this site in the genome allows the RNA to adopt alternate 493 conformations with different roles in genome replication and virion assembly. A functional 494 requirement for multiple RNA conformations may explain the relatively weak interactions 495 between nucleotides involved in stabilising the PK motif as observed by SHAPE analysis or 496 by structural prediction.")
   (:latex) (:type . "figure"))
  (:+figref43+
   (:text
    . "was supported by funding from the Biotechnology and Biological Sciences Research 503 Council (BBSRC) of the United Kingdom (research grant BB/K003801/1). Additionally, the 504 Pirbright Institute receives grant-aided support from the BBSRC (projects BB/E/I/00007035, 505 BB/E/I/00007036 and BBS/E/I/00007037).")
   (:latex) (:type . "figure"))
  (:+figref44+
   (:text
    . "Jones TJD, Rushton J. 2013. The economic impacts of foot and mouth disease 511 -What are they, how big are they and where do they occur? Prev Vet Med 112:161-M, Parida S. 2018. Foot and mouth disease vaccine strain selection: current 514 approaches and future perspectives. Expert Rev Vaccines 17:577-591.")
   (:latex) (:type . "figure"))
  (:+figref45+
   (:text
    . "J-H. 2013. Requirements for improved vaccines against foot-and-mouth disease 516 epidemics. Clin Exp Vaccine Res 2:8-18.")
   (:latex) (:type . "figure"))
  (:+figref46+
   (:text
    . "C, Eschbaumer M, Rekant SI, Pacheco JM, Smoliga GR, Hartwig EJ, 518 Rodriguez LL, Arzt J. 2016. The Foot-and-Mouth Disease Carrier State Divergence in 519 Cattle. J Virol 90:6344-64.")
   (:latex) (:type . "figure"))
  (:+figref47+
   (:text
    . "C, Tulman ER, Delhon G, Lu Z, Carreno A, Vagnozzi A, Kutish GF, Rock 521 DL. 2005. Comparative genomics of foot-and-mouth disease virus. J Virol 79:6487-D. 1997. Dissecting the roles of VP0 cleavage and RNA packaging in 525 picornavirus capsid stabilization: the structure of empty capsids of foot-and-mouth 526 disease virus. J Virol 71:9743-52. 527 7. Gao Y, Sun S-Q, Guo H-C. 2016. Biological function of Foot-and-mouth disease virus 528 non-structural proteins and non-coding elements. Virol J 13:107. 529 8. Herod MR, Gold S, LaseckaDykes L, Wright C, Ward JC, McLean TC, Forrest S, 530 Jackson T, Tuthill TJ, Rowlands DJ, Stonehouse NJ. 2017. Genetic economy in 531 picornaviruses: Foot-and-mouth disease virus replication exploits alternative precursor 532 cleavage pathway. PLOS Pathog 13:e1006666. 533 9. Tulloch F, Pathania U, Luke GA, Nicholson J, Stonehouse NJ, Rowlands DJ, Jackson 534 T, Tuthill T, Haas J, Lamond AI, Ryan MD. 2014. FMDV replicons encoding green 535 fluorescent protein are replication competent. J Virol Methods 209:35-40. 536 10. Herod MR, Tulloch F, Loundras E-A, Ward JC, Rowlands DJ, Stonehouse NJ. 2015. 537 Employing transposon mutagenesis to investigate foot-and-mouth disease virus 538 replication. J Gen Virol 96:3507-3518. 539 11. Mellor EJC, Brown F, Harris TJR. 1985. Analysis of the Secondary Structure of the 540 Poly(C) Tract in Foot-and-Mouth Disease Virus RNAs. J Gen Virol 66:1919-1929. 541 12. Clarke BE, Brown AL, Currey KM, Newton SE, Rowlands DJ, Carroll AR. 1987. 542 Potential secondary and tertiary structure in the genomic RNA of foot and mouth 543 disease virus. Nucleic Acids Res 15:7067-7079. 544 13. Nayak A, Goodfellow IG, Woolaway KE, Birtley J, Curry S, Belsham GJ. 2006. Role 545 of RNA structure and RNA binding activity of foot-and-mouth disease virus 3C 546 protein in VPg uridylylation and virus replication. J Virol 80:9865-75. Kloc A, Diaz-San Segundo F, Schafer EA, Rai DK, Kenney M, de los Santos T, 555 Rieder E. 2017. Foot-and-mouth disease virus 5'-terminal S fragment is required for 556 replication and modulation of the innate immune response in host cells. Virology 557 512:132-143. 558 17. Kloc A, Rai DK, Rieder E. 2018. The roles of picornavirus untranslated regions in 559 infection and innate immunity. Front Microbiol. Frontiers Media S.A. 560 18. Zhu Z, Yang F, Cao W, Liu H, Zhang K, Tian H, Dang W, He J, Guo J, Liu X, Zheng 561 H. 2019. The Pseudoknot Region of the 5' Untranslated Region Is a Determinant of 562 Viral Tropism and Virulence of Foot-and-Mouth Disease Virus. J Virol 93. 563 19. Mohapatra JK, Pawar SS, Tosh C, Subramaniam S, Palsamy R, Sanyal A, Hemadri D, 564 Pattnaik B. 2011. Genetic characterization of vaccine and field strains of serotype A 565 foot-andmouth disease virus from India. Acta Virol 55:349-352. 566 20. Escarmís C, Dopazo J, Dávila M, Palma EL, Domingo E. 1995. Large deletions in the 567 5'-untranslated region of foot-and-mouth disease virus of serotype C. Virus Res 568 35:155-67.")
   (:latex) (:type . "figure"))
  (:+figref48+
   (:text
    . "Carocci M, Bakkali-Kassimi L. 2012. The encephalomyocarditis virus. Virulence")
   (:latex) (:type . "figure"))
  (:+figref49+
   (:text
    . ". Wutz G, Auer H, Nowotny N, Grosse B, Skern T, Kuechler E. 1996. Equine rhinovirus Xrn1 produce a pathogenic Dengue virus RNA. Elife 3. 576 24. Kieft JS, Rabe JL, Chapman EG. 2015. New hypotheses derived from the structure of 577 a flaviviral Xrn1-resistant RNA: Conservation, folding, and host adaptation. RNA Biol 578 12:1169-77.579 25. Gultyaev AP, Olsthoorn RCL. 2010. A family of non-classical pseudoknots in 580 influenza A and B viruses. RNA Biol 7:125-9. 581 26. Moss WN, Dela-Moss LI, Priore SF, Turner DH. 2012. The influenza A segment 7 582 mRNA 3' splice site pseudoknot/hairpin family. RNA Biol 9:1305-10. 583 27. Plant EP, Dinman JD. 2008. The role of programmed-1 ribosomal frameshifting in 584 coronavirus propagation. Front Biosci 13:4873-81. 585 28. Herod MR, Ferrer-Orta C, Loundras E-A, Ward JC, Verdaguer N, Rowlands DJ, 586 Stonehouse NJ. 2016. Both cis and trans Activities of Foot-and-Mouth Disease Virus 587 3D Polymerase Are Essential for Viral RNA Replication. J Virol 90:6864-6883. 588 29. Karabiber F, McGinnis JL, Favorov O V., Weeks KM. 2013. QuShape: Rapid, 589 accurate, and best-practices quantification of nucleic acid probing information, 590 resolved by capillary electrophoresis. RNA 19:63-73. 591 30. Darty K, Denise A, Ponty Y. 2009. VARNA: Interactive drawing and editing of the 592 RNA secondary structure. Bioinformatics 25:1974-1975. 593 31. King AMQ, Blakemore WE, Ellard FM, Drew J, Stuart DI. 1999. Evidence for the role 594 of His-142 of protein 1C in the acid-induced disassembly of foot-and-mouth disease 595 virus capsids. J Gen Virol 80:1911-1918. 596 32. Herod MR, Gold S, Lasecka-Dykes L, Wright C, Ward JC, McLean TC, Forrest S, 597 author/funder. All rights reserved. No reuse allowed without permission.")
   (:latex) (:type . "figure"))
  (:+figref50+
   (:text
    . "Replicon and PK schematic. Schematic of the FMDV O1K sub-genomic replicon, 627 showing both 5' and 3' untranslated regions (UTRs) together with the RNA structures present 628 in these regions. IRES-driven translation produces a single polyprotein. Here, the structural 629 proteins have been replaced with a green fluorescent reporter, upstream of the non-structural 630 proteins 2A-3D (A). Predicted PK structures, with putative interactions highlighted in hot-pink 631 are shown. Numbers indicate nucleotide positions after the poly-C-tract (B). Sequence 632 alignment of the 4 PKs, with the interacting regions shown in hot-pink and invariant 633 nucleotides represented by asterisk (C).")
   (:latex) (:type . "figure"))
  (:+figref51+
   (:text
    . "SHAPE NMIA reactivity of the PK region. NMIA reactivity at nucleotides 640 following the poly-C-tract (PCT). High reactivity indicates increased chance of the nucleotide 641 being non base-paired at that position (A). NMIA reactivity of each PK overlaid onto the 642 predicted PK structure using VARNA (30). Loop and downstream interactions represent those 643 supported by SHAPE data (B). NMIA reactivity is represented on a colour scale from low 644 (white) to high (red) (n = 4). 645 646 author/funder. All rights reserved. No reuse allowed without permission.")
   (:latex) (:type . "figure"))
  (:+figref52+
   (:text
    . "Disrupting the PK structure and reversing the orientation of a PK reduces 663 replication. Cartoon representations of disrupting and restoring mutations made to PK 1, 664 where nucleotides in the bulge of the stem loop and interacting region downstream were 665 mutated to disrupt structure formation 'PK disrupt', or mutated to maintain bulge and 666 downstream interaction but with different nucleotides 'PK restore' (Ai). Replication of PK 667 disrupt and restore mutants were measured by transfection of RNA into BHK-21 cells and 668 shown here at 8 hours post-transfection alongside wt, 3D-GNN and C11 ΔPK 1234 controls.")
   (:latex) (:type . "figure"))
  (:+figref54+
   (:text
    . "Visual representation of the reversing of the nucleotide sequence of PK1 creating the C11 PK 671 Rvs construct (Bi). Replication of PK Rvs at 8 hours post transfection of BHK-21 cells (Bii).")
   (:latex) (:type . "figure"))
  (:+figref56+
   (:text
    . "More than 2 PKs provides a replicative advantage in co-transfection")
   (:latex) (:type . "figure"))
  (:+tabref0+
   (:text
    . "encephalomyocarditis virus (EMCV) and equine rhinitis A virus (ERAV) (21, 22). However, in both cases the PKs are located at the 5′ side of the poly-C-tract, making their location in the FMDV genome unique. PKs have been reported to have roles in several aspects of viral replication including splicing 97 (e.g. HIV and influenza), ribosomal frameshifting (e.g. coronaviruses) and RNase protection 98 (e.g. Dengue virus) (23-27). In the work reported here, the role of the PKs in the FMDV life cycle was investigated, together with biochemical probing of PK structures. The combination of both virus and replicon systems allowed us to distinguish effects on genome replication and 101 other aspects of the viral life cycle. Selective mutation within the PK domain and sequential 102 deletion of PKs confirmed the importance of PK structure and that although genome replication")
   (:latex) (:type . "table"))
  (:+tabref1+
   (:text
    . "Materials and MethodsCells lines.BHK-21 cells obtained from the ATCC (LGC Standard) were maintained in Dulbecco's modified Eagle's Medium with glutamine (Sigma-Aldrich) supplemented with 10 % foetal calf serum (FCS), 50 U/ml penicillin and 50 µg/ml streptomycin.")
   (:latex) (:type . "table"))
  (:+tabref2+
   (:text
    . "Wt, C11, ∆PK 34 and ∆PK 234 constructs all resulted in the production of infectious virus as was expected from the replicon experiments, with no alteration to input sequence. However, the C11 ∆PK 1234, which replicated (albeit to a lesser degree) as a replicon, produced no recoverable infectious virus(Table 1). Interestingly, there were differences noted in both the")
   (:latex) (:type . "table")))
 (:back--matter
  ((:text
    . "author/funder. All rights reserved. No reuse allowed without permission.The copyright holder for this preprint (which was not peer-reviewed) is the The copyright holder for this preprint (which was not peer-reviewed) is the . https://doi.org/10.1101/2020.01.10.901801 doi: bioRxiv preprint")
   (:cite--spans) (:ref--spans) (:section . "annex")))))
