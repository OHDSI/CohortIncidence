# CohortIncidence 4.0.0
===========

## Major Changes

The results DDL has been split into 5 tables:
- incidence_summary
- target_def
- outcome_def
- tar_def
- age_group_def
- subgroup_def

`executeAnalysis()` will return a list of dataframes with the following fields:
- incidenceSummary
- targetDef
- outcomeDef
- tarDef
- ageGroupDef
- subgroupDef

These dataframes follow the same structure as the corresponding table.



# CohortIncidence 3.3.1
===========

## Bug Fixes

* Fixed summing large number (bigint) of days by casting to bigint.


# CohortIncidence 3.3.0
===========

## Major Changes

* Performance release: improved IR Calculation SQL.


# CohortIncidence 3.2.0
===========

## Major Changes

* Performance release: improved era-building SQL to improve performance.


# CohortIncidence 3.1.5
===========

## Bug Fixes

* Fixed strata settings when index-year strata was applied when gender was applied.

# CohortIncidence 3.1.4
===========

## Bug Fixes

* Fixed non-deterministic query when finding end dates of eras.


# CohortIncidence 3.1.3
===========

## Bug Fixes

1.  Fixed Bug: Encode input strings to prevent sql injection (#29)
2.  Fixed Bug: Truncate target and outcome names to 255 characters.


# CohortIncidence 3.1.2
===========

## Bug Fixes

1. Fixed bug:  Exlusion time was not being calculated when clean window = 0.


# CohortIncidence 3.1.1
===========

## Bug Fixes

1. Fixed SQL error when all strata settings were set to F.


# CohortIncidence 3.1.0
===========

## Major Changes

1. Implemented StudyWindow setting:   TAR will be censored at the study window end, and excluded if TAR did not start during the study window.

# CohortIncidence 3.0.1
===========

## Bug Fixes

1. Fixed issue when age stratify is false.

# CohortIncidence 3.0.0
===========

## Major Changes

This release introduces R6 classes to encapsulate the elements of an Incidence Design.  See documentation and vignettes for information on use of these new classes.  Note:  the createXXX() methods which formerly returned a jsonlite-compliant list now return R6 classes. Therefore, the release was incremented by a major version.


# CohortIncidence 2.0.0
===========

## Major Changes

This release introduces new features and an altered results schema table, requiring a major version increase.

Features:

1. New 'strataSettings' option in the CohortIncidence design that can stratify by age, gender and start year.
2. New 'useTempTable' option to do everything in temp tables, with an additional 'cleanup' function to remove tables post-execution.
3. incidence_summary table had some columns renamed for clarity
4. Results schema has columns and column values changed (example: TAR_START_INDEX 0=end, 1=start changed to TAR_START_WITH 'start' = start and 'end' = end)


# CohortIncidence 1.0.1
===========

## Bugfixes:

1. Fixed missing date padding by adding +1 to sum(start-end).
2. Fixed lean window dates by setting timespan to start+1 .. end+cleanWindow

# CohortIncidence 1.0.0
===========

Initial Release Including:

1. Java implementation 
2. Standard object model for defining CohortIncidence design.
3. Test cases

