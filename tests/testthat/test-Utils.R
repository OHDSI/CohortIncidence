test_that("fetch resultsDDL works", {
  ddl <- CohortIncidence::getResultsDdl()
  expect_true(nchar(ddl) > 0)
})

test_that("fetch cleanup sql works", {
  cleanupSql <- CohortIncidence::getCleanupSql()
  expect_true(nchar(cleanupSql) > 0)
})