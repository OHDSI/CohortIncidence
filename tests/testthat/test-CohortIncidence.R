test_that("executeAnalysis() works", {
  
  #skip('No suitable test DB implementaton for this test.')

  connectionDetails <- Eunomia::getEunomiaConnectionDetails()
  Eunomia::createCohorts(connectionDetails)

  designJSON <-readr::read_file(testthat::test_path("resources/strataAllTest.json"));
  buildOptions <- CohortIncidence::buildOptions(cohortTable = "main.cohort",
                                                cdmDatabaseSchema = "main",
                                                refId = 1);
  
  executeResults <- CohortIncidence::executeAnalysis(connectionDetails = connectionDetails,
                                                     incidenceDesign = designJSON,
                                                     buildOptions = buildOptions);
  requiredNames <- c("incidence_summary", "target_def", "outcome_def", "tar_def", "age_group_def", "subgroup_def")
  expect_true(all(requiredNames %in% names(executeResults)))
  expect_true(all(vapply(executeResults, is.data.frame, logical(1))))
})

test_that("result tables can be streamed to Andromeda", {
  skip_if_not_installed("Andromeda", minimum_version = "1.0.0")

  databaseFile <- tempfile(fileext = ".duckdb")
  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = "duckdb",
    server = databaseFile
  )
  connection <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection), add = TRUE)

  requiredNames <- c("incidence_summary", "target_def", "outcome_def", "tar_def", "age_group_def", "subgroup_def")
  for (tableName in requiredNames) {
    ddl <- SqlRender::translate(
      sprintf("CREATE TABLE #%s (id INT)", tableName),
      targetDialect = "duckdb"
    )
    DatabaseConnector::executeSql(connection, ddl)
  }

  executeResults <- CohortIncidence:::.downloadResults(
    connection = connection,
    targetDialect = "duckdb",
    resultType = "andromeda"
  )
  on.exit(Andromeda::close(executeResults), add = TRUE)

  expect_s4_class(executeResults, "Andromeda")
  expect_true(all(requiredNames %in% names(executeResults)))
  expect_true(all(vapply(requiredNames, function(tableName) {
    Andromeda::isAndromedaTable(executeResults[[tableName]])
  }, logical(1))))
})

test_that("executeAnalysis() validates resultType", {
  expect_error(
    CohortIncidence::executeAnalysis(resultType = "invalid"),
    "'arg' should be one of"
  )
})
