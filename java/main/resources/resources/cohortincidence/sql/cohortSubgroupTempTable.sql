DROP TABLE IF EXISTS #subgroup_person;

INSERT INTO #subgroup_person (subgroup_id, subject_id, start_date)
select distinct cast(@subgroupId as int) as subgroup_id, t1.subject_id, t1.start_date
FROM #TTAR_erafied_all t1
JOIN @subgroupCohortTable s1 on t1.subject_id = s1.subject_id
  and t1.start_date  >= s1.cohort_start_date
  and t1.start_date <= s1.cohort_end_date
WHERE s1.cohort_definition_id = @cohortId
;
