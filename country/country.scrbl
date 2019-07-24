#lang scribble/manual

@(require (for-label country
                     racket/base
                     racket/contract)
          scribble/example)

@title{@exec{country}: ISO country database}
@author[(author+email "Bogdan Popa" "bogdan@defn.io")]
@defmodule[country]

@(define pkg-isocodes-link
   (hyperlink "https://salsa.debian.org/iso-codes-team/iso-codes" "pkg-isocodes"))

@(define mledoze-link
   (hyperlink "https://github.com/mledoze/countries" "mledoze/countries"))

This library provides facilities for working with standardized country
data.  It is based on the Debian @pkg-isocodes-link and @mledoze-link
databases.

@section[#:tag "reference"]{Reference}

@subsection{Regions}
@defmodule[country/region]

@defproc[(region? [v any/c]) boolean?]{
  Returns @racket[#t] when @racket[v] is a region.
}

@defproc[(region-name [r region?]) string?]{
  Returns the name of @racket[r].
}

@defthing[all-regions (non-empty-listof region?)]{
  A list of all the known regions.
}


@subsection{Countries}
@defmodule[country/country]

@defproc[(country? [v any/c]) boolean?]{
  Returns @racket[#t] when @racket[v] is a country.
}

@deftogether[
  (@defproc[(country-region [c country?]) region?]
   @defproc[(country-common-name [c country?]) string?]
   @defproc[(country-official-name [c country?]) string?]
   @defproc[(country-code/alpha-2 [c country?]) symbol?]
   @defproc[(country-code/alpha-3 [c country?]) symbol?]
   @defproc[(country-code/numeric [c country?]) (integer-in 1 999)])]{

  Accessors for the various properties on @racket[c].
}

@defthing[all-countries (non-empty-listof country?)]{
  A list of all the known countries.
}

@defproc[(country-ref [selector (or/c (integer-in 1 999) string? symbol?)]) (or/c false/c country?)]{
  Looks up a country based on one of its (case-insensitive) names or
  codes.  Returns @racket[#f] when no country matches the given
  @racket[selector].
}

@defproc[(region-countries [r region?]) (non-empty-listof country?)]{
  Returns a list of all countries within the given @racket[r].
}


@subsection{Subdivisions}
@defmodule[country/subdivision]

@defproc[(subdivision? [v any/c]) boolean?]{
  Returns @racket[#t] when @racket[v] is a subdivision.
}

@deftogether[
  (@defproc[(subdivision-country [s subdivision?]) country?]
   @defproc[(subdivision-code [s subdivision?]) symbol?]
   @defproc[(subdivision-name [s subdivision?]) string?])]{

  Accessors for the various properties on @racket[s].
}

@defthing[all-subdivisions (non-empty-listof subdivision?)]{
  A list of all the known subdivisions.
}

@defproc[(country-subdivisions [c country?]) (non-empty-listof subdivision?)]{
  Returns a list of all subdivisions within the given @racket[c].
}
