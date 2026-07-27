# R6 Class Representing an Time-at-Risk (TAR) definition

The TimeAtRisk class, encapsulating the id, startWith, startOffset,
endWith and endOffset

## Details

This class is used to specify a time-at-risk (TAR) definition. A TAR is
defined by choosing the start/end date of a cohort to start with (plus
an offset), and a start/end date of the cohort to end with (plus an
offset).

Note, when serializing with a library such as jsonlite, first call
toList() on the R6 class before calling jsonlite::toJSON().

## Active bindings

- `id`:

  an integer uniquely identifying this time at risk

- `startWith`:

  the cohort date to start the time-at-risk. Can be either "start" or
  "end".

- `startOffset`:

  The number of days added to the date specified in startWith.

- `endWith`:

  the cohort date to start the time-at-risk. Can be either "start" or
  "end".

- `endOffset`:

  The number of days added to the date specified in startWith.

## Methods

### Public methods

- [`TimeAtRisk$new()`](#method-TimeAtRisk-initialize)

- [`TimeAtRisk$toList()`](#method-TimeAtRisk-toList)

- [`TimeAtRisk$asJSON()`](#method-TimeAtRisk-asJSON)

- [`TimeAtRisk$clone()`](#method-TimeAtRisk-clone)

------------------------------------------------------------------------

### `TimeAtRisk$new()`

creates a new instance, using the provided data param if provided. The
JSON takes the form:
"id":1,"start":"dateField":"start","offset":1,"end":"dateField":"start","offset":30

#### Usage

    TimeAtRisk$new(data = list())

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

------------------------------------------------------------------------

### `TimeAtRisk$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    TimeAtRisk$toList()

------------------------------------------------------------------------

### `TimeAtRisk$asJSON()`

returns the JSON string for this R6 class

#### Usage

    TimeAtRisk$asJSON()

------------------------------------------------------------------------

### `TimeAtRisk$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeAtRisk$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
