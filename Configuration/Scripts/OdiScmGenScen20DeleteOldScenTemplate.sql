--
-- Generate list of scenarios to be deleted.
-- We delete scenarios for objects that have been updated by an import process
-- We don't care if the source object has been marked or not as 'should have a scenario'.
--
SELECT 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmOdiStartCmdBat>" OdiDeleteScen "-SCEN_NAME='
    || scen_name
    || '" "-SCEN_VERSION='
    || scen_version
    || '"'
  FROM (
       SELECT scen_no
            , scen_name
            , scen_version
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i.i_pop
                FROM snp_pop i
               INNER
                JOIN snp_folder f
                  ON i.i_folder = f.i_folder
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
                LEFT
               OUTER
                JOIN snp_obj_state os
                  ON i.i_pop = os.i_instance    
                LEFT
               OUTER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
                LEFT
               OUTER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE --
                     -- Always allow ODI-SCM scenarios to be exported. 
                     --
                 NOT (
                     p.project_code = 'OS'
                     )
                     --
                     -- Allow non ODI-SCM scenarios to be exported if they have the appropriate marker.
                     --
                 AND
                 NOT (
                     NVL(os.i_object, -1) = 3100                            -- Value for Interfaces.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
                     )
                 AND i.last_date >
                     (
                     SELECT import_start_datetime
                       FROM odiscm_controls
                     )
              )
        UNION
       SELECT scen_no
            , scen_name
            , scen_version
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT t.i_trt
                FROM snp_trt t
               INNER
                JOIN snp_project p
                  ON t.i_project = p.i_project
                LEFT
               OUTER
                JOIN snp_obj_state os
                  ON t.i_trt = os.i_instance    
                LEFT
               OUTER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
                LEFT
               OUTER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE --
                     -- Always allow ODI-SCM scenarios to be exported. 
                     --
                 NOT (
                     p.project_code = 'OS'
                     )
                     --
                     -- Allow non ODI-SCM scenarios to be exported if they have the appropriate marker.
                     --
                 AND
                 NOT (
                     NVL(os.i_object, -1) = 3600                            -- Value for Procedures.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
                     )
                 AND t.last_date >
                     (
                     SELECT import_start_datetime
                       FROM odiscm_controls
                     )
              )
        UNION
       SELECT scen_no
            , scen_name
            , scen_version
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT a.i_package
                FROM snp_package a
               INNER
                JOIN snp_folder f
                  ON a.i_folder = f.i_folder                
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
                LEFT
               OUTER
                JOIN snp_obj_state os
                  ON a.i_package = os.i_instance    
                LEFT
               OUTER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
                LEFT
               OUTER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE --
                     -- Always allow ODI-SCM scenarios to be exported. 
                     --
                 NOT (
                     p.project_code = 'OS'
                     )
                     --
                     -- Allow non ODI-SCM scenarios to be exported if they have the appropriate marker.
                     --
                 AND
                 NOT (
                     NVL(os.i_object, -1) = 3200                            -- Value for Packages.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
                     )
                 AND a.last_date >
                     (
                     SELECT import_start_datetime
                       FROM odiscm_controls
                     )
              )
        UNION
       SELECT scen_no
            , scen_name
            , scen_version
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT v.i_var
                FROM snp_var v
                LEFT
               OUTER -- Allow for Global Variables
                JOIN snp_project p
                  ON v.i_project = p.i_project
                LEFT
               OUTER
                JOIN snp_obj_state os
                  ON v.i_var = os.i_instance    
                LEFT
               OUTER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
                LEFT
               OUTER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE --
                     -- Always allow ODI-SCM scenarios to be exported. 
                     --
                 NOT (
                     NVL(p.project_code,'XX') = 'OS'
                     )
                     --
                     -- Allow non ODI-SCM scenarios to be exported if they have the appropriate marker.
                     --
                 AND
                 NOT (
                     NVL(os.i_object, -1) = 3500                            -- Value for Variables.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
                     )
                 AND v.last_date >
                     (
                     SELECT import_start_datetime
                       FROM odiscm_controls
                     )
              )
       )
/