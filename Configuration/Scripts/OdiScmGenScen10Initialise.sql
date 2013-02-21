INSERT
  INTO odisvn_controls
       (
       odi_user_name
     , import_start_datetime
       )
SELECT 'SUPERVISOR'
     , SYSDATE
  FROM dual
 WHERE
   NOT
EXISTS (
       SELECT 1
         FROM odisvn_controls
       )
/

UPDATE odisvn_controls
  SET import_start_datetime = SYSDATE
/

COMMIT
/