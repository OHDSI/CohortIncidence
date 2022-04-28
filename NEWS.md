Cohort Incidence 2.0.0
===========

This release introduces new features and an altered results schema table, requiring a major version increase.

Features:

1. New 'strataSettings' option in the CohortIncidence design that can stratify by age, gender and start year.
2. New 'useTempTable' option to do everything in temp tables, with an additional 'cleanup' function to remove tables post-execution.
3. incidence_summary table had some columns renamed for clarity
4. Results schema has columns and column values changed (example: TAR_START_INDEX 0=end, 1=start changed to TAR_START_WITH 'start' = start and 'end' = end)


Cohort Incidence 1.0.1
===========

Bugfixes:

1. Fixed missing date padding by adding +1 to sum(start-end).
2. Fixed lean window dates by setting timespan to start+1 .. end+cleanWindow


Cohort Incidence 1.0.0
===========

Initial Release Including:

1. Java implementation 
2. Standard object model for defining cohort incidence design.
3. Test cases

