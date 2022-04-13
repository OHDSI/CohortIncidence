test_that("executeAnalysis() works", {
  cdmDbFile<- withr::local_tempfile(fileext=".sqlite");
  initDb(cdmDbFile, "resources/dbtest");
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sqlite", server = cdmDbFile);
  designJSON <-readr::read_file(testthat::test_path("resources/strataAllTest.json"));
  buildOptions <- CohortIncidence::buildOptions(cohortTable = "main.cohort",
                                                cdmDatabaseSchema = "main",
                                                refId = 1);
  
  executeResults <- CohortIncidence::executeAnalysis(connectionDetails = connectionDetails,
                                                     incidenceDesign = designJSON,
                                                     buildOptions = buildOptions);
  
  browser();
})
