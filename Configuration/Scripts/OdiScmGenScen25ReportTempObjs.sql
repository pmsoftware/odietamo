--
-- Report any temporary object markings.
--
SELECT 'I_OBJECT_STATE = '
    || i_obj_state
    || ' / '
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

SELECT 'I_STATE = '
    || i_state
    || ' / '
    || 'STATE_CODE = '
    || state_code
  FROM snp_state2
 WHERE state_code = 'GENERATE_SCENARIO'
   AND i_grp_state
    IN (
       SELECT i_grp_state
         FROM snp_grp_state
        WHERE grp_state_code  = 'ODISCM_TEMPORARY'
       )
<OdiScmGenerateSqlStatementDelimiter>

SELECT 'I_GRP_STATE = '
    || i_grp_state
    || ' / '
    || grp_state_code
  FROM snp_grp_state
 WHERE grp_state_code = 'ODISCM_TEMPORARY'
<OdiScmGenerateSqlStatementDelimiter>
