test_that("buildOptions works", {
  buildOptions <- CohortIncidence::buildOptions(cohortTable = "demoCohortSchema.cohort",
                                                outcomeCohortTable = "outcomeCohortSchema.cohort",
                                                subgroupCohortTable = "subgroupCohortSchema.cohort",
                                                cdmSchema = "mycdm",
                                                resultsSchema = "myresults",
                                                refId = 1);
  
  expect_equal(as.character(buildOptions$targetCohortTable), "demoCohortSchema.cohort")
  expect_equal(as.character(buildOptions$outcomeCohortTable), "outcomeCohortSchema.cohort")
  expect_equal(as.character(buildOptions$subgroupCohortTable), "subgroupCohortSchema.cohort")

})