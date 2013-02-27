--
-- Script to check for conflicting Scenario source objects.
-- Only objects marked as being the source of a Scenario are checked.
--

--
-- Duplicate Procedures.
--
SELECT 1 / 0
           AS cause_an_error
  FROM (
       SELECT trt_name
         FROM snp_trt
        WHERE i_trt
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
        GROUP
           BY trt_name
       HAVING COUNT(*) > 1
       )
;

--
-- Duplicate Packages.
--
SELECT 1 / 0
           AS cause_an_error
  FROM (
       SELECT pack_name
         FROM snp_package
        WHERE i_package
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
        GROUP
           BY pack_name
       HAVING COUNT(*) > 1
       )
;

--
-- Duplicate Interfaces.
--
SELECT 1 / 0
           AS cause_an_error
  FROM (
       SELECT pop_name
         FROM snp_pop
        WHERE i_pop 
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
        GROUP
           BY pop_name
       HAVING COUNT(*) > 1
       )
;

--
-- Interfaces and Packages.
--
SELECT 1 / 0
           AS cause_an_error
  FROM (
       SELECT pop_name
         FROM snp_pop
        WHERE i_pop 
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
       INTERSECT
       SELECT pack_name
         FROM snp_package
        WHERE i_package
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
       )
;

--
-- Interfaces and Procedures.
--
SELECT 1 / 0
           AS cause_an_error
  FROM (
       SELECT pop_name
         FROM snp_pop
        WHERE i_pop 
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
       INTERSECT
       SELECT trt_name
         FROM snp_trt
        WHERE i_trt
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
       )
;

--
-- Packages and Procedures.
--
SELECT 1 / 0
           AS cause_an_error
  FROM (
       SELECT pack_name
         FROM snp_package
        WHERE i_package
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
       INTERSECT
       SELECT trt_name
         FROM snp_trt
        WHERE i_trt
           IN (
              SELECT i_instance
                FROM snp_obj_state
               WHERE i_object = 3100
                 AND i_state
                  IN ( 
                     SELECT i_state
                       FROM snp_state2
                      WHERE state_code
                         IN (
                            'HAS_SCENARIO'
                          , 'MOI_CODE_RECONCILLIATION'
                            )
                        AND i_grp_state
                         IN (
                            SELECT i_grp_state
                              FROM snp_grp_state
                             WHERE grp_state_code
                                IN (
                                   'ODISCM_AUTOMATION'
                                 , 'MOI_CODE_RECONCILLIATION'
                                   )
                            )
                     )
              )
       )
;