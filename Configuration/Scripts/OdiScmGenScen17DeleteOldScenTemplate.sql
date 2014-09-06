--
-- Generate list of scenarios to be deleted.
-- We delete scenarios for objects that will be imported by an import process.
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
                     -- Objects from the ODI-SCM project (which shouldn't get imported anyway).
              SELECT i.i_pop
                FROM snp_pop i
               INNER
                JOIN snp_folder f
                  ON i.i_folder = f.i_folder
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
               WHERE p.project_code = 'OS'
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
                     -- Objects from the ODI-SCM project (which shouldn't get imported anyway).
              SELECT t.i_trt
                FROM snp_trt t
               INNER
                JOIN snp_project p
                  ON t.i_project = p.i_project
               WHERE p.project_code = 'OS'
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
                     -- Objects from the ODI-SCM project (which shouldn't get imported anyway).
              SELECT a.i_package
                FROM snp_package a
               INNER
                JOIN snp_folder f
                  ON a.i_folder = f.i_folder                
               INNER
                JOIN snp_project p
                  ON f.i_project = p.i_project
               WHERE p.project_code = 'OS'
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
                     -- Objects from the ODI-SCM project (which shouldn't get imported anyway).
              SELECT v.i_var
                FROM snp_var v
               INNER
                JOIN snp_project p
                  ON v.i_project = p.i_project
               WHERE p.project_code = 'OS'
              )
       )
/