#!/usr/bin/env racket
#lang racket

(require json
         racket/runtime-path)

(define-runtime-path source
  (build-path 'up "country"))

(define-runtime-path vendor
  (build-path 'up "vendor"))

(define subdivision-code-re
  #rx"^([^-]+)-(.+)$")

(define subdivisions
  (with-input-from-file (build-path vendor "iso-codes" "data" "iso_3166-2.json")
    (lambda _
      (for/list ([subdivision-data (in-list (hash-ref (read-json) '3166-2))])
        (define code (hash-ref subdivision-data 'code))
        (match-define (list _ alpha-2 _)
          (regexp-match subdivision-code-re code))

        (define alpha-2:sym
          (string->symbol alpha-2))

        (list alpha-2:sym
              (string->symbol code)
              (hash-ref subdivision-data 'name))))))

(with-output-to-file (build-path source "data" "subdivisions.dat")
  #:exists 'truncate/replace
  (lambda _
    (write subdivisions)))

(define countries
  (with-input-from-file (build-path vendor "countries" "countries.json")
    (lambda _
      (for/list ([country (in-list (read-json))])
        (define names (hash-ref country 'name))
        (list (hash-ref country 'region)
              (hash-ref names 'common)
              (hash-ref names 'official)
              (string->symbol (hash-ref country 'cca2))
              (string->symbol (hash-ref country 'cca3))
              (string->number (hash-ref country 'ccn3)))))))

(with-output-to-file (build-path source "data" "countries.dat")
  #:exists 'truncate/replace
  (lambda _
    (write (sort countries string-locale-ci<? #:key cadr))))

(define regions
  (sort
   (remove-duplicates
    (for/list ([country (in-list countries)])
      (car country)))
   string-locale-ci<?))

(with-output-to-file (build-path source "data" "regions.dat")
  #:exists 'truncate/replace
  (lambda _
    (write regions)))
