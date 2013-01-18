--
-- Generate list of scenarios to be deleted.
-- We delete scenarios for objects that have been updated by an import process
-- We don't care if the source object has been marked or not as 'should have a scenario'.
--
SELECT 'call startcmd.bat OdiDeleteScen "-SCEN_NAME='
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
               WHERE p.project_name <> 'ODI-SVN'
                 AND i.last_date >
                     (
                     SELECT import_start_datetime
                       FROM odisvn_controls
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
               WHERE p.project_name <> 'ODI-SVN'
                 AND t.last_date >
                     (
                     SELECT import_start_datetime
                       FROM odisvn_controls
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
               WHERE p.project_name <> 'ODI-SVN'
                 AND a.last_date >
                     (
                     SELECT import_start_datetime
                       FROM odisvn_controls
                     )
              )
       )
/