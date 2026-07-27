# R6 Class Representing a IncidenceAnalysis

The IncidenceAnalysis class, encapsulating the targets, outcomes and
tars.

## Details

The targets, outcomes and tars fields are referencing IDs of the
targetDef, outcomeDef and tarDefs R6 classes.

Note, when serializing with a library such as jsonlite, first call
toList() on the R6 class before calling jsonlite::toJSON().

## Active bindings

- `targets`:

  A vector of target IDs from target definitions. Must be a vector.

- `outcomes`:

  A vector of outcome IDs from outcome definitions. Must be a vector.

- `tars`:

  A vector of TAR IDs from time-at-risk definitions. Must be a vector.

## Methods

### Public methods

- [`IncidenceAnalysis$new()`](#method-IncidenceAnalysis-initialize)

- [`IncidenceAnalysis$toList()`](#method-IncidenceAnalysis-toList)

- [`IncidenceAnalysis$asJSON()`](#method-IncidenceAnalysis-asJSON)

- [`IncidenceAnalysis$clone()`](#method-IncidenceAnalysis-clone)

------------------------------------------------------------------------

### `IncidenceAnalysis$new()`

creates a new instance, using the provided data param if provided.

#### Usage

    IncidenceAnalysis$new(data = list())

#### Arguments

- `data`:

  the data (as a json string or list) to initialize with

------------------------------------------------------------------------

### `IncidenceAnalysis$toList()`

returns the R6 class elements as a list for use in jsonlite::toJSON()

#### Usage

    IncidenceAnalysis$toList()

------------------------------------------------------------------------

### `IncidenceAnalysis$asJSON()`

returns the JSON string for this R6 class

#### Usage

    IncidenceAnalysis$asJSON()

------------------------------------------------------------------------

### `IncidenceAnalysis$clone()`

The objects of this class are cloneable with this method.

#### Usage

    IncidenceAnalysis$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
