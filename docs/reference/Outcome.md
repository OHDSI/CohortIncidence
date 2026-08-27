# R6 Class Representing an Outcome definition

The Outcome class, encapsulating the id, name, outcome cohortId,
exclusion cohortId, and clean window.

## Value

An `Outcome` R6 object describing one outcome definition, including the
outcome cohort id, clean window, and optional exclusion cohort id.

## Details

This class is used to specify an outcome definition. The outcome id is
distinct from the outcome cohort ID in that you can define multiple
outcomes that use the same outcome cohort with different clean windows
or exclusion cohort.

Note, when serializing with a library such as jsonlite, first call
toList() on the R6 class before calling jsonlite::toJSON().

## Active bindings

- `id`:

  an integer uniquely identifying this outcome definition

- `name`:

  the name given to this outcome definition

- `cohortId`:

  The outcome cohort ID for this outcome.

- `cleanWindow`:

  The clean window for this outcome.

- `excludeCohortId`:

  The cohort that will be used to exclude time at risk.

## Methods

### Public methods

- [`Outcome$new()`](#method-Outcome-initialize)

- [`Outcome$toList()`](#method-Outcome-toList)

- [`Outcome$asJSON()`](#method-Outcome-asJSON)

- [`Outcome$clone()`](#method-Outcome-clone)

------------------------------------------------------------------------

### `Outcome$new()`

creates a new instance, using the provided data param if provided.

#### Usage

    Outcome$new(data = list())

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

#### Returns

A new `Outcome` object initialized from a list or JSON string.

------------------------------------------------------------------------

### `Outcome$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    Outcome$toList()

#### Returns

A named list with `id`, `name`, `cohortId`, `cleanWindow`, and
`excludeCohortId` fields.

------------------------------------------------------------------------

### `Outcome$asJSON()`

returns the JSON string for this R6 class

#### Usage

    Outcome$asJSON()

#### Returns

A JSON string representation of the `Outcome` object.

------------------------------------------------------------------------

### `Outcome$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Outcome$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
