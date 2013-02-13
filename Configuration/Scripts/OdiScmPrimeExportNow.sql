INSERT
  INTO odisvn_master_flush_controls
       (
       odi_user_name
     , flush_from_datetime
     , flush_to_datetime
     , last_updated_by_command_name
       )
VALUES (
       'SUPERVISOR'
     , SYSDATE
     , NULL
     , 'Demo Set Up'
       )
/

INSERT
  INTO odisvn_work_flush_controls
       (
       odi_user_name
     , flush_from_datetime
     , flush_to_datetime
     , last_updated_by_command_name
       )
VALUES (
       'SUPERVISOR'
     , SYSDATE
     , NULL
     , 'Demo Set Up'
       )
/

COMMIT
/

