;;; Variables
;; Player State
(defparameter *player-health* nil)
(defparameter *player-strength* nil)
(defparameter *player-agility* nil)

;; Monsters

(defparameter *monsters* nil)
(defparameter *monster-builders* nil)
(defparameter *monster-num* 12)

;;;; Orc-battle: The top level function that initiates and starts a game

(defun orc-battle ()
                  (init-player)
                  (init-monsters)
                  (game-loop)
                  (when (player-dead) 
                        (princ "You were killed by the orcs. Game over!"))
                  (when (monsters-dead)
                        (princ "Congratulations Commodore! You have vanquished all your foes!")))

;;; init-player: Set player state variables to maximum

(defun init-player ()
                   (setf *player-health* 30)
                   (setf *player-strength* 30)
                   (setf *player-agility* 30))

;;; init-monsters

(defun init-monsters ()
                     (setf *monsters* 
                           (map 'vector (lambda (x)
                                                (funcall (nth (random (length *monster-builders*)) *monster-builders*)))
                                        (make-array *monster-num*)))) 
                                

;;; Game REPL: the loop

(defun game-loop ()
                 (unless (or (player-dead) (monsters-dead))
                         (show-player)
                         (dotimes (k (1+ (truncate (/ (max 0 *player-agility*) 15))))
                                  (unless (monsters-dead)
                                          (show-monsters)
                                          (player-attack)))
                         (fresh-line)
                         (map 'list (lambda (m)
                                            (or (monster-dead m) (monster-attack m)))
                                    *monsters*)
                         (game-loop)))
                                      


;;; game-loop dependencies
;;; Player Managaement

;; player-dead
(defun player-dead ()
                   (<= *player-health* 0))

;; show-player

(defun show-player ()
                   (fresh-line)
                   (princ "You are a valiant knight with a health of ")
                   (princ *player-health*)
                   (princ ", agility ")
                   (princ *player-agility*)
                   (princ ", and strength ")
                   (princ *player-strength*)
                   (princ "."))

;; player-attack

(defun player-attack ()
                     (fresh-line)
                     (princ "Attack style: [s]tab, [d]ouble swing, [r]oundhouse:")
                     (case (read)
                           (s (monster-hit (pick-monster) (+ 2 (randval (ash *player-strength* -1)))))
                           (d (let ((x (randval (truncate (/ *player-strength* 6)))))
                                   (princ "Your double swing has a strength of ")
                                   (princ x)
                                   (fresh-line)
                                   (monster-hit (pick-monster) x)
                                   (unless (monsters-dead)
                                           (monster-hit (pick-monster) x))))
                           (otherwise (dotimes (x (1+ (randval (truncate (/ *player-strength* 3)))))
                                               (unless (monsters-dead)
                                                       (monster-hit (random-monster) 1))))))


; player-attack helper functions
; randval
(defun randval (n)
               (1+ (random (max 1 n))))

; random-monster
(defun random-monster ()
                      (let ((m (aref *monsters* (random (length *monsters*)))))
                           (if (monster-dead m)
                               (random-monster)
                               m)))
; pick-monster

(defun pick-monster ()
                    (fresh-line)
                    (princ "Monster #: ")
                    (let ((x (read)))
                         (if (not (and (integerp x) (>= x 1) (<= x *monster-num*)))
                             (progn (princ "That is a not a valid monster.") 
                                    (pick-monster))
                             (let ((m (aref *monsters* (1- x))))
                                  (if (monster-dead m)
                                      (progn (princ "That monster is already dead. Pick another one.")
                                             (pick-monster))
                                      m)))))
       
;;; Monster Management

;; monsters-dead
(defun monster-dead (m)
                    (<= (monster-health m) 0))

(defun monsters-dead ()
                     (every #'monster-dead *monsters*)) 
 
;; show-monsters

(defun show-monsters ()
                     (fresh-line)
                     (princ "Your foes: ")
                     (let ((x 0))
                          (map 'list 
                               (lambda (m)
                                       (fresh-line)
                                       (princ "  ")
                                       (princ (incf x))
                                       (princ ".")
                                       (if (monster-dead m)
                                           (princ "**dead**")
                                           (progn (princ "(Health = ")
                                                  (princ (monster-health m))
                                                  (princ " )")
                                                  (monster-show m))))
                               *monsters*)))
                                        
;; Monster Structure
;; Generic Monster Structure
(defstruct monster (health (randval 10)))

;; Orcs

(defstruct (orc (:include monster)) (club-level (randval 8)))
(push #'make-orc *monster-builders*)

; Orc specific monster-show

(defmethod monster-show ((m orc))
                        (princ "A wicked orc with a level ")
                        (princ (orc-club-level m))
                        (princ " club. "))

; Orc specific monster-attack

(defmethod monster-attack ((m orc))
                          (let ((x (randval (orc-club-level m))))
                               (princ "An orc swings his club and knocks off ")
                               (princ x)
                               (princ " points of your health. ")
                               (decf *player-health* x)))

;; Hydra

(defstruct (hydra (:include monster)))
(push #'make-hydra *monster-builders*)

; Hydra-specific monster-show

(defmethod monster-show ((m hydra))
                        (princ "A malicious hydra with ")
                        (princ (monster-health m))
                        (princ " heads. "))
                       
; Hydra-specific monster-hit

(defmethod monster-hit ((m hydra) x)
                       (decf (monster-health m) x)
                       (if (monster-dead m)
                           (princ "The corpse of the fully decapitated and decapacitated hydra falls to the ground! ")
                           (progn (princ "You lop off ")
                                  (princ x)
                                  (princ " of the hydra's heads! "))))
                                  
                                  

; Hydra-specific monster-attack 

(defmethod monster-attack ((m hydra))
                          (let ((x (randval (ash (monster-health m) -1))))
                               (princ "A hydra attacks you with ")
                               (princ x)
                               (princ " of its heads. ")
                               (decf *player-health* x)
                               (incf (monster-health m))))
           
;; Slime Mold

(defstruct (slime-mold (:include monster)) (sliminess (randval 5)))
(push #'make-slime-mold *monster-builders*)

; Slime-Mold Specific monster-show

(defmethod monster-show ((m slime-mold))
                          (princ "A slimy slime-mold with a sliminess of ")
                          (princ (slime-mold-sliminess m))
                          (princ ". "))

; Slime-Mold Specific monster-attack

(defmethod monster-attack ((m slime-mold))
                          (let ((x (randval (slime-mold-sliminess m))))
                               (princ "A slime-mold wraps around your legs and decreases your agility by ")
                               (princ x)
                               (princ " points. ")
                               (decf *player-agility* x)
                               (when (zerop (random 2))
                                     (princ "It also squirts in your face, and takes away a health point. ")
                                     (decf *player-health*))))                                     
                          

;; Brigand

(defstruct (brigand (:include monster)))
(push #'make-brigand *monster-builders*)

; Brigand specific monster-attack

(defmethod monster-attack ((m brigand))
                          (let ((x (max *player-health* *player-agility* *player-strength*)))
                               (cond ((= x *player-health*)
                                      (princ "A brigand hits you with his slingshot and takes away 2 of your health points. ")
                                      (decf *player-health* 2))
                     
                                     ((= x *player-agility*)
                                      (princ "A brigand hits your leg with his whip and takes away 2 of your agility points. ")
                                      (decf *player-agility* 2))
                                    
                                     ((= x *player-strength*)
                                      (princ "A brigand cuts your arm with his whip and takes away 2 of your strength points. ")
                                      (decf *player-strength* 2)))))

;; Generic Monster Functions

; monster-hit

(defmethod monster-hit (m x)
                       (decf (monster-health m) x)
                       (if (monster-dead m)
                           (progn (princ "You killed the ")
                                  (princ (type-of m))
                                  (princ "! "))
                           (progn (princ "You hit the ")
                                  (princ (type-of m))
                                  (princ ", knocking off ")
                                  (princ x)
                                  (princ " health points. "))))

; monster-show

(defmethod monster-show (m)
                        (princ "A fierce ")
                        (princ (type-of m))
                        (princ ". "))

; monster-attack

(defmethod monster-attack (m))
                          