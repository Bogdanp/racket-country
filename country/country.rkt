#lang racket/base

(require (for-syntax racket/base)
         racket/contract
         racket/function
         racket/runtime-path
         racket/struct
         "region.rkt")

;; country ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 country?
 country-region
 country-common-name
 country-official-name
 country-code/alpha-2
 country-code/alpha-3
 country-code/numeric
 all-countries
 country-ref)

(define-runtime-path data-file
  (build-path "data" "countries.dat"))

(define numeric-code/c
  (integer-in 1 999))

(struct country (region-name common-name official-name code/alpha-2 code/alpha-3 code/numeric)
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (lambda (_) 'country)
      (lambda (c) (list (country-common-name c)))))])

(define/contract all-countries
  (non-empty-listof country?)
  (with-input-from-file data-file
    (lambda _
      (for/list ([country-data (in-list (read))])
        (apply country country-data)))))

(define country-db
  (for/fold ([db (hash)])
            ([c (in-list all-countries)])
    (let* ([db (hash-set db (string-downcase (country-common-name c)) c)]
           [db (hash-set db (string-downcase (country-official-name c)) c)]
           [db (hash-set db (country-code/alpha-2 c) c)]
           [db (hash-set db (country-code/alpha-3 c) c)]
           [db (hash-set db (country-code/numeric c) c)])
      db)))

(define symbol-upcase
  (compose1 string->symbol string-upcase symbol->string))

(define/contract (country-ref selector)
  (-> (or/c numeric-code/c string? symbol?) (or/c false/c country?))
  (define selector*
    (cond
      [(string? selector) (string-downcase selector)]
      [(symbol? selector) (symbol-upcase selector)]
      [else selector]))

  (hash-ref country-db selector* #f))

(define/contract (country-region c)
  (-> country? region?)
  (hash-ref regions-by-name (country-region-name c)))


;; region ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Region-mapping code lives in this module so that users can require
;; country/region w/o having to load all the country data.

(provide
 region-countries)

(define regions-by-name
  (for/hash ([region (in-list all-regions)])
    (values (region-name region) region)))

(define countries-by-region
  (for/fold ([regions (hasheq)]
             #:result (for/hash ([(name countries) (in-hash regions)])
                        (values name (reverse countries))))
            ([country (in-list all-countries)])
    (hash-update regions
                 (country-region country)
                 (curry cons country)
                 null)))

(define/contract (region-countries r)
  (-> region? (non-empty-listof country?))
  (hash-ref countries-by-region r))


;; tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(module+ test
  (require rackunit
           rackunit/text-ui)

  (run-tests
   (test-suite
    "country"

    (test-suite
     "country"

     (test-suite
      "country-ref"

      (test-case "returns #f upon failed lookup"
        (check-false (country-ref "foo")))

      (test-case "returns a country on successful lookup"
        (check-true (country? (country-ref 'US)))
        (check-true (country? (country-ref 'us)))
        (check-true (country? (country-ref 'usa)))
        (check-true (country? (country-ref "United States"))))))

    (test-suite
     "region"

     (test-suite
      "region-countries"

      (test-case "returns all countries in that region"
        (for ([region (in-list all-regions)])
          (check-equal?
           (sort #:key country-code/alpha-2
                 (region-countries region)
                 symbol<?)
           (sort #:key country-code/alpha-2
                 (filter (lambda (c)
                           (string=? (country-region-name c) (region-name region)))
                         all-countries)
                 symbol<?)))))))))
