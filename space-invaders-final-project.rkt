;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-final-project) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 3)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 20)
(define MAX-INVADER-SPEED 3)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))

(define TANK-Y (- HEIGHT 20)) 





;; Data Definitions:

(define-struct game (invaders missiles tank clock))
;; Game is (make-game  (listof Invader) (listof Missile) Tank InvaderClock)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))
       (fn-for-clock (game-clock s))))

;; InvaderClock is Integer[0, INVADE-RATE]
;; interp, # of times tock has run since last resetting.

(define C1 0) ;start
(define C2 (/ INVADE-RATE 2)) ; middle
(define C3 INVADE-RATE) ; end

#;
(define (fn-for-invaderclock c)
  (... ic))

;; template rules used:
;; - atomic non-distinct: Integer [0, INVADE-RATE]



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1


(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))

;;ListOfInvaders is one of:
;; - empty
;; - (cons Invader ListOfInvaders)
;; interp. a list of invaders

(define LOI-1 empty)
(define LOI-2 (list I1))
(define LOI-3 (list I1 I2 I3))

#;
(define (fn-for-LOI loi)
  (cond [(empty? loi) (...)]
        [else (... (fn-for-invader (first loi))
                   (fn-for-LOI (rest loi)))]))

;; Template rules used:
;; - one of: 2 cases
;; - atomic distinct: empty
;; - compound: (cons Invader ListOfInvaders)
;; - Mutual reference: first lom is Invader
;; - self reference: rest lom is ListOfInvaders


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))

;;ListOfMissiles is one of:
;; - empty
;; - (cons Missile ListOfMissiles)
;; interp. a list of missiles.

(define LOM-1 empty)
(define LOM-2 (list M1 M2))
(define LOM-3 (list M1 M2 M3))

#;
(define (fn-for-LOM lom)
  (cond [(empty? lom) (...)]
        [else (... (fn-for-missile (first lom))
                   (fn-for-LOM (rest lom)))]))

;; Template rules used:
;; - one of: 2 cases
;; - atomic distinct: empty
;; - compound: (cons Missile ListOfMissiles)
;; - Mutual reference: first lom is Missile
;; - self reference: rest lom is ListOfMissiles


(define G0 (make-game empty empty T0 0))
(define G1 (make-game empty empty T1 0))
(define G2 (make-game (list I1) (list M1) T1 0))
(define G3 (make-game (list I1 I2) (list M1 M2) T1 0))

;; =================
;; Functions:

;; game -> game
;; start the world with G0
;; 
(define (main g)
  (big-bang g                   ; game
    (on-tick   tock)     ; game -> game
    (to-draw   render)   ; game -> Image
    (stop-when end-game)      ; game -> Boolean
    (on-key    key-handler)))    ; game KeyEvent -> game

;; Game -> Game
;; Advance missiles, tank and invaders.
;; Advance the invasion counter, if counter is equivalent to the invasion rate, add a new invader to listof Invader and reset counter to zero.
;; if any missiles are colliding with invaders, remove from the list).
;;(define (tock g) (make-game empty empty T0)) ;stub

(check-expect (tock G0) (make-game empty empty (make-tank (+ TANK-SPEED (/ WIDTH 2)) 1) 1)) ; advance tank by tank speed, tank is going to the right
(check-expect (tock (make-game empty empty T2 0)) (make-game empty empty
                                                           (make-tank (- 50 TANK-SPEED) -1) 1)) ; dir is -1, so subtract tank speed (tank going to the left)
(check-expect (tock G2) (make-game
                         (list (make-invader 168 118 12))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)))
                         (make-tank (+ 50 TANK-SPEED) 1) 1))


(define (tock g)
  (delete-missiles (check-collisions (spawn-new-invaders (advance-items g)))))

;; Game -> Game
;; Deletes any missiles from the game that are off the screen (missile-y < 0).

;; (define (delete-missiles g) G0) ;stub

(check-expect (delete-missiles G0) G0)
(check-expect (delete-missiles G3) G3)
(check-expect (delete-missiles (make-game empty (list M1 M2 (make-missile 20 0)) T1 0))
                               (make-game empty (list M1 M2) T1 0))
(check-expect (delete-missiles (make-game empty (list (make-missile 20 0) M1 M2) T1 0))
                               (make-game empty (list M1 M2) T1 0))
(check-expect (delete-missiles (make-game empty (list (make-missile 20 0) M1 (make-missile 20 0) M2) T1 0))
                               (make-game empty (list M1 M2) T1 0))
(check-expect (delete-missiles (make-game empty (list (make-missile 20 -5) M1 (make-missile 20 -2) M2) T1 0))
                               (make-game empty (list M1 M2) T1 0))
;; Template from game

(define (delete-missiles g)
  (make-game (game-invaders g)
       (filter-missiles (game-missiles g)) ;;returns a filtered list of missiles
       (game-tank g)
       (game-clock g)))

;; ListOfMissiles -> ListOfMissiles
;; Returns a list of missiles with all missiles that are off the screen removed.
;; (define (filter-missiles lom) empty) ;stub

(check-expect (filter-missiles (list M1 M2 M3)) (list M1 M2 M3))
(check-expect (filter-missiles (list (make-missile 20 0) M1 M2))
              (list M1 M2))
(check-expect (filter-missiles (list (make-missile 20 -5) M1 (make-missile 20 -2) M2))
              (list M1 M2))

;; template from LOM

(define (filter-missiles lom)
  (cond [(empty? lom) empty]
        [else (if (off-screen? (first lom))
                  (filter-missiles (rest lom))
                  (cons (first lom) (filter-missiles (rest lom))))]))

;; Missile -> Boolean
;; Checks whether or not a missile is off the screen. 
;;(define (off-screen? m) false) ;stub

(check-expect (off-screen? M1) false)
(check-expect (off-screen? (make-missile 20 0)) true)
(check-expect (off-screen? (make-missile 20 -5)) true)
(check-expect (off-screen? (make-missile 20 -2)) true)

;; template from Missile
(define (off-screen? m)
  (<= (missile-y m) 0))



;; Game -> Game
;; Checks to see if any missiles are colliding with invaders. If the are, the affected invaders and missiles are removed from ListOfInvaders and ListOfMissiles.

;;(define (check-collisions g) G0) ;stub

(check-expect (check-collisions G0) G0) ;; no invaders or missiles are present
(check-expect (check-collisions
               (make-game
                (list (make-invader 162 112 12))
                (list (make-missile 150 0))
                T0
                0))
              (make-game
               (list (make-invader 162 112 12))
               (list (make-missile 150 0))
               
               T0
               0)) ;; missile goes off screen
(check-expect (check-collisions G2)
              (make-game
               (list I1)
               (list M1)
               T1
               0)) ;;no missiles hit

;; hit I1:
(check-expect (check-collisions G3)
              (make-game
               (list (make-invader 150 HEIGHT -10))
               (list (make-missile 150 300)) 
               T1
               0))
;; hit middle of list
(check-expect (check-collisions
               (make-game
                (list (make-invader 150 150 10) (make-invader 200 100 -5) (make-invader 100 100 2))
                (list (make-missile 300 400) (make-missile 203 98))
                T1
                0))
              (make-game
               (list (make-invader 150 150 10) (make-invader 100 100 2))
               (list (make-missile 300 400))
               T1
               0))

;; template from game

(define (check-collisions g)
  (make-game (check-missiles-against-invaders (game-missiles g) (game-invaders g)) ;; return filtered list of invaders
             (check-invaders-against-missiles (game-invaders g) (game-missiles g))  ;; return filtered list of missiles
             (game-tank g)
             (game-clock g)))


;; ListOfMissiles ListOfInvaders -> ListOfInvaders
;; Uses a list of missiles and filters each missile through the check-invader-collision function to produce a final filtered list of the remaining invaders.

;(define (check-missiles-against-invaders lom loi) empty) ;stub

(check-expect (check-missiles-against-invaders (list M1) (list I1)) (list I1)) ;none hit
(check-expect (check-missiles-against-invaders (list M1 M2) (list I1 I2 I3)) (list I2 I3)) ; I1 hit
(check-expect (check-missiles-against-invaders (list M1 M3) (list I1 I2 I3)) (list I2 I3)) ; I1 hit


(define (check-missiles-against-invaders lom loi)
  (cond [(empty? lom) loi]
        [else
         (check-missiles-against-invaders (rest lom) (check-invader-collisions loi (first lom)))]))

;; ListOfInvaders ListOfMissiles -> ListOfMissiles
;; Filters each invader through the check-missile-collision function to produce a final filtered list of the remaining missiles. 

;; (define (check-invaders-against-missiles loi lom) empty) ;stub

(check-expect (check-invaders-against-missiles empty empty) empty)
(check-expect (check-invaders-against-missiles (list I1) (list M1)) (list M1))
(check-expect (check-invaders-against-missiles (list I1 I2 I3) (list M1 M2 M3)) (list M1))
(check-expect (check-invaders-against-missiles (list I1) (list M1 M2 M3)) (list M1))

(define (check-invaders-against-missiles loi lom)
  (cond [(empty? loi) lom]
        [else
         (check-invaders-against-missiles (rest loi) (check-missile-collisions lom (first loi)))]))




;; ListOfInvaders Missile -> ListOfInvaders
;; Takes in a list of invaders and a single missiles and compares coordinates of this missile agains each invader.
;; If coordinates of the missile are (invader-x +/- HIT-RANGE, invader-y +/- HIT-RANGE) delete that invader from the list.
;; This function filters the invaders and returns a new list of invaders for the new game state.
;(define (check-invader-collisions loi m) empty) ;stub

(check-expect (check-invader-collisions empty M1) empty) ; no more invaders to compare
(check-expect (check-invader-collisions (list I1 I2 I3) M1) (list I1 I2 I3)) ;no collisions
(check-expect (check-invader-collisions (list I1 I2 I3) M2) (list I2 I3))
(check-expect (check-invader-collisions (list I1 I2 I3) M3) (list I2 I3))
(check-expect (check-invader-collisions (list I1 I2 (make-invader 290 50 10) I3) (make-missile 300 46)) (list I1 I2 I3))
(check-expect (check-invader-collisions (list I2 I1 I3) M2) (list I2 I3))
(check-expect (check-invader-collisions (list I2 I3 I1 I1 I3 I2) M2) (list I2 I3 I3 I2))



;; template from ListOfInvaders

(define (check-invader-collisions loi m)
  (cond [(empty? loi) empty]
        [else (if (remove? (first loi) m)
                  (check-invader-collisions (rest loi) m)
                  (cons (first loi) (check-invader-collisions (rest loi) m)))]))

;; Invader Missile -> Boolean
;; Check if an invader or missile needs to be removed from a list (if their coordinates match) and returns true or false.

;;(define (remove? i m) false) ;stub

(check-expect (remove? I1 M1) false)
(check-expect (remove? I1 M2) true)
(check-expect (remove? I1 M3) true)
(check-expect (remove? I2 M2) false)
(check-expect (remove? (make-invader 155 104 10) M1) false)


;; template from invader 
(define (remove? invader missile)
  (and (check-coord? (invader-x invader) (missile-x missile))
       (check-coord? (invader-y invader) (missile-y missile))))

;; Number Number -> Boolean
;; checks to see if coordinates of invader and missile are within hit range

;; (define (check-coord? i m) false) ;stub

(check-expect (check-coord? 100 105) true)
(check-expect (check-coord? 100 200) false)
(check-expect (check-coord? 200 100) false)
(check-expect (check-coord? 110 100) true)
(check-expect (check-coord? 100 100) true)

(define (check-coord? i m)
  (<= (* -1 HIT-RANGE) (- i m) HIT-RANGE))
                                
                           

;; ListOfMissiles Invader -> ListOfMissiles
;; Takes a list of missiles and compares each one to a single invader. If the missile is within the
;; range of the invader, deletes the missile from the list.
;; This function returns a filtered list missiles for the new game state.

;;(define (check-missile-collisions lom i) empty) ;stub

(check-expect (check-missile-collisions empty I1) empty)
(check-expect (check-missile-collisions (list M1) I1) (list M1))
(check-expect (check-missile-collisions (list M1 M2) I1) (list M1))
(check-expect (check-missile-collisions (list M1 M2 M3) I1) (list M1))
(check-expect (check-missile-collisions (list M2 M3 M1) I1) (list M1))
(check-expect (check-missile-collisions (list M2 M1 M3) I1) (list M1))
(check-expect (check-missile-collisions (list M2 M1 M3) I2) (list M2 M1 M3))


;; template from ListOfMissiles

(define (check-missile-collisions lom i)
  (cond [(empty? lom) empty]
        [else (if (remove? i (first lom))
                  (check-missile-collisions (rest lom) i)
                  (cons (first lom) (check-missile-collisions (rest lom) i)))]))



;; Game -> Game
;; Adds new invaders to the game each time invade-clock reaches INVADE-RATE, the invade-clock is then reset to 0.
;; Each new invader is added to the invader list. The Y-coordinate is always 0 (top of screen), but the x-coordinate is a random value between 0 and WIDTH.
;; The dx value is integer[- MAX-INVADER-SPEED, MAX-INVADER-SPEED] not including 0.
;; (define (spawn-new-invaders g) G0);stub
 


(check-expect (spawn-new-invaders G0) G0) ; clock at 0

;; invade-clock < INVADE-RATE, so no new invaders spawn. 

(check-expect (spawn-new-invaders
               (make-game empty empty
                          (make-tank (+ TANK-SPEED (/ WIDTH 2)) 1) 2)) 
              (make-game empty empty
                         (make-tank (+ TANK-SPEED (/ WIDTH 2)) 1) 2))

;; invade-clock > INVADE-RATE, so new invaders spawn. Test commented out as new invaders are random - cannot write a check-expect for random.
#;
(check-expect (spawn-new-invaders
               (make-game empty empty
                          (make-tank (+ TANK-SPEED (/ WIDTH 2)) 1) 100))
              (make-game (list (make-invader (< WIDTH) 0 -10)) 
                         empty
                         (make-tank (+ TANK-SPEED (/ WIDTH 2)) 1) 0))

;; template from game
(define (spawn-new-invaders g)
  (cond [(< (game-clock g) INVADE-RATE)
         (make-game (game-invaders g) (game-missiles g) (game-tank g)(game-clock g))]
        [(eq? (game-clock g) INVADE-RATE)
         (make-game
          (cons (invader-maker (rand-invader-maker 1)) (game-invaders g))
          (game-missiles g)
          (game-tank g)
          0)]))

;; ___ -> Invader 
;; Invader-maker - produces an invader with a random x axis value between 0 and width and a random direction b/w -12 and 12, but not including 0.
;; cannot check-expect due to random nature.

(define (rand-invader-maker a)
  (make-invader (random (- WIDTH 10)) 0 (- (random (* 2 MAX-INVADER-SPEED)) MAX-INVADER-SPEED)))

;; Invader -> Invader
;; takes newly created invader and if dx is = 0, either adds or subtracts 1.

;; Test commented out as could be either 1 or -1 due to coin-flip function
#;
(check-expect (invader-maker (make-invader 58 0 0))
            (make-invader 58 0 1)) 


;; template from invader
(define (invader-maker invader)
  (if (eq? (invader-dx invader) 0)
      (make-invader
       (invader-x invader)
       (invader-y invader)
       (coin-flip 1))
      (make-invader
       (invader-x invader)
       (invader-y invader)
       (invader-dx invader))))

;; Number -> Number[-1, 1]
;; returns either -1 or 1. NOT zero. 
;;coin-flip
;; no check-expects due to random nature.

;;(define (coin-flip n) 1) ;stub

(define (coin-flip n)
  (if (eq? (random 2) 1)
      1
      -1))



;; Game -> Game
;; advances missiles, tank and invaders by their speed.
;;(define (advance-items g) (make-game empty empty T0)) ;stub

(check-expect (advance-items G0) (make-game empty empty
                                            (make-tank (+ TANK-SPEED (/ WIDTH 2)) 1) 1))
(check-expect (advance-items G2) (make-game
                                  (list (make-invader 168 118 12))
                                  (list (make-missile 150 (- 300 MISSILE-SPEED)))
                                  (make-tank (+ 50 TANK-SPEED) 1) 1))

(check-expect (advance-items G3) (make-game
                                  (list (make-invader 168 118 12)(make-invader 135 (+ HEIGHT 15) -10))
                                  (list (make-missile 150 (- 300 MISSILE-SPEED))
                                        (make-missile (invader-x I1) (- (+ (invader-y I1) 10) MISSILE-SPEED))) ;M2 hit I1. I1 was deleted from the list as was M2
                                  (make-tank (+ 50 TANK-SPEED) 1) 1))

;; template from game
(define (advance-items g)
  (make-game (advance-invaders (game-invaders g))
             (advance-missiles (game-missiles g))
             (advance-tank (game-tank g))
             (+ (game-clock g) 1)))

;; ListOfInvaders -> ListOfInvaders
;; Advances all of the invaders by their x and y speed along the x and y axis.

;;(define (advance-invaders LOI) empty) ;stub

(check-expect (advance-invaders empty) empty)
(check-expect (advance-invaders (list I1))
              (list (make-invader (+ 150 (* 12 INVADER-X-SPEED)) (+ 100 (* 12 INVADER-Y-SPEED)) 12)))
(check-expect (advance-invaders (list I1 I2))
              (list (make-invader (+ 150 (* 12 INVADER-X-SPEED)) (+ 100 (* 12 INVADER-Y-SPEED)) 12)
                    (make-invader (+ 150 (* -10 INVADER-X-SPEED)) (+ HEIGHT (* 10 INVADER-Y-SPEED)) -10))) ;; y cannot be -ve. Must always move in positive direction.
(check-expect (advance-invaders (list I1 I2 I3))
              (list (make-invader (+ 150 (* 12 INVADER-X-SPEED)) (+ 100 (* 12 INVADER-Y-SPEED)) 12)
                    (make-invader (+ 150 (* -10 INVADER-X-SPEED)) (+ HEIGHT (* 10 INVADER-Y-SPEED)) -10)
                    (make-invader (+ 150 (* 10 INVADER-X-SPEED)) (+ (+ HEIGHT 10) (* 10 INVADER-Y-SPEED)) 10)))

;; template from ListOfInvaders
(define (advance-invaders loi)
  (cond [(empty? loi) empty]
        [else (cons (advance-single-invader (first loi))
                    (advance-invaders (rest loi)))]))

;; Invader -> Invader
;; Advances a single invader along the x and y axis by speed multiplied by dx.
;; If dx is negative, it must be changed to positive before being added to y axis to avoid going in the opposite direction.
;; If the invader hits a wall, it must be redirected back along the other way.

;;(define (advance-single-invader i) I1) ;stub

(check-expect (advance-single-invader I1)
              (make-invader (+ 150 (* 12 INVADER-X-SPEED)) (+ 100 (* 12 INVADER-Y-SPEED)) 12))

;; Invader hitting the left wall and bouncing off to start moving right instead. 
(check-expect (advance-single-invader (make-invader 10 100 -10))
              (make-invader (+ 10 (* 10 INVADER-X-SPEED)) (+ 100 (* 10 INVADER-Y-SPEED)) 10))

;; Invader hitting right wall and bouncing off to move left instead.
(check-expect (advance-single-invader (make-invader (- WIDTH 10) 100 10))
              (make-invader (+ (- WIDTH 10) (* -10 INVADER-X-SPEED)) (+ 100 (* 10 INVADER-Y-SPEED)) -10))

;; template from invader
(define (advance-single-invader invader)
  (cond [(hit-wall? invader)
         (make-invader
          (+ (invader-x invader) (* -1 (invader-dx invader) INVADER-X-SPEED))
          (+ (invader-y invader) (* (make-positive (invader-dx invader)) INVADER-Y-SPEED))
          (* -1 (invader-dx invader)))]
        [else
         (make-invader
          (+ (invader-x invader) (* (invader-dx invader) INVADER-X-SPEED))
          (+ (invader-y invader) (* (make-positive (invader-dx invader)) INVADER-Y-SPEED))
          (invader-dx invader))]))

;; Invader -> Boolean
;; Returns true if the invader has hit the side of the wall - ie if x value is 10 or (WIDTH - 10)

;; (define (hit-wall? i) false) ;stub

(check-expect (hit-wall? (make-invader (- WIDTH 10) 100 10)) true)
(check-expect (hit-wall? (make-invader 10 100 -10)) true)
(check-expect (hit-wall? (make-invader (/ WIDTH 2) (/ HEIGHT 2) 10)) false)

(define (hit-wall? i)
  (or (<= (invader-x i) 10) (>= (invader-x i) (- WIDTH 10))))



;; Number -> Number
;; Takes in a number (invader-dx) and makes it positive.

;; (define (make-positive n) 0) ; stub

(check-expect (make-positive 10) 10)
(check-expect (make-positive -10) 10)

(define (make-positive n)
  (if (positive? n)
      n
      (* -1 n)))
 



;; ListOfMissiles -> ListOfMissiles
;; Advances all of the missiles up the y axis by their speed
;; (define (advance-missiles LOM) empty) ;stub

(check-expect (advance-missiles empty) empty)
(check-expect (advance-missiles (list M1)) (list (make-missile 150 (- 300 MISSILE-SPEED))))
(check-expect (advance-missiles (list M1 M2))
              (list (make-missile 150 (- 300 MISSILE-SPEED))
                    (make-missile (invader-x I1) (- (+ (invader-y I1) 10) MISSILE-SPEED))))
(check-expect (advance-missiles (list M1 M2 M3))
              (list (make-missile 150 (- 300 MISSILE-SPEED))
                    (make-missile (invader-x I1) (- (+ (invader-y I1) 10) MISSILE-SPEED))
                    (make-missile (invader-x I1) (- (+ (invader-y I1)  5) MISSILE-SPEED))))

;; template from ListOfMissiles

(define (advance-missiles lom)
  (cond [(empty? lom) empty]
        [else (cons (single-missile-advance (first lom))
                    (advance-missiles (rest lom)))]))

;; Missile -> Missile
;; advance an individual missile by missile speed up the screen.
;; (define (single-missile-advance m) M1) ;stub

(check-expect (single-missile-advance M1)
              (make-missile 150 (- 300 MISSILE-SPEED)))
(check-expect (single-missile-advance M2)
              (make-missile (invader-x I1) (- (+ (invader-y I1) 10) MISSILE-SPEED)))
(check-expect (single-missile-advance M3)
              (make-missile (invader-x I1) (- (+ (invader-y I1)  5) MISSILE-SPEED)))
              

;; Template from Missile

(define (single-missile-advance m)
  (make-missile (missile-x m) (- (missile-y m) MISSILE-SPEED)))


;; Tank -> Tank
;; advances the tank either left or right (depending on its current direction) by its speed.
;; (define (advance-tank t) T0) ;stub

(check-expect (advance-tank T0) (make-tank (+ (/ WIDTH 2) TANK-SPEED) 1))
(check-expect (advance-tank T1) (make-tank (+ 50 TANK-SPEED) 1))
(check-expect (advance-tank T2) (make-tank (- 50 TANK-SPEED) -1))

;;template from Tank

(define (advance-tank t)
  (make-tank (+ (tank-x t) (* (tank-dir t) TANK-SPEED)) (tank-dir t)))



;; Game -> Image
;; render images of current missiles, tank and invaders. 

;;(define (render g) (square 1 "solid" "white")) ; stub

(check-expect (render G0)
              (place-image TANK (/ WIDTH 2) TANK-Y BACKGROUND))

(check-expect (render G2)
              (place-image INVADER 150 100
                           (place-image MISSILE 150 300
                                        (place-image TANK 50 TANK-Y BACKGROUND)
                                        )))

(check-expect (render G3)
              (place-image INVADER 150 100
                           (place-image INVADER 150 HEIGHT
                                        (place-image MISSILE 150 300
                                                     (place-image MISSILE (invader-x I1) (+ (invader-y I1) 10)
                                                                  (place-image  TANK 50 TANK-Y BACKGROUND))))))



;; template from game

(define (render g)
  (place-invaders (game-invaders g)
                  (place-missiles (game-missiles g) (place-tank (game-tank g)))))

;; LOI -> image
;; places images of all the invaders onto canvas with the misiles and tanks.

;;(define (place-invaders loi bg) (square 1 "solid" "white")) ;stub

(check-expect (place-invaders empty (place-missiles empty (place-tank T0)))
              (place-tank T0))

(check-expect (place-invaders (list I1) (place-missiles empty (place-tank T0)))
              (place-image INVADER 150 100 (place-missiles empty (place-tank T0))))

(check-expect (place-invaders (list I1 I2 I3) (place-missiles (list M1 M2 M3) (place-tank T1)))
              (place-image INVADER 150 100
                           (place-image INVADER 150 HEIGHT
                                        (place-image INVADER 150 (+ HEIGHT 10)
                                                     (place-missiles (list M1 M2 M3) (place-tank T1))))))

;; template from ListOfInvaders

(define (place-invaders loi bg)
  (cond [(empty? loi) bg]
        [else (place-image INVADER (invader-x (first loi)) (invader-y (first loi))
                           (place-invaders (rest loi) bg))]))



                                         


;; LOM image -> image
;; places images of all the missiles onto the canvas with the tanks (second argument is current background image). 
;;(define (place-missiles lom bg) (square 1 "solid" "white")) ;stub

(check-expect (place-missiles empty (place-tank T0)) (place-tank T0))

(check-expect (place-missiles (list M1) (place-tank T0))
              (place-image MISSILE 150 300 (place-tank T0)))

(check-expect (place-missiles (list M1 M2 M3) (place-tank T1))
              (place-image MISSILE 150 300
                           (place-image MISSILE (invader-x I1) (+ (invader-y I1) 10)
                                        (place-image MISSILE (invader-x I1) (+ (invader-y I1)  5)
                                                     (place-tank T1)))))
;; template from ListOfMissiles

(define (place-missiles lom bg)
  (cond [(empty? lom) bg]
        [else (place-image MISSILE (missile-x (first lom)) (missile-y (first lom))
                           (place-missiles (rest lom) bg))]))





;; Tank -> Image
;; places image of the tank onto the background.
;; (define (place-tank t) (square 1 "solid" "white")) ;stub

(check-expect (place-tank T0)
              (place-image TANK (/ WIDTH 2) TANK-Y BACKGROUND))

(check-expect (place-tank T1)
              (place-image TANK 50 TANK-Y BACKGROUND))

(check-expect (place-tank (make-tank 32 1))
              (place-image TANK 32 TANK-Y BACKGROUND))


;; template from tank

(define (place-tank t)
  (place-image TANK (tank-x t) TANK-Y BACKGROUND))





;; Game -> Boolean
;; Stop game when invader hits bottom of the screen (ie invader y is HEIGHT - 10).

;; (define (end-game g) false) ;stub

(check-expect (end-game G0) false)
(check-expect (end-game G1) false)
(check-expect (end-game G2) false)
(check-expect (end-game G3) true)


;; Template from Game

(define (end-game g)
  (check-landed? (game-invaders g))
       )

;; ListOfInvaders -> Boolean
;; Checks if any of the invaders in the list have "landed".

;; (define (check-landed? loi) false) ;stub

(check-expect (check-landed? empty) false)
(check-expect (check-landed? (list I1)) false)
(check-expect (check-landed? (list I1 I2)) true)
(check-expect (check-landed? (list I1 I2 I3)) true)


;; template from ListOfInvaders
(define (check-landed? loi)
  (cond [(empty? loi) false]
        [else (if (invader-land? (first loi))
                  true
                  (check-landed? (rest loi)))]))

;; Invader -> Boolean
;; returns true if invader y coordinate is > height.
;; (define (invader-land? i) false) ;stub

(check-expect (invader-land? I1) false)
(check-expect (invader-land? I2) true)
(check-expect (invader-land? I3) true)

;; template from Invader

(define (invader-land? invader)
  (>= (invader-y invader) HEIGHT))



;; Game KeyEvent -> Game
;; if key is left arrow, move tank in the left direction.
;; if key pressed is right arrow, move tank in right direction.
;; if key pressed is spacebar, add a missile to the list of missiles.

  
;; (define (key-handler g k) G0) ;stub

(check-expect (key-handler G0 " ")
              (make-game empty (list (make-missile (/ WIDTH 2) TANK-Y)) T0 0))
(check-expect (key-handler G3 " ")
              (make-game (list I1 I2) (list (make-missile 50 TANK-Y) M1 M2) T1 0))
(check-expect (key-handler G0 "left")
              (make-game empty empty (make-tank (/ WIDTH 2) -1) 0))
(check-expect (key-handler G0 "right")
              (make-game empty empty (make-tank (/ WIDTH 2) 1) 0))
(check-expect (key-handler G2 "right")
              (make-game (list I1) (list M1) (make-tank 50 1)  0))
(check-expect (key-handler G2 "left")
              (make-game (list I1) (list M1) (make-tank 50 -1)  0))




(define (key-handler g k)
  (cond [(key=? k "right") (tank-right g) ]
        [(key=? k "left") (tank-left g)]
        [(key=? k " ") (add-missile g)]
        [else g]))


;; Game -> Game
;; Adds a missile to list. Starting x and y of missile is equivalent to current tank x and y.

;; (define (add-missile g) G0) ;stub

(check-expect (add-missile G0)
              (make-game empty (list (make-missile (/ WIDTH 2) TANK-Y)) T0 0))
(check-expect (add-missile G3)
              (make-game (list I1 I2) (list (make-missile 50 TANK-Y) M1 M2) T1 0))

;; template from Game
(define (add-missile g)
  (make-game (game-invaders g)
       (add-missile-to-list (game-missiles g) (game-tank g))
       (game-tank g)
       (game-clock g)))

;; ListOfMissiles Tank -> ListOfMissiles
;; Adds a new missile to the list of missiles with the same coordinates as the tank.

;; (define (add-missile-to-list lom t) empty) ;stub

(check-expect (add-missile-to-list empty T0)
              (list (make-missile (/ WIDTH 2) TANK-Y)))
(check-expect (add-missile-to-list (list M1 M2) T1)
              (list (make-missile 50 TANK-Y) M1 M2))

;; template from Tank
(define (add-missile-to-list lom t)
  (cons (make-missile (tank-x t) TANK-Y) lom))

    

;; Game -> Game
;; changes the direction of the tank movement to the right
;; (define (tank-right g) G0) ;stub

(check-expect (tank-right G0)
              G0)
(check-expect (tank-right (make-game (list I1) (list M1) T2 0))
              (make-game (list I1) (list M1) (make-tank 50 1) 0))

;; template from game
(define (tank-right g)
  (make-game (game-invaders g)
       (game-missiles g)
       (go-right (game-tank g))
       (game-clock g)))

;; Tank -> Tank
;; changes dir of tank to 1 (right)

;; (define (go-right t) T1) ;stub

(check-expect (go-right T1)
              (make-tank 50 1))
(check-expect (go-right T2)
              (make-tank 50 1))
;; template from Tank
(define (go-right t)
  (make-tank (tank-x t) 1))



;; Game -> Game
;; changes the direction of the tank movement to the left
;; (define (tank-left g) G0) ;stub

(check-expect (tank-left G1)
              (make-game empty empty (make-tank 50 -1) 0))
(check-expect (tank-left (make-game empty empty T2 0))
              (make-game empty empty T2 0))

;; Template from game
(define (tank-left g)
  (make-game (game-invaders g)
       (game-missiles g)
       (go-left (game-tank g))
       (game-clock g)))

;; Tank -> Tank
;; changes dir of tank to -1 (left)

;; (define (go-left t) T1) ;stub

(check-expect (go-left T1)
              (make-tank 50 -1))
(check-expect (go-left T2)
              (make-tank 50 -1))
;; template from Tank

(define (go-left t)
  (make-tank (tank-x t) -1))








  
              









