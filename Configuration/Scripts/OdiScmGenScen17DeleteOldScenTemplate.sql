--
-- Generate list of scenarios to be deleted.
-- We delete scenarios for objects that will be imported by an import process and that don't have
-- the marker that allows the source object to retain its Scenario when its imported and exported.
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
              -- All Interfaces that will be imported.
              SELECT source_object_id
                       AS i_pop
                FROM odiscm_imports
               WHERE source_type_id = 3100 -- Value for Interfaces.
               MINUS
                     -- Objects from the ODI-SCM project.
              SELECT i.i_pop
                FROM snp_pop i
               INNER
                JOIN snp_folder f
                  ON i.i_folder = f.i_folder
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
               WHERE p.project_code = 'OS'
               MINUS
                     -- Objects that are allowed to have a Scenario added to the SCM system.
              SELECT i.i_pop
                FROM snp_pop i
               INNER
                JOIN snp_folder f
                  ON i.i_folder = f.i_folder
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
               INNER
                JOIN snp_obj_state os
                  ON i.i_pop = os.i_instance    
               INNER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
               INNER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE os.i_object = 3100 -- Value for Interfaces.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
              )
        UNION
       SELECT scen_no
            , scen_name
            , scen_version
         FROM snp_scen
        WHERE i_trt
           IN (
              -- All Procedures that will be imported.
              SELECT source_object_id
                       AS i_trt
                FROM odiscm_imports
               WHERE source_type_id = 3600 -- Value for Procedures.
               MINUS
                     -- Objects from the ODI-SCM project.
              SELECT t.i_trt
                FROM snp_trt t
               INNER
                JOIN snp_project p
                  ON t.i_project = p.i_project
               WHERE p.project_code = 'OS'
               MINUS
                     -- Objects that are allowed to have a Scenario added to the SCM system.
              SELECT t.i_trt
                FROM snp_trt t
               INNER
                JOIN snp_project p
                  ON t.i_project = p.i_project
               INNER
                JOIN snp_obj_state os
                  ON t.i_trt = os.i_instance    
               INNER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
               INNER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE os.i_object = 3600 -- Value for Procedures.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
              )
        UNION
       SELECT scen_no
            , scen_name
            , scen_version
         FROM snp_scen
        WHERE i_package
           IN (
              -- All Packages that will be imported.
              SELECT source_object_id
                       AS i_package
                FROM odiscm_imports
               WHERE source_type_id = 3200 -- Value for Packages.
               MINUS
                     -- Objects from the ODI-SCM project.
              SELECT a.i_package
                FROM snp_package a
               INNER
                JOIN snp_folder f
                  ON a.i_folder = f.i_folder                
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
               WHERE p.project_code = 'OS'
               MINUS
                     -- Objects that are allowed to have a Scenario added to the SCM system.
              SELECT a.i_package
                FROM snp_package a
               INNER
                JOIN snp_folder f
                  ON a.i_folder = f.i_folder                
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
               INNER
                JOIN snp_obj_state os
                  ON a.i_package = os.i_instance    
               INNER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
               INNER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE os.i_object = 3200 -- Value for Packages.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
              )
        UNION
       SELECT scen_no
            , scen_name
            , scen_version
         FROM snp_scen
        WHERE i_var
           IN (
              -- All Variables that will be imported.
              SELECT source_object_id
                       AS i_var
                FROM odiscm_imports
               WHERE source_type_id = 3500 -- Value for Variables.
               MINUS
                     -- Objects from the ODI-SCM project.
              SELECT v.i_var
                FROM snp_var v
               INNER
                JOIN snp_project p
                  ON v.i_project = p.i_project
               WHERE p.project_code = 'OS'
               MINUS
                     -- Objects that are allowed to have a Scenario added to the SCM system.
              SELECT v.i_var
                FROM snp_var v
               INNER -- Don't allow for Global Variables - they can't be assigned a marker to generate a Scenario.
                JOIN snp_project p
                  ON v.i_project = p.i_project
               INNER
                JOIN snp_obj_state os
                  ON v.i_var = os.i_instance    
               INNER
                JOIN snp_state2 s2
                  ON os.i_state = s2.i_state
               INNER
                JOIN snp_grp_state gs
                  ON s2.i_grp_state = gs.i_grp_state
               CROSS
                JOIN odiscm_configurations osco
               WHERE os.i_object = 3500 -- Value for Variables.
                 AND osco.scenario_export_markers LIKE ('%' || NVL(gs.grp_state_code,'XXX') || '.' || NVL(s2.state_code,'XXX') || '%')
              )
       )
/