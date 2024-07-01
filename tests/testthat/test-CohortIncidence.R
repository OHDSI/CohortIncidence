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
  requiredNames <- c("incidenceSummary", "targetDef", "outcomeDef", "tarDef", "ageGroupDef", "subgroupDef")
  expect_true(all(requiredNames %in% names(executeResults)))
})
