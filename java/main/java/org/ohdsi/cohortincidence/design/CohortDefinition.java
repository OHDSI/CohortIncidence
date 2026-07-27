package org.ohdsi.cohortincidence.design;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

/**
 *
 * @author cknoll1
 */

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.WRAPPER_OBJECT)
@JsonSubTypes({
  @JsonSubTypes.Type(value = SqlCohortDefinition.class, name = "SqlCohortDefinition")
})
public abstract class CohortDefinition  {
	public Integer id;
	public String name;
	public String description;	
}
