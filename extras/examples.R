# jsonlite corruption of non-array values
x0 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1]}");
jsonlite::toJSON(x0); # x became an array
jsonlite::toJSON(x0,auto_unbox = T); # y became a scalar


# nested objects are also corrupted
z0 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1], \"z\": { \"x\": 1, \"y\": [1]}}");
jsonlite::toJSON(z0);
jsonlite::toJSON(z0,auto_unbox = T);


# simplify vector may change behcaior
x0 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1]}", simplifyVector = TRUE);
jsonlite::toJSON(x0, auto_unbox=T);

# with simplifyVector = FALSE, the arrays are left alone
x1 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1]}", simplifyVector = FALSE);
jsonlite::toJSON(x1, auto_unbox=T);

# also seems to work correctly
x2 <- jsonlite::fromJSON("{\"x\":1, \"y\":[]}", simplifyVector = FALSE);
jsonlite::toJSON(x2, auto_unbox=T);


# for some reason, the 'x' in the z-collection is not made into an array when auto_unbox is not set
z0 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1], \"z\": [{ \"x\": 1, \"y\": [1]}]}", simplifyVector = TRUE);
jsonlite::toJSON(z0); # z[0].x is not an array
jsonlite::toJSON(z0,auto_unbox = T); # everything is made into non-array


# simplifyVector = FALSE leads to better output
z1 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1], \"z\": { \"x\": 1, \"y\": [1]}}", simplifyVector = FALSE);
jsonlite::toJSON(z1); # everything is an array, and the y's are arrays of arrays
jsonlite::toJSON(z1,auto_unbox = T); # single element arrays are now non-arrays, with the 'wrapepd' y-arrays are now just arrays

z2 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1,2], \"z\": { \"x\": 1, \"y\": [1,2]}}", simplifyVector = FALSE);
jsonlite::toJSON(z2); # everything is an array, and the y's are arrays of arrays
jsonlite::toJSON(z2,auto_unbox = T); # single element arrays are now non-arrays, with the 'wrapepd' y-arrays are now just arrays


z3 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1], \"z\": [{ \"x\": 1, \"y\": [1]}]}", simplifyVector = TRUE);
jsonlite::toJSON(z3); # everything is non-array
jsonlite::toJSON(z3,auto_unbox = T); # everything is array

# same as z2 case, seems to work better.
z4 <- jsonlite::fromJSON("{\"x\":1, \"y\":[1], \"z\": [{ \"x\": 1, \"y\": [1]}]}", simplifyVector = FALSE);
jsonlite::toJSON(z4);
jsonlite::toJSON(z4,auto_unbox = T);


# use unbox to define non-array elements
x<-jsonlite::unbox("Test");
jsonlite::toJSON(list(x=x))

# some createXXX tests
target1 <- CohortIncidence::createCohortRef(id=1, name="Target cohort 1");
jsonlite::toJSON(target1);

outcomeDef1 <- CohortIncidence::createOutcomeDef(id=1,name="Outcome 1, 30d Clean", 
                                                 cohortId =2,
                                                 cleanWindow =30);
jsonlite::toJSON(outcomeDef1);


# test array elements (using list() for arrays of objects works well)
jsonlite::toJSON(list(outcomeDef1));
jsonlite::toJSON(list(outcomeDef1, outcomeDef1));

# again, using list() to make an array
tarDef1 <- CohortIncidence::createTimeAtRiskDef(id=1, startDateField="StartDate", endDateField="StartDate", endOffset=30);
jsonlite::toJSON(tarDef1);
jsonlite::toJSON(list(tarDef1));

# but, for arrays of numeric, use c() to create arrays
analysis1 <- CohortIncidence::createIncidenceAnalysis(targets = c(target1$id),
                                                      outcomes = c(outcomeDef1$id),
                                                      tars = c(tarDef1$id));
jsonlite::toJSON(analysis1);


# Create Design:
irDesign <- CohortIncidence::createIncidenceDesign(
                                                   targetDefs = list(CohortIncidence::createCohortRef(id=1, name="Target cohort 1")),
                                                   outcomeDefs = list(outcomeDef1, outcomeDef1),
                                                   tars=list(tarDef1),
                                                   analysisList = list(analysis1,analysis1));
jsonlite::toJSON(irDesign,pretty = T);


# Example for getting the result schema DDL
cat(CohortIncidence::getResultsDdl());

utils<-rJava::J("org.ohdsi.cohortincidence.Utils");
utils$getResultsSchemaDDL()


buildOptions1 <- CohortIncidence::buildOptions(cohortTable = "demoCohortSchema.cohort",
                                              cdmSchema = "mycdm",
                                              resultsSchema = "results",
                                              refId = 1)


analysisSql1 <- CohortIncidence::buildQuery(incidenceDesign =  as.character(jsonlite::toJSON(irDesign)),
                                           buildOptions = buildOptions1);
cat(analysisSql1)


# Or leave cdmSchema and resultsSchema out, and use sqlRender to replace those values
buildOptions2 <- CohortIncidence::buildOptions(cohortTable = "demoCohortSchema.cohort",
                                               refId = 1)


analysisSql2 <- CohortIncidence::buildQuery(incidenceDesign =  as.character(jsonlite::toJSON(irDesign)),
                                            buildOptions = buildOptions2);
cat(substr(analysisSql2,3000,4000))



class(as.character(jsonlite::toJSON(irDesign)))

as.character(jsonlite::toJSON(irDesign))


rJava::J("org.ohdsi.analysis.cohortincidence.design.CohortIncidence")$fromJson(as.character(jsonlite::toJSON(irDesign)))
  
