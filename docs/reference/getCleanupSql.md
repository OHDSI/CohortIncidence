# Gets the sql that drops the results tables

Gets the sql that drops the results tables

## Usage

``` r
getCleanupSql(useTempTables = FALSE)
```

## Arguments

- useTempTables:

  if TRUE, then temp table notation will be used.

## Value

SQL code in MS Sql Server dialect. If analysis will run on another DBMS,
translate the SQL with
[`SqlRender::translateSql()`](https://ohdsi.github.io/SqlRender/reference/translateSql.html)
before execution.
