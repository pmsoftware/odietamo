INSERT
  INTO odiscm_master_flush_controls
       (
       odi_user_name
     , flush_from_datetime
     , flush_to_datetime
     , last_updated_by_command_name
       )
VALUES (
       'SUPERVISOR'
     , TO_DATE('0001-01-01', 'YYYY-MM-DD')
     , NULL
     , 'Demo Set Up'
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
VALUES (
       'SUPERVISOR'
     , TO_DATE('0001-01-01', 'YYYY-MM-DD')
     , NULL
     , 'Demo Set Up'
       )
/

COMMIT
/

