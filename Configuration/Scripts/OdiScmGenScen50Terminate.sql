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
          AND state_name = 'GENERATE_SCENARIO'
          AND i_grp_state
           IN (
              SELECT i_grp_state
                FROM snp_grp_state
               WHERE (
                     (
                     grp_state_code  = 'ODISCM_AUTOMATION'
                 AND grp_state_name  = 'ODISCM_AUTOMATION'
                     )
                  OR (
                     --
                     -- The deprecated marker group.
                     --
                     grp_state_code  = 'MOI_CODE_RECONCILLIATION'
                 AND grp_state_name  = 'MOI_CODE_RECONCILLIATION'
                     )
                     )
              )
       )
/

ANALYZE TABLE snp_obj_state ESTIMATE STATISTICS
/

DELETE
  FROM snp_state2
 WHERE state_code = 'GENERATE_SCENARIO'
   AND state_name = 'GENERATE_SCENARIO'
   AND i_grp_state
    IN (
       SELECT i_grp_state
         FROM snp_grp_state
        WHERE (
              (
              grp_state_code  = 'ODISCM_AUTOMATION'
          AND grp_state_name  = 'ODISCM_AUTOMATION'
              )
           OR (
              --
              -- The deprecated marker group.
              --
              grp_state_code  = 'MOI_CODE_RECONCILLIATION'
          AND grp_state_name  = 'MOI_CODE_RECONCILLIATION'
              )
              )
       )
/

COMMIT
/

ANALYZE TABLE snp_state2 ESTIMATE STATISTICS
/