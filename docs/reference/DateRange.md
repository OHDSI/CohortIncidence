# R6 Class Representing a DataRange

The DateRange class, encapsulating the startDate and endDate of a date
range.

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

------------------------------------------------------------------------

### `DateRange$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    DateRange$toList()

------------------------------------------------------------------------

### `DateRange$asJSON()`

returns the JSON string for this R6 class

#### Usage

    DateRange$asJSON()

------------------------------------------------------------------------

### `DateRange$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DateRange$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
