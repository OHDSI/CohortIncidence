# R6 Class Representing the Stratification Settings of a IncidenceDesign

The StrataSettings class, encapsulating the age, gender and start-year +
age breaks settings.

## Details

This class is used to specify the stratification settings for an
analysis. The settings can indicate the statistics should be grouped by
the age, gender, or start year, and any combination of those selections.

Example: age = T and gender = T will produce statisics by age, by
gender, and by age and gender.

Note, when serializing with a library such as jsonlite, first call
toList() on the R6 class before calling jsonlite::toJSON().

## Active bindings

- `byAge`:

  enables stratification by age

- `byGender`:

  enables stratification by gender

- `byYear`:

  enables stratification by start year of TAR

- `ageBreaks`:

  a list of age breaks with at least 1 member

- `ageBreakList`:

  a list of age breaks

## Methods

### Public methods

- [`StrataSettings$new()`](#method-StrataSettings-initialize)

- [`StrataSettings$toList()`](#method-StrataSettings-toList)

- [`StrataSettings$asJSON()`](#method-StrataSettings-asJSON)

- [`StrataSettings$clone()`](#method-StrataSettings-clone)

------------------------------------------------------------------------

### `StrataSettings$new()`

creates a new instance, using the provided data param if provided.

#### Usage

    StrataSettings$new(data = list())

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

------------------------------------------------------------------------

### `StrataSettings$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    StrataSettings$toList()

------------------------------------------------------------------------

### `StrataSettings$asJSON()`

returns the JSON string for this R6 class

#### Usage

    StrataSettings$asJSON()

------------------------------------------------------------------------

### `StrataSettings$clone()`

The objects of this class are cloneable with this method.

#### Usage

    StrataSettings$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
