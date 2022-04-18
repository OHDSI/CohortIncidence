test_that("executeAnalysis() works", {
  
  skip('No suitable test DB implementaton for this test.')
  cdmDbFile<- withr::local_tempfile(fileext=".duckdb");
  initDb(cdmDbFile, "resources/dbtest");
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "duckdb", server = cdmDbFile);
  designJSON <-readr::read_file(testthat::test_path("resources/strataAllTest.json"));
  buildOptions <- CohortIncidence::buildOptions(cohortTable = "main.cohort",
                                                cdmDatabaseSchema = "main",
                                                refId = 1);
  
  executeResults <- CohortIncidence::executeAnalysis(connectionDetails = connectionDetails,
                                                     incidenceDesign = designJSON,
                                                     buildOptions = buildOptions);
  
})
