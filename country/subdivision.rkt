#lang racket/base

(require (for-syntax racket/base)
         racket/contract
         racket/function
         racket/runtime-path
         racket/struct
         "country.rkt")

;; subdivision ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 subdivision?
 subdivision-country
 subdivision-code
 subdivision-name
 all-subdivisions)

(define-runtime-path data-file
  (build-path "data" "subdivisions.dat"))

(struct subdivision (country-code code name)
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (_) 'subdivision)
      (lambda (s) (list (subdivision-code s)))))])

(define/contract all-subdivisions
  (non-empty-listof subdivision?)
  (with-input-from-file data-file
    (lambda _
      (for/list ([subdivision-data (in-list (read))])
        (apply subdivision subdivision-data)))))

(define/contract (subdivision-country s)
  (-> subdivision? country?)
  (country-ref (subdivision-country-code s)))


;; countries ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 country-subdivisions)

(define subdivisions-by-country
  (for/fold ([countries (hasheq)]
             #:result (for/hash ([(name subdivisions) (in-hash countries)])
                        (values name (reverse subdivisions))))
            ([subdivision (in-list all-subdivisions)])
    (hash-update countries
                 (country-ref (subdivision-country-code subdivision))
                 (curry cons subdivision)
                 null)))

(define/contract (country-subdivisions c)
  (-> country? (non-empty-listof subdivision?))
  (hash-ref subdivisions-by-country c))
