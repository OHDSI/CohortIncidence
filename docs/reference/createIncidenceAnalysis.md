# Creates R6 object for IncidenceAnalysis

Creates R6 object for IncidenceAnalysis

## Usage

``` r
createIncidenceAnalysis(targets, outcomes, tars)
```

## Arguments

- targets:

  A list or vector of target IDs from target definitions.

- outcomes:

  A list or vector of outcome IDs from outcome definitions.

- tars:

  A list or vector of TAR IDs from time-at-risk definitions.

## Value

An `IncidenceAnalysis` R6 object containing the target, outcome, and TAR
identifier vectors used to define one analysis combination.
