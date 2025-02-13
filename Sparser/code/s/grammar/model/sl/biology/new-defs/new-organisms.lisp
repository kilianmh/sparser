(in-package :sparser)

;; many things were moved out of bio to mid-level/organisms in 9/2021

;;(def-indiv-with-id organism "strain" "NCIT:C14419" :name "organism strains") use def from taxonomy
;;(def-indiv-with-id organism "prokaryote" "NCIT:C14263" :name "prokaryote") 
;;(def-indiv-with-id organism "eukaryote" "NCIT:C25796" :name "eukaryota")
(def-indiv-with-id eukaryote "protista" "NCIT:C77914" :name "protista") 
(def-indiv-with-id prokaryote "archaea" "NCIT:C61092" :name "archaea") 
;;(def-indiv-with-id organism "amoeba" "NCIT:C119581" :name "amoeba" :plural ("amoebas" "amoebae")) 
(def-indiv-with-id eukaryote "protozoan" "NCIT:C77916" :name "protozoa") 
#| added to mid-level organisms as categories
(def-indiv-with-id organism "Plant" "BTO:0001481" :name "plant") ;; NCIT:C14258
(def-indiv-with-id organism "fungus" "BTO:0001494" :name "fungus" :plural ("fungi"))
(def-indiv-with-id organism "vertebrate" "NCIT:C14282" :name "vertebrate")
(def-indiv-with-id organism "Vertebrata" "NCIT:C14282" :name "vertebrata") 
(def-indiv-with-id organism "Mammalia" "NCIT:C14234" :name "mammalia") 
(def-synonym mammal (:noun "mammalians")) 
|#
(def-indiv-with-id mammal "Carnivora" "NCIT:C79104" :name "carnivora") 
(def-indiv-with-id animal "arthropod" "NCIT:C77917" :name "arthropoda") 
(def-indiv-with-id vertebrate "Amphibia" "NCIT:C14180" :name "amphibia") 
(def-indiv-with-id mammal "mustelid" "NCIT:C77096" :name "mustelidae") ;; should be under carnivvora

#| life-stages moved to mid-level organisms as categories
(def-indiv-with-id insect "larva" "BTO:0000707" :name "larva" :plural ("larvas" "larvae") :adj "larval") 
(def-indiv-with-id animal "juvenile" "BTO:0002168" :name "juvenile") 
(def-indiv-with-id mammal "pup" "BTO:0004377" :name "pup")
(def-indiv-with-id mammal "neonate" "BTO:0001762" :name "neonate") 
|#

#| other organism groupings moved to mid-level
(def-indiv-with-id organism "parasite" "NCIT:C28176" :name "parasite") 
(def-indiv-with-id organism "chimera" "NCIT:C14194" :name "chimera") 
(def-indiv-with-id organism "GMO" "NCIT:C97158" :name "genetically modified organism") 
(def-indiv-with-id organism "MDRO" "NCIT:C111564" :name "multi-drug resistant organism") 
|#
;; I think these are too bio-specific
(def-indiv-with-id organism "mosaicism" "NCIT:C88144" :name "mosaic") 
(def-indiv-with-id organism "recombinants" "NCIT:C14353" :name "recombinants")

#| other organism groupings moved to mid-level
(def-indiv-with-id organism "microbe" "NCIT:C14329" :name "microorganism")
(def-indiv-with-id organism "microbiome" "NCIT:C68564" :name "microbiome") 
(def-indiv-with-id organism "microflora" "NCIT:C93019" :name "intestinal flora") 
(def-indiv-with-id organism "mycobiome" "NCIT:C128180" :name "mycobiome") 
|#

;; rodents etc
#| added to mid-level organisms as category
(def-indiv-with-id organism "rodent" "NCIT:C14270" :name "rodent") |#
(def-indiv-with-id mammal "Rodentia" "NCIT:C14270" :name "rodentia") 

(def-indiv-with-id rodent "Muridae" "NCIT:C14246" :name "muridae") ;; mice, rats, gerbils
(def-indiv-with-id mouse "nude mice" "TI:10090") 
(def-indiv-with-id mouse "transgenic mice" "TI:10090")
(def-indiv-with-id mouse "C57BL" "NCIT:C37375" :name "C57BL mouse") 
(def-indiv-with-id mouse "DBA" "NCIT:C37402" :name "DBA mouse") 
(def-indiv-with-id mouse "FVB" "NCIT:C37406" :name "FVB mouse") 
(def-indiv-with-id mouse "PWK" "NCIT:C37429" :name "PWK mouse") 
(def-indiv-with-id mouse "BALB/c" "NCIT:C37357" :name "BALB/c mouse" :plural "BALB/c mice")
(def-indiv-with-id mouse "B6C3F1" "NCIT:C76182" :name "B6C3 mouse") 
(def-indiv-with-id mouse "ICR" "NCIT:C37408" :name "ICR mouse") 
(def-indiv-with-id mouse "Nus" "NCIT:C14239" :name "nude mouse") 
(def-indiv-with-id mouse "NZW" "NCIT:C37425" :name "NZW mouse") 
(def-indiv-with-id mouse "NZB" "NCIT:C37421" :name "NZB mouse") 
(def-indiv-with-id mouse "NMRI" "NCIT:C37416" :name "NMRI mouse") ;; possibly imaging
(def-indiv-with-id mouse "SWV" "NCIT:C15062" :name "SWV mouse") 
(def-indiv-with-id mouse "SJL" "NCIT:C37437" :name "SJL mouse") 
;(def-indiv-with-id organism "NIH" "NCIT:C14476" :name "NIH mouse") 
(def-indiv-with-id mouse "ddY" "NCIT:C14777" :name "DDY mouse") 
(def-indiv-with-id mouse "C57BLKS" "NCIT:C14545" :name "C57BLKS mouse") 
(def-indiv-with-id mouse "CBA" "NCIT:C37395" :name "CBA mouse") 
(def-indiv-with-id mouse "CD1" "NCIT:C76183" :name "ICR BR mouse") 
(def-indiv-with-id mouse "CF1" "NCIT:C77116" :name "CF-1 mouse") 
(def-indiv-with-id mouse "YBR" "NCIT:C14510" :name "YBR mouse") 
(def-indiv-with-id mouse "SWR" "NCIT:C37443" :name "SWR mouse") 
(def-indiv-with-id mouse "C57Br" "NCIT:C37389" :name "C57BR mouse") 
(noun "iDTR" :super mouse) 

(def-indiv-with-id rat "Sprague-Dawley" "NCIT:C76189" :name "Sprague-Dawley rat" :synonyms ("SD rat strain" "TI:10116"))
(def-indiv-with-id rat "Wistar rat" "TI:10116")
(def-indiv-with-id rat "WIST" "NCIT:C76190" :name "WIST, rat strain") 
(def-indiv-with-id rat "WKY" "NCIT:C76192" :name "WKY rat strain") 
(def-indiv-with-id rat "Lewis" "NCIT:C106538" :name "lewis rat strain") 
(def-indiv-with-id rat "LEW" "NCIT:C106538" :name "lewis, rat strain") 
(def-indiv-with-id rat "shR" "NCIT:C14412" :name "SHR rat strain") 
(def-indiv-with-id rat "Aci" "NCIT:C14392" :name "ACI rat strain") 
(def-indiv-with-id rat "zucker" "NCIT:C76194" :name "Z, rat strain") 
(def-indiv-with-id rat "rnu" "NCIT:C122237" :name "RNU, rat strain") 

#| moved to mid-level:organisms
(def-indiv-with-id organism "guinea pig" "TI:10141")  
(def-indiv-with-id organism "hamster" "NCIT:C14212" :name "hamster") 
(def-indiv-with-id organism "gerbil" "NCIT:C77807" :name "gerbil") 
(def-indiv-with-id organism "woodchuck" "NCIT:C124252" :name "eastern woodchuck") 
|#
(def-indiv-with-id mammal "Chinchillidae" "NCIT:C91814" :name "chinchillidae") 

(def-indiv-with-id mammal "Lagomorpha" "NCIT:C79106" :name "lagomorpha") 
(def-indiv-with-id mammal "bovid" "NCIT:C14323" :name "bovidae")
#| moved to mid-level:organisms
(def-indiv-with-id organism "Rabbit" "NCIT:C14264" :name "rabbit") 
(def-indiv-with-id organism "bovine" "NCIT:C14192" :name "cow") 
(def-indiv-with-id organism "ovine" "NCIT:C14273" :name "sheep")
(def-indiv-with-id organism "equine" "NCIT:C14222" :name "horse") 
(def-indiv-with-id organism "porcine" "NCIT:C14280" :name "pig" :synonyms ("swine"))
|#
(def-indiv-with-id mammal "Landracecross" "NCIT:C77105" :name "landrace pig") 

(def-indiv-with-id mammal "canid" "NCIT:C14331" :name "canidae")
#| moved to mid-level:organisms
(def-indiv-with-id organism "canine" "NCIT:C14201" :name "dog")
(def-indiv-with-id organism "Yorkie" "NCIT:C53946" :name "yorkshire terrier") 
(def-indiv-with-id organism "Doberman" "NCIT:C53767" :name "doberman pinscher") 
(def-indiv-with-id organism "Pekingese" "NCIT:C53940" :name "pekingese") 
(def-indiv-with-id organism "malamute" "NCIT:C53760" :name "alaskan malamute") 
(def-indiv-with-id organism "Rottweiler" "NCIT:C53775" :name "rottweiler") 
(def-indiv-with-id organism "Weimaraner" "NCIT:C53891" :name "weimaraner") 
(def-indiv-with-id organism "coonhound" "NCIT:C53921" :name "black and tan coonhound") 
(def-indiv-with-id organism "papillon" "NCIT:C53939" :name "papillon") 

|#
(def-indiv-with-id mammal "Pon" "NCIT:C54054" :name "polish lowland sheepdog") 

(def-indiv-with-id mammal "Felidae" "NCIT:C14321" :name "felidae") 
(def-indiv-with-id mammal "Felid" "NCIT:C14321" :name "felidae")
#| moved to mid-level:organisms
(def-indiv-with-id organism "feline" "NCIT:C14191" :name "cat")
|#


;; possibly should be location/demonym or other confound
;(def-indiv-with-id fish "Indonesia" "NCIT:C79977" :name "zebrafish line indonesia") 
;(def-indiv-with-id fish "Singapore" "NCIT:C79980" :name "zebrafish line singapore") 
(def-indiv-with-id mammal "Yucatan" "NCIT:C77108" :name "yucatan pig") 
(def-indiv-with-id mammal "Suffolk" "NCIT:C106572" :name "suffolk sheep") 
(def-indiv-with-id mammal "Mongolians" "NCIT:C77100" :name "mongolian gerbil") 
(def-indiv-with-id mammal "Hampshire" "NCIT:C77103" :name "hampshire pig")
(def-indiv-with-id mammal "Gottingen" "NCIT:C77102" :name "gottingen pig" :synonyms ("Göttingen")) 
(def-indiv-with-id mammal "california" "NCIT:C76364" :name "california rabbit") 
;; dog breeds 
(def-indiv-with-id dog "Newfoundland" "NCIT:C53765" :name "newfoundland") 
(def-indiv-with-id dog "Pyrenees" "NCIT:C53766" :name "great pyrenees") 
(def-indiv-with-id dog "Brittany" "NCIT:C53879" :name "brittany spaniel") 
(def-indiv-with-id dog "Chihuahua" "NCIT:C53929" :name "chihuahua") 
(def-indiv-with-id dog "Lab" "NCIT:C53873" :name "labrador retriever")

(def-indiv-with-id fish "Cologne" "NCIT:C79955" :name "cologne zebrafish") 
(def-indiv-with-id fish "Ind" "NCIT:C79976" :name "zebrafish line india") 

#| added to mid-level organisms as category and these monkeys as individuals
(def-indiv-with-id organism "primate" "NCIT:C14262" :name "primate") 
(def-indiv-with-id organism "chimpanzee" "NCIT:C14297" :name "chimpanzee") 
(def-indiv-with-id organism "Cercopithecidae" "NCIT:C161029" :name "old world monkey") 
(def-indiv-with-id organism "Macaca" "NCIT:C14231" :name "macaque" :synonyms ("macacus")) 
(def-indiv-with-id organism "Papio" "NCIT:C14252" :name "baboon") 
|# ;; the monkeys below seemed less relevant
(def-indiv-with-id primate "Cynomolgus" "NCIT:C14232" :name "cynomolgus monkey")
(def-indiv-with-id primate "saimiri" "NCIT:C160934" :name "saimiri") ;; new world monkey


;; category in midlevel
;;(def-indiv-with-id organism "avians" "NCIT:C14189" :name "bird" :adj "avian" :synonyms ("aves")) 
(def-indiv-with-id bird "Quail" "NCIT:C91813" :name "quail") 
(def-indiv-with-id bird "Ross" "NCIT:C77099" :name "ross chicken") 

(def-indiv-with-id fish "SJA" "NCIT:C79981" :name "SJA zebrafish") 
(def-indiv-with-id fish "wik" "NCIT:C79954" :name "WIK zebrafish") 
(def-indiv-with-id fish "Tubingen" "NCIT:C79982" :name "tubingen zebrafish") 

#| moved to midlevel
(def-indiv-with-id organism "Insecta" "NCIT:C14227" :name "insect") ;; category in mid-level
(def-indiv-with-id organism "firefly" "NCIT:C61008" :name "lampyridae") 
(def-indiv-with-id organism "roundworm" "NCIT:C14248" :name "nematode" :synonyms ("nematoda"))  
|#

;; mixed - may include bacteria that should be moved
(def-indiv-with-id organism "Aspergillus" "NCIT:C77180" :name "aspergillus") 
(def-indiv-with-id organism "basidiomycetes" "NCIT:C77169" :name "basidiomycota") 
(def-indiv-with-id organism "Pneumocystis" "NCIT:C124358" :name "pneumocystis") 
(def-indiv-with-id organism "Schizophyllum" "NCIT:C124393" :name "schizophyllum") 
(def-indiv-with-id organism "Fusarium" "NCIT:C77185" :name "fusarium") 
(def-indiv-with-id organism "Monascus" "NCIT:C127295" :name "monascus") 
(def-indiv-with-id organism "Rhizopus" "NCIT:C77196" :name "rhizopus") 
(def-indiv-with-id organism "Leishmania" "NCIT:C123421" :name "leishmania") ;;parasite
(def-indiv-with-id organism "Alternaria" "NCIT:C119320" :name "alternaria") 
(def-indiv-with-id organism "Babesia" "NCIT:C122040" :name "babesia") 
(def-indiv-with-id organism "Candida" "NCIT:C77163" :name "candida") 
(def-indiv-with-id organism "Encephalitozoon" "NCIT:C122293" :name "encephalitozoon") 
(def-indiv-with-id organism "Kluyveromyces" "NCIT:C114123" :name "kluyveromyces") 
(def-indiv-with-id organism "Nosema" "NCIT:C123530" :name "nosema") 
(def-indiv-with-id organism "Strongyloides" "NCIT:C125924" :name "strongyloides") 
(def-indiv-with-id organism "Toxoplasma" "NCIT:C75538" :name "toxoplasma") ;;parasite
(def-indiv-with-id organism "LOA" "NCIT:C123425" :name "loa") 
(def-indiv-with-id organism "Opisthorchis" "NCIT:C124284" :name "opisthorchis") 
(def-indiv-with-id organism "Acanthamoeba" "NCIT:C118934" :name "acanthamoeba") 
(def-indiv-with-id organism "cryptosporidium" "NCIT:C77214" :name "cryptosporidium" :plural ("cryptosporidiums" "cryptosporidia")) 
(def-indiv-with-id organism "Crysptosporidium" "NCIT:C77214" :name "cryptosporidium") 
(def-indiv-with-id organism "Cryptosporidiurn" "NCIT:C77214" :name "cryptosporidium") 
(def-indiv-with-id organism "Cryprosporidiurn" "NCIT:C77214" :name "cryptosporidium") 
(def-indiv-with-id organism "Cryprosporidium" "NCIT:C77214" :name "cryptosporidium") 
(def-indiv-with-id organism "Andromeda" "NCIT:C74316" :name "andromeda") 
(def-indiv-with-id organism "Plasmodium" "NCIT:C98268" :name "plasmodium" :plural ("plasmodium" "plasmodia")) ;;parasite
(def-indiv-with-id organism "helminth" "NCIT:C125642" :name "helminth" :plural ("helminthes")) ;;parasite
(def-indiv-with-id organism "Boswellia" "NCIT:C54081" :name "boswellia serrata") 
(def-indiv-with-id organism "SUS" "NCIT:C160990" :name "sus") 
(def-indiv-with-id organism "Chlorocebus" "NCIT:C161031" :name "chlorocebus") 
(def-indiv-with-id organism "Cladosporium" "NCIT:C122261" :name "cladosporium") 
(def-indiv-with-id organism "Echinococcus" "NCIT:C122025" :name "echinococcus") 
(def-indiv-with-id organism "Entamoeba" "NCIT:C122048" :name "entamoeba") 
(def-indiv-with-id organism "Erythrocebus" "NCIT:C161036" :name "erythrocebus") 
(def-indiv-with-id organism "Fasciola" "NCIT:C122021" :name "fasciola") 
(def-indiv-with-id organism "Giardia" "NCIT:C77213" :name "giardia") 
(def-indiv-with-id organism "Mansonella" "NCIT:C118942" :name "mansonella") 
(def-indiv-with-id organism "Onchocerca" "NCIT:C124282" :name "onchocerca") 
(def-indiv-with-id organism "Penicillium" "NCIT:C123540" :name "penicillium") 
(def-indiv-with-id organism "Pichia" "NCIT:C123544" :name "pichia") 
(def-indiv-with-id organism "Solanum" "NCIT:C72445" :name "solanum nigrum") 
(def-indiv-with-id organism "Suid" "NCIT:C14322" :name "suidae") 
(def-indiv-with-id organism "Taenia" "NCIT:C125925" :name "taenia") 
(def-indiv-with-id organism "Trichinella" "NCIT:C125928" :name "trichinella") 
(def-indiv-with-id plant "ViteX" "NCIT:C72243" :name "angus castus") 
(def-indiv-with-id organism "Wuchereria" "NCIT:C122013" :name "wuchereria")
(def-indiv-with-id organism "yohimbe" "NCIT:C93306" :name "pausinystalia yohimbe") 
(def-indiv-with-id organism "cricetid" "NCIT:C79741" :name "cricetidae") 
(def-indiv-with-id organism "gliocladium" "NCIT:C122317" :name "gliocladium") 
(def-indiv-with-id organism "poikilotherms" "NCIT:C14320" :name "poikilotherms") 
(def-indiv-with-id organism "Equidae" "NCIT:C14313" :name "equidae") 
(def-indiv-with-id organism "Cestoda" "NCIT:C122045" :name "cestoda") 
(def-indiv-with-id organism "Euphrasia" "NCIT:C74309" :name "euphrasia stricta") 
(def-indiv-with-id organism "Chrysosporium" "NCIT:C122260" :name "chrysosporium") 
(def-indiv-with-id organism "Hansenula" "NCIT:C123544" :name "pichia") 
(def-indiv-with-id organism "Yarrowia" "NCIT:C114124" :name "yarrowia") 
(def-indiv-with-id organism "Crypto" "NCIT:C14195" :name "cryptococcus neoformans") 
(def-indiv-with-id organism "Madurella" "NCIT:C127291" :name "madurella") 
(def-indiv-with-id organism "Trematosphaeria" "NCIT:C127303" :name "trematosphaeria") 
(def-indiv-with-id organism "Caviidae" "NCIT:C79103" :name "caviidae") 
(def-indiv-with-id organism "Naegleria" "NCIT:C123422" :name "naegleria") 
(def-indiv-with-id organism "Ascomycetes" "NCIT:C77167" :name "ascomycota") 
(def-indiv-with-id organism "Verticillium" "NCIT:C125983" :name "verticillium") 
(def-indiv-with-id organism "Cynara" "NCIT:C72295" :name "cynara scolymus") 
(def-indiv-with-id organism "Chaetomium" "NCIT:C122258" :name "chaetomium") 
(def-indiv-with-id organism "Eurotium" "NCIT:C127282" :name "eurotium") 
(def-indiv-with-id organism "Ailanthus" "NCIT:C72232" :name "ailanthus altissima") 
(def-indiv-with-id organism "Anisakis" "NCIT:C122043" :name "anisakis") 
(def-indiv-with-id organism "Nigrospora" "NCIT:C123529" :name "nigrospora") 
(def-indiv-with-id organism "Dipetalonema" "NCIT:C122283" :name "dipetalonema") 
(def-indiv-with-id organism "Nimba" "NCIT:C72259" :name "azadirachta indica") 
(def-indiv-with-id organism "Epidermophyton" "NCIT:C127281" :name "epidermophyton") 
(def-indiv-with-id organism "Magnusiomyces" "NCIT:C114126" :name "magnusiomyces") 
(def-indiv-with-id organism "Trypanosome" "NCIT:C125931" :name "trypanosoma") 
(def-indiv-with-id organism "Arthrographis" "NCIT:C139106" :name "arthrographis") 
(def-indiv-with-id organism "Paecilomyces" "NCIT:C123532" :name "paecilomyces") 
(def-indiv-with-id organism "Curvularia" "NCIT:C122277" :name "curvularia") 
(def-indiv-with-id organism "Cyperus" "NCIT:C72504" :name "cyperus esculentus") 
(def-indiv-with-id organism "Epicoccum" "NCIT:C122304" :name "epicoccum") 
(def-indiv-with-id organism "Amoebozoa" "NCIT:C118932" :name "amoebozoa") 
(def-indiv-with-id organism "Hymenolepis" "NCIT:C124278" :name "hymenolepis") 
(def-indiv-with-id organism "Dracunculus" "NCIT:C122011" :name "dracunculus") 
(def-indiv-with-id organism "Balamuthia" "NCIT:C122041" :name "balamuthia") 
(def-indiv-with-id organism "Ulocladium" "NCIT:C125978" :name "ulocladium") 
(def-indiv-with-id organism "Acremonium" "NCIT:C118935" :name "acremonium") 
(def-indiv-with-id organism "Arthroderma" "NCIT:C127273" :name "arthroderma") 
(def-indiv-with-id organism "Cyclospora" "NCIT:C122047" :name "cyclospora") 
(def-indiv-with-id organism "Dientamoeba" "NCIT:C122010" :name "dientamoeba") 
(def-indiv-with-id organism "Exophiala" "NCIT:C127283" :name "exophiala") 
(def-indiv-with-id organism "Fonsecaea" "NCIT:C122311" :name "fonsecaea") 
(def-indiv-with-id organism "Scedosporium" "NCIT:C127297" :name "scedosporium") 
(def-indiv-with-id organism "Althea" "NCIT:C65227" :name "althea officinalis") 
(def-indiv-with-id organism "Geomyces" "NCIT:C122314" :name "geomyces") 
(def-indiv-with-id organism "Akebia" "NCIT:C72486" :name "akebia X pentaphylla") 
(def-indiv-with-id organism "Ocimum" "NCIT:C73979" :name "ocimum basilicum") 
(def-indiv-with-id organism "Taraxacum" "NCIT:C73951" :name "taraxacum officinale") 
(def-indiv-with-id organism "Tamarindus" "NCIT:C74506" :name "tamarindus indica") 
(def-indiv-with-id organism "Trichosporon" "NCIT:C114129" :name "trichosporon") 
(def-indiv-with-id organism "Diptera" "NCIT:C14197" :name "diptera") 
(def-indiv-with-id organism "Platyhelminthes" "NCIT:C122024" :name "platyhelminthes") 
(def-indiv-with-id organism "Enterobius" "NCIT:C122012" :name "enterobius") 
(def-indiv-with-id organism "Grindelia" "NCIT:C72515" :name "grindelia lanceolata") 
(def-indiv-with-id organism "Perissodactyla" "NCIT:C79107" :name "perissodactyla") 
(def-indiv-with-id organism "Trichoderma" "NCIT:C125966" :name "trichoderma") 
(def-indiv-with-id organism "Lamiaceae" "NCIT:C86564" :name "lamiaceae") 
(def-indiv-with-id organism "Pelargonium" "NCIT:C93332" :name "pelargonium graveolens") 
(def-indiv-with-id organism "Cricetidae" "NCIT:C79741" :name "cricetidae") 
(def-indiv-with-id organism "Absidia" "NCIT:C119580" :name "absidia") 
(def-indiv-with-id organism "Leporidae" "NCIT:C14358" :name "leporidae") 
(def-indiv-with-id organism "Mucorales" "NCIT:C125637" :name "mucorales") 
(def-indiv-with-id organism "Angiostrongylus" "NCIT:C122042" :name "angiostrongylus") 
(def-indiv-with-id organism "Capillaria" "NCIT:C122044" :name "capillaria") 
(def-indiv-with-id organism "Hypericum" "NCIT:C72523" :name "hypericum erectum") 
(def-indiv-with-id organism "Mesocricetus" "NCIT:C14212" :name "hamster") ;;genus
(def-indiv-with-id organism "Nadia" "NCIT:C79957" :name "nadia zebrafish") 
(def-indiv-with-id organism "Panax" "NCIT:C91401" :name "ginseng") ;; genus
(def-indiv-with-id organism "Sarcocystis" "NCIT:C124286" :name "sarcocystis") 
(def-indiv-with-id organism "Mucor" "NCIT:C120708" :name "mucor") 
(def-indiv-with-id organism "Balantidium" "NCIT:C122015" :name "balantidium") 
(def-indiv-with-id organism "Blastocystis" "NCIT:C122016" :name "blastocystis") 
(def-indiv-with-id organism "Enterocytozoon" "NCIT:C122302" :name "enterocytozoon") 
(def-indiv-with-id organism "Trichostrongylus" "NCIT:C125930" :name "trichostrongylus") 
(def-indiv-with-id organism "Ascaris" "NCIT:C122014" :name "ascaris") 
(def-indiv-with-id organism "Apophysomyces" "NCIT:C127271" :name "apophysomyces") 
(def-indiv-with-id organism "Artiodactyla" "NCIT:C79105" :name "artiodactyla") 
(def-indiv-with-id organism "Ascomycota" "NCIT:C77167" :name "ascomycota") 
(def-indiv-with-id organism "Aureobasidium" "NCIT:C127275" :name "aureobasidium") 
(def-indiv-with-id organism "Bipolaris" "NCIT:C122250" :name "bipolaris") 
(def-indiv-with-id organism "Chlorophyta" "NCIT:C114082" :name "chlorophyta") 
(def-indiv-with-id organism "Cocksfoot" "NCIT:C72299" :name "dactylis glomerata") 
(def-indiv-with-id organism "Cystoisospora" "NCIT:C123419" :name "cystoisospora") 
(def-indiv-with-id organism "Exserohilum" "NCIT:C122306" :name "exserohilum") 
(def-indiv-with-id organism "Histoplasma" "NCIT:C86075" :name "histoplasma") 
(def-indiv-with-id organism "Malassezia" "NCIT:C127292" :name "malassezia") 
(def-indiv-with-id organism "Mucoromycotina" "NCIT:C120539" :name "mucoromycotina") 
(def-indiv-with-id organism "Oryctolagus" "NCIT:C161040" :name "oryctolagus") 
(def-indiv-with-id organism "Rhodotorula" "NCIT:C124370" :name "rhodotorula") 
(def-indiv-with-id organism "Sporothrix" "NCIT:C127301" :name "sporothrix") 
(def-indiv-with-id organism "Trichomonas" "NCIT:C89825" :name "trichomonas") 
(def-indiv-with-id organism "Trichophyton" "NCIT:C127305" :name "trichophyton") 
(def-indiv-with-id organism "Trichuris" "NCIT:C125929" :name "trichuris") 
(def-indiv-with-id organism "Wickerhamomyces" "NCIT:C114125" :name "wickerhamomyces") 
(def-indiv-with-id organism "Isospora" "NCIT:C122325" :name "isospora") 
(def-indiv-with-id organism "Toxocara" "NCIT:C125927" :name "toxocara") 
(def-indiv-with-id organism "Dactylaria" "NCIT:C86061" :name "dactylaria") 
(def-indiv-with-id organism "Geotrichum" "NCIT:C122315" :name "geotrichum") 
(def-indiv-with-id organism "Phialophora" "NCIT:C123543" :name "phialophora") 
(def-indiv-with-id organism "Pleistophora" "NCIT:C124357" :name "pleistophora") 
(def-indiv-with-id organism "Syncephalastrum" "NCIT:C125959" :name "syncephalastrum") 
(def-indiv-with-id organism "Zygomycetes" "NCIT:C77194" :name "zygomycota")

(def-indiv-with-id organism "microspora" "NCIT:C123335" :name "microsporidia") ;; any spore forming ffungus
(def-indiv-with-id organism "Microsporum" "NCIT:C127294" :name "microsporum") ;; fungus genus including ringworm


;; plants moved to midlevel
#|(def-indiv-with-id organism "liverwort" "NCIT:C72334" :name "hepatica triloba") 
(def-indiv-with-id organism "Scutellaria" "NCIT:C74304" :name "scutellaria") 
(def-indiv-with-id organism "aloe" "NCIT:C65225" :name "aloe vera") 
(def-indiv-with-id organism "allium" "NCIT:C73974" :name "allium") 
(def-indiv-with-id organism "ginseng" "NCIT:C91401" :name "ginseng plant") 
(def-indiv-with-id organism "echinacea" "NCIT:C54160" :name "echinacea") 
(def-indiv-with-id organism "crampbark" "NCIT:C72466" :name "viburnum opulus") 
(def-indiv-with-id organism "figwort" "NCIT:C72438" :name "scrophularia nodosa") 
(def-indiv-with-id organism "ribgrass" "NCIT:C72477" :name "plantago lanceolata") 
(def-indiv-with-id organism "spurges" "NCIT:C72508" :name "euphorbia kansui") 
(def-indiv-with-id organism "mugwort" "NCIT:C72251" :name "artemisia vulgaris") 
(def-indiv-with-id organism "knotgrass" "NCIT:C74495" :name "paspalum distichum") 
(def-indiv-with-id organism "neem" "NCIT:C72259" :name "azadirachta indica") 
(def-indiv-with-id organism "bergamot" "NCIT:C72537" :name "monarda didyma") 
(def-indiv-with-id organism "coneflower" "NCIT:C54160" :name "echinacea") 
(def-indiv-with-id organism "lappa" "NCIT:C74313" :name "arctium lappa") 
(def-indiv-with-id organism "Citronella" "NCIT:C72498" :name "collinsonia canadensis") 
(def-indiv-with-id organism "Catnip" "NCIT:C73978" :name "nepeta cataria") 
(def-indiv-with-id organism "Juniperus" "NCIT:C74315" :name "juniperus communis") 
(def-indiv-with-id organism "Kudzu" "NCIT:C73971" :name "pueraria montana var. lobata") 
(def-indiv-with-id organism "Pueraria" "NCIT:C73971" :name "pueraria montana var. lobata") 
(def-indiv-with-id organism "Ginkgo" "NCIT:C93305" :name "ginkgo biloba")
(def-indiv-with-id organism "JASMINE" "NCIT:C73955" :name "jasminum officinale") 
|#
