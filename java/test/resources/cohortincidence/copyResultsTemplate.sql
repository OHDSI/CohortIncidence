insert into @results_schema.incidence_summary select * from #incidence_summary;
insert into @results_schema.age_group_def select * from #age_group_def;
insert into @results_schema.target_def select * from #target_def;
insert into @results_schema.outcome_def select * from #outcome_def;
