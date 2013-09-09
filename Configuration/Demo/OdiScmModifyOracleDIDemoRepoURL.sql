UPDATE snp_connect
   SET java_url = 'jdbc:hsqldb:hsql://localhost:9003'
 WHERE con_name = 'WORKREP'
   AND connect_type = 'R'
/

UPDATE snp_connect
   SET java_url = 'jdbc:hsqldb:hsql://localhost:9003'
 WHERE con_name = 'Security Connection'
   AND connect_type = 'R'
/

UPDATE snp_mtxt
   SET full_txt = 'jdbc:hsqldb:hsql://localhost:9003'
 WHERE i_txt
    in (
       SELECT i_txt_java_url
         FROM snp_connect
        WHERE con_name = 'WORKREP'
          AND connect_type = 'R'
       )
/

UPDATE snp_mtxt
   SET full_txt = 'jdbc:hsqldb:hsql://localhost:9003'
 WHERE i_txt
    in (
       SELECT i_txt_java_url
         FROM snp_connect
        WHERE con_name = 'Security Connection'
          AND connect_type = 'R'
       )
/

COMMIT
/