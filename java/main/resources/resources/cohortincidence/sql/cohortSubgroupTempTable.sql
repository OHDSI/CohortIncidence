INSERT INTO #TTAR_erafied (cohort_definition_id, subgroup_id, time_at_risk_id, subject_id, start_date, end_date)
select t1.cohort_definition_id, cast(@subgroupId as int) as subgroup_id, t1.time_at_risk_id, t1.subject_id, t1.start_date, t1.end_date
FROM #TTAR_erafied t1
JOIN @subgroupCohortTable s1 on t1.subject_id = s1.subject_id
  and t1.start_date  >= s1.cohort_start_date
  and t1.start_date <= s1.cohort_end_date
WHERE s1.cohort_definition_id = @cohortId
;
