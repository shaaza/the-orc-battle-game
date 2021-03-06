;; Monsters & Monster Methods

;; @func init-monsters
;; @desc Instantiate monster objects with random health etc. based on global variables set.

(defun init-monsters ()
                     (setf *monsters*
                           (map 'vector (lambda (x)
                                                (funcall (nth (random (length *monster-builders*)) *monster-builders*)))
                                        (make-array *monster-num*))))

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
