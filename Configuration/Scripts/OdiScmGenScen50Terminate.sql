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
          AND i_grp_state
           IN (
              SELECT i_grp_state
                FROM snp_grp_state
               WHERE grp_state_code  = 'ODISCM_TEMPORARY'
              )
       )
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_state2
 WHERE state_code = 'GENERATE_SCENARIO'
   AND i_grp_state
    IN (
       SELECT i_grp_state
         FROM snp_grp_state
        WHERE grp_state_code  = 'ODISCM_TEMPORARY'
       )
<OdiScmGenerateSqlStatementDelimiter>

DELETE
  FROM snp_grp_state
 WHERE grp_state_code = 'ODISCM_TEMPORARY'
<OdiScmGenerateSqlStatementDelimiter>

COMMIT
<OdiScmGenerateSqlStatementDelimiter>

ANALYZE TABLE snp_obj_state ESTIMATE STATISTICS
<OdiScmGenerateSqlStatementDelimiter>

ANALYZE TABLE snp_state2 ESTIMATE STATISTICS
<OdiScmGenerateSqlStatementDelimiter>

ANALYZE TABLE snp_grp_state ESTIMATE STATISTICS
<OdiScmGenerateSqlStatementDelimiter>