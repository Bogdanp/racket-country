#lang info

(define version "2019-07-24")
(define collection "country")

(define deps '("base"))
(define build-deps '("racket-doc"
                     "rackunit-lib"
                     "scribble-lib"))

(define scribblings '(("country.scrbl" ())))
