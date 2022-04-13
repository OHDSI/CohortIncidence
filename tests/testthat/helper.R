initDb <- function(dbFile, dataFolder) {
  #connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sqlite", server = dbFile)
  #conn <- withr::local_db_connection(DatabaseConnector::connect(connectionDetails)) ;
  
  conn <- withr::local_db_connection(DBI::dbConnect(RSQLite::SQLite(), dbFile)) ;
  
  cdmDdl <-readr::read_file(testthat::test_path("resources/ddl/cdm_v5.4.sql"));
  cdmDdl <- SqlRender::render(cdmDdl, "schemaName" = "main");
  cdmDdl <- SqlRender::translate(cdmDdl, "sqlite");
  
  ddlStatements <- SqlRender::splitSql(cdmDdl);
  
  for (statement in ddlStatements) {
    DBI::dbExecute(conn, statement)
  }
  
  #DatabaseConnector::executeSql(conn, cdmDdl);
  
  for (file in list.files(testthat::test_path(dataFolder))) {
    tableName <- gsub(pattern = "\\.csv$", "", file)
    csvFile <- file.path(dataFolder, file)
    tableData <- read.csv(csvFile)
    browser()
    RSQLite::dbWriteTable(conn, tableName, tableData, append=T)
  }
}