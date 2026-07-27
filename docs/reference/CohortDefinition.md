# R6 Class Representing a CohortDefinition

The CohortDefinition class, encapsulating the id, name and expression of
a cohort definition.

## Details

This R6 class is intended to wrap the Cohort Defintion expression used
to generate the cohort, and provide the id and name attribute for this
cohort.

Note, when serializing with a library such as jsonlite, first call
toList() on the R6 class before calling jsonlite::toJSON().

## Public fields

- `id`:

  The cohort ID

- `name`:

  The cohort name

- `expression`:

  The cohort expression

## Methods

### Public methods

- [`CohortDefinition$toList()`](#method-CohortDefinition-toList)

- [`CohortDefinition$asJSON()`](#method-CohortDefinition-asJSON)

- [`CohortDefinition$clone()`](#method-CohortDefinition-clone)

------------------------------------------------------------------------

### `CohortDefinition$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    CohortDefinition$toList()

------------------------------------------------------------------------

### `CohortDefinition$asJSON()`

returns the JSON string for this R6 class

#### Usage

    CohortDefinition$asJSON()

------------------------------------------------------------------------

### `CohortDefinition$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CohortDefinition$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
