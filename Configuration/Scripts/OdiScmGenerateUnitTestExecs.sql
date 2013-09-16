SELECT i_project
    || '/'
    || object_type_name
    || '/'
    || i_object
    || '/'
    || TRIM(object_name)
   FROM (
       --
       -- Interfaces with a Scenario.
       --
       SELECT f.i_project
            , 'Interface'
                  AS object_type_name
            , o.i_pop
                  AS i_object
            , o.pop_name
                  AS object_name
         FROM snp_pop o
        INNER
         JOIN snp_folder f
           ON o.i_folder = f.i_folder
        INNER
         JOIN snp_obj_state os
           ON o.i_pop = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3100 -- From SNP_OBJECT.
          AND '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
          <OdiScmModifiedObjectsOnlyFilterText>
        UNION
       --
       -- Procedures with a Scenario.
       --
       SELECT f.i_project
            , 'Procedure'
                  AS object_type_name
            , o.i_trt
                  AS i_object
            , o.trt_name
                  AS object_name
         FROM snp_trt o
        INNER
         JOIN snp_folder f
           ON o.i_folder = f.i_folder
        INNER
         JOIN snp_obj_state os
           ON o.i_trt = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3600 -- From SNP_OBJECT.
          AND '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%') 
          <OdiScmModifiedObjectsOnlyFilterText>
              -- Procedures, not Knowledge Modules.
          AND o.i_folder IS NOT NULL
        UNION
       --
       -- Knowledge Modules unit tests. Test independently of the Interfaces that use them.
       --
       SELECT o.i_project
            , 'KnowledgeModule'
                  AS object_type_name
            , o.i_trt
                  AS i_object
            , o.trt_name
                  AS object_name
         FROM snp_trt o
        INNER
         JOIN snp_obj_state os
           ON o.i_trt = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3600 -- From SNP_OBJECT.
          AND '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
          <OdiScmModifiedObjectsOnlyFilterText>
              -- Project Knowledge Modules.
          AND o.i_folder IS NULL
        UNION
       SELECT o.i_project
            , 'KnowledgeModule'
                  AS object_type_name
            , o.i_trt
                  AS i_object
            , o.trt_name
                  AS object_name
         FROM snp_trt o
        INNER
         JOIN snp_obj_state os
           ON o.i_trt = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3600 -- From SNP_OBJECT.
          AND '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
          <OdiScmModifiedObjectsOnlyFilterText>
              -- Global Knowledge Modules.
          AND o.i_project IS NULL
        UNION
       --
       -- Packages with a Scenario.
       -- 
       SELECT f.i_project
            , 'Package'
                  AS object_type_name
            , o.i_package
                  AS i_object
            , o.pack_name
                  AS object_name
         FROM snp_package o
        INNER
         JOIN snp_folder f
           ON o.i_folder = f.i_folder
        INNER
         JOIN snp_obj_state os
           ON o.i_package = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3200 -- From SNP_OBJECT.
          AND '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
          <OdiScmModifiedObjectsOnlyFilterText>
        UNION
       --
       -- Variables with a Scenario.
       -- 
       SELECT o.i_project -- Null for Global variables.
            , 'Variable'
                  AS object_type_name
            , o.i_var
                  AS i_object
            , o.var_name
                  AS object_name
         FROM snp_var o
        INNER
         JOIN snp_obj_state os
           ON o.i_var = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3500 -- From SNP_OBJECT.
          AND '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
          <OdiScmModifiedObjectsOnlyFilterText>
       )
/