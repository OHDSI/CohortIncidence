CREATE TABLE @schemaName.incidence_summary
(  
	ref_id int,
	source_name varchar(255),
	target_cohort_definition_id bigint,
	tar_id bigint,
	subgroup_id bigint,
	outcome_id bigint,
	age_group_id int,
	gender_id int,
	gender_name varchar(255),
	start_year int,
	persons_at_risk_pe bigint,
	persons_at_risk bigint,
	person_days_pe bigint,
	person_days bigint,
	person_outcomes_pe bigint,
	person_outcomes bigint,
	outcomes_pe bigint,
	outcomes bigint,
	incidence_proportion_p100p float,
	incidence_rate_p100py float
 );

CREATE TABLE @schemaName.target_def
(  
	ref_id int,
	target_cohort_definition_id bigint,
	target_name varchar(255)
);

CREATE TABLE @schemaName.outcome_def
(  
	ref_id int,
	outcome_id bigint,
	outcome_cohort_definition_id bigint,
	outcome_name varchar(255),
	clean_window bigint,
	excluded_cohort_definition_id bigint
);

CREATE TABLE @schemaName.tar_def
(
	ref_id int,
	tar_id bigint,
	tar_start_with varchar(10),
	tar_start_offset bigint,
	tar_end_with varchar(10),
	tar_end_offset bigint

);

create table @schemaName.age_group_def
(
	ref_id int,
	age_group_id int NOT NULL,
	age_group_name varchar(50) NOT NULL,
	min_age int NULL,
	max_age int NULL

);

CREATE TABLE @schemaName.subgroup_def
(
	ref_id int,
	subgroup_id bigint,
	subgroup_name varchar(255)
);
