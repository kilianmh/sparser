;;; -*- Mode:LISP; Syntax:Common-Lisp; Package:SPARSER -*-
;;; copyright (c) 2022 David D. McDonald  -- all rights reserved
;;;
;;;     File:  "eci-categories"
;;;   Module:  "model;core:kinds:"
;;;  version:  July 2022

;; Initiated 6/10/22 to fold in useful conceptualizations from
;; when we developed the ECIs. Closely parallels TRIPS taxonomy.

(in-package :sparser)

(defun eci-categories () t) ; for meta-dot


#| In processes.lisp we have the mixins
    takes-tense-aspect-modal and
    temporally-localized

 Perdurant also mixes in takes-adverb and has-location
 
 Its specialization are
   state
   process
     transition
     accomplishment

Instead of 'event' we'll start with either state or process, copied
here from processes.lisp

(define-category state
  :specializes perdurant
  :lemma (:common-noun "state")
  :documentation 
  "A state is a period during which some some condition remains constant.
 An event analysis (Dowty, Bach, Pustejovsky) would say that it is
 a single event. Nothing happens in a State. It does not cause anything
 to change state (as in the 'state' of an FSA).")

(define-category process
  :specializes perdurant
  :lemma (:common-noun "process")
  :documentation
  "A process involves a change over time. It will decompose into a
 sequence of smaller events that that can be given the same
 description: 'the flow of Mississippi river', 'my life, 'your reading
 this documentation'.")

|#


;;--- event-of-state

#|  + 2 event-of-state
      + 3 cognitive-state
        + 4 awareness
          + 5 believe
            + 6 know
          + 5 understand
        + 4 perceive
          + 5 perceive-taste
          + 5 perceive-smell
          + 5 perceive-sound
          + 5 perceive-by-touch
          + 5 perceive-sight
      + 3 emit
        + 4 emit-substance
        + 4 emit-smell
        + 4 emit-light
        + 4 emit-sound  |#

(define-category event-of-state
  :specializes state
  :documentation 
   ":args  ((@theme :isa entity)  ;; trips neutral role
           (@state :isa state-description) ;; trips formal role
           (@pivot :isa entity)) ;; trips also has norole (optional) ")


(define-category event-of-association
  :specializes event-of-state
  :documentation "Called 'relate' in TRIPS, with words like 'relate',
 'pertain' and 'associate'.")


(define-category event-of-experience
  :specializes event-of-state
  :documentation "From TRIPS for 'experience' -- cross-cuts what's
 in our ecis, but adds options that capture passive, done-to cases.")

(define-category have-experience
  :specializes event-of-experience
  :documentation "When you're exposed to something. Music, aromas,
 new kinds of sensations or activities, but alway as an experiencer
 not as an agent.")


;; TRIPS: event-of-state > position > be-at -- "located"
(define-category positioned ; 'position' is already very overloaded, and in PCT
  :specializes event-of-state
  :documentation "From TRIPS: These are stative predicates indicating
 the position of an object with respect to another. They also typically
 allow a causal variant where an agent causes this position (see ont::cause-position),n
 with examples 'mirror', 'settle'")

(define-category be-at
  :specializes positioned
  :documentation "tailored copula for locations. ///should unify this
 notion semantically with the earlier treatments of 'there' (in syntax/be)
 and make-copular-predication (in syntax/copulars).")


(define-category event-as-situation
  :specializes event-of-state
  :documentation "Tries to make sense of TRIPS event-type, which is a
 peer of event-of-state there. Given the sorts of things it dominates
 (order-tranquility, trouble, lack) I'm inclined to think of it as a very
 expansive state. The sort you'd assign to a large social thing like NYC
 as use to make pronouncements about haw things are going.")

(define-category troubled-situation
  :specializes event-as-situation
  :documentation "In the TRIPS synset for ont::trouble: concern, damage,
 danger, difficulty, distress, mess, problem, risk, shame, tragedy, trouble,
 turmoil. This is 'there's trouble in River City' (Music Man) sort of trouble.")



;;---------- event of change

(define-category event-of-change
  :specializes process
  :documentation 
   ":args ((@agent :isa entity) ;; animate or not, physical or not
          (@patient :isa entity)  ;; trips affected
          (@beneficiary :isa entity)
         (@result-state :isa state-description)) ;; trips result ")

#|  + 2 event-of-change
      + 3 transfer
        + 4 transfer-possession
        + 4 transfer-information
          + 5 communicate
            + 6 identify
            + 6 answer
              + 7 counter-propose
              + 7 reject
              + 7 accept
              + 7 disconfirm
              + 7 confirm
            + 6 ask
            + 6 tell
              + 7 action-discussion
                + 8 propose
                  + 9 suggest
                  + 9 instruct
        + 4 transfer-location
          + 5 move-self
          + 5 move
            + 6 give
            + 6 put
        + 4 transfer-to
          + 5 receive
        + 4 transfer-from |#

(define-category transfer-generic ; leave 'transfer' for the verb
  :specializes event-of-change
  :mixins (with-agent with-theme with-source with-goal)
  :documentation
    "generalized transfer of location, possesion of entities or ideas
    :properties (:trips ont::transfer)
    :args ((@theme)
           (@source)
           (@result) ;; affected-result
           (@path_rel :isa predicate))
    :const
     ((:holds-in @start-e (@path_rel @source @theme))
      (:holds-in @e (transfering :theme @theme))
      (:holds-in @end-e (@path_rel @result @theme)))  ")

#|  + 2 event-of-change
      + 3 cognitive-event
        + 4 acquire-belief
          + 5 become-aware
          + 5 learn
          + 5 active-perception
            + 6 assess
              + 7 contrast
            + 6 find
            + 6 search
        + 4 cogitation
          + 5 forget
          + 5 remember
          + 5 deduce
          + 5 evaluate
            + 6 compare
              + 7 measure
      + 3 transformation
        + 4 life-process
          + 5 die
          + 5 live
          + 5 be-born 
   |#

(define-category transformation
  :specializes event-of-change
  :documentation "change to type or view of entity
    :properties (:trips ont::transformation) ")

(define-category successive-changes
  :specializes transformation
  :documentation "The canonical transformation is the different stages
 (steps, roles) in life. But there are many more kinds of things
 that undergo named changes: tadpole to frog, freshman to sophomore.
 This is usually a progression that we could explicitly order and
 model, and it can be interrupted, resumed, etc.")  

(define-category life-process
  :specializes successive-changes
  :documentation "The stages and normal events from birth to death.
 Their names will have different form depending on the perspective
 being taken. Roles: 'teenager', attributes: 'teenage (years)'.
 /// It would be nice to be explicit about these.")


;;-------- communicate
#|
    + 2 event-of-change
      + 3 transfer
        + 4 transfer-possession
        + 4 transfer-information
          + 5 communicate
            + 6 identify
            + 6 answer
              + 7 counter-propose
              + 7 reject
              + 7 accept
              + 7 disconfirm
              + 7 confirm
            + 6 ask
            + 6 tell
              + 7 action-discussion
                + 8 propose
                  + 9 suggest
                  + 9 instruct
|#

(define-category transfer-something ; 'transfer'
    :specializes event-of-change)

(define-category transfer-information
    :specializes transfer-something)

(define-category communicate-information ; avoid the verb
    :specializes transfer-information )




;;---- events of action

(define-category event-of-action
  :specializes event-of-change
  :documentation 
   " 'agent does process of performing an action
    :args ((@agent :isa animate)) ")

#|
    + 2 event-of-change
      + 3 event-of-action
        + 4 change
          + 5 destroy                                                                                                                                                                                                                                                                                                                                                                                                                                                                        + 5 destroy
            + 6 kill
          + 5 degrade
            + 6 damage
            + 6 pierce
            + 6 cut
            + 6 remove
              + 7 separate
          + 5 augment
            + 6 absorb
            + 6 add
              + 7 join
            + 6 combine
              + 7 mix
          + 5 create
            + 6 create-image
            + 6 build
            + 6 create-by-forming
            + 6 create-entity

|#

(define-category acting
  :specializes event-of-action
  :documentation "From TRIPS, with synonyms 'act', 'behave', 'do', 'perform'")


(define-category event-of-causation
  :specializes event-of-action
  :documentation "agent performs an action that causes a result")

(define-category acquire-something
  :specializes event-of-causation
  :documentation "to come into possession or awareness of something.
 In TRIPS +intentional and +tangible. Synonyms: pick_up, access, acquire,
 acquisition, cadge, download, fetch, gain, get, grab, obtain, procure,
 recover, regain, score, take, trap, win .")  


(define-category inhibit-effect
  :specializes event-of-causation
  :documentation "agent's action inhibits or prevents a result
 Synonyms from TRIPS:
  abort, adjourn, arrest, break, burn out, cease, cut off, end, exit, expire,
  give up, halt, interrupt, kill, lapse, put out, quelch, quit, sever,
  stop, suspend, terminate, wear off  ")

;; change
;; create -- verb in bio;general-verbs
;; augment

;;--- event-of-causation --> motion

(define-category motion
  :specializes event-of-causation
  :documentation "This is TRIPS placement of motion. Our ECIs put under
 event-of-action. Like it here -- 'cause to move'. This coordinates with
 the definition of 'move' in kinds/movement.lisp and the movement verb
 generator in places/moving.lisp
   (def-eci motion (event-of-action)
    :comment 'event of moving through some space (physical or abstract).'
    :properties (:trips ont::motion :vn motion-51*))  ")

(define-category disperse-generic
  :specializes motion
  :documentation "For disceminate, disperse, proliferate(?), scatter, spread, strew")

(define-category place-in-position
  :specializes motion
  :documentation "This is the source for 'put', 'place'. Move something to
 a new position")



;;--- agent-interaction-ecis

  #|  + 3 event-of-action
        + 4 co-occuring-events
          + 5 agent-interaction
            + 6 associate
            + 6 disengagement
            + 6 engagement
            + 6 judgement
            + 6 collaborate  |#
         
(define-category co-occuring-events
  :specializes event-of-action
  :documentation "events involving multiple agents acting at approximately
    the same time
    args: ((@agent1 :isa animate)) ")

(define-category agent-interaction
  :specializes co-occuring-events
  :documentation "activity that involves two or more agents
  :properties (:trips ont::agent-interaction
               :vn (correspond-36.1.1 meet-36.2 battle-36.4 interact-36.6))
  :args ((@theme :isa description) ;; formal
         (@agent1 :isa animate)) ;; agent1 ")








;;--- cognitive-event-ecis

(define-category cognitive-event
  :specializes event-of-change
  :documentation "Event involving changing mental state or awareness
    :properties (:trips ont::event-of-awareness)
    ;; (:essential ont::formal ((? cau4 f::situation f::abstr-obj)))
    :args ((@topic :isa state-description)) ;; trips formal role
       before 10/4/18 the argument was theme ")


(define-category cogitation  ;; thinking ?
  :specializes cognitive-event
  :documentation "event involving changing mental state or awareness
    :properties (:trips ont::cogitation :vn consider-29.9)
    :args ((@theme :isa description))) ;; trips formal role ")


