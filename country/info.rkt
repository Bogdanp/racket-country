#lang info

(define license '((BSD-3-Clause AND ODbL-1.0) AND GPL-2.0-or-later))
(define version "20221211.0")
(define collection "country")

(define deps '("base"))
(define build-deps '("racket-doc"
                     "rackunit-lib"
                     "scribble-lib"))

(define scribblings '(("country.scrbl" ())))
