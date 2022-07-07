package org.ohdsi.cohortincidence.serializer;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.MatcherAssert.assertThat;
import org.junit.Test;
import org.ohdsi.analysis.cohortincidence.design.IncidenceAnalysis;
import org.ohdsi.analysis.cohortincidence.design.CohortIncidence;
import org.ohdsi.cohortincidence.BaseTest;
import org.ohdsi.cohortincidence.BuilderOptions;
import org.ohdsi.cohortincidence.CohortIncidenceQueryBuilder;

public class DesignSerializeTest extends BaseTest {

    private CohortIncidenceQueryBuilder queryBuilder = new CohortIncidenceQueryBuilder();

    @Test
    public void collectionTest() throws Exception {
			String designJson = this.readResource("/cohortincidence/simpleDesign.json");
			CohortIncidence design = CohortIncidence.fromJson(designJson);
			
			assertThat("cohort defs", design.cohortDefs.size(), equalTo(0));
			assertThat("target defs", design.targetDefs.size(), equalTo(2));
			assertThat("outcome defs", design.outcomeDefs.size(), equalTo(2));
			assertThat("tar defs", design.timeAtRiskDefs.size(), equalTo(2));
			assertThat("analysisList size", design.analysisList.size(), equalTo(1));
			IncidenceAnalysis a1 = design.analysisList.get(0);
			
			assertThat("Analysis 1 targets", a1.targets.size(), equalTo(1));
			assertThat("Analysis 1 outcomes", a1.outcomes.size(), equalTo(2));
			assertThat("Analysis 1 tars", a1.tars.size(), equalTo(2));
    }
		
    @Test
    public void emptyAgeStrataTest() throws Exception {
			String designJson = this.readResource("/cohortincidence/emptyAgeStrataDesign.json");
			CohortIncidence design = CohortIncidence.fromJson(designJson);
			
			BuilderOptions options = new BuilderOptions();
			options.refId = 1;
			options.targetCohortTable = "dummy";
			options.cdmSchema = "dummy";
			options.vocabularySchema = "dummy";
			options.useTempTables = true;
			options.resultsSchema = "dummy";		

			CohortIncidenceQueryBuilder builder = new CohortIncidenceQueryBuilder();
			builder.setDesign(design);
			builder.setOptions(options);
			String analysisSql = builder.build();
    }		
}