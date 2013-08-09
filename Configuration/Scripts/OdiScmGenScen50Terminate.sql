--
-- Clear down the temporary object markings.
--
DELETE
  FROM snp_obj_state
 WHERE i_state
    IN (
       SELECT i_state
         FROM snp_state2
        WHERE state_code = 'GENERATE_SCENARIO'
          AND state_name = 'Generate Scenario'
          AND i_grp_state
           IN (
              SELECT i_grp_state
                FROM snp_grp_state
               WHERE (
                     grp_state_code  = 'ODISCM'
                 AND grp_state_name  = 'OdiScm'
                     )
              )
       )
/

ANALYZE TABLE snp_obj_state ESTIMATE STATISTICS
/

DELETE
  FROM snp_state2
 WHERE state_code = 'GENERATE_SCENARIO'
   AND state_name = 'Generate Scenario'
   AND i_grp_state
    IN (
       SELECT i_grp_state
         FROM snp_grp_state
        WHERE (
              grp_state_code  = 'ODISCM'
          AND grp_state_name  = 'OdiScm'
              )
       )
/

COMMIT
/

ANALYZE TABLE snp_state2 ESTIMATE STATISTICS
/