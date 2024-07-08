  SELECT
    t1.target_cohort_definition_id,
    t1.tar_id,
    t1.subgroup_id,
    t1.outcome_id,    
    @selectCols,
    SUM(t1.excluded_days) as excluded_days,
    -- excluded persons is number of distinct persons minus distinct persons with tar
    COUNT(distinct t1.subject_id) - COUNT(distinct case when t1.tar_days > t1.excluded_days then t1.subject_id end) as excluded_persons,
    COUNT(distinct case when t1.outcomes_pe > 0 then t1.subject_id end) as person_outcomes_pe,
    COUNT(distinct case when t1.outcomes > 0 then t1.subject_id end) as person_outcomes,
    SUM(t1.outcomes_pe) as outcomes_pe,
    SUM(t1.outcomes) as outcomes
  FROM outcomes_overall t1
@ageGroupJoin
  GROUP BY target_cohort_definition_id, tar_id, subgroup_id, outcome_id@groupCols