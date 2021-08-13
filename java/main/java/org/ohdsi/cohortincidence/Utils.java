/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.ohdsi.cohortincidence;

import org.ohdsi.circe.helper.ResourceHelper;

/**
 *
 * @author cknoll1
 */
public class Utils {
	private static final String RESULTS_DDL_PATH = "/resources/cohortincidence/ddl/resultsSchema.sql";

	public static String getResultsSchemaDDL() {
		return ResourceHelper.GetResourceAsString(RESULTS_DDL_PATH);
	}
}
