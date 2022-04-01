/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.ohdsi.cohortincidence;

import org.apache.commons.lang3.StringUtils;
import org.ohdsi.circe.helper.ResourceHelper;

/**
 *
 * @author cknoll1
 */
public class Utils {
	private static final String RESULTS_DDL_PATH = "/resources/cohortincidence/ddl/resultsSchema.sql";
	private static final String CLEANUP_PATH = "/resources/cohortincidence/sql/cleanup.sql";

	public static String getResultsSchemaDDL() {
		return getResultsSchemaDDL(false);
	}
	
	public static String getResultsSchemaDDL(boolean useTempTables) {
		if (useTempTables) {
			return StringUtils.replace(ResourceHelper.GetResourceAsString(RESULTS_DDL_PATH), "@schemaName.", "#");
		}
		else {
			return ResourceHelper.GetResourceAsString(RESULTS_DDL_PATH);
		}
	}	
	
	public static String getCleanupSql() {
		return getCleanupSql(false);
	}
	
	public static String getCleanupSql(boolean useTempTables) {
		if (useTempTables) {
			return StringUtils.replace(ResourceHelper.GetResourceAsString(CLEANUP_PATH), "@schemaName.", "#");
		}
		else {
			return ResourceHelper.GetResourceAsString(CLEANUP_PATH);
		}
	}
}
