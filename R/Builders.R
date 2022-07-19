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

#' Creates R6 object for IncidenceDesign
#'
#' @param cohortDefs The set of cohort definitions.  Optional.
#' @param targetDefs A list of target definitions, each element must be class CohortReference.
#' @param outcomeDefs A list of outcome definitions, each element must be class Outcome
#' @param tars A list of TAR definitions, each element must be class TimeAtRisk
#' @param analysisList A list of analysis definitions, each element must be class IncidenceAnalysis
#' @param conceptSets A list of concept sets, currently unused.
#' @param subgroups A list of cohort subgroups, each element must be class Subgroup. 
#' @param strataSettings The strata settings used in the anlaysis, must be class StrataSettings.
#' @param studyWindow Limits time at risk to the specified study window. Must be class DateRange.
#' @return a R6 class: IncidenceDesign.
#' 
#' @export
createIncidenceDesign <- function(cohortDefs, targetDefs, outcomeDefs, tars, analysisList, conceptSets, subgroups, strataSettings, studyWindow) {

  design <- IncidenceDesign$new();
  if (!missing(cohortDefs)) design$cohortDefs <- cohortDefs;
  if (!missing(targetDefs)) design$targetDefs <- targetDefs;
  if (!missing(outcomeDefs)) design$outcomeDefs <- outcomeDefs;
  if (!missing(tars)) design$timeAtRiskDefs <- tars;
  if (!missing(analysisList)) design$analysisList <- analysisList;
  if (!missing(conceptSets)) design$conceptSets <- conceptSets;
  if (!missing(subgroups)) design$subgroups <- subgroups;
  if (!missing(strataSettings)) design$strataSettings <- strataSettings;
  if (!missing(studyWindow)) design$studyWindow <- studyWindow;
  
  return (design);
}

#' Creates R6 object for IncidenceAnalysis
#'
#' @param targets A list or vector of target IDs from target definitions.
#' @param outcomes A list or vector of outcome IDs from outcome definitions.
#' @param tars A list or vector of TAR IDs from time-at-risk definitions.
#' @return a R6 class: IncidenceAnalysis
#' 
#' @export
createIncidenceAnalysis <- function(targets, outcomes, tars) {
  analysis <- IncidenceAnalysis$new();
  if (!missing(targets)) analysis$targets <- targets;
  if (!missing(outcomes)) analysis$outcomes <- outcomes;
  if (!missing(tars)) analysis$tars <- tars;
  return(analysis)
}


#' Creates R6 object for CohortReference
#'
#' @param id the cohort id that is being referenced
#' @param name the name to use for this reference
#' @param description an optional description to use for this reference.
#' @return a R6 class: CohortReference
#' 
#' @export
createCohortRef <- function(id, name, description) {
  cohortRef <- CohortReference$new();
  if (!missing(id)) cohortRef$id <- id
  if (!missing(name)) cohortRef$name <- name
  if (!missing(description)) cohortRef$description <- description;
  return (cohortRef);
}


#' Creates R6 object for Outcome
#'
#' @param id the unique identifier for this outcome definition
#' @param name an optional name for this outcome definition
#' @param cohortId the cohort id reference for this outcome
#' @param cleanWindow the number of days to extend the outcome cohort’s end date. See \code{executeAnalysis()} for details on how this is applied.
#' @param excludeCohortId a cohort ID from the outcomeCohrotTable that is used to exclude time at risk. See \code{executeAnalysis()} for details on how this is applied.
#' @return a R6 class: Outcome
#' 
#' @export
createOutcomeDef <- function(id, name, cohortId = 0, cleanWindow = 0, excludeCohortId) {
  outcomeDef <- Outcome$new();

  if (!missing(id)) outcomeDef$id <- id;
  if (!missing(name)) outcomeDef$name <- name;
  if (!missing(cohortId)) outcomeDef$cohortId <- cohortId;
  if (!missing(cleanWindow)) outcomeDef$cleanWindow <- cleanWindow;
  if (!missing(excludeCohortId)) outcomeDef$excludeCohortId <- excludeCohortId;

  return (outcomeDef);
}

#' Creates R6 object for TimeAtRisk
#'
#' @param id the unique identifier for this outcome definition
#' @param startWith Specifies the field (start or end) to offset from for the TAR start.  Allowed values: 'start', 'end'
#' @param startOffset The number of days to offset for the TAR start, defaults to 0.
#' @param endWith Specifies the field (start or end) to offset from for the TAR end.  Allowed values: 'start', 'end'
#' @param endOffset The number of days to offset for the TAR start, defaults to 0.
#' @return a R6 class: TimeAtRisk
#' 
#' @export
createTimeAtRiskDef <- function(id, startWith = "start", startOffset = 0, endWith="end", endOffset=0) {
  tarDef <- TimeAtRisk$new();
  
  if (!missing(id)) tarDef$id <- jsonlite::unbox(id);
  tarDef$startWith <- startWith
  tarDef$startOffset <- startOffset
  tarDef$endWith <- endWith
  tarDef$endOffset <- endOffset

  return (tarDef);
}

#' Creates R6 object for CohortSubgroup
#'
#' @param id the unique identifier for this subgroup
#' @param name The subgroup name
#' @param description The subgroup description
#' @param cohortRef A cohort reference, as an R6 Class CohortReference
#' @return a R6 class: CohortSubgroup
#' @export
createCohortSubgroup <- function (id, name, description, cohortRef) {
  cohortSubgroup <- CohortSubgroup$new();
  
  if (!missing(id)) cohortSubgroup$id <- id;
  if (!missing(name)) cohortSubgroup$name = name;
  if (!missing(cohortRef)) cohortSubgroup$cohort <- cohortRef;
  
  return(cohortSubgroup);
}

#' Creates R6 object for StrataSettings
#'
#' @param byAge a boolean indicating to stratify by age, defaults to F
#' @param byGender a boolean indicating to stratify by gender, defaults to F
#' @param byYear a boolean indicating to stratify by year, defaults to F
#' @param ageBreaks a vector of integers indicating the age group bounds.
#' @return an R list containing name-value pairs that will serialize into a org.ohdsi.analysis.cohortincidence.design.StratifySettings JSON format.
#' @export
createStrataSettings <- function (byAge = F, byGender = F, byYear = F, ageBreaks) {
  strataSettings <- StrataSettings$new()
  
  strataSettings$byAge <- byAge;
  strataSettings$byGender <- byGender;
  strataSettings$byYear <- byYear;
  if(byAge == T && missing(ageBreaks)) stop ("Error: ageBreaks must be a list of integers with at least 1 element")
  if (!missing(ageBreaks)) strataSettings$ageBreaks <- ageBreaks;

  return(strataSettings);
}

#' Creates R6 object for DateRange
#'
#' @param startDate a character vector representing a date in YYYY-MM-DD format
#' @param endDate a character vector representing a date in YYYY-MM-DD format
#' @return a new instance of CohortIncidence::DateRange
#' @export
createDateRange <- function (startDate, endDate) {
  dateRange <- DateRange$new()
  
  if (!missing(startDate)) dateRange$startDate <- startDate
  if (!missing(endDate)) dateRange$endDate <- endDate

  return(dateRange);
}



