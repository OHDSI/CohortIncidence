# R6 Class Representing a DataRange

The DateRange class, encapsulating the startDate and endDate of a date
range.

## Value

A `DateRange` R6 object storing `startDate` and `endDate` as
`YYYY-MM-DD` strings.

## Details

This class is used to specify a DateRange, with start and end dates
specified as strings formatted as YYYY-MM-DD.

## Active bindings

- `startDate`:

  a character with format YYYY-MM-DD to be used as the date range's
  start date.

- `endDate`:

  a character with format YYYY-MM-DD to be used as the date range's end
  date.

## Methods

### Public methods

- [`DateRange$new()`](#method-DateRange-initialize)

- [`DateRange$toList()`](#method-DateRange-toList)

- [`DateRange$asJSON()`](#method-DateRange-asJSON)

- [`DateRange$clone()`](#method-DateRange-clone)

------------------------------------------------------------------------

### `DateRange$new()`

creates a new instance, using the provided data param if provided.

#### Usage

    DateRange$new(data = list())

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

#### Returns

A new `DateRange` object initialized from a list or JSON string.

------------------------------------------------------------------------

### `DateRange$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    DateRange$toList()

#### Returns

A named list with `startDate` and `endDate` fields.

------------------------------------------------------------------------

### `DateRange$asJSON()`

returns the JSON string for this R6 class

#### Usage

    DateRange$asJSON()

#### Returns

A JSON string representation of the `DateRange` object.

------------------------------------------------------------------------

### `DateRange$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DateRange$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
