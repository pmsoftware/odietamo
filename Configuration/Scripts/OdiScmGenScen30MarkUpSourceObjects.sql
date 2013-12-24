TRUNCATE
   TABLE odiscm_genscen_sources
/

--
-- Identify modified source objects for which we must generate a Scenario.
--
-- First, directly.
--
INSERT
  INTO odiscm_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
-----, marker_group_code
       )
--
-- Modified Interfaces with a Scenario.
--
SELECT DISTINCT         -- Because of multiple markers.
       p.i_pop
     , 3100             -- For Interfaces.
     , p.i_folder
     , f.i_project
-----, gs.grp_state_code
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
 WHERE os.i_object = 3100
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       )
   AND p.last_date >
       (
       SELECT import_start_datetime
         FROM odiscm_controls
       )
 UNION
--
-- Modified Procedures with a Scenario.
--
SELECT DISTINCT         -- Because of multiple markers.
       t.i_trt
     , 3600             -- For Procedures.
     , t.i_folder
     , f.i_project
-----, gs.grp_state_code
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
 WHERE os.i_object = 3600
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       ) 
   AND t.last_date >
       (
       SELECT import_start_datetime
         FROM odiscm_controls
       )
 UNION
--
-- Modified Packages with a Scenario.
-- 
SELECT DISTINCT         -- Because of multiple markers.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
-----, gs.grp_state_code 
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
 WHERE os.i_object = 3200
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       ) 
   AND p.last_date >
       (
       SELECT import_start_datetime
         FROM odiscm_controls
       )
/

COMMIT
/

--
-- Second, indirectly.
--
-- Packages, with a Scenario, referencing a modified Interface.
--
INSERT
  INTO odiscm_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
-----, marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP, and multiple markers.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
-----, gs.grp_state_code 
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
 INNER
  JOIN snp_step s
    ON p.i_package = s.i_package
 WHERE os.i_object = 3200
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       )
   AND s.i_pop
    IN (
       SELECT source_object_id
         FROM odiscm_genscen_sources
        WHERE source_type_id = 3100
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odiscm_genscen_sources
                )
/

--
-- Packages, with a Scenario, referencing a modified Procedure.
--
INSERT
  INTO odiscm_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
-----, marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP, and multiple markers.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
-----, gs.grp_state_code
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
 INNER
  JOIN snp_step s
    ON p.i_package = s.i_package
 WHERE os.i_object = 3200
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       ) 
   AND s.i_trt
    IN (
       SELECT source_object_id
         FROM odiscm_genscen_sources
        WHERE source_type_id = 3600 -- For Procedures.
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odiscm_genscen_sources
                )
/

COMMIT
/

--
-- Third, other Package dependencies
--
-- Packages, with a Scenario, referencing a modified Variable.
--
INSERT
  INTO odiscm_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
-----, marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP, and multiple markers.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
-----, gs.grp_state_code
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
 INNER
  JOIN snp_step s
    ON p.i_package = s.i_package
 WHERE os.i_object = 3200
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       ) 
   AND s.i_var
    IN (
       SELECT i_var
         FROM snp_var
        WHERE last_date >= (
                           SELECT import_start_datetime
                             FROM odiscm_controls
                           )
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odiscm_genscen_sources
                )
/

--
-- Packages, with a Scenario, referencing a modified Model (or Sub Model, Data Store in the Model, or
-- a Knowledge Module used by the Model).
--
INSERT
  INTO odiscm_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
-----, marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP, and multiple markers.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
-----, gs.grp_state_code
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
 INNER
  JOIN snp_step s
    ON p.i_package = s.i_package
 WHERE os.i_object = 3200
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       )  
   AND (
       s.i_mod IN (
                  SELECT i_mod
                    FROM snp_model
                   WHERE last_date >= (
                                      SELECT import_start_datetime
                                        FROM odiscm_controls
                                      )
                   UNION
                  SELECT i_mod
                    FROM snp_sub_model
                   WHERE last_date >= (
                                      SELECT import_start_datetime
                                        FROM odiscm_controls
                                      )
                   UNION
                  SELECT i_mod
                    FROM snp_table
                   WHERE last_date >= (
                                      SELECT import_start_datetime
                                        FROM odiscm_controls
                                      )
                  )
    OR s.i_mod IN (
                  SELECT i_mod
                    FROM snp_model
                   WHERE i_trt_kcm IN (
                                      SELECT i_trt
                                        FROM snp_trt
                                       WHERE last_date >= (
                                                          SELECT import_start_datetime
                                                            FROM odiscm_controls
                                                          )
                                      )
                      OR i_trt_kdm IN (
                                      SELECT i_trt
                                        FROM snp_trt
                                       WHERE last_date >= (
                                                          SELECT import_start_datetime
                                                            FROM odiscm_controls
                                                          )
                                      )
                      OR i_trt_kjm IN (
                                      SELECT i_trt
                                        FROM snp_trt
                                       WHERE last_date >= (
                                                          SELECT import_start_datetime
                                                            FROM odiscm_controls
                                                          )
                                      )
                      OR i_trt_skm IN (
                                      SELECT i_trt
                                        FROM snp_trt
                                       WHERE last_date >= (
                                                          SELECT import_start_datetime
                                                            FROM odiscm_controls
                                                          )
                                      )
                  )
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odiscm_genscen_sources
                )
/

--
-- Packages, with a Scenario, referencing a modified Data Store.
--
INSERT
  INTO odiscm_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
-----, marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP, and multiple markers.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
-----, gs.grp_state_code
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
 INNER
  JOIN snp_step s
    ON p.i_package = s.i_package
 WHERE os.i_object = 3200
   AND (
       '<OdiScmScenarioSourceMarkers>' LIKE ('%' || gs.grp_state_code || '.' || s2.state_code || '%')
       ) 
   AND (
       s.i_table IN (
                    SELECT i_table
                      FROM snp_table
                     WHERE last_date >= (
                                        SELECT import_start_datetime
                                          FROM odiscm_controls
                                        )
                    )
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odiscm_genscen_sources
                )
/

ANALYZE TABLE odiscm_genscen_sources ESTIMATE STATISTICS
/

--SET SERVER OUTPUT ON SIZE 10000000;

DECLARE
    cRepId          CHAR(3);
    iGrpState       snp_grp_state.i_grp_state%TYPE;
    iState          snp_state2.i_state%TYPE;
    iObjState       snp_obj_state.i_obj_state%TYPE;

BEGIN
    --
    -- Get the fixed length character representation of the work repository ID.
    --
    SELECT LPAD(rep_short_id,3,'0')
      INTO cRepId
      FROM snp_loc_repw
    ;
    
    --
    -- Get the last used (note last used, not next value as the column name suggests) SnpGrpState, State2 and ObjState IDs.
    --
    SELECT COALESCE(MAX(id_next),0) 
      INTO iGrpState
      FROM snp_id
     WHERE id_tbl = 'SNP_GRP_STATE'
    ;

    SELECT COALESCE(MAX(id_next),0) 
      INTO iState
      FROM snp_id
     WHERE id_tbl = 'SNP_STATE2'
    ;

    SELECT COALESCE(MAX(id_next),0) 
      INTO iObjState
      FROM snp_id
     WHERE id_tbl = 'SNP_OBJ_STATE'
    ;
    
    --
    -- Create the temporary marker group for every project with source objects which require a scenario to be generated.
    --
    FOR c_project IN (
                     SELECT DISTINCT
                            project_id
                       FROM odiscm_genscen_sources
                      ORDER
                         BY project_id
                     )
    LOOP
        dbms_output.put_line('ODI-SCM: Creating temporary ''ODISCM_TEMPORARY'' marker group for project ' ||  c_project.project_id);
        
        iGrpState := iGrpState + 1;
        INSERT
          INTO snp_grp_state
               (
               i_grp_state
             , i_project
             , grp_state_name
             , grp_state_code
             , grp_order_disp
             , tree_display
             , ind_internal
             , ind_multi_states
             , ind_auto_increment
             , int_version
             , ind_change
             , first_date
             , first_user
             , last_date
             , last_user
             , ext_version
               )
        VALUES (
               TO_NUMBER(iGrpState || cRepId)
             , c_project.project_id
             , 'OdiScm Temporary'
             , 'ODISCM_TEMPORARY'
             , -99
             , 'X'
             , 'X'
             , 'X'
             , 'X'
             , -1
             , 'N'
             , SYSDATE
             , 'ODISCM'
             , SYSDATE
             , 'ODISCM'
             , 'X'
               )
        ;
        --
        -- Create the temporary marker, and object marking for every updated source project.
        --
        dbms_output.put_line('ODISCM: Creating temporary ''GENERATE_SCENARIO'' marker for project ' ||  c_project.project_id);
        
        iState := iState + 1;
        INSERT
          INTO snp_state2
               (
               i_state                       
             , i_grp_state                   
             , state_code                    
             , state_name                   
             , state_order                   
             , in_use                        
             , show_desc                     
             , icon_res                      
             , state_datatype                
             , last_date                     
             , int_version                   
             , ind_change                    
             , first_date                    
             , first_user                    
             , last_user
               )
        VALUES (
               TO_NUMBER(iState || cRepId)
             , TO_NUMBER(iGrpState || cRepId)
             , 'GENERATE_SCENARIO'
             , 'Generate Scenario'
             , -99                          -- State order
             , '1'                          -- In Use
             , '1'                          -- Show Desc
             , NULL                         -- Icon Res
             , 'A'                          -- State data type
             , SYSDATE                      -- Last Date
             , NULL                         -- Internal version
             , 'I'                          -- Ind Change
             , SYSDATE                      -- First Date
             , 'ODISCM'                     -- First User
             , 'ODISCM'                     -- Last User
               )
        ;
    END LOOP;

    --
    -- Set the markers for updated source objects.
    --
    FOR c_object IN (
                    SELECT ogss.source_object_id
                         , ogss.source_type_id
                         , sns2.i_state
                      FROM odiscm_genscen_sources ogss
                     INNER
                      JOIN snp_grp_state sngs
                        ON ogss.project_id = sngs.i_project
                     INNER
                      JOIN snp_state2 sns2
                        ON sngs.i_grp_state = sns2.i_grp_state
                     WHERE (
                           sngs.grp_state_code = 'ODISCM_TEMPORARY'
                       AND sns2.state_code = 'GENERATE_SCENARIO'
                           )
                    )
    LOOP
        dbms_output.put_line('OdiScm: Creating temporary object-to-marker relationship for state <' || c_object.i_state
                          || '> source object <' ||  c_object.source_object_id || '> object type <' || c_object.source_type_id || '>');
        iObjState := iObjState + 1;

        INSERT
          INTO snp_obj_state
               (
               i_obj_state
             , i_state
             , i_object
             , i_instance
             , info_text
             , info_date
             , info_num
             , i_txt_memo
             , last_date
             , last_user
               )
        VALUES (
               TO_NUMBER(iObjState || cRepId)
             , c_object.i_state
             , c_object.source_type_id
             , c_object.source_object_id
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
               )
        ;
    END LOOP;   

    COMMIT;
END;                     
/

ANALYZE TABLE snp_obj_state ESTIMATE STATISTICS
/

ANALYZE TABLE snp_state2 ESTIMATE STATISTICS
/

ANALYZE TABLE snp_grp_state ESTIMATE STATISTICS
/
