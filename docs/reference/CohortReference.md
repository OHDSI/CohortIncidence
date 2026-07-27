# R6 Class Representing a CohortReference

The CohortReference class, encapsulating the id, name and descritpion
fields that refernces a cohort definition.

## Details

This class is used to reference a cohort definition by ID, while
providing a way to substitute a name for this specific reference.

Note, when serializing with a library such as jsonlite, first call
toList() on the R6 class before calling jsonlite::toJSON().

## Active bindings

- `id`:

  the cohort id being referenced

- `name`:

  the name for the cohort to be used in this reference.

- `description`:

  A description for this Cohort Reference.

## Methods

### Public methods

- [`CohortReference$new()`](#method-CohortReference-initialize)

- [`CohortReference$toList()`](#method-CohortReference-toList)

- [`CohortReference$asJSON()`](#method-CohortReference-asJSON)

- [`CohortReference$clone()`](#method-CohortReference-clone)

------------------------------------------------------------------------

### `CohortReference$new()`

creates a new instance, using the provided data param if provided.

#### Usage

    CohortReference$new(data = list())

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

------------------------------------------------------------------------

### `CohortReference$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    CohortReference$toList()

------------------------------------------------------------------------

### `CohortReference$asJSON()`

returns the JSON string for this R6 class

#### Usage

    CohortReference$asJSON()

------------------------------------------------------------------------

### `CohortReference$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CohortReference$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
