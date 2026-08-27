# Creates R6 object for CohortSubgroup

Creates R6 object for CohortSubgroup

## Usage

``` r
createCohortSubgroup(id, name, description, cohortRef)
```

## Arguments

- id:

  the unique identifier for this subgroup

- name:

  The subgroup name

- description:

  The subgroup description

- cohortRef:

  A cohort reference, as an R6 Class CohortReference

## Value

A `CohortSubgroup` R6 object containing subgroup metadata and the
`CohortReference` used to determine subgroup membership.
