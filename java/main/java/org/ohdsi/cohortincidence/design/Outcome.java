/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.ohdsi.cohortincidence.design;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 *
 * @author cknoll1
 */
public class Outcome {

	@JsonProperty("id")
	public Integer id;
	
	@JsonProperty("name")
	public String name;

	@JsonProperty("cohortId")
	public Integer cohortId;

	@JsonProperty("cleanWindow")
	public int cleanWindow;

	@JsonProperty("excludeCohortId")
	public Integer excludeCohortId;
}
