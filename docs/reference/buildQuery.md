# Builds SQL code to run analyses according given Cohort Characterization design

Builds SQL code to run analyses according given Cohort Characterization
design

## Usage

``` r
buildQuery(incidenceDesign, buildOptions)
```

## Arguments

- incidenceDesign:

  A string object containing valid JSON that represents cohort incidence
  design

- buildOptions:

  the parameters to use in building the analysis queries, created by
  buildOptions()

## Value

SQL code in MS Sql Server dialect, if it's required to run analysis on
another DBMS you have to use
[`translateSql`](https://ohdsi.github.io/SqlRender/reference/translateSql.html)
function in the SqlRender package.
