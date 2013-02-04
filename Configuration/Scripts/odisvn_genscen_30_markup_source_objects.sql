-- For SQL*Plus / TOAD usage only: SET SERVEROUTPUT ON SIZE 1000000;

TRUNCATE
   TABLE odisvn_genscen_sources
/

--
-- Identify modified source objects for which we must generate a Scenario.
--
-- First, directly.
--
INSERT
  INTO odisvn_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
     , marker_group_code
       )
--
-- Modified Interfaces with a Scenario.
--
SELECT p.i_pop
     , 3100             -- For Interfaces.
     , p.i_folder
     , f.i_project
     , gs.grp_state_code
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       )
   AND p.last_date >
       (
       SELECT import_start_datetime
         FROM odisvn_controls
       )
 UNION
--
-- Modified Procedures with a Scenario.
--
SELECT t.i_trt
     , 3600             -- For Procedures.
     , t.i_folder
     , f.i_project
     , gs.grp_state_code
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       ) 
   AND t.last_date >
       (
       SELECT import_start_datetime
         FROM odisvn_controls
       )
 UNION
--
-- Modified Packages with a Scenario.
-- 
SELECT p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
     , gs.grp_state_code 
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       ) 
   AND p.last_date >
       (
       SELECT import_start_datetime
         FROM odisvn_controls
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
  INTO odisvn_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
     , marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
     , gs.grp_state_code 
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       )
   AND s.i_pop
    IN (
       SELECT source_object_id
         FROM odisvn_genscen_sources
        WHERE source_type_id = 3100
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odisvn_genscen_sources
                )
/

--
-- Packages, with a Scenario, referencing a modified Procedure.
--
INSERT
  INTO odisvn_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
     , marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
     , gs.grp_state_code
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       ) 
   AND s.i_trt
    IN (
       SELECT source_object_id
         FROM odisvn_genscen_sources
        WHERE source_type_id = 3600 -- For Procedures.
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odisvn_genscen_sources
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
  INTO odisvn_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
     , marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
     , gs.grp_state_code
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       ) 
   AND s.i_var
    IN (
       SELECT i_var
         FROM snp_var
        WHERE last_date >= (
                           SELECT import_start_datetime
                             FROM odisvn_controls
                           )
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odisvn_genscen_sources
                )
/

--
-- Packages, with a Scenario, referencing a modified Model (or Sub Model, Data Store in the Model, or
-- a Knowledge Module used by the Model).
--
INSERT
  INTO odisvn_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
     , marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
     , gs.grp_state_code
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       )  
   AND (
       s.i_mod IN (
                  SELECT i_mod
                    FROM snp_model
                   WHERE last_date >= (
                                      SELECT import_start_datetime
                                        FROM odisvn_controls
                                      )
                   UNION
                  SELECT i_mod
                    FROM snp_sub_model
                   WHERE last_date >= (
                                      SELECT import_start_datetime
                                        FROM odisvn_controls
                                      )
                   UNION
                  SELECT i_mod
                    FROM snp_table
                   WHERE last_date >= (
                                      SELECT import_start_datetime
                                        FROM odisvn_controls
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
                                                            FROM odisvn_controls
                                                          )
                                      )
                      OR i_trt_kdm IN (
                                      SELECT i_trt
                                        FROM snp_trt
                                       WHERE last_date >= (
                                                          SELECT import_start_datetime
                                                            FROM odisvn_controls
                                                          )
                                      )
                      OR i_trt_kjm IN (
                                      SELECT i_trt
                                        FROM snp_trt
                                       WHERE last_date >= (
                                                          SELECT import_start_datetime
                                                            FROM odisvn_controls
                                                          )
                                      )
                      OR i_trt_skm IN (
                                      SELECT i_trt
                                        FROM snp_trt
                                       WHERE last_date >= (
                                                          SELECT import_start_datetime
                                                            FROM odisvn_controls
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
                  FROM odisvn_genscen_sources
                )
/

--
-- Packages, with a Scenario, referencing a modified Data Store.
--
INSERT
  INTO odisvn_genscen_sources
       (
       source_object_id
     , source_type_id
     , folder_id
     , project_id
     , marker_group_code
       )
SELECT DISTINCT         -- Because of the use of SNP_STEP.
       p.i_package
     , 3200             -- For Packages.
     , p.i_folder
     , f.i_project
     , gs.grp_state_code
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
       (
       --
       -- This marker group is deprecated.
       --
       gs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
   AND gs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_code = 'MOI_CODE_RECONCILLIATION'
   AND s2.state_name = 'MOI_CODE_RECONCILLIATION'
       )
    OR (
       --
       -- This is the new marker group going forward.
       --
       gs.grp_state_code = 'ODISVN_AUTOMATION'
   AND gs.grp_state_name = 'ODISVN_AUTOMATION'
   AND s2.state_code = 'HAS_SCENARIO'
   AND s2.state_name = 'HAS_SCENARIO'
       )
       ) 
   AND (
       s.i_table IN (
                    SELECT i_table
                      FROM snp_table
                     WHERE last_date >= (
                                        SELECT import_start_datetime
                                          FROM odisvn_controls
                                        )
                    )
       )
   AND (
       p.i_package
     , 3200
       ) NOT IN (
                SELECT source_object_id
                     , source_type_id
                  FROM odisvn_genscen_sources
                )
/

--
-- If there are any objects marked with both the current AND deprecated
-- marker groups then delete one of the entries.
--
DELETE
  FROM odisvn_genscen_sources
 WHERE (
       source_object_id
     , source_type_id
     , marker_group_code
       )
    IN (
       SELECT source_object_id
            , source_type_id
            , MIN(marker_group_code) -- Prefer the current marker group to the deprecated one.
         FROM odisvn_genscen_sources
        GROUP
           BY source_object_id
            , source_type_id
       HAVING COUNT(*) > 1
       )
/

COMMIT
/

ANALYZE TABLE odisvn_genscen_sources ESTIMATE STATISTICS
/

--SET SERVER OUTPUT ON SIZE 10000000;

DECLARE
    cRepId          CHAR(3);
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
    -- Get the last used (note last used, not next value as the column name suggests) State2 and ObjState IDs.
    --
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
    -- Create the temporary marker, and object marking for every updated source project.
    --
    FOR c_project IN (
                     SELECT DISTINCT
                            project_id
                       FROM odisvn_genscen_sources
                      ORDER
                         BY project_id
                     )
    LOOP
        dbms_output.put_line('ODISVN: Creating temporary GENERATE_SCENARIO marker for project ' ||  c_project.project_id);

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
        SELECT TO_NUMBER(iState || cRepId)
             , sngs.i_grp_state
             , 'GENERATE_SCENARIO'
             , 'GENERATE_SCENARIO'
             , -99                          -- State order
             , '1'                          -- In Use
             , '1'                          -- Show Desc
             , NULL                         -- Icon Res
             , 'A'                          -- State data type
             , SYSDATE                      -- Last Date
             , NULL                         -- Internal version
             , 'I'                          -- Ind Change
             , SYSDATE                      -- First Date
             , 'ODISVN'                     -- First User
             , 'ODISVN'                     -- Last User 
          FROM snp_grp_state sngs
         WHERE sngs.grp_state_code = 'ODISVN_AUTOMATION'
           AND sngs.i_project = c_project.project_id
        ;
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
        SELECT TO_NUMBER(iState || cRepId)
             , sngs.i_grp_state
             , 'GENERATE_SCENARIO'
             , 'GENERATE_SCENARIO'
             , -99                          -- State order
             , '1'                          -- In Use
             , '1'                          -- Show Desc
             , NULL                         -- Icon Res
             , 'A'                          -- State data type
             , SYSDATE                      -- Last Date
             , NULL                         -- Internal version
             , 'I'                          -- Ind Change
             , SYSDATE                      -- First Date
             , 'ODISVN'                     -- First User
             , 'ODISVN'                     -- Last User 
          FROM snp_grp_state sngs
         WHERE sngs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
           AND sngs.i_project = c_project.project_id
        ;
    END LOOP;

    --
    -- Set the markers for updated source objects.
    --
    FOR c_object IN (
                    SELECT ogss.source_object_id
                         , ogss.source_type_id
                         , sns2.i_state
                      FROM odisvn_genscen_sources ogss
                     INNER
                      JOIN snp_grp_state sngs
                        ON ogss.project_id = sngs.i_project
                     INNER
                      JOIN snp_state2 sns2
                        ON sngs.i_grp_state = sns2.i_grp_state
                     WHERE (
                           (
                           sngs.grp_state_code = 'MOI_CODE_RECONCILLIATION'
                       AND sngs.grp_state_name = 'MOI_CODE_RECONCILLIATION'
                       AND sns2.state_code = 'GENERATE_SCENARIO'
                       AND sns2.state_name = 'GENERATE_SCENARIO'
                           )
                        OR (
                           sngs.grp_state_code = 'ODISVN_AUTOMATION'
                       AND sngs.grp_state_name = 'ODISVN_AUTOMATION'
                       AND sns2.state_code = 'GENERATE_SCENARIO'
                       AND sns2.state_name = 'GENERATE_SCENARIO'
                           )
                           )
                    )
    LOOP
        dbms_output.put_line('ODISVN: Creating temporary object-to-marker relationship for state <' || c_object.i_state
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
                 );
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