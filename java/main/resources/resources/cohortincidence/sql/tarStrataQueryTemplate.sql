  SELECT t1.target_cohort_definition_id,
    t1.tar_id,
    t1.subgroup_id,
    @selectCols,
    SUM(CAST((DATEDIFF(day,t1.start_date,t1.end_date) + 1) as bigint)) as person_days_pe,
    COUNT(distinct t1.subject_id) as persons_at_risk_pe
  FROM tar_overall t1
@ageGroupJoin
  GROUP BY t1.target_cohort_definition_id, t1.tar_id, t1.subgroup_id@groupCols