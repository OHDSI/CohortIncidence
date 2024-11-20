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
#' 
#' R6 Class Representing a IncidenceDesign
#' 
#' @description 
#' This class encapsulates the other R6 Class elements that define an IncidenceDesign
#' 
#' @details 
#' The IncidenceDesign class encapsulates the following:
#' - Cohort Definitions
#' - Target Definitions
#' - Outcome Definitions
#' - Time At Risk Definitions
#' - A List of Analyses
#' - Concept Sets
#' - Subgruops
#' - Strata Settings
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON(), or call toJSON directy on this class.

#' @export
IncidenceDesign <- R6::R6Class("IncidenceDesign",
  private = list(
    .cohortDefs = NA,
    .targetDefs = NA,
    .outcomeDefs = NA,
    .timeAtRiskDefs = NA,
    .analysisList = NA,
    .conceptSets = NA,
    .subgroups = NA,
    .strataSettings=NA,
    .studyWindow=NA
  ),
  active = list(
    #' @field cohortDefs A list of cohort definitions.  Must be a list of \link[=CohortDefinition]{CohortDefinition}
    cohortDefs = function(cohortDefs) {
      if (missing(cohortDefs)) {
        private$.cohortDefs
      } else {
        # check type
        checkmate::assertList(cohortDefs, types="CohortDefinition", min.len = 0)
        private$.cohortDefs <- cohortDefs
        self
      }
    },
    #' @field conceptSets A list of concept set expressions.  Currently unused.
    conceptSets = function(conceptSets) {
      if (missing(conceptSets)) {
        private$.conceptSets
      } else {
        # check type
        checkmate::assertList(conceptSets, max.len = 0)
        private$.conceptSets <- conceptSets
        self
      }
    },
    #' @field targetDefs A list of cohort references to be used as target cohorts.  Must be a list of \link[=CohortReference]{CohortReference}
    targetDefs = function(targetDefs) {
      if (missing(targetDefs)) {
        private$.targetDefs
      } else {
        # check type
        checkmate::assertList(targetDefs, types="CohortReference", min.len = 0)
        private$.targetDefs <- targetDefs
        self
      }
    },
    #' @field outcomeDefs A list of outcome definitions.  Must be a list of \link[=Outcome]{Outcome}
    outcomeDefs = function(outcomeDefs) {
      if (missing(outcomeDefs)) {
        private$.outcomeDefs
      } else {
        # check type
        checkmate::assertList(outcomeDefs, types="Outcome", min.len = 0)
        private$.outcomeDefs <- outcomeDefs
        self
      }
    },
    #' @field timeAtRiskDefs A list of time-at-risk definitions.  Must be a list of \link[=TimeAtRisk]{TimeAtRisk}
    timeAtRiskDefs = function(timeAtRiskDefs) {
      if (missing(timeAtRiskDefs)) {
        private$.timeAtRiskDefs
      } else {
        # check type
        checkmate::assertList(timeAtRiskDefs, types="TimeAtRisk", min.len = 0)
        private$.timeAtRiskDefs <- timeAtRiskDefs
        self
      }
    },
    #' @field analysisList A list of analyses, containing the T-O-TAR combinations to perform.  Must be a list of \link[=IncidenceAnalysis]{IncidenceAnalysis}
    analysisList = function(analysisList) {
      if (missing(analysisList)) {
        private$.analysisList
      } else {
        # check type
        checkmate::assertList(analysisList, types="IncidenceAnalysis", min.len = 0)
        private$.analysisList <- analysisList
        self
      }
    },
    #' @field subgroups A list of subgroups.  Must be a list of \link[=CohortSubgroup]{CohortSubgroup}
    subgroups = function(subgroups) {
      if (missing(subgroups)) {
        private$.subgroups
      } else {
        # check type
        checkmate::assertList(subgroups, types="CohortSubgroup", min.len = 0)
        private$.subgroups <- subgroups
        self
      }
    },
    #' @field strataSettings The strata settings for this design.  Must be a class \link[=StrataSettings]{StrataSettings}
    strataSettings = function(strataSettings) {
      if (missing(strataSettings)) {
        private$.strataSettings
      } else {
        # check type
        checkmate::assertClass(strataSettings, classes="StrataSettings")
        private$.strataSettings <-strataSettings
        self
      }
    },
    #' @field studyWindow a study window for this design.  Must be a list of class \link[=DateRange]{DateRange}
    studyWindow = function(studyWindow) {
      if (missing(studyWindow)) {
        private$.studyWindow
      } else {
        # check type
        checkmate::assertClass(studyWindow, classes="DateRange")
        private$.studyWindow <-studyWindow
        self
      }   
    }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list()) {
      dataList <- .convertJSON(data)
      
      if ("cohortDefs" %in% names (dataList)) self$cohortDefs <- dataList$cohortDefs
      if ("targetDefs" %in% names (dataList)) self$targetDefs <- lapply(dataList$targetDefs, CohortIncidence::CohortReference$new)
      if ("outcomeDefs" %in% names (dataList)) self$outcomeDefs <- lapply(dataList$outcomeDefs, CohortIncidence::Outcome$new)
      if ("timeAtRiskDefs" %in% names (dataList)) self$timeAtRiskDefs <- lapply(dataList$timeAtRiskDefs, CohortIncidence::TimeAtRisk$new)
      if ("analysisList" %in% names (dataList)) self$analysisList <- lapply(dataList$analysisList, CohortIncidence::IncidenceAnalysis$new)
      if ("conceptSets" %in% names (dataList)) self$conceptSets <- dataList$conceptSets
      if ("subgroups" %in% names (dataList)) self$analysisList <- lapply(dataList$subgroups, .resolveSubgroup)
      if ("strataSettings" %in% names (dataList)) self$strataSettings <- CohortIncidence::StrataSettings$new(dataList$strataSettings)
      if ("studyWindow" %in% names (dataList)) self$studyWindow <- CohortIncidence::DateRange$new(dataList$studyWindow)
      
    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
      .removeEmpty(list(
        cohortDefs = .r6ToListOrNA(private$.cohortDefs),
        targetDefs = .r6ToListOrNA(private$.targetDefs),
        outcomeDefs = .r6ToListOrNA(private$.outcomeDefs),
        timeAtRiskDefs = .r6ToListOrNA(private$.timeAtRiskDefs),
        analysisList = .r6ToListOrNA(private$.analysisList),
        conceptSets = private$.conceptSets,
        subgroups = .r6ToListOrNA(private$.subgroups),
        strataSettings = .r6ToListOrNA(private$.strataSettings),
        studyWindow = .r6ToListOrNA(private$.studyWindow)
      ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    #' @param ... paramaters that are passed forward to rjsonlite::toJSON()
    asJSON = function(...) {
      jsonlite::toJSON(self$toList(), na = "null", null="null" , ...)
    }
  )
)

#' R6 Class Representing a IncidenceAnalysis
#' 
#' @description 
#' The IncidenceAnalysis class, encapsulating the targets, outcomes and tars.
#' 
#' @details 
#' The targets, outcomes and tars fields are referencing IDs of the targetDef, 
#' outcomeDef and tarDefs R6 classes.
#' 
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON().

#' @export
IncidenceAnalysis <- R6::R6Class("IncidenceAnalysis",
  private = list (
    .targets = NA,
    .outcomes = NA,
    .tars = NA
  ),
  active = list (
    #' @field targets A vector of target IDs from target definitions.  Must be a vector.
    targets = function(targets) {
      if (missing(targets)) {
        private$.targets
      } else {
        # check type
        checkmate::assertList(as.list(targets), types="numeric", min.len = 0)
        private$.targets <- targets
        self
      }
    },
    #' @field outcomes A vector of outcome IDs from outcome definitions.  Must be a vector.
    outcomes = function(outcomes) {
      if (missing(outcomes)) {
        private$.outcomes
      } else {
        # check type
        checkmate::assertList(as.list(outcomes), types="numeric", min.len = 0)
        private$.outcomes <- outcomes
        self
      }
    },
    #' @field tars A vector of TAR IDs from time-at-risk definitions.  Must be a vector.
    tars = function(tars) {
      if (missing(tars)) {
        private$.tars
      } else {
        # check type
        checkmate::assertList(as.list(tars), types="numeric", min.len = 0)
        private$.tars <- tars
        self
      }
    }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list()) {
      dataList <- .convertJSON(data)
      
      if ("targets" %in% names (dataList)) self$targets <- dataList$targets
      if ("outcomes" %in% names (dataList)) self$outcomes <- dataList$outcomes
      if ("tars" %in% names (dataList)) self$tars <- dataList$tars
    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
      .removeEmpty(list(
        targets = .toJsonArray(private$.targets),
        outcomes = .toJsonArray(private$.outcomes),
        tars = .toJsonArray(private$.tars)
      ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
      jsonlite::toJSON(self$toList(), null="null")
    }
  )
)

#' R6 Class Representing a CohortDefinition
#' 
#' @description 
#' The CohortDefinition class, encapsulating the id, name and expression of a cohort definition.
#' 
#' @details 
#' This R6 class is intended to wrap the Cohort Defintion expression used to generate the cohort,
#' and provide the id and name attribute for this cohort.
#' 
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON().

#' @export
CohortDefinition <- R6::R6Class("CohortDefinition", 
  public=list(
    #' @field id The cohort ID
    id = NA,
    #' @field name The cohort name
    name = NA,
    #' @field expression The cohort expression
    expression = NA,
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
      .removeEmpty(list(
        id = jsonlite::unbox(private$id),
        name = jsonlite::unbox(private$.name),
        expression = ifelse(is.na(private$.expression),NA,private$.expression$toList())
      ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
      jsonlite::toJSON(self$toList(), null="null")
    }
  )
)

#' R6 Class Representing a CohortReference
#' 
#' @description 
#' The CohortReference class, encapsulating the id, name and descritpion fields that refernces a cohort definition.
#' 
#' @details 
#' This class is used to reference a cohort definition by ID, while providing a way to 
#' substitute a name for this specific reference.
#' 
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON().

#' @export
CohortReference <- R6::R6Class("CohortReference",
  private = list (
   .id = NA,
   .name = NA,
   .description = NA
  ),
  active = list (
   #' @field id the cohort id being referenced
   id = function(id) {
     if (missing(id)) {
       private$.id
     } else {
       # check type
       checkmate::assertInt(id)
       private$.id <- id
       self
     }
   },
   #' @field name the name for the cohort to be used in this reference.
   name = function(name) {
     if (missing(name)) {
       private$.name
     } else {
       # check type
       checkmate::assertCharacter(name, len = 1)
       private$.name <- name
       self
     }
   },
   #' @field description A description for this Cohort Reference.
   description = function(description) {
     if (missing(description)) {
       private$.description
     } else {
       # check type
       checkmate::assertCharacter(description)
       private$.description <-description
       self
     }
   }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list()) {
      dataList <- .convertJSON(data)
      
      if ("id" %in% names (dataList)) self$id <- dataList$id
      if ("name" %in% names (dataList)) self$name <- dataList$name
      if ("description" %in% names (dataList)) self$description <- dataList$description
    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
     .removeEmpty(list(
       id = jsonlite::unbox(private$.id),
       name = jsonlite::unbox(private$.name),
       description = jsonlite::unbox(private$.description)
     ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
     jsonlite::toJSON(self$toList(), null="null")
    }
  )
)

#' R6 Class Representing an Outcome definition
#' 
#' @description 
#' The Outcome class, encapsulating the id, name, outcome cohortId, 
#' exclusion cohortId, and clean window.
#' 
#' @details 
#' This class is used to specify an outcome definition.  The outcome id is distinct from 
#' the outcome cohort ID in that you can define multiple outcomes that use the same outcome cohort 
#' with different clean windows or exclusion cohort.
#' 
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON().

#' @export
Outcome <- R6::R6Class("Outcome",
  private = list (
    .id = NA,
    .name = NA,
    .cohortId = NA,
    .cleanWindow = 0L,
    .excludeCohortId = NA
  ),
  active = list (
    #' @field id an integer uniquely identifying this outcome definition
    id = function(id) {
      if (missing(id)) {
        private$.id
      } else {
        # check type
        checkmate::assertInt(id)
        private$.id <- id
        self
      }
    },
    #' @field name the name given to this outcome definition
    name = function(name) {
      if (missing(name)) {
        private$.name
      } else {
        # check type
        checkmate::assertCharacter(name, len = 1)
        private$.name <- name
        self
      }
    },
    #' @field cohortId The outcome cohort ID for this outcome.
    cohortId = function(cohortId) {
      if (missing(cohortId)) {
        private$.cohortId
      } else {
        # check type
        checkmate::assertInt(cohortId)
        private$.cohortId <-cohortId
        self
      }
    },
    #' @field cleanWindow The clean window for this outcome.
    cleanWindow = function(cleanWindow) {
      if (missing(cleanWindow)) {
        private$.cleanWindow
      } else {
        # check type
        checkmate::assertInt(cleanWindow)
        private$.cleanWindow <- cleanWindow
        self
      }
    },
    #' @field excludeCohortId The cohort that will be used to exclude time at risk.
    excludeCohortId = function(excludeCohortId) {
      if (missing(excludeCohortId)) {
        private$.excludeCohortId
      } else {
        # check type
        checkmate::assertInt(excludeCohortId)
        private$.excludeCohortId <- excludeCohortId
        self
      }
    }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list()) {
      dataList <- .convertJSON(data)
      
      if ("id" %in% names (dataList)) self$id <- dataList$id
      if ("name" %in% names (dataList)) self$name <- dataList$name
      if ("cohortId" %in% names (dataList)) self$cohortId <- dataList$cohortId
      if ("cleanWindow" %in% names (dataList)) self$cleanWindow <- dataList$cleanWindow
      if ("excludeCohortId" %in% names (dataList)) self$excludeCohortId <- dataList$excludeCohortId
      
    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
      .removeEmpty(list(
        id = jsonlite::unbox(private$.id),
        name = jsonlite::unbox(private$.name),
        cohortId = jsonlite::unbox(private$.cohortId),
        cleanWindow = jsonlite::unbox(private$.cleanWindow),
        excludeCohortId = jsonlite::unbox(private$.excludeCohortId)
      ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
      jsonlite::toJSON(self$toList(), null="null")
    }
  )
)

#' R6 Class Representing an Time-at-Risk (TAR) definition
#' 
#' @description 
#' The TimeAtRisk class, encapsulating the id, startWith, startOffset, endWith and endOffset
#' 
#' @details 
#' This class is used to specify a time-at-risk (TAR) definition. A TAR is defined by choosing
#' the start/end date of a cohort to start with (plus an offset), and a start/end date of the cohort
#'  to end with (plus an offset).
#' 
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON().

#' @export
TimeAtRisk <- R6::R6Class("TimeAtRisk",
  private = list (
   .id = NA,
   .startWith = "start",
   .startOffset = 0L,
   .endWith = "end",
   .endOffset = 0L
  ),
  active = list (
   #' @field id an integer uniquely identifying this time at risk
   id = function(id) {
     if (missing(id)) {
       private$.id
     } else {
       # check type
       checkmate::assertInt(id)
       private$.id <- id
       self
     }
   },
   #' @field startWith the cohort date to start the time-at-risk.  Can be either "start" or "end".
   startWith = function(startWith) {
     if (missing(startWith)) {
       private$.startWith
     } else {
       # check type
       checkmate::assertChoice(startWith, c("start","end"))
       private$.startWith <- startWith
       self
     }
   },
   #' @field startOffset The number of days added to the date specified in startWith.
   startOffset = function(startOffset) {
     if (missing(startOffset)) {
       private$.startOffset
     } else {
       # check type
       checkmate::assertInt(startOffset)
       private$.startOffset <-startOffset
       self
     }
   },
   #' @field endWith the cohort date to start the time-at-risk.  Can be either "start" or "end".
   endWith = function(endWith) {
     if (missing(endWith)) {
       private$.endWith
     } else {
       # check type
       checkmate::assertChoice(endWith, c("start","end"))
       private$.endWith <- endWith
       self
     }
   },
   #' @field endOffset The number of days added to the date specified in startWith.
   endOffset = function(endOffset) {
     if (missing(endOffset)) {
       private$.endOffset
     } else {
       # check type
       checkmate::assertInt(endOffset)
       private$.endOffset <-endOffset
       self
     }
   }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' The JSON takes the form: {"id":1,"start":{"dateField":"start","offset":1},"end":{"dateField":"start","offset":30}}
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list()) {
      dataList <- .convertJSON(data)
      
      if ("id" %in% names (dataList)) self$id <- dataList$id
      if ("start" %in% names (dataList)) {
        if ("dateField" %in% names(dataList$start)) {
          self$startWith <- dataList$start$dateField  
        } else {
          self$startWith <- "start"
        }
        if ("offset" %in% names(dataList$start)) {
          self$startOffset <- dataList$start$offset  
        } else {
          self$startOffset <- 0L  
        }
        
      }
      if ("end" %in% names (dataList)) {
        if ("dateField" %in% names(dataList$end)) {
          self$endWith <- dataList$end$dateField  
        } else {
          self$endWith <- "end"
        }
        if ("offset" %in% names(dataList$end)) {
          self$endOffset <- dataList$end$offset  
        } else {
          self$endOffset <- 0L  
        }
      }
    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
     .removeEmpty(list(
       id = jsonlite::unbox(private$.id),
       start = list("dateField" = jsonlite::unbox(private$.startWith), "offset"= jsonlite::unbox(private$.startOffset)),
       end = list("dateField" = jsonlite::unbox(private$.endWith), "offset"= jsonlite::unbox(private$.endOffset))
     ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
     jsonlite::toJSON(self$toList(), null="null")
    }
  )
)

#' R6 Class Representing a Cohort Subgroup definition
#' 
#' @description 
#' The CohortSubgroup class, encapsulating the id, name, description, and CohortRef.
#' 
#' @details 
#' This class is used to specify a cohort subgroup to be used in the analysis. A TAR will be considered
#' part of the subgroup if the TAR starts between the subgroup's cohort start and cohort end.
#' 
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON().

#' @export
CohortSubgroup <- R6::R6Class("CohortSubgroup",
  private = list (
    .id = NA,
    .name = NA,
    .description = NA,
    .cohort = NA
  ),
  active = list (
    #' @field id an integer uniquely identifying this subgroup
    id = function(id) {
      if (missing(id)) {
        private$.id
      } else {
        # check type
        checkmate::assertInt(id)
        private$.id <- id
        self
      }
    },
    #' @field name The name to use for this cohort reference
    name = function(name) {
      if (missing(name)) {
        private$.name
      } else {
        # check type
        checkmate::assertCharacter(name, len = 1)
        private$.name <- name
        self
      }
    },
    #' @field description The description for this subgroup
    description = function(description) {
      if (missing(description)) {
        private$.description
      } else {
        # check type
        checkmate::assertCharacter(description)
        private$.description <- description
        self
      }
    },
    #' @field cohort the cohort used to represent this subgroup.  Must be class CohortReference
    cohort = function(cohort) {
      if (missing(cohort)) {
        private$.cohort
      } else {
        # check type
        checkmate::assertClass(cohort, "CohortReference")
        private$.cohort <- cohort
        self
      }
    }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' The JSON takes the form: {"id":1,"name":"some name","description":"some description","cohort":{"id":99, "name":"cohort"}}
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list("CohortSubgroup"=list())) {
      dataList <- .convertJSON(data)
      if (!("CohortSubgroup" %in% names(dataList))) {
        stop("Initialization of CohortSubgrup must contain element 'CohortSubgroup'")
      }
      dataList <- dataList$CohortSubgroup # reassign dataList to reference the element with data 'CohortSubgroup'
      if ("id" %in% names (dataList)) self$id <- dataList$id
      if ("name" %in% names (dataList)) self$name <- dataList$name
      if ("description" %in% names (dataList)) self$description <- dataList$description
      if ("cohort" %in% names (dataList)) self$cohort <-  CohortIncidence::CohortReference$new(dataList$cohort)
      
    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
      list("CohortSubgroup" = .removeEmpty(list(
        id = jsonlite::unbox(private$.id),
        name = jsonlite::unbox(private$.name),
        description = jsonlite::unbox(private$.description),
        cohort = .r6ToListOrNA(private$.cohort)
      )))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
      jsonlite::toJSON(self$toList(), null="null")
    }
  )
)

#' R6 Class Representing the Stratification Settings of a IncidenceDesign
#' 
#' @description 
#' The StrataSettings class, encapsulating the age, gender and start-year + age breaks settings.
#' 
#' @details 
#' This class is used to specify the stratification settings for an analysis.
#' The settings can indicate the statistics should be grouped by the age, gender, or 
#' start year, and any combination of those selections.
#' 
#' Example:  age = T and gender = T will produce statisics by age, by gender, and by age and gender.
#' 
#' Note, when serializing with a library such as jsonlite, first call toList() on the R6 class
#' before calling jsonlite::toJSON().

#' @export
StrataSettings <- R6::R6Class("StrataSettings",
  private = list (
    .byAge = F,
    .byGender = F,
    .byYear = F,
    .ageBreaks = NA,
    .ageBreakList = NA
  ),
  active = list (
    #' @field byAge enables stratification by age
    byAge = function(byAge) {
      if (missing(byAge)) {
        private$.byAge
      } else {
        # check type
        checkmate::assertFlag(byAge)
        private$.byAge <- byAge
        self
      }
    },
    #' @field byGender enables stratification by gender
    byGender = function(byGender) {
      if (missing(byGender)) {
        private$.byGender
      } else {
        # check type
        checkmate::assertFlag(byGender)
        private$.byGender <- byGender
        self
      }
    },
    #' @field byYear enables stratification by start year of TAR
    byYear = function(byYear) {
      if (missing(byYear)) {
        private$.byYear
      } else {
        # check type
        checkmate::assertFlag(byYear)
        private$.byYear <- byYear
        self
      }
    },
    #' @field ageBreaks a list of age breaks with at least 1 member
    ageBreaks = function(ageBreaks) {
      if (missing(ageBreaks)) {
        private$.ageBreaks
      } else {
        # check type
        checkmate::assertList(as.list(ageBreaks), types="numeric", min.len = 1)
        private$.ageBreaks <- ageBreaks
        self
      }
    },
    #' @field ageBreakList a list of age breaks
    ageBreakList = function(ageBreakList) {
      if (missing(ageBreakList)) {
        private$.ageBreakList
      } else {
        # check type
        checkmate::assertList(as.list(ageBreakList), types="list")
        checkmate::assertTRUE(all(sapply(ageBreakList, 
                                         function(x) {
                                           checkmate::testList(x) && all(sapply(x, checkmate::testNumeric))
                                         })))
        private$.ageBreakList <- ageBreakList
        self
      }
    }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list()) {
      dataList <- .convertJSON(data)
      
      if ("byAge" %in% names (dataList)) self$byAge <- dataList$byAge
      if ("byGender" %in% names (dataList)) self$byGender <- dataList$byGender
      if ("byYear" %in% names (dataList)) self$byYear <- dataList$byYear
      if ("ageBreaks" %in% names (dataList)) self$ageBreaks <- dataList$ageBreaks
      if ("ageBreakList" %in% names (dataList)) self$ageBreakList <- dataList$ageBreakList
      
    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
      .removeEmpty(list(
        byAge = jsonlite::unbox(private$.byAge),
        byGender = jsonlite::unbox(private$.byGender),
        byYear = jsonlite::unbox(private$.byYear),
        ageBreaks = .toJsonArray(private$.ageBreaks),
        ageBreakList = lapply(private$.ageBreakList, .toJsonArray)
      ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
      jsonlite::toJSON(self$toList(), null="null")
    }
  )
)


#' R6 Class Representing a DataRange
#' 
#' @description 
#' The DateRange class, encapsulating the startDate and endDate of a date range.
#' 
#' @details 
#' This class is used to specify a DateRange, with start and end dates specified as 
#' strings formatted as YYYY-MM-DD.

#' @export
DateRange <- R6::R6Class("DateRange",
  private = list (
    .startDate = NA,
    .endDate = NA
  ),
  active = list (
    #' @field startDate a character with format YYYY-MM-DD to be used as the date range's start date.
    startDate = function(startDate) {
      if (missing(startDate)) {
        private$.startDate
      } else {
        # check type
        checkmate::assertCharacter(startDate)
        checkmate::assertDate(as.Date(startDate, format = '%Y-%m-%d'), len=1, any.missing=F)
        private$.startDate <- startDate
        self
      }
    },
    #' @field endDate a character with format YYYY-MM-DD to be used as the date range's end date.
    endDate = function(endDate) {
      if (missing(endDate)) {
        private$.endDate
      } else {
        # check type
        checkmate::assertCharacter(endDate)
        checkmate::assertDate(as.Date(endDate, format = '%Y-%m-%d'), len=1, any.missing=F)
        private$.endDate <- endDate
        self
      }
    }
  ),
  public = list(
    #' @description
    #' creates a new instance, using the provided data param if provided.
    #' @param data the data (as a json string or list) to initialize with
    initialize = function(data = list()) {
      dataList <- .convertJSON(data)
      
      if ("startDate" %in% names (dataList)) self$startDate <- dataList$startDate
      if ("endDate" %in% names (dataList)) self$endDate <- dataList$endDate

    },
    #' @description
    #' returns the R6 class elements as a list for use in jsonlite::toJSON()
    toList = function() {
      .removeEmpty(list(
        startDate = jsonlite::unbox(private$.startDate),
        endDate = jsonlite::unbox(private$.endDate)
      ))
    },
    #' @description
    #' returns the JSON string for this R6 class
    asJSON = function() {
      jsonlite::toJSON(self$toList(), null="null")
    }
  )
)


# helper functions
.r6ToListOrNA <- function(x) {
  if (length(x) == 0) {
    return(invisible(list()))
  } else if (is.logical(x) && is.na(x)) {
    return(invisible(jsonlite::unbox(NA)))
  } else if (checkmate::testList(x)) {
    return(invisible(lapply(x, function(item) { item$toList() })))
  } else {
    return(invisible(x$toList()))
  }
}

.toJsonArray <- function(x) {
  if (checkmate::testScalarNA(x) || checkmate::testNull(x)) {
    return(jsonlite::unbox(NA))
  } else if (length(x) > 0) {
    return(unlist(x))
  }else {
    return(list())
  }
}

.removeEmpty <- function(x) {
  Filter(Negate(anyNA),x)
}

.convertJSON <- function(data) {
  if (checkmate::testString(data)) {
    return(.removeEmpty(.nullToNa(jsonlite::fromJSON(data, simplifyDataFrame = FALSE))))
  } else if (checkmate::testList(data)) {
    return(.removeEmpty(data))
  } else {
    stop("Error: Attempting to initalize R6 class witn non-list or non-string")
  }
}

.nullToNa <- function(obj) {
  if (is.list(obj)) {
    obj <- lapply(obj, function(x) if (is.null(x)) NA else x)
    obj <- lapply(obj, .nullToNa)
  }
  return(obj)
}

.resolveSubgroup <- function(obj) {
  if("CohortSubgroup" %in% names(obj)) return(CohortIncidence::CohortSubgroup$new(obj))
}


