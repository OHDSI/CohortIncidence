--Standard tar exclusion
--ways for entry into excluded
--1:  duration of outcome periods  (ex:  immortal time due to clean period)
--2:  other periods excluded  (ex: persons post-appendectomy for appendicitis)

-- create exclusion eras from cohort clean windows and exclusion cohorts
--HINT DISTRIBUTE_ON_KEY(subject_id)
select subject_id, outcome_id, min(start_date) as start_date, max(end_date) as end_date 
into  #excluded_tar_cohort
from (
  select subject_id, outcome_id, start_date, end_date, sum(is_start) over (partition by subject_id, outcome_id order by start_date, is_start desc rows unbounded preceding) group_idx
  from (
    select subject_id, outcome_id, start_date, end_date, 
      case when max(end_date) over (partition by subject_id, outcome_id order by start_date rows between unbounded preceding and 1 preceding) >= start_date then 0 else 1 end is_start
    from (
      -- find excluded time from outcome cohorts and exclusion cohorts
      -- note, clean window added to event end date
      select oc1.subject_id, or1.outcome_id, dateadd(dd,1,oc1.cohort_start_date) as start_date, dateadd(dd,or1.clean_window, oc1.cohort_end_date) as end_date
      from @outcomeCohortTable oc1
      inner join (
        select outcome_id, outcome_cohort_definition_id, clean_window
        from @results_database_schema.outcome_def 
        where outcome_id in (@outcomeIds) and ref_id = @ref_id
      ) or1 on oc1.cohort_definition_id = or1.outcome_cohort_definition_id
      where dateadd(dd,or1.clean_window, oc1.cohort_end_date) >= dateadd(dd,1,oc1.cohort_start_date)

      union all

      SELECT c1.subject_id, or1.outcome_id, c1.cohort_start_date as start_date, c1.cohort_end_date as end_date
      FROM @outcomeCohortTable c1
      inner join (
        select outcome_id, excluded_cohort_definition_id 
        from @results_database_schema.outcome_def 
        where outcome_id in (@outcomeIds) and ref_id = @ref_id
      ) or1 on c1.cohort_definition_id = or1.excluded_cohort_definition_id
    ) EXCLUDED
  ) ST
) GR
GROUP BY subject_id, outcome_id, group_idx;

-- intersect the exclusion eras with the time at risk to create the t-tar-outcome exclusion periods
--HINT DISTRIBUTE_ON_KEY(subject_id)
select  ec1.subject_id,
  te1.cohort_definition_id as target_cohort_definition_id,
  te1.tar_id,
  te1.subgroup_id,
  ec1.outcome_id,
  case when ec1.start_date > te1.start_date then ec1.start_date else te1.start_date end as start_date,
  case when ec1.end_date < te1.end_date then ec1.end_date else te1.end_date end as end_date
into #exc_TTAR_o_erafied
from #TTAR_erafied te1
inner join #excluded_tar_cohort ec1 on te1.subject_id = ec1.subject_id
  and ec1.start_date <= te1.end_date
  and ec1.end_date >= te1.start_date
;

DROP TABLE #excluded_tar_cohort;
