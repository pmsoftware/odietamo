SELECT 'ALTER TABLE ' || table_name || ' DISABLE CONSTRAINT ' || constraint_name || ';'
  FROM user_constraints
 WHERE constraint_type = 'R'
   AND status <> 'DISABLED'
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_connect targ
   SET targ.i_txt_java_url =
       (
       SELECT SUBSTR(TO_CHAR(srce.i_txt_java_url), 1, LENGTH(TO_CHAR(srce.i_txt_java_url)) - 3) || '<new repository ID>'
         FROM snp_connect srce
        WHERE LENGTH(TO_CHAR(srce.i_txt_java_url)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt_java_url), LENGTH(TO_CHAR(srce.i_txt_java_url)) - 3 + 1) = '<old repository ID>'
          AND srce.i_connect = targ.i_connect
       )
 WHERE targ.i_connect =
       (
       SELECT srce.i_connect
         FROM snp_connect srce
        WHERE LENGTH(TO_CHAR(srce.i_txt_java_url)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt_java_url), LENGTH(TO_CHAR(srce.i_txt_java_url)) - 3 + 1) = '<old repository ID>'
          AND srce.i_connect = targ.i_connect       
       )       
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_connect targ
   SET targ.i_connect =
       (
       SELECT SUBSTR(TO_CHAR(srce.i_connect), 1, LENGTH(TO_CHAR(srce.i_connect)) - 3) || '<new repository ID>'
         FROM snp_connect srce
        WHERE LENGTH(TO_CHAR(srce.i_connect)) > 3
          AND SUBSTR(TO_CHAR(srce.i_connect), LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1) = '<old repository ID>'
          AND srce.i_connect = targ.i_connect
       )
 WHERE targ.i_connect =
       (
       SELECT srce.i_connect
         FROM snp_connect srce
        WHERE LENGTH(TO_CHAR(srce.i_connect)) > 3
          AND SUBSTR(TO_CHAR(srce.i_connect), LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1) = '<old repository ID>'
          AND srce.i_connect = targ.i_connect       
       )       
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_mtxt targ
   SET targ.i_txt =
       (
       SELECT SUBSTR(TO_CHAR(i_txt), 1, LENGTH(TO_CHAR(i_txt)) - 3) || '<new repository ID>'
         FROM snp_mtxt srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '<old repository ID>'
          AND srce.i_txt = targ.i_txt
       )
 WHERE targ.i_txt =
       (
       SELECT srce.i_txt
         FROM snp_mtxt srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '<old repository ID>'
          AND srce.i_txt = targ.i_txt
       )
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_mtxt_part targ
   SET targ.i_txt =
       (
       SELECT SUBSTR(TO_CHAR(srce.i_txt), 1, LENGTH(TO_CHAR(srce.i_txt)) - 3) || '<new repository ID>'
         FROM snp_mtxt_part srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '<old repository ID>'
          AND srce.i_txt = targ.i_txt
       )
 WHERE targ.i_txt =
       (
       SELECT srce.i_txt
         FROM snp_mtxt_part srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '<old repository ID>'
          AND srce.i_txt = targ.i_txt
       )
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_host targ
   SET targ.i_host =
       (
       SELECT SUBSTR(TO_CHAR(srce.i_host), 1, LENGTH(TO_CHAR(srce.i_host)) - 3) || '<new repository ID>'
         FROM snp_host srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
 WHERE targ.i_host =
       (
       SELECT srce.i_host
         FROM snp_host srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_host_mod targ
   SET i_host =
       (
       SELECT SUBSTR(TO_CHAR(srce.i_host), 1, LENGTH(TO_CHAR(srce.i_host)) - 3) || '<new repository ID>'
         FROM snp_host_mod srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
 WHERE targ.i_host =
       (
       SELECT srce.i_host
         FROM snp_host_mod srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_loc_rep targ
   SET targ.rep_short_id =
       (
       SELECT SUBSTR(TO_CHAR(srce.rep_short_id), 1, LENGTH(TO_CHAR(srce.rep_short_id)) - 3) || '<new repository ID>'
         FROM snp_loc_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
 WHERE targ.rep_short_id =
       (
       SELECT srce.rep_short_id
         FROM snp_loc_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_loc_repw targ
   SET targ.rep_short_id =
       (
       SELECT SUBSTR(TO_CHAR(srce.rep_short_id), 1, LENGTH(TO_CHAR(srce.rep_short_id)) - 3) || '<new repository ID>'
         FROM snp_loc_repw srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
 WHERE targ.rep_short_id =
       (
       SELECT srce.rep_short_id
         FROM snp_loc_repw srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_rem_rep targ
   SET targ.i_connect =
       (
       SELECT SUBSTR(TO_CHAR(srce.i_connect), 1, LENGTH(TO_CHAR(srce.i_connect)) - 3) || '<new repository ID>'
         FROM snp_rem_rep srce
        WHERE SUBSTR(TO_CHAR(srce.i_connect), LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_id = targ.rep_id
       )
 WHERE targ.rep_id =
       (
       SELECT srce.rep_id
         FROM snp_rem_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_id), LENGTH(TO_CHAR(srce.rep_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_id = targ.rep_id
       )
<OdiScmGenerateSqlStatementDelimiter>

UPDATE snp_rem_rep targ
   SET targ.rep_id =
       (
       SELECT SUBSTR(TO_CHAR(srce.rep_id), 1, LENGTH(TO_CHAR(srce.rep_id)) - 3) || '<new repository ID>'
         FROM snp_rem_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_id), LENGTH(TO_CHAR(srce.rep_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_id = targ.rep_id
       )
 WHERE targ.rep_id =
       (
       SELECT srce.rep_id
         FROM snp_rem_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_id), LENGTH(TO_CHAR(srce.rep_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_id = targ.rep_id
       )
<OdiScmGenerateSqlStatementDelimiter>

COMMIT
<OdiScmGenerateSqlStatementDelimiter>

SELECT 'ALTER TABLE ' || table_name || ' ENABLE CONSTRAINT ' || constraint_name || ';'
  FROM user_constraints
 WHERE constraint_type = 'R'
   AND status = 'DISABLED'
<OdiScmGenerateSqlStatementDelimiter>
