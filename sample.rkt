#lang racket

;; informal
(+ 1 2) ;; => 3

(define (my-fn x)
  (+ x 2))

(my-fn 1) ;; => 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the "blessed" style?
(require rackunit)

(check-equal? (my-fn 3) 5)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; something nice about this way...
(require tests/eli-tester)

(test

 (my-fn 3)
 =>
 5

 )

