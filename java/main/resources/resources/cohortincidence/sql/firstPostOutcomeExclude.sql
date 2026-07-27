--First PostOutcome Exclusion:
--ways for entry into excluded
--1: outcome starts within clean window of TAR start
--2: other periods excluded  (ex: persons post-appendectomy for appendicitis)
-- Note, this differs from the 'standard outcome' exclusion such that the outcomes to consider are T-specific,
-- so can build the query that inserts directly into #exc_TTAR_o_erafied 

--HINT DISTRIBUTE_ON_KEY(subject_id)
SELECT
  subject_id,
  target_cohort_definition_id,
  tar_id,
  subgroup_id,
  outcome_id,
  min(start_date) as start_date,
  max(end_date) as end_date
into #exc_TTAR_o_erafied
FROM (
  select subject_id, target_cohort_definition_id, tar_id, subgroup_id, outcome_id, start_date, end_date, 
    sum(is_start) over (partition by subject_id, target_cohort_definition_id, tar_id, subgroup_id, outcome_id order by start_date, is_start desc rows unbounded preceding) group_idx
  from (
    select subject_id, target_cohort_definition_id, tar_id, subgroup_id, outcome_id, start_date, end_date,
      case
        when max(end_date) over (partition by subject_id, target_cohort_definition_id, tar_id, subgroup_id, outcome_id order by start_date rows between unbounded preceding and 1 preceding) >= start_date 
          then 0
          else 1
      end is_start
    from (
      -- find excluded time from outcome cohorts and exclusion cohorts
      -- excluded time starts day after first_post outcome until the tar's end_date.
      select tfo.subject_id, tfo.target_cohort_definition_id, tfo.tar_id, tfo.subgroup_id, tfo.outcome_id,
        case when tfo.first_outcome_date < te1.start_date then te1.start_date else dateadd(dd,1,tfo.first_outcome_date) end as start_date,
        te1.end_date as end_date -- exclusion always extends to tar end for first-post-outcome
      from (
        select te1.subject_id, te1.cohort_definition_id as target_cohort_definition_id, te1.tar_id, te1.subgroup_id, or1.outcome_id,
          MIN(oc1.cohort_start_date) as first_outcome_date
        from @outcomeCohortTable oc1
        inner join (
          select outcome_id, outcome_cohort_definition_id, clean_window
          from @results_database_schema.outcome_def 
          where outcome_id in (@outcomeIds) and ref_id = @ref_id
        ) or1 on oc1.cohort_definition_id = or1.outcome_cohort_definition_id
         inner join #TTAR_erafied te1 on te1.subject_id = oc1.subject_id
         where dateadd(dd,or1.clean_window,oc1.cohort_end_date) >= te1.start_date
         GROUP BY te1.subject_id, te1.cohort_definition_id, te1.tar_id, te1.subgroup_id, or1.outcome_id
       ) tfo -- tar first outcome
      inner join #TTAR_erafied te1 on te1.subject_id = tfo.subject_id
        and te1.cohort_definition_id = tfo.target_cohort_definition_id
        and te1.tar_id = tfo.tar_id
        and te1.subgroup_id = tfo.subgroup_id
      where te1.end_date > tfo.first_outcome_date -- tar end must be after tfo.first_outcome_date
    union all -- include the exlcusion cohort time intersecting with TTAR
      SELECT
        te1.subject_id, 
        te1.cohort_definition_id as target_cohort_definition_id,
        te1.tar_id, 
        te1.subgroup_id, 
        or1.outcome_id,
        -- trim exclusion time to tar start/end
        case when ex1.cohort_start_date > te1.start_date then ex1.cohort_start_date else te1.start_date end as start_date,
        case when ex1.cohort_end_date < te1.end_date then ex1.cohort_end_date else te1.end_date end as end_date
      FROM @outcomeCohortTable ex1
      inner join (
          select outcome_id, excluded_cohort_definition_id
          from @results_database_schema.outcome_def 
          where outcome_id in (@outcomeIds) and ref_id = @ref_id
        ) or1 on ex1.cohort_definition_id = or1.excluded_cohort_definition_id
       inner join #TTAR_erafied te1 on ex1.subject_id = te1.subject_id
        and ex1.cohort_start_date <= te1.end_date
        and ex1.cohort_end_date >= te1.start_date
     ) EXCLUDED
   ) ST
) GR
GROUP BY
  subject_id,
  target_cohort_definition_id,
  tar_id,
  subgroup_id,
  outcome_id,
  group_idx;
