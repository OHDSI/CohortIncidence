# Builds the BuilderOptions jObject with the specified paramaters

Builds the BuilderOptions jObject with the specified paramaters

## Usage

``` r
buildOptions(
  cohortTable,
  outcomeCohortTable = cohortTable,
  subgroupCohortTable = cohortTable,
  sourceName,
  cdmDatabaseSchema,
  resultsDatabaseSchema,
  vocabularySchema = cdmDatabaseSchema,
  useTempTables = FALSE,
  refId
)
```

## Arguments

- cohortTable:

  The name of table with cohorts

- outcomeCohortTable:

  The name of table with outcome cohorts, defaults to cohortTable param.

- subgroupCohortTable:

  The name of table with subgroup cohorts, defaults to cohortTable
  param.

- sourceName:

  A value to inject to the results table for the source name.

- cdmDatabaseSchema:

  the name of schema containing data in CDM format

- resultsDatabaseSchema:

  the name of schema where results would be placed

- vocabularySchema:

  the name of schema with vocabulary tables, defaults to
  cdmDatabaseSchema param

- useTempTables:

  use temp tables instead of a results schema.

- refId:

  A number tagged to the results for retrieval purposes.

## Value

a BuilderOptions object used in buildQuery.
