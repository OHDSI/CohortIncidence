test_that("CohortReference R6 Class Works", {
  cohortRef <- CohortIncidence::CohortReference$new()
  cohortRef$id <- 1
  cohortRef$name <- "Target cohort 1"
  expect_equal(as.character(cohortRef$asJSON()), '{"id":1,"name":"Target cohort 1"}')
  
  cohortRef$description <- "Cohort 1 Description"
  expect_equal(as.character(cohortRef$asJSON()), '{"id":1,"name":"Target cohort 1","description":"Cohort 1 Description"}')
  
  expect_error(cohortRef$id <- c(1,2,3), "Assertion on 'id' failed: Must have length 1.")
  expect_error(cohortRef$id <- 'x', "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(cohortRef$id <- NULL, "Assertion on 'id' failed: Must be of type 'single integerish value'")

  # initalize from json
  expect_equal(as.character(CohortIncidence::CohortReference$new('{"id":1,"name":"Cohort 1"}')$asJSON()), '{"id":1,"name":"Cohort 1"}')
  expect_equal(as.character(CohortIncidence::CohortReference$new('{"id":1,"name":"Cohort 1","description":null}')$asJSON()), '{"id":1,"name":"Cohort 1"}')
  
  # initalize from list
  expect_equal(as.character(CohortIncidence::CohortReference$new(list(id=1, name="Cohort 1"))$asJSON()), '{"id":1,"name":"Cohort 1"}')
  expect_equal(as.character(CohortIncidence::CohortReference$new(list(id=1, name="Cohort 1", description=NA))$asJSON()), '{"id":1,"name":"Cohort 1"}')

  expect_error(CohortIncidence::CohortReference$new('{"id":"x","name":"Cohort 1"}'), "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(CohortIncidence::CohortReference$new('{"id":[1,2],"name":"Cohort 1"}'), "Assertion on 'id' failed: Must have length 1")
  expect_error(CohortIncidence::CohortReference$new('{"id":1,"name":[1,2,3]}'), "Assertion on 'name' failed: Must be of type 'character'")

})

test_that("Outcome R6 Class Works", {
  outcome <- CohortIncidence::Outcome$new()
  
  expect_equal(as.character(outcome$asJSON()), '{"cleanWindow":0}')
  
  outcome$id <- 1
  outcome$name <- "Outcome 1"
  outcome$cohortId = 99
  outcome$cleanWindow = 30
  outcome$excludeCohortId = 0

  expect_equal(as.character(outcome$asJSON()), '{"id":1,"name":"Outcome 1","cohortId":99,"cleanWindow":30,"excludeCohortId":0}')
  
  expect_error(outcome$id <- c(1,2,3), "Assertion on 'id' failed: Must have length 1.")
  expect_error(outcome$id <- 'x', "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(outcome$id <- NULL, "Assertion on 'id' failed: Must be of type 'single integerish value'")

  # initalize from json
  expect_equal(as.character(CohortIncidence::Outcome$new('{"id":1,"name":"Outcome 1"}')$asJSON()), '{"id":1,"name":"Outcome 1","cleanWindow":0}')
  expect_equal(as.character(CohortIncidence::Outcome$new('{"id":1,"name":"Cohort 1","cohortId":1}')$asJSON()), '{"id":1,"name":"Cohort 1","cohortId":1,"cleanWindow":0}')
  
  # initalize from list
  expect_equal(as.character(CohortIncidence::Outcome$new(list(id=1, name="Cohort 1"))$asJSON()), '{"id":1,"name":"Cohort 1","cleanWindow":0}')
  expect_equal(as.character(CohortIncidence::Outcome$new(list(id=1, name="Cohort 1", cohortId=1))$asJSON()), '{"id":1,"name":"Cohort 1","cohortId":1,"cleanWindow":0}')
  
  expect_error(CohortIncidence::Outcome$new('{"id":"x","name":"Cohort 1"}'), "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(CohortIncidence::Outcome$new('{"id":[1,2],"name":"Cohort 1"}'), "Assertion on 'id' failed: Must have length 1")
  expect_error(CohortIncidence::Outcome$new('{"id":1,"name":[1,2,3]}'), "Assertion on 'name' failed: Must be of type 'character'")
  
})

test_that("TimeAtRisk R6 Class works", {

  tar <- CohortIncidence::TimeAtRisk$new()
  tar$id <- 1
  expect_equal(as.character(tar$asJSON()), '{"id":1,"start":{"dateField":"start","offset":0},"end":{"dateField":"end","offset":0}}')
  
  #setting start date
  tar$startWith <- "start"
  tar$startOffset <- 1
  expect_equal(as.character(tar$asJSON()), '{"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"end","offset":0}}')
  
  #setting all dates
  tar$endWith <- "start"
  tar$endOffset <- 30
  expect_equal(as.character(tar$asJSON()), '{"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"start","offset":30}}')
  
  expect_error(tar$id <- c(1,2,3), "Assertion on 'id' failed: Must have length 1.")
  expect_error(tar$id <- 'x', "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(tar$id <- NULL, "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(tar$startWith <- "startX", "Assertion on 'startWith' failed: Must be element of set \\{'start','end'\\}")
  expect_error(tar$endWith <- "startX", "Assertion on 'endWith' failed: Must be element of set \\{'start','end'\\}")

  # initalize from json
  # {"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"start","offset":30}}
  expect_equal(as.character(
    CohortIncidence::TimeAtRisk$new('{"id":1}')$asJSON()),
    '{"id":1,"start":{"dateField":"start","offset":0},"end":{"dateField":"end","offset":0}}')
  expect_equal(as.character(
    CohortIncidence::TimeAtRisk$new('{"id":1,"start":{"dateField":"start","offset":1}}')$asJSON()),
    '{"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"end","offset":0}}')
  
  # initalize from list
  expect_equal(
    as.character(CohortIncidence::TimeAtRisk$new(list(id=1))$asJSON()),
    '{"id":1,"start":{"dateField":"start","offset":0},"end":{"dateField":"end","offset":0}}')
  expect_equal(
    as.character(CohortIncidence::TimeAtRisk$new(list(id=1, start=list("offset" = 1)))$asJSON()),
    '{"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"end","offset":0}}')
  expect_equal(
    as.character(CohortIncidence::TimeAtRisk$new(list(id=1, start=list("offset" = 1), end=list("dateField"="start", "offset"=30)))$asJSON()),
    '{"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"start","offset":30}}')
  
  expect_error(CohortIncidence::TimeAtRisk$new('{"id":"x"}'), "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(CohortIncidence::TimeAtRisk$new('{"id":[1,2]}'), "Assertion on 'id' failed: Must have length 1")
  expect_error(CohortIncidence::TimeAtRisk$new('{"id":1, "start":{"dateField":"startx"}}'), "Assertion on 'startWith' failed: Must be element of set \\{'start','end'\\}")

})

test_that("IncidenceAnalysis R6 Class Works", {
  ia <- CohortIncidence::IncidenceAnalysis$new()
  expect_equal(as.character(ia$asJSON()), '{}')
  ia$targets <- list(1,2,3)
  expect_equal(as.character(ia$asJSON()), '{"targets":[1,2,3]}')
  ia$outcomes <- list(1,2,3)
  expect_equal(as.character(ia$asJSON()), '{"targets":[1,2,3],"outcomes":[1,2,3]}')
  ia$tars <- list(1,2,3)
  expect_equal(as.character(ia$asJSON()), '{"targets":[1,2,3],"outcomes":[1,2,3],"tars":[1,2,3]}')
  expect_error(ia$targets <- list(1,"2",3), "Assertion on 'as.list\\(targets\\)' failed: May only contain the following types: \\{numeric\\}")
  expect_error(ia$outcomes <- list(1,"2",3), "Assertion on 'as.list\\(outcomes\\)' failed: May only contain the following types: \\{numeric\\}")
  expect_error(ia$tars <- list(1,"2",3), "Assertion on 'as.list\\(tars\\)' failed: May only contain the following types: \\{numeric\\}")
  
  # initalize from json
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new('{}')$asJSON()), '{}')
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new('{"targets":[1,2,3]}')$asJSON()), '{"targets":[1,2,3]}')
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new('{"targets":[1,2,3],"outcomes":[4,5,6]}')$asJSON()),
               '{"targets":[1,2,3],"outcomes":[4,5,6]}')
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new('{"targets":[1,2,3],"outcomes":[4,5,6],"tars":[7,8,9]}')$asJSON()),
               '{"targets":[1,2,3],"outcomes":[4,5,6],"tars":[7,8,9]}')
  
  # initalize from list
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new(list())$asJSON()), '{}')
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new(list("targets"=c(1,2,3)))$asJSON()), '{"targets":[1,2,3]}')
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new(list("targets"=c(1,2,3),"outcomes"=c(4,5,6)))$asJSON()),
               '{"targets":[1,2,3],"outcomes":[4,5,6]}')
  expect_equal(as.character(CohortIncidence::IncidenceAnalysis$new(list("targets"=c(1,2,3),"outcomes"=c(4,5,6),"tars"=c(7,8,9)))$asJSON()),
               '{"targets":[1,2,3],"outcomes":[4,5,6],"tars":[7,8,9]}')
  
  expect_error(CohortIncidence::IncidenceAnalysis$new(list("targets"=c(1,"x",3))), "Assertion on 'as.list\\(targets\\)' failed: May only contain the following types: \\{numeric\\}")
  expect_error(CohortIncidence::IncidenceAnalysis$new('{"targets":[1,"x",2]}'), "Assertion on 'as.list\\(targets\\)' failed: May only contain the following types: \\{numeric\\}")

})

test_that("CohortSubgroup R6 Class Works", {
  
  cohortSubgroup <- CohortIncidence::CohortSubgroup$new()

  expect_equal(as.character(cohortSubgroup$asJSON()), '{"CohortSubgroup":{}}')
  
  cohortSubgroup$id <- 1
  expect_equal(as.character(cohortSubgroup$asJSON()), '{"CohortSubgroup":{"id":1}}')
  cohortSubgroup$name <- "Subgroup 1"
  expect_equal(as.character(cohortSubgroup$asJSON()), '{"CohortSubgroup":{"id":1,"name":"Subgroup 1"}}')
  cohortSubgroup$description = "Subgroup Description."
  expect_equal(as.character(cohortSubgroup$asJSON()), '{"CohortSubgroup":{"id":1,"name":"Subgroup 1","description":"Subgroup Description."}}')

  cohortRef <- CohortIncidence::CohortReference$new()
  cohortRef$id <- 60
  cohortRef$name <- "Subgroup cohort 1"
  cohortSubgroup$cohort <- cohortRef;
  expect_equal(as.character(cohortSubgroup$asJSON()), '{"CohortSubgroup":{"id":1,"name":"Subgroup 1","description":"Subgroup Description.","cohort":{"id":60,"name":"Subgroup cohort 1"}}}')
  
  expect_error(cohortSubgroup$id <- "1", "Assertion on 'id' failed: Must be of type 'single integerish value'")
  expect_error(cohortSubgroup$name <- c(1,2), "Assertion on 'name' failed: Must be of type 'character'")
  expect_error(cohortSubgroup$description <- c(1,2), "Assertion on 'description' failed: Must be of type 'character'")
  expect_error(cohortSubgroup$cohort <- CohortIncidence::TimeAtRisk$new(), "Assertion on 'cohort' failed: Must inherit from class 'CohortReference'")
  
  # initalize from json
  expect_equal(as.character(CohortIncidence::CohortSubgroup$new('{"CohortSubgroup":{}}')$asJSON()), '{"CohortSubgroup":{}}')
  expect_equal(as.character(CohortIncidence::CohortSubgroup$new('{"CohortSubgroup":{"id":1}}')$asJSON()), '{"CohortSubgroup":{"id":1}}')
  expect_equal(as.character(CohortIncidence::CohortSubgroup$new('{"CohortSubgroup":{"id":1, "name":"subgroup name"}}')$asJSON()), 
               '{"CohortSubgroup":{"id":1,"name":"subgroup name"}}')
  expect_equal(as.character(CohortIncidence::CohortSubgroup$new('{"CohortSubgroup":{"id":1, "name":"subgroup name","cohort":{"id":60,"name":"subroup cohort"}}}')$asJSON()), 
               '{"CohortSubgroup":{"id":1,"name":"subgroup name","cohort":{"id":60,"name":"subroup cohort"}}}')

  # initalize from list
  expect_equal(as.character(CohortIncidence::CohortSubgroup$new(list("CohortSubgroup"=list()))$asJSON()), '{"CohortSubgroup":{}}')
  expect_equal(as.character(CohortIncidence::CohortSubgroup$new(list("CohortSubgroup"=list("id"=1, "name"="subgroup name")))$asJSON()),
               '{"CohortSubgroup":{"id":1,"name":"subgroup name"}}')
  expect_equal(as.character(CohortIncidence::CohortSubgroup$new(list("CohortSubgroup"=list("id"=1, "name"="subgroup name", "cohort"=list("id"=60,"name"="subgroup cohort"))))$asJSON()),
               '{"CohortSubgroup":{"id":1,"name":"subgroup name","cohort":{"id":60,"name":"subgroup cohort"}}}')
  
  expect_error(CohortIncidence::CohortSubgroup$new('{"CohortSubgroupx":{}}'),"Initialization of CohortSubgrup must contain element 'CohortSubgroup'")
  expect_error(CohortIncidence::CohortSubgroup$new('{"CohortSubgroup":{"id":[1,2,3]}}'),"Assertion on 'id' failed: Must have length 1.")
  expect_error(CohortIncidence::CohortSubgroup$new('{"CohortSubgroup":{"id":1,"name":123}}'),"Assertion on 'name' failed: Must be of type 'character'")
})

test_that("StrataSettings R6 Class Works", {

  strataSettings <- CohortIncidence::StrataSettings$new()
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":false,"byGender":false,"byYear":false}')
  
  strataSettings$byYear <- T
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":false,"byGender":false,"byYear":true}')

  strataSettings$byGender <- T
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":false,"byGender":true,"byYear":true}')

  strataSettings$byAge <- T
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":true,"byGender":true,"byYear":true}')

  strataSettings$ageBreaks <- c(17, 35, 65)
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":true,"byGender":true,"byYear":true,"ageBreaks":[17,35,65]}')
  strataSettings$ageBreaks <- list(17, 35, 65)
  expect_equal(as.character(strataSettings$asJSON()), '{"byAge":true,"byGender":true,"byYear":true,"ageBreaks":[17,35,65]}')
  
    
  expect_error(strataSettings$byAge <- c(1,2,3), "Assertion on 'byAge' failed: Must be of type 'logical flag'")
  expect_error(strataSettings$byYear <- c(1,2,3), "Assertion on 'byYear' failed: Must be of type 'logical flag'")
  expect_error(strataSettings$byGender <- c(1,2,3), "Assertion on 'byGender' failed: Must be of type 'logical flag'")
  expect_error(strataSettings$ageBreaks <- list(1,"2",3), "Assertion on 'as.list\\(ageBreaks\\)' failed: May only contain the following types: \\{numeric\\}")
  expect_error(strataSettings$ageBreaks <- list(), "Assertion on 'as.list\\(ageBreaks\\)' failed: Must have length >= 1, but has length 0.")

  # initalize from string
  deserializeStrataSettings <- CohortIncidence::StrataSettings$new('{"byAge":true,"byGender":true}')
  expect_equal(as.character(deserializeStrataSettings$asJSON()), '{"byAge":true,"byGender":true,"byYear":false}')
  
  deserializeStrataSettings <- CohortIncidence::StrataSettings$new('{"byAge":true,"byGender":true,"byYear":true}')
  expect_equal(as.character(deserializeStrataSettings$asJSON()), '{"byAge":true,"byGender":true,"byYear":true}')

  expect_error(CohortIncidence::StrataSettings$new('{"byAge":"true","byGender":true,"byYear":true}'), "Assertion on 'byAge' failed: Must be of type 'logical flag'")
  expect_error(CohortIncidence::StrataSettings$new('{"byAge":true,"byGender":"true","byYear":true}'), "Assertion on 'byGender' failed: Must be of type 'logical flag'")
  expect_error(CohortIncidence::StrataSettings$new('{"byAge":true,"byGender":true,"byYear":"true"}'), "Assertion on 'byYear' failed: Must be of type 'logical flag'")
  
})


test_that("createIncidenceDesign works", {
  
  target1 <- CohortIncidence::CohortReference$new()
  target1$id <- 1
  target1$name <- "Target cohort 1"
  
  outcomeDef1 <- CohortIncidence::Outcome$new()
  outcomeDef1$id <- 1
  outcomeDef1$name <- "Outcome 1, 30d Clean"
  outcomeDef1$cohortId <- 2
  outcomeDef1$cleanWindow <- 30
  
  tarDef1 <- CohortIncidence::TimeAtRisk$new()
  tarDef1$id <- 1
  tarDef1$startWith <- "start"
  tarDef1$endWith <- "start"
  tarDef1$endOffset <- 30
  
  analysis1 <- CohortIncidence::IncidenceAnalysis$new()
  analysis1$targets <- list(target1$id)
  analysis1$outcomes <- list(outcomeDef1$id)
  analysis1$tars <- list(tarDef1$id)
  
  irDesign <- CohortIncidence::IncidenceDesign$new()
  irDesign$cohortDefs = list()
  irDesign$conceptSets = list()
  irDesign$targetDefs = list(target1)
  irDesign$outcomeDefs = list(outcomeDef1)
  irDesign$timeAtRiskDefs <- list(tarDef1)
  irDesign$analysisList <- list(analysis1)
  irDesign$subgroups <- list()
  
  expectedJson <- paste(readLines("resources/serializeDesignTest.json"),collapse="\n");
  expect_equal(as.character(irDesign$asJSON(pretty=T)), expectedJson)

  strataSettings <- CohortIncidence::StrataSettings$new()
  strataSettings$byYear <- T
  strataSettings$byGender <- T
  strataSettings$byAge <- T
  strataSettings$ageBreaks <- list(17, 35, 65)
  
  irDesign$strataSettings <- strataSettings
  
  expectedStrataJson <- paste(readLines("resources/serializeDesignStrataTest.json"),collapse="\n")
  expect_equal(as.character(irDesign$asJSON(pretty=T)), expectedStrataJson)

})
