UPDATE odiscm_master_flush_controls
   SET flush_from_datetime = SYSDATE
     , last_updated_by_command_name = 'OdiScmPrimeExportNowMaster.sql'
 WHERE odi_user_name = '<OdiScmUserName>'
<OdiScmGenerateSqlStatementDelimiter>

INSERT
  INTO odiscm_master_flush_controls
       (
       odi_user_name
     , flush_from_datetime
     , flush_to_datetime
     , last_updated_by_command_name
       )
SELECT '<OdiScmUserName>'
     , SYSDATE
     , NULL
     , 'OdiScmPrimeExportNowMaster.sql'
  FROM dual
 WHERE '<OdiScmUserName>'
   NOT
    IN (
       SELECT odi_user_name
         FROM odiscm_master_flush_controls
       )
<OdiScmGenerateSqlStatementDelimiter>

COMMIT
<OdiScmGenerateSqlStatementDelimiter>
