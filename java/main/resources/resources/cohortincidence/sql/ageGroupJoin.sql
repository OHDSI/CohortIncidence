  LEFT JOIN @results_database_schema.age_group_def ag ON ag.ref_id = @ref_id
    and t1.age  >= coalesce(ag.min_age, -999) 
    and t1.age  < coalesce(ag.max_age, 999)