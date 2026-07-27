# Creates R6 object for StrataSettings

Creates R6 object for StrataSettings

## Usage

``` r
createStrataSettings(
  byAge = F,
  byGender = F,
  byYear = F,
  ageBreaks,
  ageBreakList
)
```

## Arguments

- byAge:

  a boolean indicating to stratify by age, defaults to F

- byGender:

  a boolean indicating to stratify by gender, defaults to F

- byYear:

  a boolean indicating to stratify by year, defaults to F

- ageBreaks:

  a vector of integers indicating the age group bounds.

- ageBreakList:

  a list of ageBreaks, used to specify multiple age break strata.

## Value

an R list containing name-value pairs that will serialize into a
org.ohdsi.cohortincidence.design.StratifySettings JSON format.
