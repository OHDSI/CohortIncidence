/*
 * Copyright 2016 Observational Health Data Sciences and Informatics [OHDSI.org].
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.ohdsi.cohortincidence.design;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.ArrayList;
import java.util.List;
import org.ohdsi.cohortincidence.common.CohortRef;
import org.ohdsi.cohortincidence.common.DateRange;
import org.ohdsi.cohortincidence.common.TimeAtRisk;

/**
 *
 * @author Chris Knoll cknoll@ohdsi.org
 */
@JsonPropertyOrder({ "cohortDefs", "targets", "outcomes", "timeAtRiskList", "subgroups", "studyWindow" })
public class CohortIncidence {

	private static final ObjectMapper JSON_MAPPER = new ObjectMapper();

	@JsonProperty("cohortDefs")
	public List<CohortDefinition> cohortDefs = new ArrayList<>();

	@JsonProperty("targetDefs")
	public List<CohortRef> targetDefs = new ArrayList<>();

	@JsonProperty("outcomeDefs")
	public List<Outcome> outcomeDefs = new ArrayList<>();

	@JsonProperty("timeAtRiskDefs")
	public List<TimeAtRisk> timeAtRiskDefs = new ArrayList<>();

	@JsonProperty("analysisList")
	public List<IncidenceAnalysis> analysisList = new ArrayList<>();

	@JsonProperty("subgroups")
	public List<Subgroup> subgroups = new ArrayList<>();
	
	@JsonProperty("strataSettings")
	public StratifySettings strataSettings;
	
	@JsonProperty("studyWindow")
	public DateRange studyWindow;

	@JsonProperty("firstAtRisk")
	public boolean firstAtRisk = false;
	
	@JsonProperty("firstPostOutcome")
	public boolean firstPostOutcome = false;

	public CohortIncidence() {
	}
	
	public static CohortIncidence fromJson(String json) {
		try {
			return JSON_MAPPER.readValue(json, new TypeReference<CohortIncidence>() {});
		} catch (Exception e) {
			throw new RuntimeException("Error deserializing CohortIncidence from JSON", e);
		}
	}

}
