--
-- A utility script to quickly delete all of the ODI scenarios scenarios in a repository.
-- To include the scenarios of the ODI-SVN project comment out the indicated sections of the WHERE clause.
--
DELETE
  FROM snp_scen_txt
------ Comment-out from here - to include ODI-SVN project scenarios.  
 WHERE scen_no
   NOT
    IN (
       --
       -- Scenarios of procedures of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT i_trt
                FROM snp_trt
               WHERE i_project
                  IN (
                     SELECT i_project
                       FROM snp_project
                      WHERE project_name = 'ODI-SVN'
                        AND project_code = 'OS'
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of packages of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT i_package
                FROM snp_package
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of interfaces of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i_pop
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of variables of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT i_var
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
------ Comment-out to here - to include ODI-SVN project scenarios.         
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_scen_task
------ Comment-out from here - to include ODI-SVN project scenarios.    
 WHERE scen_no
   NOT
    IN (
       --
       -- Scenarios of procedures of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT i_trt
                FROM snp_trt
               WHERE i_project
                  IN (
                     SELECT i_project
                       FROM snp_project
                      WHERE project_name = 'ODI-SVN'
                        AND project_code = 'OS'
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of packages of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT i_package
                FROM snp_package
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of interfaces of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i_pop
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of variables of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT i_var
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
------ Comment-out to here - to include ODI-SVN project scenarios.                
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_scen_step
------ Comment-out from here - to include ODI-SVN project scenarios.    
 WHERE scen_no
   NOT
    IN (
       --
       -- Scenarios of procedures of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT i_trt
                FROM snp_trt
               WHERE i_project
                  IN (
                     SELECT i_project
                       FROM snp_project
                      WHERE project_name = 'ODI-SVN'
                        AND project_code = 'OS'
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of packages of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT i_package
                FROM snp_package
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of interfaces of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i_pop
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of variables of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT i_var
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
------ Comment-out to here - to include ODI-SVN project scenarios.                
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_var_scen
------ Comment-out from here - to include ODI-SVN project scenarios.    
 WHERE scen_no
   NOT
    IN (
       --
       -- Scenarios of procedures of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT i_trt
                FROM snp_trt
               WHERE i_project
                  IN (
                     SELECT i_project
                       FROM snp_project
                      WHERE project_name = 'ODI-SVN'
                        AND project_code = 'OS'
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of packages of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT i_package
                FROM snp_package
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of interfaces of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i_pop
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of variables of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT i_var
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
------ Comment-out to here - to include ODI-SVN project scenarios.                
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_step_report
------ Comment-out from here - to include ODI-SVN project scenarios.    
 WHERE scen_no
   NOT
    IN (
       --
       -- Scenarios of procedures of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT i_trt
                FROM snp_trt
               WHERE i_project
                  IN (
                     SELECT i_project
                       FROM snp_project
                      WHERE project_name = 'ODI-SVN'
                        AND project_code = 'OS'
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of packages of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT i_package
                FROM snp_package
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of interfaces of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i_pop
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of variables of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT i_var
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
------ Comment-out to here - to include ODI-SVN project scenarios.                
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_scen_report
------ Comment-out from here - to include ODI-SVN project scenarios.    
 WHERE scen_no
   NOT
    IN (
       --
       -- Scenarios of procedures of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT i_trt
                FROM snp_trt
               WHERE i_project
                  IN (
                     SELECT i_project
                       FROM snp_project
                      WHERE project_name = 'ODI-SVN'
                        AND project_code = 'OS'
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of packages of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT i_package
                FROM snp_package
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of interfaces of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i_pop
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of variables of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT i_var
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
------ Comment-out to here - to include ODI-SVN project scenarios.                
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_scen
------ Comment-out from here - to include ODI-SVN project scenarios.    
 WHERE scen_no
   NOT
    IN (
       --
       -- Scenarios of procedures of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_trt
           IN (
              SELECT i_trt
                FROM snp_trt
               WHERE i_project
                  IN (
                     SELECT i_project
                       FROM snp_project
                      WHERE project_name = 'ODI-SVN'
                        AND project_code = 'OS'
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of packages of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_package
           IN (
              SELECT i_package
                FROM snp_package
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of interfaces of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_pop
           IN (
              SELECT i_pop
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
   AND scen_no
   NOT
    IN (
       --
       -- Scenarios of variables of the ODI-SVN project.
       --
       SELECT scen_no
         FROM snp_scen
        WHERE i_var
           IN (
              SELECT i_var
                FROM snp_pop
               WHERE i_folder
                  IN (
                     SELECT i_folder
                       FROM snp_folder
                      WHERE i_project
                         IN (
                            SELECT i_project
                              FROM snp_project
                             WHERE project_name = 'ODI-SVN'
                               AND project_code = 'OS'
                            )
                     )
              )
       )
------ Comment-out to here - to include ODI-SVN project scenarios.                
<OdiScmGenerateSqlStatementDelimiter>

COMMIT
<OdiScmGenerateSqlStatementDelimiter>
