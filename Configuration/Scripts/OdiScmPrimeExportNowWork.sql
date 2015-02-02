UPDATE odiscm_work_flush_controls
   SET flush_from_datetime = SYSDATE
     , last_updated_by_command_name = 'OdiScmPrimeExportNowWork.sql'
 WHERE odi_user_name = '<OdiScmUserName>'
<OdiScmGenerateSqlStatementDelimiter>

INSERT
  INTO odiscm_work_flush_controls
       (
       odi_user_name
     , flush_from_datetime
     , flush_to_datetime
     , last_updated_by_command_name
       )
SELECT '<OdiScmUserName>'
     , SYSDATE
     , NULL
     , 'OdiScmPrimeExportNowWork.sql'
  FROM dual
 WHERE '<OdiScmUserName>'
   NOT
    IN (
       SELECT odi_user_name
         FROM odiscm_work_flush_controls
       )
<OdiScmGenerateSqlStatementDelimiter>

COMMIT
<OdiScmGenerateSqlStatementDelimiter>
