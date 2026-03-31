/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.ohdsi.cohortincidence.design;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.ohdsi.cohortincidence.common.CohortRef;

/**
 *
 * @author cknoll1
 */
public class CohortSubgroup extends Subgroup {
		@JsonProperty("cohort")
		public CohortRef cohort;
}
