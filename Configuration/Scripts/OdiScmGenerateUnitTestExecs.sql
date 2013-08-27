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
            , p.i_pop
                  AS i_object
            , p.pop_name
                  AS object_name
         FROM snp_pop p
        INNER
         JOIN snp_folder f
           ON p.i_folder = f.i_folder
        INNER
         JOIN snp_obj_state os
           ON p.i_pop = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3100 -- From SNP_OBJECT.
          AND (
              gs.grp_state_code = 'ODISCM'
          AND gs.grp_state_name = 'OdiScm'
          AND s2.state_code = 'HAS_SCENARIO'
          AND s2.state_name = 'Has Scenario'
              )
        UNION
       --
       -- Procedures with a Scenario.
       --
       SELECT f.i_project
            , 'Procedure'
                  AS object_type_name
            , t.i_trt
                  AS i_object
            , t.trt_name
                  AS object_name
         FROM snp_trt t
        INNER
         JOIN snp_folder f
           ON t.i_folder = f.i_folder
        INNER
         JOIN snp_obj_state os
           ON t.i_trt = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3600 -- From SNP_OBJECT.
          AND (
              gs.grp_state_code = 'ODISCM'
          AND gs.grp_state_name = 'OdiScm'
          AND s2.state_code = 'HAS_SCENARIO'
          AND s2.state_name = 'Has Scenario'
              ) 
              -- Procedures, not Knowledge Modules.
          AND t.i_folder IS NOT NULL
        UNION
       --
       -- Knowledge Modules unit tests. Test independently of the Interfaces that use them.
       --
       SELECT t.i_project
            , 'KnowledgeModule'
                  AS object_type_name
            , t.i_trt
                  AS i_object
            , t.trt_name
                  AS object_name
         FROM snp_trt t
        INNER
         JOIN snp_obj_state os
           ON t.i_trt = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3600 -- From SNP_OBJECT.
          AND (
              gs.grp_state_code = 'ODISCM'
          AND gs.grp_state_name = 'OdiScm'
          AND s2.state_code = 'HAS_SCENARIO'
          AND s2.state_name = 'Has Scenario'
              )
              -- Project Knowledge Modules.
          AND t.i_folder IS NULL
        UNION
       SELECT t.i_project
            , 'KnowledgeModule'
                  AS object_type_name
            , t.i_trt
                  AS i_object
            , t.trt_name
                  AS object_name
         FROM snp_trt t
        INNER
         JOIN snp_obj_state os
           ON t.i_trt = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3600 -- From SNP_OBJECT.
          AND (
              gs.grp_state_code = 'ODISCM'
          AND gs.grp_state_name = 'OdiScm'
          AND s2.state_code = 'HAS_SCENARIO'
          AND s2.state_name = 'Has Scenario'
              )
              -- Global Knowledge Modules.
          AND t.i_project IS NULL
        UNION
       --
       -- Packages with a Scenario.
       -- 
       SELECT f.i_project
            , 'Package'
                  AS object_type_name
            , p.i_package
                  AS i_object
            , p.pack_name
                  AS object_name
         FROM snp_package p
        INNER
         JOIN snp_folder f
           ON p.i_folder = f.i_folder
        INNER
         JOIN snp_obj_state os
           ON p.i_package = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3200 -- From SNP_OBJECT.
          AND (
              gs.grp_state_code = 'ODISCM'
          AND gs.grp_state_name = 'OdiScm'
          AND s2.state_code = 'HAS_SCENARIO'
          AND s2.state_name = 'Has Scenario'
              )
        UNION
       --
       -- Variables with a Scenario.
       -- 
       SELECT v.i_project -- Null for Global variables.
            , 'Variable'
                  AS object_type_name
            , v.i_var
                  AS i_object
            , v.var_name
                  AS object_name
         FROM snp_var v
        INNER
         JOIN snp_obj_state os
           ON v.i_var = os.i_instance
        INNER
         JOIN snp_state2 s2
           ON os.i_state = s2.i_state
        INNER
         JOIN snp_grp_state gs
           ON s2.i_grp_state = gs.i_grp_state
        WHERE os.i_object = 3500 -- From SNP_OBJECT.
          AND (
              gs.grp_state_code = 'ODISCM'
          AND gs.grp_state_name = 'OdiScm'
          AND s2.state_code = 'HAS_SCENARIO'
          AND s2.state_name = 'Has Scenario'
              )
       )
/