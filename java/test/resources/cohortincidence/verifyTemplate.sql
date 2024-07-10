select @verify_cols 
from @results_schema.incidence_summary i 
join @results_schema.target_def td on i.target_cohort_definition_id = td.target_cohort_definition_id
  and i.ref_id = td.ref_id
join @results_schema.outcome_def od on od.outcome_id = i.outcome_id
  and i.ref_id = od.ref_id
order by i.target_cohort_definition_id, i.tar_id, i.subgroup_id, i.outcome_id, i.age_group_id, i.gender_id, i.start_year