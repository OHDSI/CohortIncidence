# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of CohortIncidence
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#' Executes IR analysis given a design, options, and connection settings.
#'
#' @param connectionDetails      An R object of type \code{connectionDetails} created using the
#'                               function \code{createConnectionDetails} in the
#'                               \code{DatabaseConnector} package. Either the \code{connection} or
#'                               \code{connectionDetails} argument should be specified.
#' @param connection             A connection to the server containing the schema as created using the
#'                               \code{connect} function in the \code{DatabaseConnector} package.
#'                               Either the \code{connection} or \code{connectionDetails} argument
#'                               should be specified.
#' @param incidenceDesign  A string object containing valid JSON that represents cohort incidence design
#' @param buildOptions the parameters to use in building the analysis queries, created by buildOptions()
#' @param sourceName the source name to attach to the results
#' @return a \code{data.frame} containing the IR results
#' 
#' @export
executeAnalysis <- function(connectionDetails = NULL, 
                            connection = NULL,
                            incidenceDesign, 
                            buildOptions,
                            sourceName = "default") {
  if (is.null(connectionDetails) && is.null(connection)) {
    stop("Need to provide either connectionDetails or connection")
  }
  
  if (!is.null(connectionDetails) && !is.null(connection)) {
    stop("Need to provide either connectionDetails or connection, not both")
  }
  
  if (!is.null(connectionDetails)) {
    conn <- DatabaseConnector::connect(connectionDetails)
    on.exit(DatabaseConnector::disconnect(conn))
  } else {
    conn <- connection;
  }
  
  if (rJava::is.jnull(buildOptions$targetCohortTable) || rJava::is.jnull(buildOptions$cdmSchema)) {
    stop("buildOptions$targetCohortTable or buildOptions$cdmSchema is missing.")
  }
  
  # Force useTempTables for analysis
  buildOptions$useTempTables = T
  
  targetDialect = attr(conn, "dbms")
  
  tempDDL <- SqlRender::translate(CohortIncidence::getResultsDdl(useTempTables=T), targetDialect = targetDialect); 
  DatabaseConnector::executeSql(conn, tempDDL);
  
  #execute analysis
  analysisSql <- CohortIncidence::buildQuery(incidenceDesign =  as.character(jsonlite::toJSON(irDesign)),
                                             buildOptions = buildOptions);
  
  analysisSql <- SqlRender::render(analysisSql, "sourceName"=sourceName);
  
  analysisSql <- SqlRender::translate(analysisSql, targetDialect = targetDialect);

    
  DatabaseConnector::executeSql(conn, analysisSql);
  
  #download results into dataframe
  results <- DatabaseConnector::querySql(conn, SqlRender::translate("select * from #incidence_summary", targetDialect = targetDialect));
  
  # use the getCleanupSql to fetch the DROP TABLE expressions for the tables that were created in tempDDL.
  cleanupSql <- SqlRender::translate(CohortIncidence::getCleanupSql(useTempTables=T), targetDialect);  
  DatabaseConnector::executeSql(conn, cleanupSql);
  
  return(invisible(results))

}