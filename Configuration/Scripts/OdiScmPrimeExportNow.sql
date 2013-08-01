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
     , 'Demo Set Up'
  FROM dual
 WHERE '<OdiScmUserName>'
   NOT
    IN (
       SELECT odi_user_name
         FROM odiscm_master_flush_controls
       )
/

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
     , 'Demo Set Up'
  FROM dual
 WHERE '<OdiScmUserName>'
   NOT
    IN (
       SELECT odi_user_name
         FROM odiscm_work_flush_controls
       )
/

COMMIT
/

