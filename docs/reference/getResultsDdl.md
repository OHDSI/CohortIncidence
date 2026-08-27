# Gets the results schema DDL for Incidence Analysis

Gets the results schema DDL for Incidence Analysis

## Usage

``` r
getResultsDdl(useTempTables = FALSE)
```

## Arguments

- useTempTables:

  if TRUE, then temp table notation will be used.

## Value

SQL code in MS Sql Server dialect, if it's required to run analysis on
another DBMS you have to use
[`translateSql`](https://ohdsi.github.io/SqlRender/reference/translateSql.html)
function in the SqlRender package.
