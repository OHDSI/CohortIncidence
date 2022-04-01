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

#' Creates R object for Incidence Design
#'
#' @param cohortDefs The set of cohort definitions.  Optional.
#' @param targetDefs A list of target definitions, each created with createCohortRef.
#' @param outcomeDefs A list of outcome definitions, each created with createOutcomeDef.
#' @param tars A list of TAR definitions, each created with createTimeAtRiskDef.
#' @param analysisList A list of analysis definitions, each created with createIncidenceAnalysis.
#' @param conceptSets A list of concept sets, currently unused.
#' @param subgroups A list of cohort subgroups, creatd with createCohortSubgroup.
#' @return SQL code in MS Sql Server dialect, if it's required to run analysis on another DBMS
#'         you have to use \code{\link[SqlRender]{translateSql}} function in the SqlRender package.
#' 
#' @export
createIncidenceDesign <- function(cohortDefs = list(), targetDefs = list(), outcomeDefs=list(), tars=list(), analysisList=list(), conceptSets=list(), subgroups=list(), strataSettings=NULL) {

  design <- {};
  design$cohortDefs <- cohortDefs;
  design$targetDefs <- targetDefs;
  design$outcomeDefs <- outcomeDefs;
  design$timeAtRiskDefs <- tars;
  design$analysisList <- analysisList;
  design$conceptSets <- conceptSets;
  design$subgroups <- subgroups;
  design$strataSettings <- strataSettings;

  return (design);
}

#' Helper function for creatingIncidenceAnalysis, which encapsulates the target-outcome-timeAtRisk pairs for a given analysis.
#'
#' @param targets A vector of target IDs from target definitions.
#' @param outcomes A vector of outcome IDs from outcome definitions.
#' @param tars A vector of TAR IDs from time-at-risk definitions.
#' @return an R list containing name-value pairs that will serialize into a org.ohdsi.analysis.cohortincidence.design.IncidenceAnalysis JSON format.
#' 
#' @export
createIncidenceAnalysis <- function(targets, outcomes, tars) {
  analysis <- {};
  analysis$targets <- targets;
  analysis$outcomes <- outcomes;
  analysis$tars <- tars;
  return(analysis)
}


#' Helper function for creating Cohort References, which are used in different parts of a design to reference a cohort definition
#' and, optionally, to provide a name.
#'
#' @param id the unique identifier for this outcome definition
#' @param name the name to use for this reference
#' @param description an optional description to use for this reference.
#' @return an R list containing name-value pairs that will serialize into a org.ohdsi.analysis.CohortRef JSON format.
#' 
#' @export
createCohortRef <- function(id, name, description) {
  cohortRef <- {};
  cohortRef$id <- jsonlite::unbox(id);
  if (!missing(name)) {
    cohortRef$name = jsonlite::unbox(name);
  }
  if (!missing(description)) {
    cohortRef$description <-jsonlite::unbox(description);
  }
  return (cohortRef);
}


#' Helper function for creating Outcome Definitions
#'
#' @param id the unique identifier for this outcome definition
#' @param name an optional name for this outcome definition
#' @param cohortId the cohort id reference for this outcome
#' @param cleanWindow the number of days for the clean window of this outcome definition
#' @param excludeCohortId a cohort ID for the cohort to use to exclude time at risk
#' @return an R list containing name-value pairs that will serialize into a org.ohdsi.analysis.cohortincidence.design.Outcome JSON format.
#' 
#' @export
createOutcomeDef <- function(id, name, cohortId = 0, cleanWindow = 0, excludeCohortId) {
  outcomeDef <- {};

  outcomeDef$id <- jsonlite::unbox(id);
  
  if (!missing(name)) {
    outcomeDef$name = jsonlite::unbox(name);
  }
  
  outcomeDef$cohortId <- jsonlite::unbox(cohortId);
  
  outcomeDef$cleanWindow <- jsonlite::unbox(cleanWindow);
  
  if (!missing(excludeCohortId)) {
    outcomeDef$excludeCohortId <- jsonlite::unbox(excludeCohortId);
  }
  
  return (outcomeDef);
}

#' Helper function for creating TAR Definitions
#'
#' @param id the unique identifier for this outcome definition
#' @param startDateField Specifies the field (start or end) to offset from for the TAR start.  Allowed values: 'StartDate', 'EndDate'
#' @param startOffset The number of days to offset for the TAR start, defaults to 0.
#' @param endDateField Specifies the field (start or end) to offset from for the TAR end.  Allowed values: 'StartDate', 'EndDate'
#' @param endOffset The number of days to offset for the TAR start, defaults to 0.
#' @return an R list containing name-value pairs that will serialize into a org.ohdsi.analysis.cohortincidence.design.TimeAtRisk JSON format.
#' 
#' @export
createTimeAtRiskDef <- function(id, startDateField = "StartDate", startOffset = 0, endDateField="EndDate", endOffset=0) {
  tarDef <- {};
  
  tarDef$id <- jsonlite::unbox(id);
  
  if (!(startDateField %in% c("StartDate", "EndDate"))) {
    stop(paste0("Invalid startDateField option:", startDateField, ". Valid options are StartDate, EndDate."));
  } else {
    tarDef$start = list("dateField" = jsonlite::unbox(startDateField), "offset"=jsonlite::unbox(startOffset));
  }
  
  if (!(endDateField %in% c("StartDate", "EndDate"))) {
    stop(paste0("Invalid endDateField option:", endDateField, ". Valid options are StartDate, EndDate."));
  } else {
    tarDef$end = list("dateField" = jsonlite::unbox(endDateField), "offset"=jsonlite::unbox(endOffset));
  }

  return (tarDef);
}

#' Helper function for creating TAR Definitions
#'
#' @param id the unique identifier for this subgroup
#' @param name The subgroup name
#' @param description The subgroup description
#' @param cohortRef A cohort reference created by calling createCohortRef()
#' @return an R list containing name-value pairs that will serialize into a org.ohdsi.analysis.cohortincidence.design.CohortSubgroup JSON format.
#' @export
createCohortSubgroup <- function (id, name, description, cohortRef) {
  cohortSubgroup <- {};
  
  cohortSubgroup$id <- jsonlite::unbox(id);
  if (!missing(name)) {
    cohortSubgroup$name = jsonlite::unbox(name);
  } 
  cohortSubgroup$cohort <- cohortRef;
  
  return(list("CohortSubgroup" = cohortSubgroup));
}

#' Helper function for creating strata settings
#'
#' @param byAge a boolean indicating to stratify by age
#' @param byGender a boolean indicating to stratify by gender
#' @param byYear a boolean indicating to stratify by year
#' @param ageBreaks a vector of integers indicating the age group bounds.
#' @return an R list containing name-value pairs that will serialize into a org.ohdsi.analysis.cohortincidence.design.StratifySettings JSON format.
#' @export
createStrataSettings <- function (byAge = F, byGender = F, byYear = F, ageBreaks = NULL) {
  strataSettings <- {};
  
  strataSettings$byAge <- jsonlite::unbox(byAge);
  strataSettings$byGender <- jsonlite::unbox(byGender);
  strataSettings$byYear <- jsonlite::unbox(byYear);
  strataSettings$ageBreaks <- ageBreaks;

  return(strataSettings);
}


