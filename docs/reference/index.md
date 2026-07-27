# Package index

## R6 Classes

- [`CohortDefinition`](https://ohdsi.github.io/CohortIncidence/reference/CohortDefinition.md)
  : R6 Class Representing a CohortDefinition
- [`CohortReference`](https://ohdsi.github.io/CohortIncidence/reference/CohortReference.md)
  : R6 Class Representing a CohortReference
- [`CohortSubgroup`](https://ohdsi.github.io/CohortIncidence/reference/CohortSubgroup.md)
  : R6 Class Representing a Cohort Subgroup definition
- [`DateRange`](https://ohdsi.github.io/CohortIncidence/reference/DateRange.md)
  : R6 Class Representing a DataRange
- [`IncidenceAnalysis`](https://ohdsi.github.io/CohortIncidence/reference/IncidenceAnalysis.md)
  : R6 Class Representing a IncidenceAnalysis
- [`IncidenceDesign`](https://ohdsi.github.io/CohortIncidence/reference/IncidenceDesign.md)
  : R6 Class Representing a IncidenceDesign
- [`Outcome`](https://ohdsi.github.io/CohortIncidence/reference/Outcome.md)
  : R6 Class Representing an Outcome definition
- [`StrataSettings`](https://ohdsi.github.io/CohortIncidence/reference/StrataSettings.md)
  : R6 Class Representing the Stratification Settings of a
  IncidenceDesign
- [`TimeAtRisk`](https://ohdsi.github.io/CohortIncidence/reference/TimeAtRisk.md)
  : R6 Class Representing an Time-at-Risk (TAR) definition

## R6 Class Factory Functions

- [`createCohortRef()`](https://ohdsi.github.io/CohortIncidence/reference/createCohortRef.md)
  : Creates R6 object for CohortReference
- [`createCohortSubgroup()`](https://ohdsi.github.io/CohortIncidence/reference/createCohortSubgroup.md)
  : Creates R6 object for CohortSubgroup
- [`createDateRange()`](https://ohdsi.github.io/CohortIncidence/reference/createDateRange.md)
  : Creates R6 object for DateRange
- [`createIncidenceAnalysis()`](https://ohdsi.github.io/CohortIncidence/reference/createIncidenceAnalysis.md)
  : Creates R6 object for IncidenceAnalysis
- [`createIncidenceDesign()`](https://ohdsi.github.io/CohortIncidence/reference/createIncidenceDesign.md)
  : Creates R6 object for IncidenceDesign
- [`createOutcomeDef()`](https://ohdsi.github.io/CohortIncidence/reference/createOutcomeDef.md)
  : Creates R6 object for Outcome
- [`createStrataSettings()`](https://ohdsi.github.io/CohortIncidence/reference/createStrataSettings.md)
  : Creates R6 object for StrataSettings
- [`createTimeAtRiskDef()`](https://ohdsi.github.io/CohortIncidence/reference/createTimeAtRiskDef.md)
  : Creates R6 object for TimeAtRisk

## Other Functions

- [`buildOptions()`](https://ohdsi.github.io/CohortIncidence/reference/buildOptions.md)
  : Builds the BuilderOptions jObject with the specified paramaters
- [`buildQuery()`](https://ohdsi.github.io/CohortIncidence/reference/buildQuery.md)
  : Builds SQL code to run analyses according given Cohort
  Characterization design
- [`executeAnalysis()`](https://ohdsi.github.io/CohortIncidence/reference/executeAnalysis.md)
  : Executes IR analysis given a design, options, and connection
  settings.
- [`getCleanupSql()`](https://ohdsi.github.io/CohortIncidence/reference/getCleanupSql.md)
  : Gets the sql that drops the results tables
- [`getResultsDdl()`](https://ohdsi.github.io/CohortIncidence/reference/getResultsDdl.md)
  : Gets the results schema DDL for Incidence Analysis
