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

--HINT DISTRIBUTE_ON_KEY(subject_id)
select subject_id, cohort_definition_id, tar_id, start_date, @tarEndDateExpression 
into #TTAR_erafied
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
            from #tar_ref where tar_id in (@timeAtRiskIds)
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
    ) STARTS
  ) GROUPS_1
  GROUP BY subject_id, cohort_definition_id, tar_id, group_idx
) T
@studyWindowWhereClause
;


create table #subgroup_person
(
  subgroup_id bigint NOT NULL,
  subject_id bigint NOT NULL,
  start_date date NOT NULL
);

@subgroupQueries

/*
2) create table to store era-fied excluded at-risk periods
*/

--three ways for entry into excluded
--1:  duration of outcome periods  (ex:  immortal time due to clean period)
--2:  other periods excluded  (ex: persons post-appendectomy for appendicitis)

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
        from #outcome_ref 
        where outcome_id in (@outcomeIds)
      ) or1 on oc1.cohort_definition_id = or1.outcome_cohort_definition_id
      where dateadd(dd,or1.clean_window, oc1.cohort_end_date) >= dateadd(dd,1,oc1.cohort_start_date)

      union all

      SELECT c1.subject_id, or1.outcome_id, c1.cohort_start_date as start_date, c1.cohort_end_date as end_date
      FROM @outcomeCohortTable c1
      inner join (
        select outcome_id, excluded_cohort_definition_id 
        from #outcome_ref 
        where outcome_id in (@outcomeIds)
      ) or1 on c1.cohort_definition_id = or1.excluded_cohort_definition_id
    ) EXCLUDED
  ) STARTS
) GROUPS_1
GROUP BY subject_id, outcome_id, group_idx;

--HINT DISTRIBUTE_ON_KEY(subject_id)
select  ec1.subject_id,
  te1.cohort_definition_id as target_cohort_definition_id,
  te1.tar_id,
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

--HINT DISTRIBUTE_ON_KEY(subject_id)
select t1.cohort_definition_id as target_cohort_definition_id,
	t1.tar_id,
	t1.subject_id,
	t1.start_date,
	o1.outcome_id,
	count_big(o1.subject_id) as pe_outcomes,
	SUM(case when eo.tar_id is null then 1 else 0 end) as num_outcomes
into #outcome_smry
from #TTAR_erafied t1
inner join (
	select oref.outcome_id, oc.subject_id, oc.cohort_start_date
	from @outcomeCohortTable oc 
	JOIN #outcome_ref oref on oc.cohort_definition_id = oref.outcome_cohort_definition_id
	where oref.outcome_id in (@outcomeIds)
) o1 on t1.subject_id = o1.subject_id
	and t1.start_date <= o1.cohort_start_date
	and t1.end_date >= o1.cohort_start_date
left join #exc_TTAR_o_erafied eo on t1.cohort_definition_id = eo.target_cohort_definition_id
	and t1.tar_id = eo.tar_id
	and o1.outcome_id = eo.outcome_id
	and o1.subject_id = eo.subject_id
	and eo.start_date <= o1.cohort_start_date
	and eo.end_date >= o1.cohort_start_date
group by t1.cohort_definition_id, t1.tar_id, t1.subject_id, t1.start_date, o1.outcome_id
;

-- 4) calculate exclsion time per T/O/TAR/Subject/start_date

--HINT DISTRIBUTE_ON_KEY(subject_id)
select t1.cohort_definition_id as target_cohort_definition_id,
	t1.tar_id,
	t1.subject_id,
	t1.start_date,
	et1.outcome_id,
	sum(datediff(dd,et1.start_date, et1.end_date) + 1) as person_days
INTO #excluded_person_days
from #TTAR_erafied t1
inner join #exc_TTAR_o_erafied et1 on t1.cohort_definition_id = et1.target_cohort_definition_id
	and t1.tar_id = et1.tar_id
	and t1.subject_id = et1.subject_id
	and t1.start_date <= et1.start_date
	and t1.end_date >= et1.end_date
group by t1.cohort_definition_id,
  t1.tar_id,
  t1.subject_id,
	t1.start_date,
	et1.outcome_id
;

/*
5) generate raw result table with T/O/TAR/subject_id,start_date, pe_at_risk (datediff(d,start,end), at_risk (pe_at_risk - exclusion time), pe_outcomes, outcomes
   and attach age/gender/year columns
*/

--HINT DISTRIBUTE_ON_KEY(subject_id)
select t1.target_cohort_definition_id,
	o1.outcome_id,
	t1.tar_id,
	t1.subject_id,
	t1.start_date,
	ag.age_id,
	t1.gender_id,
	t1.start_year,
	datediff(dd,t1.start_date, t1.end_date) + 1 as pe_person_days,
	datediff(dd,t1.start_date, t1.end_date) + 1 - coalesce(te1.person_days,0) as person_days,
	coalesce(os1.pe_outcomes,0) as pe_outcomes,
	coalesce(os1.num_outcomes,0) as outcomes
into #incidence_raw
from (
	select te.cohort_definition_id as target_cohort_definition_id,
		te.tar_id,
		te.subject_id,
		te.start_date,
		te.end_date,
		YEAR(te.start_date) - p.year_of_birth as age,
		p.gender_concept_id as gender_id,
		YEAR(te.start_date) as start_year
	from #TTAR_erafied te
	join @cdm_database_schema.person p on te.subject_id = p.person_id
) t1
cross join (select outcome_id from #outcome_ref where outcome_id in (@outcomeIds)) o1
left join #excluded_person_days te1 on t1.target_cohort_definition_id = te1.target_cohort_definition_id
	and t1.tar_id = te1.tar_id
	and t1.subject_id = te1.subject_id
	and t1.start_date = te1.start_date
	and o1.outcome_id = te1.outcome_id
left join #outcome_smry os1 on t1.target_cohort_definition_id = os1.target_cohort_definition_id
	and t1.tar_id = os1.tar_id
	and t1.subject_id = os1.subject_id
	and t1.start_date = os1.start_date
	and o1.outcome_id = os1.outcome_id
left join #age_group ag on t1.age >= coalesce(ag.min_age, -999) and t1.age < coalesce(ag.max_age, 999)
;

-- 6) Create analysis_ref to produce each T/O/TAR/S combo

select t1.target_cohort_definition_id,
  t1.target_name,
	tar1.tar_id,
	tar1.tar_start_offset,
	tar1.tar_start_with,
	tar1.tar_end_offset,
	tar1.tar_end_with,
	s1.subgroup_id,
	s1.subgroup_name,
	o1.outcome_id,
	o1.outcome_cohort_definition_id,
	o1.outcome_name,
	o1.clean_window
into #tscotar_ref
from (select target_cohort_definition_id, target_name from #target_ref where target_cohort_definition_id in (@targetIds))  t1,
	(select tar_id, tar_start_offset, tar_start_with, tar_end_offset, tar_end_with from #tar_ref where tar_id in (@timeAtRiskIds)) tar1,
	(select subgroup_id, subgroup_name from #subgroup_ref) s1,
	(select outcome_id, outcome_cohort_definition_id, outcome_name, clean_window from #outcome_ref where outcome_id in (@outcomeIds)) o1
;

-- 7) perform rollup to calculate IR / IP at the T/O/TAR/S/[age|gender|year] level for 'all' and each subgroup
-- and aggregate to the selected levels
with incidence_w_subgroup (subgroup_id, target_cohort_definition_id, outcome_id, tar_id, subject_id, age_id, gender_id, start_year, pe_person_days, person_days, pe_outcomes, outcomes) as
(
	-- the 'all' group
	select cast(0 as int) as subgroup_id, ir.target_cohort_definition_id, ir.outcome_id, ir.tar_id, 
		ir.subject_id, ir.age_id, ir.gender_id, ir.start_year, 
		ir.pe_person_days, ir.person_days, ir.pe_outcomes, ir.outcomes
	from #incidence_raw ir
	
	UNION ALL
	
	-- select the individual subgroup members using the subgruop_person table
	select s.subgroup_id as subgroup_id, ir.target_cohort_definition_id, ir.outcome_id, ir.tar_id, 
		ir.subject_id, ir.age_id, ir.gender_id, ir.start_year, 
		ir.pe_person_days, ir.person_days, ir.pe_outcomes, ir.outcomes
	from #incidence_raw ir
	join #subgroup_person s on ir.subject_id = s.subject_id and ir.start_date = s.start_date
)
select target_cohort_definition_id, tar_id, subgroup_id, outcome_id, age_id, gender_id, start_year,
	persons_at_risk_pe, persons_at_risk, person_days_pe, person_days, person_outcomes_pe, person_outcomes, outcomes_pe, outcomes 
into #incidence_subgroups
from (
	select irs.target_cohort_definition_id,
		irs.tar_id,
		irs.subgroup_id,
		irs.outcome_id,
		cast (null as int) as age_id, 
		cast (null as int) as gender_id,
		cast (null as int) as start_year,
		count_big(distinct irs.subject_id) as persons_at_risk_pe,
		count_big(distinct case when irs.person_days > 0 then irs.subject_id end) as persons_at_risk,
		sum(cast(irs.pe_person_days as bigint)) as person_days_pe,
		sum(cast(irs.person_days as bigint)) as person_days,
		count_big(distinct case when irs.pe_outcomes > 0 then irs.subject_id end) as person_outcomes_pe,
		count_big(distinct case when irs.outcomes > 0 then irs.subject_id end) as person_outcomes,
		sum(cast(irs.pe_outcomes as bigint)) as outcomes_pe,
		sum(cast(irs.outcomes as bigint)) as outcomes
	from incidence_w_subgroup irs
	group by irs.target_cohort_definition_id, irs.tar_id, irs.subgroup_id, irs.outcome_id 
	@strataQueries
) IR;

insert into @results_database_schema.incidence_summary (ref_id, source_name, target_cohort_definition_id, target_name,
	tar_id, tar_start_with, tar_start_offset, tar_end_with, tar_end_offset, 
	subgroup_id, subgroup_name,
	outcome_id, outcome_cohort_definition_id, outcome_name, clean_window,
	age_id, age_group_name, gender_id, gender_name, start_year,
	persons_at_risk_pe, persons_at_risk, person_days_pe, person_days, 
	person_outcomes_pe, person_outcomes, outcomes_pe, outcomes,
	incidence_proportion_p100p, incidence_rate_p100py)
select CAST(@ref_id as int) as ref_id, '@sourceName' as source_name, tref.target_cohort_definition_id, tref.target_name,
	tref.tar_id, tref.tar_start_with, tref.tar_start_offset, tref.tar_end_with, tref.tar_end_offset,
	tref.subgroup_id, tref.subgroup_name,
	tref.outcome_id, tref.outcome_cohort_definition_id, tref.outcome_name, tref.clean_window,
	irs.age_id, ag.group_name, irs.gender_id, c.concept_name as gender_name, irs.start_year,
	coalesce(irs.persons_at_risk_pe, 0) as persons_at_risk_pe, 
	coalesce(irs.persons_at_risk, 0) as persons_at_risk, 
	coalesce(irs.person_days_pe, 0) as  person_days_pe,
	coalesce(irs.person_days, 0) as person_days,
	coalesce(irs.person_outcomes_pe, 0) as person_outcomes_pe,
	coalesce(irs.person_outcomes, 0) as person_outcomes, 
	coalesce(irs.outcomes_pe, 0) as outcomes_pe,
	coalesce(irs.outcomes, 0) as outcomes,
	case when coalesce(irs.persons_at_risk, 0) > 0 then 
		(100.0 * cast(coalesce(irs.person_outcomes,0) as float) / (cast(coalesce(irs.persons_at_risk, 0) as float)))
	end as incidence_proportion_p100p, 
	case when coalesce(irs.person_days,0) > 0 then 
		(100.0 * cast(coalesce(irs.outcomes,0) as float) / (cast(coalesce(irs.person_days,0) as float) / 365.25))
	end AS incidence_rate_p100py
from #tscotar_ref tref
left join #incidence_subgroups irs on tref.target_cohort_definition_id = irs.target_cohort_definition_id
	and tref.tar_id = irs.tar_id
	and tref.subgroup_id = irs.subgroup_id
	and tref.outcome_id = irs.outcome_id
left join #age_group ag on ag.age_id = irs.age_id
left join @cdm_database_schema.concept c on c.concept_id = irs.gender_id
;


-- CLEANUP TEMP TABLES
DROP TABLE #TTAR_erafied;
DROP TABLE #subgroup_person;
DROP TABLE #excluded_tar_cohort;
DROP TABLE #exc_TTAR_o_erafied;
DROP TABLE #outcome_smry;
DROP TABLE #excluded_person_days;
DROP TABLE #incidence_raw;
DROP TABLE #tscotar_ref;
DROP TABLE #incidence_subgroups;

--
-- End analysis @analysisIndex
--