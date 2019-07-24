#lang racket/base

(define-syntax-rule (reprovide mod0 mod ...)
  (begin
    (require mod0 mod ...)
    (provide (all-from-out mod0 mod ...))))

(reprovide
 "country.rkt"
 "region.rkt"
 "subdivision.rkt")
