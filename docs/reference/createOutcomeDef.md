# Creates R6 object for Outcome

Creates R6 object for Outcome

## Usage

``` r
createOutcomeDef(id, name, cohortId = 0, cleanWindow = 0, excludeCohortId)
```

## Arguments

- id:

  the unique identifier for this outcome definition

- name:

  an optional name for this outcome definition

- cohortId:

  the cohort id reference for this outcome

- cleanWindow:

  the number of days to extend the outcome cohort’s end date. See
  [`executeAnalysis()`](https://ohdsi.github.io/CohortIncidence/reference/executeAnalysis.md)
  for details on how this is applied.

- excludeCohortId:

  a cohort ID from the outcomeCohrotTable that is used to exclude time
  at risk. See
  [`executeAnalysis()`](https://ohdsi.github.io/CohortIncidence/reference/executeAnalysis.md)
  for details on how this is applied.

## Value

a R6 class: Outcome
