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
#' @details
#' This method performs the entire cohort incidence analysis in one step without the need for creating any permenant tables.
#'
#' The process for calculating the cohort incidence is as follows:
#' - Create the time at risk episodes from the target cohorts, using the specified startWith, endWith and offsets
#' - Calculate the excluded time by finding the overlap of TAR with the following:
#' - 1. Outcome cohort episodes (adding the clean window to each outcome episode end date)
#' - 2. Exclusion cohort that was specified in the outcome definition excludeCohortId.
#' - Count the distinct persons, distinct persons with cases, total time at risk and total cases, and calcuate the proportion and rates.
#' 
#' The resut contains the following dataframes:
#' 
#' incidence_summary:
#' 
#' |Name |Description|
#' |-----|--------|
#' |REF_ID|The reference id specified in buildOptions() to track results to the analysis execution.|
#' |SOURCE_NAME|The name of the source for these results|
#' |TARGET_COHORT_DEFIITION_ID|The cohort ID of the target population|
#' |TAR_ID|The TAR identifier|
#' |SUBGROUP_ID|The subgroup identifier|
#' |OUTCOME_ID|The outcome identifier|
#' |AGE_GROUP_ID|The age ID for this strata representing the age band specified in the strata settings|
#' |GENDER_ID| The gender concept ID for this gender strata|
#' |GENDER_NAME| The name of the gender|
#' |START_YEAR|The year strata, defined by using the year the TAR started|
#' |PERSONS_AT_RISK_PE|Distinct persons at risk before removing excluded time from TAR|
#' |PERSONS_AT_RISK|Distinct persons at risk after removing excluded time from TAR.  A person must have at least 1 day TAR to be included.|
#' |PERSON_DAYS_PE|Total TAR (in days) before excluded time was removed from TAR.|
#' |PERSON_DAYS|Total TAR (in days) after excluded time was removed from TAR.|
#' |PERSON_OUTCOMES_PE|Distinct persons with outcome before removing excluded time from TAR|
#' |PERSON_OUTCOMES|Distinct persons with outcome after removing excluded time from TAR.  A person must have at least 1 day TAR to be included.|
#' |OUTCOMES_PE|Number of cases before excluding TAR.|
#' |OUTCOMES|Number of cases after excluding TAR.|
#' |INCIDENCE_PROPORTION_P100P|The Incidence Proportion (per 100 people), calculated by person_outcomes / persons_at_risk * 100|
#' |INCIDENCE_RATE_P100PY|The Incidence Rate (per 100 person years), calculated by outcomes / person_days / 365.25 * 100|
#`
#' target_def:

#' |Name |Description|
#' |-----|--------|
#' |REF_ID|The reference id specified in buildOptions() to track results to the analysis execution.|
#' |TARGET_COHORT_DEFIITION_ID|The cohort ID of the target population|
#' |TARGET_NAME|The name of the target cohort|
#' 
#' outcome_def:
#'
#' |Name |Description|
#' |-----|--------|
#' |REF_ID|The reference id specified in buildOptions() to track results to the analysis execution.|
#' |OUTCOME_ID|The outcome identifier|
#' |OUTCOME_COHORT_DEFINITION_ID|The cohort ID of the outcome population|
#' |OUTCOME_NAME|The outcome name|
#' |CLEAN_WINDOW|The clean window for this outcome definition|
#' |EXCLUDED_COHORT_DEFINITION_ID|The cohort used to exclude TAR
#' 
#' tar_def:
#'
#' |Name |Description|
#' |-----|--------|
#' |REF_ID|The reference id specified in buildOptions() to track results to the analysis execution.|
#' |TAR_ID|The TAR identifier|
#' |TAR_START_WITH|Indicates if the TAR starts with the 'start' or 'end' of the target cohort episode|
#' |TAR_START_OFFSET|The days added to the date field specified in TAR_START_WITH|
#' |TAR_END_WITH|Indicates if the TAR ends with the 'start' or 'end' of the target cohort episode|
#' |TAR_END_OFFSET|The days added to the date field specified in TAR_END_WITH|
#' 
#' age_group_def:
#'
#' |Name |Description|
#' |-----|--------|
#' |REF_ID|The reference id specified in buildOptions() to track results to the analysis execution.|
#' |AGE_GROUP_ID|The age ID for this strata representing the age band specified in the strata settings|
#' |AGE_GROUP_NAME|The name for this age group|
#' |MIN_AGE|The minimum age for this group|
#' |MAX_AGE|the max age for this group|
#' 
#' 
#' subgroup_def:
#'
#' |Name |Description|
#' |-----|--------|
#' |REF_ID|The reference id specified in buildOptions() to track results to the analysis execution.|
#' |SUBGROUP_NAME|The name of the subgroup|
#' 
#' 
#' @return a \code{data.frame} containing the IR results
#' 
#' @export
executeAnalysis <- function(connectionDetails = NULL, 
                            connection = NULL,
                            incidenceDesign, 
                            buildOptions,
                            sourceName = "default") {
  irDesign <- incidenceDesign;
  if (checkmate::testClass(incidenceDesign,"IncidenceDesign")) {
    irDesign <- as.character(irDesign$asJSON()); 
  } else if (checkmate::testCharacter(irDesign)) {
    invisible(IncidenceDesign$new(irDesign))
  } else {
    stop("Error in executAnalysis(): incidenceDesign must be either R6 IncidenceDesign or JSON character string.")
  }

  if (is.null(connectionDetails) && is.null(connection)) {
    stop("Need to provide either connectionDetails or connection");
  }
  
  if (!is.null(connectionDetails) && !is.null(connection)) {
    stop("Need to provide either connectionDetails or connection, not both");
  }
  
  if (!is.null(connectionDetails)) {
    conn <- DatabaseConnector::connect(connectionDetails);
    on.exit(DatabaseConnector::disconnect(conn));
  } else {
    conn <- connection;
  }
  
  if (rJava::is.jnull(buildOptions$targetCohortTable) || rJava::is.jnull(buildOptions$cdmSchema)) {
    stop("buildOptions$targetCohortTable or buildOptions$cdmSchema is missing.")
  }
  
  # Force useTempTables for analysis
  buildOptions$useTempTables = T
  if (rJava::is.jnull(buildOptions$sourceName)) {
    buildOptions$sourceName = sourceName;
  }
  
  targetDialect <- attr(conn, "dbms");

  tempDDL <- SqlRender::translate(CohortIncidence::getResultsDdl(useTempTables=T), targetDialect = targetDialect);
  rlang::inform("Building temporary DDL in database for Incidence Analysis")
  DatabaseConnector::executeSql(conn, tempDDL);
  
  #execute analysis
  analysisSql <- CohortIncidence::buildQuery(incidenceDesign =  irDesign,
                                             buildOptions = buildOptions);
  
  analysisSql <- SqlRender::translate(analysisSql, targetDialect = targetDialect);

  analysisSqlQuries <- SqlRender::splitSql(analysisSql);
  rlang::inform("Executing Incidence Analysis on database")
  DatabaseConnector::executeSql(conn, analysisSql);
  
  results = list()
  #download results into dataframe.  We don't specify ref_id because the temp table will only contain this session results
  results$incidence_summary <- DatabaseConnector::querySql(conn, SqlRender::translate("select * from #incidence_summary", targetDialect = targetDialect));
  results$target_def <- DatabaseConnector::querySql(conn, SqlRender::translate("select * from #target_def", targetDialect = targetDialect));
  results$outcome_def <- DatabaseConnector::querySql(conn, SqlRender::translate("select * from #outcome_def", targetDialect = targetDialect));
  results$tar_def <- DatabaseConnector::querySql(conn, SqlRender::translate("select * from #tar_def", targetDialect = targetDialect));
  results$age_group_def <- DatabaseConnector::querySql(conn, SqlRender::translate("select * from #age_group_def", targetDialect = targetDialect));
  results$subgroup_def <- DatabaseConnector::querySql(conn, SqlRender::translate("select * from #subgroup_def", targetDialect = targetDialect));
  
  # use the getCleanupSql to fetch the DROP TABLE expressions for the tables that were created in tempDDL.
  cleanupSql <- SqlRender::translate(CohortIncidence::getCleanupSql(useTempTables=T), targetDialect);  
  rlang::inform("Drop tables created from temporary DDL")
  DatabaseConnector::executeSql(conn, cleanupSql);
  
  return(invisible(results))

}