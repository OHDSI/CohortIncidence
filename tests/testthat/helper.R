initDb <- function(dbFile, dataFolder) {
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "duckdb", server = dbFile)
  conn <- DatabaseConnector::connect(connectionDetails) ;
  withr::defer(DatabaseConnector::dbDisconnect(conn, shutdown=TRUE))
  
  #conn <- withr::local_db_connection(duckdb::dbConnect(duckdb::duckdb(), dbFile)) ;
  #conn <- duckdb::dbConnect(duckdb::duckdb(), dbFile);
  
  cdmDdl <-readr::read_file(testthat::test_path("resources/ddl/cdm_v5.4.sql"));
  cdmDdl <- SqlRender::render(cdmDdl, "schemaName" = "main");
  cdmDdl <- SqlRender::translate(cdmDdl, "duckdb");
  
  browser();
  ddlStatements <- SqlRender::splitSql(cdmDdl);
  
  # for (statement in ddlStatements) {
  #   DBI::dbExecute(conn, statement)
  # }
  
  DatabaseConnector::executeSql(conn, cdmDdl);
  
  for (file in list.files(testthat::test_path(dataFolder))) {
    tableName <- gsub(pattern = "\\.csv$", "", file)
    csvFile <- file.path(dataFolder, file)
    tableData <- read.csv(csvFile)
    duckdb::dbWriteTable(conn, tableName, tableData, append=T)
  }
}