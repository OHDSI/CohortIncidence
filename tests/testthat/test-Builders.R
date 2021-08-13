library(jsonlite);

test_that("createCohortRef works", {
  no_desc <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1");
  expect_equal(as.character(jsonlite::toJSON(no_desc)), '{"id":1,"name":"Target cohort 1"}')
  
  desc <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1", description = "Some Description");
  expect_equal(as.character(jsonlite::toJSON(desc)), '{"id":1,"name":"Target cohort 1","description":"Some Description"}')
})


test_that("createOutcomeDef works", {
  t1 <- CohortIncidence::createOutcomeDef(id=1, name="Outcome 1");
  expect_equal(as.character(jsonlite::toJSON(t1)), '{"id":1,"name":"Outcome 1","cohortId":0,"cleanWindow":0}')
  
  t2 <- CohortIncidence::createOutcomeDef(id=1, name="Outcome 1", cohortId=2, excludeCohortId=3);
  expect_equal(as.character(jsonlite::toJSON(t2)), '{"id":1,"name":"Outcome 1","cohortId":2,"cleanWindow":0,"excludeCohortId":3}')
})

test_that("createTimeAtRiskDef works", {
  t1 <- CohortIncidence::createTimeAtRiskDef(id=1); #default values for start and end date will be used
  expect_equal(as.character(jsonlite::toJSON(t1)), '{"id":1,"start":{"dateField":"StartDate","offset":0},"end":{"dateField":"EndDate","offset":0}}')
  t2 <- CohortIncidence::createTimeAtRiskDef(id=1, startDateField = "StartDate", startOffset = 1); #setting start date
  expect_equal(as.character(jsonlite::toJSON(t2)), '{"id":1,"start":{"dateField":"StartDate","offset":1},"end":{"dateField":"EndDate","offset":0}}')
  t3 <-   CohortIncidence::createTimeAtRiskDef(id=1, startDateField = "StartDate", startOffset = 1, endDateField = "StartDate", endOffset = 30); #setting all dats
  expect_equal(as.character(jsonlite::toJSON(t3)), '{"id":1,"start":{"dateField":"StartDate","offset":1},"end":{"dateField":"StartDate","offset":30}}')
  
  # test validate
  expect_error({
    CohortIncidence::createTimeAtRiskDef(id=1, startDateField = "xDate", startOffset = 1)
  }, "Invalid startDateField option:xDate. Valid options are StartDate, EndDate.")
  expect_error({
    CohortIncidence::createTimeAtRiskDef(id=1, endDateField = "xDate", startOffset = 1)
  }, "Invalid endDateField option:xDate. Valid options are StartDate, EndDate.")
  
})

test_that("createIncidenceAnalysis works", {
  t1 <- CohortIncidence::createIncidenceAnalysis(targets = c(1),
                                                 outcomes = c(2),
                                                 tars = c(3));
  expect_equal(as.character(jsonlite::toJSON(t1)), '{"targets":[1],"outcomes":[2],"tars":[3]}')
  t2 <- CohortIncidence::createIncidenceAnalysis(targets = c(1),
                                                 outcomes = c(2),
                                                 tars = c(3:5));
  expect_equal(as.character(jsonlite::toJSON(t2)), '{"targets":[1],"outcomes":[2],"tars":[3,4,5]}')
  
})

test_that("createIncidenceDesign works", {

  target1 <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1");
  
  outcomeDef1 <- CohortIncidence::createOutcomeDef(id=1,name="Outcome 1, 30d Clean", 
                                                   cohortId =2,
                                                   cleanWindow =30);
  tarDef1 <- CohortIncidence::createTimeAtRiskDef(id=1, startDateField="StartDate", endDateField="StartDate", endOffset=30);

  analysis1 <- CohortIncidence::createIncidenceAnalysis(targets = c(target1$id),
                                                        outcomes = c(outcomeDef1$id),
                                                        tars = c(tarDef1$id));
  
  irDesign <- CohortIncidence::createIncidenceDesign(
    targetDefs = list(target1),
    outcomeDefs = list(outcomeDef1),
    tars=list(tarDef1),
    analysisList = list(analysis1));

  expectedJson <- paste(readLines("resources/serializeDesignTest.json"),collapse="\n");
  
  expect_equal(as.character(jsonlite::toJSON(irDesign,pretty = TRUE)), expectedJson);
  
  # adding a subgroup
  subgroup1 <- CohortIncidence::createCohortSubgroup(id=1, name="Subgroup 1", cohortRef = createCohortRef(id=100));
  
  irDesign <- CohortIncidence::createIncidenceDesign(
    targetDefs = list(target1),
    outcomeDefs = list(outcomeDef1),
    tars=list(tarDef1),
    analysisList = list(analysis1),
    subgroups = list(subgroup1));

  expectedSubgroupJson <- paste(readLines("resources/serializeDesignSubgroupTest.json"),collapse="\n");
  
  expect_equal(as.character(jsonlite::toJSON(irDesign,pretty = TRUE)), expectedSubgroupJson);
  
})

test_that("createCohortSubgroup works", {
  subgroup1 <- CohortIncidence::createCohortSubgroup(id=1, name="Subgroup 1", cohortRef = createCohortRef(id=100));
  
  expect_equal(as.character(jsonlite::toJSON(subgroup1)), '{"CohortSubgroup":{"id":1,"name":"Subgroup 1","cohort":{"id":100}}}');
  
  expect_equal(as.character(jsonlite::toJSON(list(subgroup1))), '[{"CohortSubgroup":{"id":1,"name":"Subgroup 1","cohort":{"id":100}}}]');
  
})