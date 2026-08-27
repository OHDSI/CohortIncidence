# R6 Class Representing a CohortDefinition

The CohortDefinition class, encapsulating the id, name and expression of
a cohort definition.

## Value

A `CohortDefinition` R6 object used to hold optional cohort metadata and
a serialized cohort definition expression. This object is primarily
metadata for the design and is not required for analysis generation.

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

#### Returns

A named list with `id`, `name`, and `expression`, where `expression` is
itself a nested list representation of the cohort definition expression.

------------------------------------------------------------------------

### `CohortDefinition$asJSON()`

returns the JSON string for this R6 class

#### Usage

    CohortDefinition$asJSON()

#### Returns

A JSON string representing the `CohortDefinition` object.

------------------------------------------------------------------------

### `CohortDefinition$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CohortDefinition$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
