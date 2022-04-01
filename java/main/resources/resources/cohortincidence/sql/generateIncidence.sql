select target_cohort_definition_id, target_name
into #target_ref
from (
@targetRefUnion
) O
;

select tar_id, tar_start_index, tar_start_offset, tar_end_index, tar_end_offset
into #tar_ref 
FROM (
@tarRefUnion
) T
;

select outcome_id, outcome_cohort_definition_id, outcome_name, clean_window, excluded_cohort_definition_id
into #outcome_ref
from (
@outcomeRefUnion
) O
;

select subgroup_id, subgroup_name
INTO #subgroup_ref
FROM (
@subgroupRefUnion
) S
;

create table #age_group
(
	age_id int NOT NULL,
	group_name varchar(50) NOT NULL,
	min_age int NULL,
	max_age int NULL

);

@ageGroupInsert

@analysisSql

DROP TABLE #target_ref;
DROP TABLE #tar_ref;
DROP TABLE #outcome_ref;
DROP TABLE #subgroup_ref;
DROP TABLE #age_group;
