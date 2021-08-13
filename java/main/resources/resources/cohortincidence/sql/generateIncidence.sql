select target_cohort_definition_id, target_name
into #target_ref
from (
@targetRefUnion
) O
;

select time_at_risk_id, time_at_risk_start_index, time_at_risk_start_offset, time_at_risk_end_index, time_at_risk_end_offset
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

-- Will figure out subgroup mechanics at a later time
select subgroup_id, subgroup_name
INTO #subgroup_ref
FROM (
@subgroupRefUnion
) S
;

@analysisSql

DROP TABLE #target_ref;
DROP TABLE #tar_ref;
DROP TABLE #outcome_ref;
DROP TABLE #subgroup_ref;
