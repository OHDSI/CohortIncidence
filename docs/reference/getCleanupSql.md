# Gets the sql that drops the results tables

Gets the sql that drops the results tables

## Usage

``` r
getCleanupSql(useTempTables = F)
```

## Arguments

- useTempTables:

  if true, then temp table notation will be used.

## Value

SQL code in MS Sql Server dialect, if it's required to run analysis on
another DBMS you have to use
[`translateSql`](https://ohdsi.github.io/SqlRender/reference/translateSql.html)
function in the SqlRender package.
