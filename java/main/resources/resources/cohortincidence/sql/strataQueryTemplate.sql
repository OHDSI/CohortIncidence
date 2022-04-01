	select irs.target_cohort_definition_id,
		irs.tar_id,
		irs.subgroup_id,
		irs.outcome_id,
@selectCols,
		count_big(distinct irs.subject_id) as persons_at_risk_pe,
		count_big(distinct case when irs.person_days > 0 then irs.subject_id end) as persons_at_risk,
		sum(cast(irs.pe_person_days as bigint)) as person_days_pe,
		sum(cast(irs.person_days as bigint)) as person_days,
		count_big(distinct case when irs.pe_outcomes > 0 then irs.subject_id end) as person_outcomes_pe,
		count_big(distinct case when irs.outcomes > 0 then irs.subject_id end) as person_outcomes,
		sum(cast(irs.pe_outcomes as bigint)) as outcomes_pe,
		sum(cast(irs.outcomes as bigint)) as outcomes
	from incidence_w_subgroup irs
	group by irs.target_cohort_definition_id, irs.tar_id, irs.subgroup_id, irs.outcome_id, @groupCols