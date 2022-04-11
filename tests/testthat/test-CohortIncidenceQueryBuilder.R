test_that("buildOptions works", {
  buildOptions <- CohortIncidence::buildOptions(cohortTable = "demoCohortSchema.cohort",
                                                outcomeCohortTable = "outcomeCohortSchema.cohort",
                                                subgroupCohortTable = "subgroupCohortSchema.cohort",
                                                cdmDatabaseSchema = "mycdm",
                                                resultsDatabaseSchema = "myresults",
                                                refId = 1);
  
  expect_equal(as.character(buildOptions$targetCohortTable), "demoCohortSchema.cohort")
  expect_equal(as.character(buildOptions$outcomeCohortTable), "outcomeCohortSchema.cohort")
  expect_equal(as.character(buildOptions$subgroupCohortTable), "subgroupCohortSchema.cohort")
  expect_equal(as.character(buildOptions$useTempTables), "FALSE")
  
})

test_that("buildOptions correct null values", {
  buildOptions <- CohortIncidence::buildOptions();
  
  expect_true(rJava::is.jnull(buildOptions$targetCohortTable))
  expect_true(rJava::is.jnull(buildOptions$outcomeCohortTable))
  expect_true(rJava::is.jnull(buildOptions$subgroupCohortTable))
  expect_true(rJava::is.jnull(buildOptions$databaseName))
  expect_true(rJava::is.jnull(buildOptions$cdmSchema))
  expect_true(rJava::is.jnull(buildOptions$resultsSchema ))
  expect_true(rJava::is.jnull(buildOptions$vocabularySchema))
  expect_false(buildOptions$useTempTables)

})

test_that("build query works", {
  
  t1 <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1");
  
  o1 <- CohortIncidence::createOutcomeDef(id=1,name="Outcome 1, 30d Clean", 
                                          cohortId =2,
                                          cleanWindow =30);
  
  tar1 <- CohortIncidence::createTimeAtRiskDef(id=1, 
                                               startDateField="StartDate", 
                                               endDateField="StartDate", 
                                               endOffset=30);
  
  # Note: c() is used when dealing with an array of numbers, 
  # later we use list() when dealing with an array of objects
  analysis1 <- CohortIncidence::createIncidenceAnalysis(targets = c(t1$id),
                                                        outcomes = c(o1$id),
                                                        tars = c(tar1$id));
  
  subgroup1 <- CohortIncidence::createCohortSubgroup(id=1, name="Subgroup 1", cohortRef = createCohortRef(id=300));
  
  
  # Create Design (note use of list() here):
  irDesign <- CohortIncidence::createIncidenceDesign(targetDefs = list(t1),
                                                     outcomeDefs = list(o1),
                                                     tars=list(tar1),
                                                     analysisList = list(analysis1),
                                                     subgroups = list(subgroup1));

  buildOptions <- CohortIncidence::buildOptions(cohortTable = "demoCohortSchema.cohort",
                                                cdmDatabaseSchema = "mycdm",
                                                resultsDatabaseSchema = "myresults",
                                                refId = 1)
  
  analysisSql <- CohortIncidence::buildQuery(incidenceDesign =  as.character(jsonlite::toJSON(irDesign)),
                                             buildOptions = buildOptions);    
  
  expect_true(nchar(analysisSql) > 0)

})