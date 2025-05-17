library(jsonlite);

test_that("createCohortRef works", {
  no_desc <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1");
  expect_equal(as.character(no_desc$asJSON()), '{"id":1,"name":"Target cohort 1"}')
  
  desc <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1", description = "Some Description");
  expect_equal(as.character(desc$asJSON()), '{"id":1,"name":"Target cohort 1","description":"Some Description"}')
  
  # check NA fields
  expect_equal(no_desc$id, 1)
  expect_equal(no_desc$name, "Target cohort 1")
  expect_equal(is.na(no_desc$description), TRUE)
})


test_that("createOutcomeDef works", {
  t1 <- CohortIncidence::createOutcomeDef(id=1, name="Outcome 1");
  expect_equal(as.character(t1$asJSON()), '{"id":1,"name":"Outcome 1","cleanWindow":0}')
  
  t2 <- CohortIncidence::createOutcomeDef(id=1, name="Outcome 1", cohortId=2, excludeCohortId=3);
  expect_equal(as.character(t2$asJSON()), '{"id":1,"name":"Outcome 1","cohortId":2,"cleanWindow":0,"excludeCohortId":3}')
  
  # check NA fields
  expect_equal(t1$id, 1)
  expect_equal(t1$name, "Outcome 1")
  expect_equal(is.na(t1$cohortId), TRUE)
  expect_equal(t1$cleanWindow, 0)
  expect_equal(is.na(t1$excludeCohortId), TRUE)
  
})

test_that("createTimeAtRiskDef works", {
  t1 <- CohortIncidence::createTimeAtRiskDef(id=1); #default values for start and end date will be used
  expect_equal(as.character(t1$asJSON()), '{"id":1,"start":{"dateField":"start","offset":0},"end":{"dateField":"end","offset":0}}')
  t2 <- CohortIncidence::createTimeAtRiskDef(id=1, startWith = "start", startOffset = 1); #setting start date
  expect_equal(as.character(t2$asJSON()), '{"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"end","offset":0}}')
  t3 <-   CohortIncidence::createTimeAtRiskDef(id=1, startWith = "start", startOffset = 1, endWith = "start", endOffset = 30); #setting all dates
  expect_equal(as.character(t3$asJSON()), '{"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"start","offset":30}}')
  
  
  # test validate
  expect_error({
    CohortIncidence::createTimeAtRiskDef(id=1, startWith = "xDate", startOffset = 1)
  }, "Assertion on 'startWith' failed: Must be element of set \\{'start','end'\\}")
  expect_error({
    CohortIncidence::createTimeAtRiskDef(id=1, endWith = "xDate", startOffset = 1)
  }, "Assertion on 'endWith' failed: Must be element of set \\{'start','end'\\}")
  
  # Test defaults from missing JSON
  t4 <- CohortIncidence::TimeAtRisk$new('{"id": 1}')
  expect_equal(t4$id, 1)
  expect_equal(t4$startWith, "start")
  expect_equal(t4$startOffset, 0)
  expect_equal(t4$endWith, "end")
  expect_equal(t4$endOffset, 0)
})

test_that("createIncidenceAnalysis works", {
  t1 <- CohortIncidence::createIncidenceAnalysis(targets = c(1),
                                                 outcomes = c(2),
                                                 tars = c(3));
  expect_equal(as.character(t1$asJSON()), '{"targets":[1],"outcomes":[2],"tars":[3]}')
  t2 <- CohortIncidence::createIncidenceAnalysis(targets = c(1),
                                                 outcomes = c(2),
                                                 tars = c(3:5));
  expect_equal(as.character(t2$asJSON()), '{"targets":[1],"outcomes":[2],"tars":[3,4,5]}')
  
  # check accessors
  expect_equal(t1$targets, c(1))
  expect_equal(t1$outcomes, c(2))
  expect_equal(t1$tars, c(3))
  
})

test_that("createIncidenceDesign works", {

  target1 <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1");
  
  outcomeDef1 <- CohortIncidence::createOutcomeDef(id=1,name="Outcome 1, 30d Clean", 
                                                   cohortId =2,
                                                   cleanWindow =30);
  tarDef1 <- CohortIncidence::createTimeAtRiskDef(id=1, startWith="start", endWith="start", endOffset=30);

  analysis1 <- CohortIncidence::createIncidenceAnalysis(targets = c(target1$id),
                                                        outcomes = c(outcomeDef1$id),
                                                        tars = c(tarDef1$id));
  
  irDesign <- CohortIncidence::createIncidenceDesign(
    cohortDefs = list(),
    conceptSets = list(),
    subgroups = list(),
    targetDefs = list(target1),
    outcomeDefs = list(outcomeDef1),
    tars=list(tarDef1),
    analysisList = list(analysis1));

  expectedJson <- paste(readLines("resources/serializeDesignTest.json"),collapse="\n");
  
  expect_equal(as.character(irDesign$asJSON(pretty = TRUE)), expectedJson);
  
  # adding a subgroup
  subgroup1 <- CohortIncidence::createCohortSubgroup(id=1, name="Subgroup 1", cohortRef = createCohortRef(id=100));
  
  irDesign <- CohortIncidence::createIncidenceDesign(
    cohortDefs = list(),
    conceptSets = list(),
    targetDefs = list(target1),
    outcomeDefs = list(outcomeDef1),
    tars=list(tarDef1),
    analysisList = list(analysis1),
    subgroups = list(subgroup1));

  expectedSubgroupJson <- paste(readLines("resources/serializeDesignSubgroupTest.json"),collapse="\n");
  
  expect_equal(as.character(irDesign$asJSON(pretty = TRUE)), expectedSubgroupJson);
  
  # check accessors
  expect_equal(irDesign$cohortDefs, list())
  expect_equal(irDesign$conceptSets, list())
  expect_equal(irDesign$targetDefs, list(target1))
  expect_equal(irDesign$outcomeDefs, list(outcomeDef1))
  expect_equal(irDesign$timeAtRiskDefs, list(tarDef1))
  expect_equal(irDesign$analysisList, list(analysis1))
  expect_equal(irDesign$subgroups, list(subgroup1))
  
})

test_that("createCohortSubgroup works", {
  subgroup1 <- CohortIncidence::createCohortSubgroup(id=1, name="Subgroup 1", cohortRef = createCohortRef(id=100));
  
  expect_equal(as.character(subgroup1$asJSON()), '{"CohortSubgroup":{"id":1,"name":"Subgroup 1","cohort":{"id":100}}}');
  
  expect_equal(as.character(jsonlite::toJSON(list(subgroup1$toList()))), '[{"CohortSubgroup":{"id":1,"name":"Subgroup 1","cohort":{"id":100}}}]');
  
})

test_that("createStrataSettings works", {
  strataSettings <- CohortIncidence::createStrataSettings(byYear=T)
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":false,"byGender":false,"byYear":true}');
  
  strataSettings <- CohortIncidence::createStrataSettings(byAge=T, ageBreaks = list(17,34,65))
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":true,"byGender":false,"byYear":false,"ageBreaks":[17,34,65]}');

  strataSettings <- CohortIncidence::createStrataSettings(byAge=T, ageBreakList = list(list(17), list(17,34,65)))
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":true,"byGender":false,"byYear":false,"ageBreakList":[[17],[17,34,65]]}');
  
})
