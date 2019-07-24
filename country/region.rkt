#lang racket/base

(require (for-syntax racket/base)
         racket/contract
         racket/runtime-path
         racket/struct)

(provide
 region?
 region-name
 all-regions)

(define-runtime-path data-file
  (build-path "data" "regions.dat"))

(struct region (name)
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (r) 'region)
      (lambda (r) (list (region-name r)))))])

(define/contract all-regions
  (non-empty-listof region?)
  (with-input-from-file data-file
    (lambda _
      (for/list ([name (in-list (read))])
        (region name)))))
