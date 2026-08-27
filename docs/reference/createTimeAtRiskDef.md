# Creates R6 object for TimeAtRisk

Creates R6 object for TimeAtRisk

## Usage

``` r
createTimeAtRiskDef(
  id,
  startWith = "start",
  startOffset = 0,
  endWith = "end",
  endOffset = 0
)
```

## Arguments

- id:

  the unique identifier for this outcome definition

- startWith:

  Specifies the field (start or end) to offset from for the TAR start.
  Allowed values: 'start', 'end'

- startOffset:

  The number of days to offset for the TAR start, defaults to 0.

- endWith:

  Specifies the field (start or end) to offset from for the TAR end.
  Allowed values: 'start', 'end'

- endOffset:

  The number of days to offset for the TAR start, defaults to 0.

## Value

A `TimeAtRisk` R6 object describing the TAR start and end anchors plus
their offsets. The serialized form contains a `start` and `end` field,
each with a `dateField` and `offset`.
