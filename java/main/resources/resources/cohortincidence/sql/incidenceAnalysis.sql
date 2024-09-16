--
-- Begin analysis @analysisIndex
--

/****************************************
code to implement calculation using the inputs above, no need to modify beyond this point

1) create T + TAR periods
2) create table to store era-fied excluded at-risk periods
3) calculate pre-exclude outcomes and outcomes 
4) calculate exclsion time per T/O/TAR/Subject/start_date
5) generate raw result table with T/O/TAR/subject_id, start_date, pe_at_risk (datediff(d,start,end), at_risk (pe_at_risk - exclusion time), pe_outcomes, outcomes
   attach age/gender/year columns
6) Create analysis_ref to produce each T/O/TAR combo
7) perform rollup to calculate IR at the T/O/TAR/S/[age|gender|year] inclusing distinct people and distinct cases for 'all' and each subgroup

**************************************/

-- 1) create T + TAR periods
DROP TABLE IF EXISTS #TTAR_erafied_all;

--HINT DISTRIBUTE_ON_KEY(subject_id)
select subject_id, cohort_definition_id, tar_id, cast(0 as int) as subgroup_id, start_date, @tarEndDateExpression 
into #TTAR_erafied_all
FROM (
  select subject_id, cohort_definition_id, tar_id, min(start_date) as start_date, max(end_date) as end_date
  from (
    select subject_id, cohort_definition_id, tar_id, start_date, end_date, sum(is_start) over (partition by subject_id, cohort_definition_id, tar_id order by start_date, is_start desc rows unbounded preceding) group_idx
    from (
      select subject_id, cohort_definition_id, tar_id, start_date, end_date, 
        case when max(end_date) over (partition by subject_id, cohort_definition_id, tar_id order by start_date rows between unbounded preceding and 1 preceding) >= start_date then 0 else 1 end is_start
      from (
        SELECT subject_id, cohort_definition_id, tar_id, start_date, end_date
        FROM
        (
          select tc1.cohort_definition_id,
            tar1.tar_id,
            subject_id,
            case 
              when tar1.tar_start_with = 'start' then
                case when DATEADD(day,CAST(tar1.tar_start_offset as int),tc1.cohort_start_date) < op1.observation_period_end_date then DATEADD(day,CAST(tar1.tar_start_offset as int),tc1.cohort_start_date)
                  when DATEADD(day,CAST(tar1.tar_start_offset as int),tc1.cohort_start_date) >= op1.observation_period_end_date then op1.observation_period_end_date
                end
              when tar1.tar_start_with = 'end' then
                case when DATEADD(day,CAST(tar1.tar_start_offset as int),tc1.cohort_end_date) < op1.observation_period_end_date then DATEADD(day,CAST(tar1.tar_start_offset as int),tc1.cohort_end_date)
                  when DATEADD(day,CAST(tar1.tar_start_offset as int),tc1.cohort_end_date) >= op1.observation_period_end_date then op1.observation_period_end_date
                end
              else null --shouldnt get here if tar set properly
            end as start_date,
            case 
              when tar1.tar_end_with = 'start' then
                case when DATEADD(day,CAST(tar1.tar_end_offset as int),tc1.cohort_start_date) < op1.observation_period_end_date then DATEADD(day,CAST(tar1.tar_end_offset as int),tc1.cohort_start_date)
                  when DATEADD(day,CAST(tar1.tar_end_offset as int),tc1.cohort_start_date) >= op1.observation_period_end_date then op1.observation_period_end_date
                end
              when tar1.tar_end_with = 'end' then
                case when DATEADD(day,CAST(tar1.tar_end_offset as int),tc1.cohort_end_date) < op1.observation_period_end_date then DATEADD(day,CAST(tar1.tar_end_offset as int),tc1.cohort_end_date)
                  when DATEADD(day,CAST(tar1.tar_end_offset as int),tc1.cohort_end_date) >= op1.observation_period_end_date then op1.observation_period_end_date
                end
              else null --shouldnt get here if tar set properly
            end as end_date
          from (
            select tar_id, tar_start_with, tar_start_offset, tar_end_with, tar_end_offset  
            from @results_database_schema.tar_def where tar_id in (@timeAtRiskIds) and ref_id = @ref_id
          ) tar1,
          (
            select cohort_definition_id, subject_id, cohort_start_date, cohort_end_date 
            from @targetCohortTable 
            where cohort_definition_id in (@targetIds)
          ) tc1
          inner join @cdm_database_schema.observation_period op1 on tc1.subject_id = op1.person_id
            and tc1.cohort_start_date >= op1.observation_period_start_date
            and tc1.cohort_start_date <= op1.observation_period_end_date
        ) COHORT_TAR
        WHERE COHORT_TAR.start_date <= COHORT_TAR.end_date
      ) TAR
    ) ST
  ) GR
  GROUP BY subject_id, cohort_definition_id, tar_id, group_idx
) T
@studyWindowWhereClause
;

DROP TABLE IF EXISTS #subgroup_person;

create table #subgroup_person
(
  subgroup_id bigint NOT NULL,
  subject_id bigint NOT NULL,
  start_date date NOT NULL
);

@subgroupQueries

DROP TABLE IF EXISTS #TTAR_erafied_sg;

--HINT DISTRIBUTE_ON_KEY(subject_id)
select tea.subject_id, tea.cohort_definition_id, tea.tar_id, s.subgroup_id, tea.start_date, tea.end_date 
into #TTAR_erafied_sg
FROM #TTAR_erafied_all tea
JOIN #subgroup_person s on tea.subject_id = s.subject_id and tea.start_date = s.start_date
;

DROP TABLE IF EXISTS #TTAR_erafied;

--HINT DISTRIBUTE_ON_KEY(subject_id)
SELECT subject_id, cohort_definition_id, tar_id, subgroup_id, start_date, end_date
INTO #TTAR_erafied
FROM (
  SELECT subject_id, cohort_definition_id, tar_id, subgroup_id, start_date, end_date
  FROM #TTAR_erafied_all
  UNION ALL
  SELECT subject_id, cohort_definition_id, tar_id, subgroup_id, start_date, end_date
  FROM #TTAR_erafied_sg
) TE;

DROP TABLE #TTAR_erafied_all;
DROP TABLE #TTAR_erafied_sg;

/*
2) create table to store era-fied excluded at-risk periods
*/

--three ways for entry into excluded
--1:  duration of outcome periods  (ex:  immortal time due to clean period)
--2:  other periods excluded  (ex: persons post-appendectomy for appendicitis)

DROP TABLE IF EXISTS #excluded_tar_cohort;

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

DROP TABLE IF EXISTS #exc_TTAR_o_erafied;

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

-- 3) calculate pre-exclude outcomes and outcomes 
-- calculate pe_outcomes and outcomes by T, TAR, O, Subject, TAR start
DROP TABLE IF EXISTS #outcome_smry;

--HINT DISTRIBUTE_ON_KEY(subject_id)
select t1.cohort_definition_id as target_cohort_definition_id,
  t1.tar_id,
  t1.subgroup_id,
  t1.subject_id,
  t1.start_date,
  o1.outcome_id,
  count_big(o1.subject_id) as outcomes_pe,
  SUM(case when eo.tar_id is null then 1 else 0 end) as outcomes
into #outcome_smry
from #TTAR_erafied t1
inner join (
  select oref.outcome_id, oc.subject_id, oc.cohort_start_date
  from @outcomeCohortTable oc 
  JOIN @results_database_schema.outcome_def oref on oc.cohort_definition_id = oref.outcome_cohort_definition_id
    and oref.ref_id = @ref_id
  where oref.outcome_id in (@outcomeIds)
) o1 on t1.subject_id = o1.subject_id
  and t1.start_date <= o1.cohort_start_date
  and t1.end_date >= o1.cohort_start_date
left join #exc_TTAR_o_erafied eo on t1.cohort_definition_id = eo.target_cohort_definition_id
  and t1.tar_id = eo.tar_id
  and t1.subgroup_id = eo.subgroup_id
  and o1.outcome_id = eo.outcome_id
  and o1.subject_id = eo.subject_id
  and eo.start_date <= o1.cohort_start_date
  and eo.end_date >= o1.cohort_start_date
group by t1.cohort_definition_id, t1.tar_id, t1.subgroup_id, t1.subject_id, t1.start_date, o1.outcome_id
;

-- 4) calculate exclsion time per T/O/TAR/Subject/start_date

DROP TABLE IF EXISTS #excluded_person_days;

--HINT DISTRIBUTE_ON_KEY(subject_id)
SELECT EX.target_cohort_definition_id, EX.tar_id, EX.subgroup_id, EX.subject_id, EX.start_date, EX.outcome_id, EX.person_days
INTO #excluded_person_days
FROM (
  SELECT t1.cohort_definition_id as target_cohort_definition_id,
    t1.tar_id,
    t1.subgroup_id,
    t1.subject_id,
    t1.start_date,
    et1.outcome_id,
    sum(cast((DATEDIFF(day,et1.start_date,et1.end_date) + 1) as bigint)) as person_days
  FROM #TTAR_erafied t1
  inner join #exc_TTAR_o_erafied et1 on t1.cohort_definition_id = et1.target_cohort_definition_id
    and t1.subgroup_id = et1.subgroup_id
    and t1.tar_id = et1.tar_id
    and t1.subject_id = et1.subject_id
    and t1.start_date <= et1.start_date
    and t1.end_date >= et1.end_date
  group by t1.cohort_definition_id,
    t1.subgroup_id,
    t1.tar_id,
    t1.subject_id,
    t1.start_date,
    et1.outcome_id
 ) EX;

/*
5) aggregate tar and excluded+outcome
*/
DROP TABLE IF EXISTS #tar_agg;

WITH tar_overall (target_cohort_definition_id, tar_id, subgroup_id, subject_id, start_date, end_date, age, gender_id, start_year)
AS (
  SELECT te.cohort_definition_id as target_cohort_definition_id,
    te.tar_id,
    te.subgroup_id,
    te.subject_id,
    te.start_date,
    te.end_date,
    YEAR(te.start_date) - p.year_of_birth as age,
    p.gender_concept_id as gender_id,
    YEAR(te.start_date) as start_year
  FROM #TTAR_erafied te
  JOIN @cdm_database_schema.person p on te.subject_id = p.person_id
)
select target_cohort_definition_id, tar_id, subgroup_id, age_group_id, gender_id, start_year, person_days_pe, persons_at_risk_pe
INTO #tar_agg
FROM (
  @tarStrataQueries
) T_OVERALL
;

DROP TABLE IF EXISTS #outcome_agg;

WITH outcomes_overall (target_cohort_definition_id, tar_id, subgroup_id, outcome_id, subject_id, age, gender_id, start_year, excluded_days, tar_days, outcomes_pe, outcomes)
 AS (
  SELECT 
    t1.cohort_definition_id as target_cohort_definition_id,
    t1.tar_id,
    t1.subgroup_id,
    op.outcome_id,
    t1.subject_id,
    YEAR(t1.start_date) - p.year_of_birth as age,
    p.gender_concept_id as gender_id,
    YEAR(t1.start_date) as start_year,
    coalesce(e1.person_days, 0) as excluded_days,
    DATEDIFF(day,t1.start_date,t1.end_date) + 1 as tar_days,
    coalesce(o1.outcomes_pe, 0) as outcomes_pe,
    coalesce(o1.outcomes, 0) as outcomes
  FROM #TTAR_erafied t1
  JOIN @cdm_database_schema.person p ON t1.subject_id = p.person_id
  JOIN ( -- get the list of TTSO of anyone with excluded time or outcomes to limit result
    select target_cohort_definition_id, tar_id, subgroup_id, outcome_id, subject_id, start_date FROM #excluded_person_days
    UNION -- will remove dupes
    select target_cohort_definition_id, tar_id, subgroup_id, outcome_id, subject_id, start_date FROM #outcome_smry
  ) op ON t1.cohort_definition_id = op.target_cohort_definition_id
    AND t1.tar_id = op.tar_id
    AND t1.subgroup_id = op.subgroup_id
    AND t1.subject_id = op.subject_id
    AND t1.start_date = op.start_date
  LEFT JOIN #excluded_person_days e1 ON e1.target_cohort_definition_id = op.target_cohort_definition_id
    AND e1.tar_id = op.tar_id
    AND e1.subgroup_id = op.subgroup_id
    AND e1.outcome_id = op.outcome_id
    AND e1.subject_id = op.subject_id 
    AND e1.start_date = op.start_date
  LEFT JOIN #outcome_smry o1 on o1.target_cohort_definition_id = op.target_cohort_definition_id
   AND o1.tar_id = op.tar_id
   AND o1.subgroup_id = op.subgroup_id
   AND o1.outcome_id = op.outcome_id
   AND o1.subject_id = op.subject_id
   AND o1.start_date = op.start_date
)
SELECT target_cohort_definition_id, tar_id, subgroup_id, outcome_id, age_group_id, gender_id, start_year, excluded_days, excluded_persons, person_outcomes_pe, person_outcomes, outcomes_pe, outcomes
INTO #outcome_agg
FROM
(
  @outcomeStrataQueries
) O_OVERALL
;

-- 6) Create analysis_ref to produce each T/O/TAR/S combo
DROP TABLE IF EXISTS #tscotar_ref;

SELECT t1.target_cohort_definition_id,
  tar1.tar_id,
  s1.subgroup_id,
  o1.outcome_id
INTO #tscotar_ref
FROM (SELECT target_cohort_definition_id FROM @results_database_schema.target_def WHERE target_cohort_definition_id in (@targetIds) and ref_id = @ref_id) t1,
  (SELECT tar_id FROM @results_database_schema.tar_def WHERE tar_id in (@timeAtRiskIds) and ref_id = @ref_id) tar1,
  (SELECT subgroup_id FROM @results_database_schema.subgroup_def where ref_id = @ref_id) s1,
  (SELECT outcome_id FROM @results_database_schema.outcome_def WHERE outcome_id in (@outcomeIds) and ref_id = @ref_id) o1
;

-- 7) Insert into final table: calculate results via #tar_agg and #outcome_agg for all TSCOTAR combinations
DROP TABLE IF EXISTS #incidence_summary;

INSERT INTO @results_database_schema.incidence_summary (ref_id, source_name, target_cohort_definition_id,
  tar_id, subgroup_id, outcome_id, age_group_id, gender_id, gender_name, start_year,
  persons_at_risk_pe, persons_at_risk, person_days_pe, person_days, 
  person_outcomes_pe, person_outcomes, outcomes_pe, outcomes,
  incidence_proportion_p100p, incidence_rate_p100py)
SELECT CAST(@ref_id as int) as ref_id, '@sourceName' as source_name, tref.target_cohort_definition_id,
  tref.tar_id, tref.subgroup_id, tref.outcome_id, ta.age_group_id, ta.gender_id, c.concept_name as gender_name, ta.start_year,
  coalesce(ta.persons_at_risk_pe, 0) as persons_at_risk_pe, 
  coalesce(ta.persons_at_risk_pe, 0) - coalesce(oa.excluded_persons, 0) as persons_at_risk, 
  coalesce(ta.person_days_pe, 0) as  person_days_pe,
  coalesce(ta.person_days_pe, 0) - coalesce(oa.excluded_days, 0) as person_days,
  coalesce(oa.person_outcomes_pe, 0) as person_outcomes_pe,
  coalesce(oa.person_outcomes, 0) as person_outcomes, 
  coalesce(oa.outcomes_pe, 0) as outcomes_pe,
  coalesce(oa.outcomes, 0) as outcomes,
  case when coalesce(ta.persons_at_risk_pe, 0) - coalesce(oa.excluded_persons, 0) > 0 then 
    (100.0 * cast(coalesce(oa.person_outcomes,0) as float) / (cast(coalesce(ta.persons_at_risk_pe, 0) - coalesce(oa.excluded_persons, 0) as float)))
  end as incidence_proportion_p100p, 
  case when coalesce(ta.person_days_pe, 0) - coalesce(oa.excluded_days, 0) > 0 then 
    (100.0 * cast(coalesce(oa.outcomes,0) as float) / (cast(coalesce(ta.person_days_pe, 0) - coalesce(oa.excluded_days, 0) as float) / 365.25))
  end AS incidence_rate_p100py
FROM #tscotar_ref tref
LEFT JOIN #tar_agg ta ON tref.target_cohort_definition_id = ta.target_cohort_definition_id
  AND tref.tar_id = ta.tar_id
  AND tref.subgroup_id = ta.subgroup_id
LEFT JOIN #outcome_agg oa ON ta.target_cohort_definition_id = oa.target_cohort_definition_id
  AND ta.tar_id = oa.tar_id
  AND ta.subgroup_id = oa.subgroup_id 
  AND tref.outcome_id = oa.outcome_id
  AND coalesce(ta.age_group_id,-1) = coalesce(oa.age_group_id,-1)
  AND coalesce(ta.gender_id,-1) = coalesce(oa.gender_id,-1)
  AND coalesce(ta.start_year, -1) = coalesce(oa.start_year,-1)
LEFT JOIN @cdm_database_schema.concept c on c.concept_id = ta.gender_id
;

-- CLEANUP TEMP TABLES

DROP TABLE #TTAR_erafied;
DROP TABLE #subgroup_person;
DROP TABLE #excluded_tar_cohort;
DROP TABLE #exc_TTAR_o_erafied;
DROP TABLE #outcome_smry;
DROP TABLE #excluded_person_days;
DROP TABLE #tscotar_ref;
DROP TABLE #tar_agg;
DROP TABLE #outcome_agg;

--
-- End analysis @analysisIndex
--