# Copyright 2021 Observational Health Data Sciences and Informatics
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
#

#' Builds SQL code to run analyses according given Cohort Characterization design
#'
#' @param incidenceDesign  A string object containing valid JSON that represents cohort incidence design
#' @param buildOptions the paramaters to use in building the analysis queries, created by buildOptions()
#' @return SQL code in MS Sql Server dialect, if it's required to run analysis on another DBMS
#'         you have to use \code{\link[SqlRender]{translateSql}} function in the SqlRender package.
#' 
#' @export
buildQuery <- function(incidenceDesign,
                       buildOptions
) {

  queryBuilder <- rJava::new(rJava::J("org.ohdsi.cohortincidence.CohortIncidenceQueryBuilder"));
  if (!missing(buildOptions)) {
    queryBuilder$setOptions(buildOptions);  
  }
  queryBuilder$setDesign(rJava::J("org.ohdsi.analysis.cohortincidence.design.CohortIncidence")$fromJson(incidenceDesign));
  sql <- queryBuilder$build()
  return(sql)
}

#' Builds the BuilderOptions jObject with the specified paramaters
#'
#' @param cohortTable The name of table with cohorts
#' @param sessionId session identifier using to build temporary tables
#' @param cdmSchema the name of schema containing data in CDM format
#' @param resultsSchema the name of schema where results would be placed
#' @param vocabularySchema the name of schema with vocabularies
#' @param tempSchema the name of database temp schema
#' @param analysisId analysis identifier
#' @return a BuilderOptions object used in buildQuery.
#' 
#' @export
buildOptions <- function(cohortTable,
                         outcomeCohortTable = cohortTable,
                         subgroupCohortTable = cohortTable,
                         databaseName,
                         cdmSchema,
                         resultsSchema,
                         vocabularySchema = cdmSchema,
                         tempSchema = resultsSchema,
                         refId) {
  builderOptions <- rJava::new(rJava::J("org.ohdsi.cohortincidence.BuilderOptions"));
  
  if (missing(cohortTable) || is.null(cohortTable)) {
    builderOptions$targetCohortTable = rJava::.jnull(class="java/lang/String");
  }
  else {
    builderOptions$targetCohortTable = cohortTable;
  }

  if (missing(outcomeCohortTable) || is.null(outcomeCohortTable)) {
      builderOptions$outcomeCohortTable = rJava::.jnull(class="java/lang/String");  
  }
  else {
    builderOptions$outcomeCohortTable = outcomeCohortTable;
  }

  if (missing(subgroupCohortTable) || is.null(subgroupCohortTable)) {
    builderOptions$subgroupCohortTable = rJava::.jnull(class="java/lang/String");  
  }
  else {
    builderOptions$subgroupCohortTable = subgroupCohortTable;
  }
  
  if (missing(databaseName) || is.null(databaseName)) {
    builderOptions$databaseName = rJava::.jnull(class="java/lang/String");  
  }
  else {
    builderOptions$databaseName = databaseName;
  }

  if (missing(cdmSchema) || is.null(cdmSchema)) {
    builderOptions$cdmSchema = rJava::.jnull(class="java/lang/String");
  }
  else {
    builderOptions$cdmSchema = cdmSchema;
  }
  
  if (missing(resultsSchema) || is.null(resultsSchema)) {
    builderOptions$resultsSchema = rJava::.jnull(class="java/lang/String");
  }
  else {
    builderOptions$resultsSchema = resultsSchema;
  }
  
  if (missing(vocabularySchema) || is.null(vocabularySchema)) {
    builderOptions$vocabularySchema = rJava::.jnull(class="java/lang/String");
  }
  else {
    builderOptions$vocabularySchema = vocabularySchema;
  }

  if (missing(tempSchema) || is.null(tempSchema)) {
    builderOptions$tempSchema = rJava::.jnull(class="java/lang/String");
  }
  else {
    builderOptions$tempSchema = tempSchema;
  }
  
  if (missing(refId) || is.null(refId)) {
    builderOptions$refId = rJava::.jnull(class="java/lang/Integer");
  }
  else {
    builderOptions$refId = rJava::.jnew("java/lang/Integer", as.integer(refId));
  }
  
  return(builderOptions);
  
}