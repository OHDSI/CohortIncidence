# R6 Class Representing a Cohort Subgroup definition

The CohortSubgroup class, encapsulating the id, name, description, and
CohortRef.

## Details

This class is used to specify a cohort subgroup to be used in the
analysis. A TAR will be considered part of the subgroup if the TAR
starts between the subgroup's cohort start and cohort end.

Note, when serializing with a library such as jsonlite, first call
toList() on the R6 class before calling jsonlite::toJSON().

## Active bindings

- `id`:

  an integer uniquely identifying this subgroup

- `name`:

  The name to use for this cohort reference

- `description`:

  The description for this subgroup

- `cohort`:

  the cohort used to represent this subgroup. Must be class
  CohortReference

## Methods

### Public methods

- [`CohortSubgroup$new()`](#method-CohortSubgroup-initialize)

- [`CohortSubgroup$toList()`](#method-CohortSubgroup-toList)

- [`CohortSubgroup$asJSON()`](#method-CohortSubgroup-asJSON)

- [`CohortSubgroup$clone()`](#method-CohortSubgroup-clone)

------------------------------------------------------------------------

### `CohortSubgroup$new()`

creates a new instance, using the provided data param if provided. The
JSON takes the form: "id":1,"name":"some name","description":"some
description","cohort":"id":99, "name":"cohort"

#### Usage

    CohortSubgroup$new(data = list(CohortSubgroup = list()))

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

------------------------------------------------------------------------

### `CohortSubgroup$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    CohortSubgroup$toList()

------------------------------------------------------------------------

### `CohortSubgroup$asJSON()`

returns the JSON string for this R6 class

#### Usage

    CohortSubgroup$asJSON()

------------------------------------------------------------------------

### `CohortSubgroup$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CohortSubgroup$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
