# Creates R6 object for IncidenceDesign

Creates R6 object for IncidenceDesign

## Usage

``` r
createIncidenceDesign(
  cohortDefs,
  targetDefs,
  outcomeDefs,
  tars,
  analysisList,
  conceptSets,
  subgroups,
  strataSettings,
  studyWindow,
  firstAtRisk,
  firstPostOutcome
)
```

## Arguments

- cohortDefs:

  The set of cohort definitions. Optional.

- targetDefs:

  A list of target definitions, each element must be class
  CohortReference.

- outcomeDefs:

  A list of outcome definitions, each element must be class Outcome

- tars:

  A list of TAR definitions, each element must be class TimeAtRisk

- analysisList:

  A list of analysis definitions, each element must be class
  IncidenceAnalysis

- conceptSets:

  A list of concept sets, currently unused.

- subgroups:

  A list of cohort subgroups, each element must be class Subgroup.

- strataSettings:

  The strata settings used in the anlaysis, must be class
  StrataSettings.

- studyWindow:

  Limits time at risk to the specified study window. Must be class
  DateRange.

- firstAtRisk:

  Limits time at risk to the first per person. Must be boolean.

- firstPostOutcome:

  Limits outcomes to first outcome within clean window of the first TAR
  or after. Must be boolean.

## Value

a R6 class: IncidenceDesign.
