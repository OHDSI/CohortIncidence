package org.ohdsi.cohortincidence;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import org.apache.commons.lang3.StringUtils;
import org.ohdsi.analysis.common.FieldOffset;
import org.ohdsi.analysis.cohortincidence.design.CohortIncidence;
import org.ohdsi.analysis.cohortincidence.design.CohortSubgroup;
import org.ohdsi.analysis.cohortincidence.design.IncidenceAnalysis;
import org.ohdsi.analysis.cohortincidence.design.Subgroup;
import org.ohdsi.circe.helper.ResourceHelper;

public class CohortIncidenceQueryBuilder {
	private CohortIncidence design;
	private BuilderOptions options;
	
	private static final String GENERATE_ANALYSIS_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/generateIncidence.sql");
	private static final String ANALYSIS_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/incidenceAnalysis.sql");
	private static final String TARGET_REF_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/targetRefTemplate.sql");
	private static final String TAR_REF_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/tarRefTemplate.sql");
	private static final String OUTCOME_REF_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/outcomeRefTemplate.sql");
	private static final String SUBGROUP_REF_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/subgroupRefTemplate.sql");
	private static final String COHORT_SUBGROUP_TEMPTABLE_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/cohortSubgroupTempTable.sql");
	private static final String TAR_STRATA_QUERY_TEMPTABLE_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/tarStrataQueryTemplate.sql");
	private static final String OUTCOME_STRATA_QUERY_TEMPTABLE_TEMPLATE = ResourceHelper.GetResourceAsString("/resources/cohortincidence/sql/outcomeStrataQueryTemplate.sql");
	private static final String AGE_GROUP_SELECT_TEMPLATE = "select CAST(%d as int) as age_group_id, '%s' as age_group_name, cast(%s as int) as min_age, cast(%s as int) as max_age";

	private static final String NULL_STRATA = "cast(null as int)";
	
	public CohortIncidence getDesign() {
		return design;
	}

	public void setDesign(CohortIncidence design) {
		this.design = design;
	}

	public BuilderOptions getOptions() {
		return options;
	}

	public void setOptions(BuilderOptions options) {
		this.options = options;
	}

	private String replaceOptions(String sql)
	{
		String finalSql = sql;
		if (this.options.targetCohortTable != null){
			finalSql = StringUtils.replace(finalSql, "@targetCohortTable", this.options.targetCohortTable);
		}
		
		if (this.options.targetCohortTable != null || this.options.outcomeCohortTable != null) {
			finalSql = StringUtils.replace(finalSql, "@outcomeCohortTable", this.options.outcomeCohortTable != null ? this.options.outcomeCohortTable : this.options.targetCohortTable);
		}

		if (this.options.targetCohortTable != null || this.options.subgroupCohortTable != null) {
			finalSql = StringUtils.replace(finalSql, "@subgroupCohortTable", this.options.subgroupCohortTable != null ? this.options.subgroupCohortTable : this.options.targetCohortTable);
		}

		if (this.options.sourceName != null) {
			finalSql = StringUtils.replace(finalSql, "@sourceName", SqlUtils.normalizeTextInput(!StringUtils.isEmpty(this.options.sourceName) ? this.options.sourceName : "", 255));
		}
		
		if (options.cdmSchema != null) {
			finalSql = StringUtils.replace(finalSql, "@cdm_database_schema", this.options.cdmSchema);
		}
		
		if (options.useTempTables) {
			finalSql = StringUtils.replace(finalSql, "@results_database_schema.", "#");
		} else if (options.resultsSchema != null) {
			finalSql = StringUtils.replace(finalSql, "@results_database_schema", this.options.resultsSchema);
		}
		
		if (this.options.refId != null) {
			finalSql = StringUtils.replace(finalSql, "@ref_id", String.valueOf(this.options.refId));
		}
		
		return finalSql;
	}

	public String build() {
		String sql = GENERATE_ANALYSIS_TEMPLATE;
		
		sql = StringUtils.replace(sql, "@targetRefUnion", this.getTargetRefQuery());
		sql = StringUtils.replace(sql, "@tarRefUnion", this.getTarRefQuery());
		sql = StringUtils.replace(sql, "@outcomeRefUnion", this.getOutcomeRefQuery());
		sql = StringUtils.replace(sql, "@subgroupRefUnion", this.getSubgroupRefQuery());
		sql = StringUtils.replace(sql, "@ageGroupInsert", this.getAgeGroupInsert());
		sql = StringUtils.replace(sql, "@analysisSql", this.buildAnalysisQueries());
		
		if (this.options != null) {
			sql = replaceOptions(sql);
		}
		
		return sql;
	}

	/**
	 * Returns a series of analysis sql queries that generate the incidence summary statistics for each design.analysisList..
	 * @return String
	 */
	private String buildAnalysisQueries() {
		List<String> finalSql = IntStream
						.range(0, design.analysisList.size())
						.mapToObj(i -> {
							String analysisQuery = ANALYSIS_TEMPLATE;
							IncidenceAnalysis ia = design.analysisList.get(i);
							analysisQuery = StringUtils.replace(analysisQuery, "@analysisIndex", Integer.toString(i));
							List<String> targetIds = ia.targets.stream().map(t -> Integer.toString(t)).collect(Collectors.toList());
							analysisQuery = StringUtils.replace(analysisQuery, "@targetIds", StringUtils.join(targetIds,","));
							List<String> outcomeIds = ia.outcomes.stream().map(o -> Integer.toString(o)).collect(Collectors.toList());
							analysisQuery = StringUtils.replace(analysisQuery, "@outcomeIds", StringUtils.join(outcomeIds,","));
							List<String> tarIds = ia.tars.stream().map(tar -> Integer.toString(tar)).collect(Collectors.toList());
							analysisQuery = StringUtils.replace(analysisQuery, "@timeAtRiskIds", StringUtils.join(tarIds,","));
							
							// Handle study window
							String tarEndDateExpression = "end_date";
							ArrayList<String> whereClauses = new ArrayList<>();
							if (this.design.studyWindow != null) {
								if (this.design.studyWindow.startDate != null) {
									whereClauses.add(String.format("start_date >= %s", SqlUtils.dateStringToSql(this.design.studyWindow.startDate)));
								}
								if (this.design.studyWindow.endDate != null) {
									whereClauses.add(String.format("start_date <= %s", SqlUtils.dateStringToSql(this.design.studyWindow.endDate)));
									String endDateSql = SqlUtils.dateStringToSql(this.design.studyWindow.endDate);
									tarEndDateExpression = String.format("case when end_date > %s then %s else end_date end as end_date",endDateSql, endDateSql);
								}
							}
							analysisQuery = StringUtils.replace(analysisQuery, "@tarEndDateExpression", tarEndDateExpression);
							String studyWindowWhereClause = "";
							if (!whereClauses.isEmpty()) {
								studyWindowWhereClause = String.format("where %s", StringUtils.join(whereClauses, " AND "));
							}
							analysisQuery = StringUtils.replace(analysisQuery, "@studyWindowWhereClause", studyWindowWhereClause);
							
							// handle subgroups
							analysisQuery = StringUtils.replace(analysisQuery, "@subgroupQueries", buildSubgroupQueries());

							// handle strata options
							analysisQuery = StringUtils.replace(analysisQuery, "@tarStrataQueries", getStrataQueries(TAR_STRATA_QUERY_TEMPTABLE_TEMPLATE));
							analysisQuery = StringUtils.replace(analysisQuery, "@outcomeStrataQueries", getStrataQueries(OUTCOME_STRATA_QUERY_TEMPTABLE_TEMPLATE));

							return analysisQuery;
						})
						.collect(Collectors.toList());
		return StringUtils.join(finalSql, "\n");
	}
	
	/**
	 * Returns a set of UNION statements with the values for the Time At Risk ref table.
	 * time_at_risk_id, time_at_risk_start_index, time_at_risk_start_offset, time_at_risk_end_index, time_at_risk_end_offset
	 * @return String
	 */
	private String getTargetRefQuery() {
		List<String> unions;
		
		unions = this.design.targetDefs.stream()
						.map(t -> {
							return String.format(TARGET_REF_TEMPLATE,
											t.getId(), 
											SqlUtils.normalizeTextInput(t.getName(), 255)
							);
						})
						.collect(Collectors.toList());
		
		return StringUtils.join(unions, "\nUNION ALL\n");
	}
	
	private String getTarRefQuery() {
		List<String> unions;
		
		unions = this.design.timeAtRiskDefs.stream()
						.map(tar -> {
							return String.format(TAR_REF_TEMPLATE,
											tar.id, 
											tar.start.dateField == FieldOffset.DateField.Start ? "start" : "end",
											tar.start.offset,
											tar.end.dateField == FieldOffset.DateField.Start ? "start" : "end",
											tar.end.offset
							);
						})
						.collect(Collectors.toList());
		
		return StringUtils.join(unions, "\nUNION ALL\n");
	}	

	/**
	 * Returns a set of UNION statements with the values for the Outcome ref table.
	 * time_at_risk_id, time_at_risk_start_index, time_at_risk_start_offset, time_at_risk_end_index, time_at_risk_end_offset
	 * @return String
	 */	
	private String getOutcomeRefQuery() {
		List<String> unions;

		unions = this.design.outcomeDefs.stream()
						.map(outcome -> {
							// name is either the outcome name, the name in the CohortRef, or the name from the set of cohort definitions.
							// throws an error if not found.
							String name = (!StringUtils.isEmpty(outcome.name)) ?  outcome.name : null;
							if (StringUtils.isEmpty(name)) {
								name = this.design.cohortDefs.stream()
											.filter(cd -> Objects.equals(cd.id, outcome.cohortId))
											.findFirst()
											.orElseThrow(() -> new RuntimeException(String.format("Outcome Cohort Definition %d not found when outcome.name is null/empty", outcome.cohortId)))
											.name;
							}
							return String.format(OUTCOME_REF_TEMPLATE,
											outcome.id,
											outcome.cohortId,
											SqlUtils.normalizeTextInput(name, 255),
											outcome.cleanWindow,
											outcome.excludeCohortId != null ? outcome.excludeCohortId : 0
							);
						})
						.collect(Collectors.toList());
		
		return StringUtils.join(unions, "\nUNION ALL\n");
	}
	/**
	 * Returns EITHER an INSERT..INTO or an empty table definition, depending on the content of the subgroup definitions.
	 * @return String
	 */	
	private String getSubgroupRefQuery() {
		
		ArrayList<String> unions = new ArrayList<>();
		
		unions.add(String.format(SUBGROUP_REF_TEMPLATE, 0, "All", "null"));
		
		unions.addAll(this.design.subgroups.stream()
						.map(subgroup -> {
							return String.format(SUBGROUP_REF_TEMPLATE, subgroup.id, SqlUtils.escapeSqlParam(subgroup.name));
						})
						.collect(Collectors.toList())
		);
		
		return StringUtils.join(unions, "\nUNION ALL\n");
	}
	
	private String buildSubgroupQueries() {
		if (this.design.subgroups.isEmpty()) {
			return "-- no subgroups defined";
		}
		
		ArrayList<String> subgroupQueryList = new ArrayList<>();
		for(Subgroup sg : this.design.subgroups) {
			if (sg instanceof CohortSubgroup) {
				subgroupQueryList.add(getSubgroupQuery((CohortSubgroup)sg));
			} else {
				throw new IllegalArgumentException(String.format("Unsupported Subgroup type: %s", sg.getClass().getName()));
			}
		}
		
		return StringUtils.join(subgroupQueryList,"");
	}
	
	private String getSubgroupQuery(CohortSubgroup sg) {
		String query = StringUtils.replace(COHORT_SUBGROUP_TEMPTABLE_TEMPLATE,"@subgroupId",sg.id.toString());
		query = StringUtils.replace(query,"@cohortId",Integer.toString(sg.cohort.getId()));
		
		return query;
	}
	
	private String buildStrataQuery(String strataTemplate, String[] selectCols, String[] groupCols) {
		String query = StringUtils.replace(strataTemplate, "@selectCols", StringUtils.join(selectCols, ",\n"));
		query = StringUtils.replace(query, "@groupCols", (groupCols.length > 0 ? "," : "") + StringUtils.join(groupCols, ","));
		return query;
	}
	
	private String getStrataQueries(String strataTemplate) {
		ArrayList<String> queries = new ArrayList<>();

		// overall strata
		queries.add(buildStrataQuery(
				strataTemplate,
				new String[] {NULL_STRATA + " as age_group_id", NULL_STRATA + " as gender_id", NULL_STRATA + " as start_year"},
				new String[] {}
		));

		// by age
		if (this.design.strataSettings != null && this.design.strataSettings.byAge) {
			queries.add(buildStrataQuery(
							strataTemplate,
							new String[] {"t1.age_group_id", NULL_STRATA + " as gender_id", NULL_STRATA + " as start_year"},
							new String[] {"t1.age_group_id"}
			));

			// by age, by gender
			if (this.design.strataSettings.byGender) {
				queries.add(buildStrataQuery(
								strataTemplate,
								new String[] {"t1.age_group_id", "t1.gender_id", NULL_STRATA + " as start_year"},
								new String[] {"t1.age_group_id", "t1.gender_id"}
				));
			}

			// by age, by year
			if (this.design.strataSettings.byYear) {
				queries.add(buildStrataQuery(
								strataTemplate,
								new String[] {"t1.age_group_id", NULL_STRATA + " as gender_id", "t1.start_year"},
								new String[] {"t1.age_group_id", "t1.start_year"}
				));
			}

			// by age, by gender, by year
			if (this.design.strataSettings.byGender && this.design.strataSettings.byYear) {
				queries.add(buildStrataQuery(
								strataTemplate,
								new String[] {"t1.age_group_id", "t1.gender_id", "t1.start_year"},
								new String[] {"t1.age_group_id", "t1.gender_id", "t1.start_year"}
				));
			}
		}
		
		// by gender
		if (this.design.strataSettings != null && this.design.strataSettings.byGender) {
			queries.add(buildStrataQuery(
							strataTemplate,
							new String[]{NULL_STRATA + " as age_group_id", "t1.gender_id", NULL_STRATA + " as start_year"},
							new String[]{"t1.gender_id"}
			));
			
			// by gender, by year
			if (this.design.strataSettings.byYear) {
				queries.add(buildStrataQuery(
								strataTemplate,
								new String[] {NULL_STRATA + " as age_group_id", "t1.gender_id", "t1.start_year"},
								new String[] {"t1.gender_id", "t1.start_year"}
				));
			}
		}
		
		// by year
		if (this.design.strataSettings != null && this.design.strataSettings.byYear) {
			queries.add(buildStrataQuery(
							strataTemplate,
							new String[]{NULL_STRATA + " as age_group_id", NULL_STRATA + "as gender_id", "t1.start_year"},
							new String[]{"t1.start_year"}
			));
		}
		
		return StringUtils.join(queries, "\nUNION ALL\n");
	}
	
	/**
	 * Creates the set of SELECT... statements to put into the age_group ref table.
	 * The first break is considered less than, the last break is considered greater than or equal
	 * The intermediate breaks is defined as the age greater or equal to [i] and less than [i+1]. 
	 * @return 
	 */
	private String getAgeGroupInsert() {
		if (this.design.strataSettings == null || this.design.strataSettings.byAge == false)
			return "";
		
		if (this.design.strataSettings.ageBreaks.isEmpty())
			throw new IllegalArgumentException("Invalid strataSettings:  ageBreaks can not be empty.");
		
		ArrayList<String> selects = new ArrayList<>();
		List<Integer> ageBreaks = this.design.strataSettings.ageBreaks;
		selects.add(String.format(AGE_GROUP_SELECT_TEMPLATE, 1, "<" + ageBreaks.get(0),"null", ageBreaks.get(0)));
		
		for (int i = 0; i < ageBreaks.size() - 1; i++)
		{
			selects.add(String.format(AGE_GROUP_SELECT_TEMPLATE, i+2, "" + ageBreaks.get(i) + " - " + (ageBreaks.get(i+1)-1),ageBreaks.get(i), ageBreaks.get(i+1)));
		}
		selects.add(String.format(AGE_GROUP_SELECT_TEMPLATE, ageBreaks.size()+1, ">=" + ageBreaks.get(ageBreaks.size()-1),ageBreaks.get(ageBreaks.size()-1), "null"));
		
		return String.format("insert into @results_database_schema.age_group_def (ref_id, age_group_id, age_group_name, min_age, max_age)\nselect CAST(@ref_id as int) as ref_id, age_group_id, age_group_name, min_age, max_age from (\n%s\n) ag;", 
						StringUtils.join(selects, "\nUNION ALL\n"));
	}
}
