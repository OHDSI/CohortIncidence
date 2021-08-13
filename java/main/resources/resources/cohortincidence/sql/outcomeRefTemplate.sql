select cast(%d as int) as outcome_id, cast(%d as int) as outcome_cohort_definition_id,
	cast ('%s' as varchar(255)) as outcome_name,
	cast (%d as int) as clean_window,
  cast (%d as int) as excluded_cohort_definition_id