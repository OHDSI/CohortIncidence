INSERT INTO @results_database_schema.target_def (ref_id, target_cohort_definition_id, target_name)
select CAST(@ref_id as int) as ref_id, target_cohort_definition_id, target_name
from (
@targetRefUnion
) T
;

INSERT INTO @results_database_schema.tar_def (ref_id, tar_id, tar_start_with, tar_start_offset, tar_end_with, tar_end_offset)
select CAST(@ref_id as int) as ref_id, tar_id, tar_start_with, tar_start_offset, tar_end_with, tar_end_offset
FROM (
@tarRefUnion
) T
;

INSERT INTO @results_database_schema.outcome_def (ref_id, outcome_id, outcome_cohort_definition_id, outcome_name, clean_window, excluded_cohort_definition_id)
select CAST(@ref_id as int) as ref_id, outcome_id, outcome_cohort_definition_id, outcome_name, clean_window, excluded_cohort_definition_id
from (
@outcomeRefUnion
) O
;

INSERT INTO @results_database_schema.subgroup_def (ref_id, subgroup_id, subgroup_name)
select CAST(@ref_id as int) as ref_id, subgroup_id, subgroup_name
FROM (
@subgroupRefUnion
) S
;

@ageGroupInsert

@analysisSql
