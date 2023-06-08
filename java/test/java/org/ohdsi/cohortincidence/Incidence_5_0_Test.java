package org.ohdsi.cohortincidence;

import com.github.mjeanroy.dbunit.core.dataset.DataSetFactory;
import java.sql.Connection;
import java.util.Arrays;
import java.util.List;
import org.apache.commons.lang3.StringUtils;
import org.dbunit.Assertion;
import org.dbunit.database.IDatabaseConnection;
import org.dbunit.dataset.CompositeDataSet;
import org.dbunit.dataset.IDataSet;
import org.dbunit.dataset.ITable;
import org.dbunit.operation.DatabaseOperation;
import org.dbunit.util.TableFormatter;
import org.junit.BeforeClass;
import org.junit.Test;
import org.ohdsi.analysis.cohortincidence.design.CohortIncidence;
import org.ohdsi.circe.helper.ResourceHelper;
import org.ohdsi.sql.SqlSplit;
import org.ohdsi.sql.SqlTranslate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.SingleConnectionDataSource;

// Note: to verify the test results, we must directly query the database
// via createQueryTable(), because loading the result schema tables via
// getTables() fails because the results schema isn't seen by the existing connection.
public class Incidence_5_0_Test extends AbstractDatabaseTest {

	private final static Logger log = LoggerFactory.getLogger(Incidence_5_0_Test.class);
	private static final String CDM_DDL_PATH = "/ddl/cdm_v5.0.sql";
	private static final String COHORT_DDL_PATH = "/ddl/cohort.sql";
	private static final String CDM_SCHEMA = "cdm";
	private static final String VERIFY_TEMPLATE = "select %s from %s order by target_cohort_definition_id, tar_id, subgroup_id, outcome_id, age_id, gender_id, start_year";

	private static final String COL_REF_ID = "ref_id";
	private static final String COL_TARGET_COHORT_ID = "target_cohort_definition_id";
	private static final String COL_TARGET_NAME = "target_name";
	private static final String COL_TAR_ID = "tar_id";
	private static final String COL_SUBGROUP_ID = "subgroup_id";
	private static final String COL_OUTCOME_ID = "outcome_id";
	private static final String COL_OUTCOME_NAME = "outcome_name";
	private static final String COL_AGE_ID = "age_id";
	private static final String COL_GENDER_ID = "gender_id";
	private static final String COL_YEAR_ID = "start_year";
	private static final String COL_PERSONS_PRE_EXCLUDE = "persons_at_risk_pe";
	private static final String COL_PERSONS_AT_RISK = "persons_at_risk";
	private static final String COL_PERSONS_DAYS_PRE_EXCLUDE = "person_days_pe";
	private static final String COL_PERSON_DAYS = "person_days";
	private static final String COL_PERSON_OUTCOMES = "person_outcomes";
	private static final String COL_PERSON_OUTCOMES_PRE_EXCLUDE = "person_outcomes_pe";
	private static final String COL_OUTCOMES_PRE_EXCLUDE = "outcomes_pe";
	private static final String COL_OUTCOMES = "outcomes";
	private static final String COL_INCIDENCE_PROPORTION_P100P = "ROUND(cast(incidence_proportion_p100p as numeric), 4) as incidence_proportion_p100p";
	private static final String COL_INCIDENCE_RATE_P100PY = "ROUND(cast(incidence_rate_p100py as numeric), 4) as incidence_rate_p100py";

	@BeforeClass
	public static void beforeClass() {
		jdbcTemplate = new JdbcTemplate(getDataSource());
		String cdmDDL = ResourceHelper.GetResourceAsString(CDM_DDL_PATH);
		prepareSchema(CDM_SCHEMA, cdmDDL);
	}

	private String getResultSchemaDDL() {
		// if using temp tables, don't return the resultsSchemaDDL for the incidence results tables.
		return StringUtils.join(
						new String[]{Utils.getResultsSchemaDDL(),  ResourceHelper.GetResourceAsString(COHORT_DDL_PATH)},
						System.lineSeparator());
	}

	private BuilderOptions createOptions(int refId, String cohortTable, String resultsSchema, boolean useTempTables) {
		BuilderOptions options = new BuilderOptions();
		options.refId = refId;
		options.targetCohortTable = cohortTable;
		options.cdmSchema = CDM_SCHEMA;
		options.vocabularySchema = CDM_SCHEMA;
		options.useTempTables = useTempTables;
		options.resultsSchema = resultsSchema;

		return options;
	}

	private String buildVerifyQuery(String tableName, List<String> columns) {
		String query = String.format(VERIFY_TEMPLATE, StringUtils.join(columns, ","), tableName);
		return query;
	}
	
	private void executeTest(TestParams params) throws Exception {
		final String RESULTS_SCHEMA = params.resultSchema; // this must be all lower case for DBUnit to work

		// prepare results schema for the specified results schema
		String resultsDDL = getResultSchemaDDL();
		prepareSchema(RESULTS_SCHEMA, resultsDDL);

		final IDatabaseConnection dbUnitCon = getConnection();

		// load test data into DB.
		final IDataSet dsPrep = DataSetFactory.createDataSet(params.prepDataSets);
		DatabaseOperation.CLEAN_INSERT.execute(dbUnitCon, dsPrep); // clean load of the DB. Careful, clean means "delete the old stuff"

		CohortIncidenceQueryBuilder builder = new CohortIncidenceQueryBuilder();
		builder.setDesign(CohortIncidence.fromJson(params.designJson));
		builder.setOptions(createOptions(1, RESULTS_SCHEMA + ".cohort", RESULTS_SCHEMA, params.useTempTables));
		String analysisSql = SqlTranslate.translateSql(builder.build(), "postgresql");

		// if using temp tables, then perform the analysis in 4 steps:  
		//	1) create temp tables, 2)execute analysis using temp tables, 3) export results into final table 4) clean up temp tables
		// else, execute the analysis sql normally
		
		if (params.useTempTables) {
			// a single db connection will be used throughout because we need to maintain temp tables across queries.
			try (Connection connection = getConnection().getConnection()){
				SingleConnectionDataSource scf = new SingleConnectionDataSource(connection, true);
				JdbcTemplate template = new JdbcTemplate(scf);
				String tempDDL = SqlTranslate.translateSql(Utils.getResultsSchemaDDL(true), "postgresql"); 
				template.batchUpdate(SqlSplit.splitSql(tempDDL));
				template.batchUpdate(SqlSplit.splitSql(analysisSql));
				String exportSql = SqlTranslate.translateSql(String.format("insert into %s.incidence_summary select * from #incidence_summary", RESULTS_SCHEMA), "postgresql");
				template.batchUpdate(SqlSplit.splitSql(exportSql));
				template.batchUpdate(SqlSplit.splitSql(SqlTranslate.translateSql(Utils.getCleanupSql(true), "postgresql")));
			}
		}
		else {
			// execute on database, expect no errors
			jdbcTemplate.batchUpdate(SqlSplit.splitSql(analysisSql));
		}			

		// Validate results
		// Load actual records from cohort table
		final ITable resultsTable = dbUnitCon.createQueryTable(RESULTS_SCHEMA + ".incidence_summary",
						buildVerifyQuery(RESULTS_SCHEMA + ".incidence_summary", params.verifyCols)
		);

		TableFormatter f = new TableFormatter();
		String resultsTableText = f.format(resultsTable);
		final IDataSet actualDataSet = new CompositeDataSet(new ITable[]{resultsTable});

		// Load expected data from dataset
		final IDataSet expectedDataSet = DataSetFactory.createDataSet(params.verifyDataSets);

		// Assert actual database table match expected table
		Assertion.assertEquals(expectedDataSet, actualDataSet);		
	}

	/**
	 * Tests that the different settings for time at risk (offsets from start/end dates, censored at observation end, etc)
	 * This test tests doesn't specify an outcome, and are only used to test if time at risk is correct based on settings.
	 * @throws Exception 
	 */
	@Test
	public void tarSettingsTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "tar_settings"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/tarSettings_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/tarSettingsTest.json");
		params.verifyDataSets =  new String[]{"/cohortincidence/timeAtRisk/tarSettings_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
							COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
							COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
							COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);

	}

	/**
	 * Tests different time at risks for the same target/outcome cohort to verify immortal time from the outcome is properly handled.
	 * This test only specifies a single outcome.
	 * @throws Exception 
	 */
	@Test
	public void singleOutcomeTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "single_outcome"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/singleOutcome_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/singleOutcomeTest.json");
		params.verifyDataSets =  new String[]{"/cohortincidence/timeAtRisk/singleOutcome_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
							COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
							COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
							COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}

	/**
	 * Tests that sqlInjection values in name fields are properly escaped
	 * @throws Exception 
	 */
	@Test
	public void sqlInjectionTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "sql_injection"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/sqlInjection_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/sqlInjectionTest.json");
		params.verifyDataSets =  new String[]{"/cohortincidence/sqlInjection_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TAR_ID, COL_TARGET_COHORT_ID, COL_TARGET_NAME, COL_OUTCOME_ID, COL_OUTCOME_NAME});

		this.executeTest(params);
	}
	/**
	 * Similar to single outcome test, this test creates different outcome definitions with different clean window settings.
	 * This test contains a single TAR definition, but with different outcome definitions with various clean windows.
	 * @throws Exception 
	 */
	@Test
	public void cleanWindowTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "clean_window"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/cleanWindow_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/cleanWindowTest.json");
		params.verifyDataSets =  new String[]{"/cohortincidence/timeAtRisk/cleanWindow_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
							COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
							COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
							COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}

	/**
	 * Tests with 2 people, multiple outcomes, but the second person has all TAR excluded.
	 * Outcomes are arranged to remove TAR from the beginning, middle and end of the TAR period.
	 * The three exclusion times are:
	 * 2/25 - 03/06, 04/01-04/11, 04/25-05/05, with TAR from 03/01-04/30 (61d)
	 * Exclusion time is: 03/01-03/06 (6d) + 04/02-04/11 (10d) + 04/26 - 4/30 (5d) = 21d with 2 cases.
	 * @throws Exception 
	 */
	@Test
	public void multiOutcomeTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "multi_outcome"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/multiOutcome_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/multiOutcomeTest.json");
		params.verifyDataSets = new String[]{"/cohortincidence/timeAtRisk/multiOutcome_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
							COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
							COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
							COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}
	
	/**
	 * Tests a single person with multiple outcomes.
	 * Outcomes are arranged to remove TAR from the beginning, middle and end of the TAR period.
	 * The three exclusion times are:
	 * 2/25 - 03/06, 04/01-04/11, 04/25-05/05, with TAR from 03/01-04/30 (61d)
	 * Exclusion time is: 03/01-03/06 (6d) + 04/02-04/11 (10d) + 04/26 - 4/30 (5d) = 21d with 2 cases.
	 * @throws Exception 
	 */
	@Test
	public void noExcludeOutcomeTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "no_exclude_outcome"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/noExcludeOutcome_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/noExcludeOutcomeTest.json");
		params.verifyDataSets = new String[]{"/cohortincidence/timeAtRisk/noExcludeOutcome_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
							COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
							COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
							COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}
	
	/**
	 * Tests a subgroups where 1 person belongs to the subgroup, and another does not.
	 * @throws Exception 
	 */
	@Test
	public void cohortSubgroupTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "cohort_subgroup"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/cohortSubgroup_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/cohortSubgroupTest.json");
		params.verifyDataSets = new String[]{"/cohortincidence/timeAtRisk/cohortSubgroup_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
							COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
							COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
							COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}	

	/**
	 * Tests multiple people with different age/gender/year strata
	 * Person 1: Male, 2 outcomes, 1 excluded, 2 TARs (age 32 and 37).
	 * Person 2: Female, 2 outcomes, 0 excluded, 2 TARs (age 35 and 37)
	 * Special notes: Person 1 will start in 1 year but have the TAR exclusion make followup start in next year 
	 *	to test that start_year is correct (it should use the erafied-start date)
	 * 
	 * @throws Exception 
	 */
	@Test
	public void strataAllTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "strata_all"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/strataAll_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/strataAllTest.json");
		params.verifyDataSets = new String[]{"/cohortincidence/timeAtRisk/strataAll_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
			COL_AGE_ID, COL_GENDER_ID, COL_YEAR_ID,
			COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
			COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
			COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}

	/**
	 * Tests multiple people with different age/gender/year strata, but only requests by-age strata
	 * Person 1: Male, 2 outcomes, 1 excluded, 2 TARs (age 32 and 37).
	 * Person 2: Female, 2 outcomes, 0 excluded, 2 TARs (age 35 and 37)
	 * Special notes: Person 1 will start in 1 year but have the TAR exclusion make followup start in next year 
	 *	to test that start_year is correct (it should use the erafied-start date)
	 * 
	 * @throws Exception 
	 */
	@Test
	public void strataByAgeTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "strata_age"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/strataByAge_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/strataByAgeTest.json");
		params.verifyDataSets = new String[]{"/cohortincidence/timeAtRisk/strataByAge_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
			COL_AGE_ID, COL_GENDER_ID, COL_YEAR_ID,
			COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
			COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
			COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}

	/**
	 * Tests multiple people with different age/gender/year strata, but only requests by-age strata
	 * Person 1: Male, 2 outcomes, 1 excluded, 2 TARs (age 32 and 37).
	 * Person 2: Female, 2 outcomes, 0 excluded, 2 TARs (age 35 and 37)
	 * Special notes: Person 1 will start in 1 year but have the TAR exclusion make followup start in next year 
	 *	to test that start_year is correct (it should use the erafied-start date)
	 * 
	 * @throws Exception 
	 */
	@Test
	public void strataByGenderTest() throws Exception {
		TestParams params = new TestParams();
		
		params.resultSchema = "strata_gender"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/strataByGender_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/strataByGenderTest.json");
		params.verifyDataSets = new String[]{"/cohortincidence/timeAtRisk/strataByGender_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
			COL_AGE_ID, COL_GENDER_ID, COL_YEAR_ID,
			COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
			COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
			COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});

		this.executeTest(params);
	}
	
	/**
	 * This is a special test case that does not use executeTest() to perform the test.
	 * Instead, temp tables are created and the results are pulled form the temp table using a single connection to the DB.
	 * This is done via SingleConnectionDataSource.
	 * We will re-use the simple singleOutcomeTest but with temp tables in this test.
	 * @throws Exception 
	 */
	@Test
	public void tempTableTest() throws Exception {

		TestParams params = new TestParams();
		
		params.resultSchema = "temp_table"; // this must be all lower case for DBUnit to work
		params.prepDataSets = new String[]{
			"/datasets/vocabulary.json",
			"/cohortincidence/timeAtRisk/tempTable_PREP.json"
		};
		params.designJson = ResourceHelper.GetResourceAsString("/cohortincidence/timeAtRisk/tempTableTest.json");
		params.verifyDataSets =  new String[]{"/cohortincidence/timeAtRisk/tempTable_VERIFY.json"};
		params.verifyCols = Arrays.asList(new String[]{COL_REF_ID, COL_TARGET_COHORT_ID, COL_TAR_ID, COL_SUBGROUP_ID, COL_OUTCOME_ID,
							COL_PERSONS_PRE_EXCLUDE, COL_PERSONS_AT_RISK, COL_PERSONS_DAYS_PRE_EXCLUDE, COL_PERSON_DAYS,
							COL_PERSON_OUTCOMES_PRE_EXCLUDE, COL_PERSON_OUTCOMES, COL_OUTCOMES_PRE_EXCLUDE, COL_OUTCOMES,
							COL_INCIDENCE_PROPORTION_P100P, COL_INCIDENCE_RATE_P100PY});
		params.useTempTables = true;
		
		this.executeTest(params);
		
	}
	
}
