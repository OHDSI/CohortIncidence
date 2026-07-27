# R6 Class Representing a IncidenceDesign

This class encapsulates the other R6 Class elements that define an
IncidenceDesign

## Details

The IncidenceDesign class encapsulates the following: - Cohort
Definitions - Target Definitions - Outcome Definitions - Time At Risk
Definitions - A List of Analyses - Concept Sets - Subgruops - Strata
Settings Note, when serializing with a library such as jsonlite, first
call toList() on the R6 class before calling jsonlite::toJSON(), or call
toJSON directy on this class.

## Active bindings

- `cohortDefs`:

  A list of cohort definitions. Must be a list of
  [CohortDefinition](https://ohdsi.github.io/CohortIncidence/reference/CohortDefinition.md)

- `conceptSets`:

  A list of concept set expressions. Currently unused.

- `targetDefs`:

  A list of cohort references to be used as target cohorts. Must be a
  list of
  [CohortReference](https://ohdsi.github.io/CohortIncidence/reference/CohortReference.md)

- `outcomeDefs`:

  A list of outcome definitions. Must be a list of
  [Outcome](https://ohdsi.github.io/CohortIncidence/reference/Outcome.md)

- `timeAtRiskDefs`:

  A list of time-at-risk definitions. Must be a list of
  [TimeAtRisk](https://ohdsi.github.io/CohortIncidence/reference/TimeAtRisk.md)

- `analysisList`:

  A list of analyses, containing the T-O-TAR combinations to perform.
  Must be a list of
  [IncidenceAnalysis](https://ohdsi.github.io/CohortIncidence/reference/IncidenceAnalysis.md)

- `subgroups`:

  A list of subgroups. Must be a list of
  [CohortSubgroup](https://ohdsi.github.io/CohortIncidence/reference/CohortSubgroup.md)

- `strataSettings`:

  The strata settings for this design. Must be a class
  [StrataSettings](https://ohdsi.github.io/CohortIncidence/reference/StrataSettings.md)

- `studyWindow`:

  a study window for this design. Must be a list of class
  [DateRange](https://ohdsi.github.io/CohortIncidence/reference/DateRange.md)

- `firstAtRisk`:

  a boolean indicating to limit TAR to first per person.

- `firstPostOutcome`:

  a boolean indicating to limit TAR to first per person.

## Methods

### Public methods

- [`IncidenceDesign$new()`](#method-IncidenceDesign-initialize)

- [`IncidenceDesign$toList()`](#method-IncidenceDesign-toList)

- [`IncidenceDesign$asJSON()`](#method-IncidenceDesign-asJSON)

- [`IncidenceDesign$clone()`](#method-IncidenceDesign-clone)

------------------------------------------------------------------------

### `IncidenceDesign$new()`

creates a new instance, using the provided data param if provided.

#### Usage

    IncidenceDesign$new(data = list())

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

------------------------------------------------------------------------

### `IncidenceDesign$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    IncidenceDesign$toList()

------------------------------------------------------------------------

### `IncidenceDesign$asJSON()`

returns the JSON string for this R6 class

#### Usage

    IncidenceDesign$asJSON(...)

#### Arguments

- `...`:

  paramaters that are passed forward to rjsonlite::toJSON()

------------------------------------------------------------------------

### `IncidenceDesign$clone()`

The objects of this class are cloneable with this method.

#### Usage

    IncidenceDesign$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
