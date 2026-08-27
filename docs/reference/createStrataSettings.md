# Creates R6 object for StrataSettings

Creates R6 object for StrataSettings

## Usage

``` r
createStrataSettings(
  byAge = FALSE,
  byGender = FALSE,
  byYear = FALSE,
  ageBreaks,
  ageBreakList
)
```

## Arguments

- byAge:

  a boolean indicating to stratify by age, defaults to FALSE

- byGender:

  a boolean indicating to stratify by gender, defaults to FALSE

- byYear:

  a boolean indicating to stratify by year, defaults to FALSE

- ageBreaks:

  a vector of integers indicating the age group bounds.

- ageBreakList:

  a list of ageBreaks, used to specify multiple age break strata.

## Value

A `StrataSettings` R6 object containing the three stratification flags
plus optional age break definitions. The serialized form matches
`org.ohdsi.cohortincidence.design.StratifySettings` JSON.
