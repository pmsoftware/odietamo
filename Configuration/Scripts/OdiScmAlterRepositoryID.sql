SELECT 'ALTER TABLE ' || table_name || ' DISABLE CONSTRAINT ' || constraint_name || ';'
  FROM user_constraints
 WHERE constraint_type = 'R'
   AND status <> 'DISABLED'
; 

UPDATE snp_connect targ
   SET targ.i_connect =
       (
       SELECT /*
              srce.i_connect
            , LENGTH(TO_CHAR(srce.i_connect))
            , LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1
              */
              SUBSTR(TO_CHAR(srce.i_connect), 1, LENGTH(TO_CHAR(srce.i_connect)) - 3) || '<new repository ID>'
                  --AS i_connect_prefix_number
              /*
            , SUBSTR(TO_CHAR(srce.i_connect), LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1)
                  AS i_connect_repo_suffix_number
              */
         FROM snp_connect srce
        WHERE LENGTH(TO_CHAR(srce.i_connect)) > 3
          AND SUBSTR(TO_CHAR(srce.i_connect), LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1) = '<old repository ID>'
          AND srce.i_connect = targ.i_connect
       )
 WHERE targ.i_connect =
       (
       SELECT srce.i_connect
              /*
            , LENGTH(TO_CHAR(srce.i_connect))
            , LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1
            , SUBSTR(TO_CHAR(srce.i_connect), 1, LENGTH(TO_CHAR(srce.i_connect)) - 3) || '<new repository ID>'
                  --AS i_connect_prefix_number
            , SUBSTR(TO_CHAR(srce.i_connect), LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1)
                  AS i_connect_repo_suffix_number
              */
         FROM snp_connect srce
        WHERE LENGTH(TO_CHAR(srce.i_connect)) > 3
          AND SUBSTR(TO_CHAR(srce.i_connect), LENGTH(TO_CHAR(srce.i_connect)) - 3 + 1) = '<old repository ID>'
          AND srce.i_connect = targ.i_connect       
       )       
;

UPDATE snp_mtxt targ
   SET targ.i_txt =
       (
       SELECT /*
              i_txt
              */
              SUBSTR(TO_CHAR(i_txt), 1, LENGTH(TO_CHAR(i_txt)) - 3) || '<new repository ID>'
                  --AS i_txt_prefix_number
              /*
            , SUBSTR(TO_CHAR(i_txt), LENGTH(TO_CHAR(i_txt)) - 3 + 1)
                  AS i_txt_repo_suffix_number
              */
         FROM snp_mtxt srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '<old repository ID>'
          AND srce.i_txt = targ.i_txt
       )
 WHERE targ.i_txt =
       (
       SELECT srce.i_txt
              /*
              SUBSTR(TO_CHAR(i_txt), 1, LENGTH(TO_CHAR(i_txt)) - 3) || '<new repository ID>'
                  --AS i_txt_prefix_number
            , SUBSTR(TO_CHAR(i_txt), LENGTH(TO_CHAR(i_txt)) - 3 + 1)
                  AS i_txt_repo_suffix_number
              */
         FROM snp_mtxt srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '<old repository ID>'
          AND srce.i_txt = targ.i_txt
       )
;

UPDATE snp_mtxt_part targ
   SET targ.i_txt =
       (
       SELECT /*
              srce.i_txt
              */
              SUBSTR(TO_CHAR(srce.i_txt), 1, LENGTH(TO_CHAR(srce.i_txt)) - 3) || '950'
                  --AS i_txt_prefix_number
              /*
            , SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1)
                  AS i_txt_repo_suffix_number
              */
         FROM snp_mtxt_part srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '166'
          AND srce.i_txt = targ.i_txt
       )
 WHERE targ.i_txt =
       (
       SELECT srce.i_txt
              /*
              SUBSTR(TO_CHAR(i_txt), 1, LENGTH(TO_CHAR(i_txt)) - 3) || '950'
                  --AS i_txt_prefix_number
            , SUBSTR(TO_CHAR(i_txt), LENGTH(TO_CHAR(i_txt)) - 3 + 1)
                  AS i_txt_repo_suffix_number
              */
         FROM snp_mtxt_part srce
        WHERE LENGTH(TO_CHAR(srce.i_txt)) > 3
          AND SUBSTR(TO_CHAR(srce.i_txt), LENGTH(TO_CHAR(srce.i_txt)) - 3 + 1) = '166'
          AND srce.i_txt = targ.i_txt
       )
;

UPDATE snp_host targ
   SET targ.i_host =
       (
       SELECT /*
              srce.i_host
              */
              SUBSTR(TO_CHAR(srce.i_host), 1, LENGTH(TO_CHAR(srce.i_host)) - 3) || '<new repository ID>'
                  --AS i_host_prefix_number
              /*
            , SUBSTR(TO_CHAR(i_host), LENGTH(TO_CHAR(i_host)) - 3 + 1)
                  AS i_host_repo_suffix_number
              */
         FROM snp_host srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
 WHERE targ.i_host =
       (
       SELECT srce.i_host
              /*
              SUBSTR(TO_CHAR(srce.i_host), 1, LENGTH(TO_CHAR(srce.i_host)) - 3) || '<new repository ID>'
                  --AS i_host_prefix_number
            , SUBSTR(TO_CHAR(i_host), LENGTH(TO_CHAR(i_host)) - 3 + 1)
                  AS i_host_repo_suffix_number
              */
         FROM snp_host srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
;

UPDATE snp_host_mod targ
   SET i_host =
       (
       SELECT /*
              srce.i_host
              */
              SUBSTR(TO_CHAR(srce.i_host), 1, LENGTH(TO_CHAR(srce.i_host)) - 3) || '<new repository ID>'
                  --AS i_host_prefix_number
              /*
            , SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1)
                  AS i_host_repo_suffix_number
              */
         FROM snp_host_mod srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
 WHERE targ.i_host =
       (
       SELECT srce.i_host
              /*
              SUBSTR(TO_CHAR(srce.i_host), 1, LENGTH(TO_CHAR(srce.i_host)) - 3) || '<new repository ID>'
                  --AS i_host_prefix_number
            , SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1)
                  AS i_host_repo_suffix_number
              */
         FROM snp_host_mod srce
        WHERE LENGTH(TO_CHAR(srce.i_host)) > 3
          AND SUBSTR(TO_CHAR(srce.i_host), LENGTH(TO_CHAR(srce.i_host)) - 3 + 1) = '<old repository ID>'
          AND srce.i_host = targ.i_host
       )
;

UPDATE snp_loc_rep targ
   SET targ.rep_short_id =
       (
       SELECT /*
              srce.rep_short_id
              */
              SUBSTR(TO_CHAR(srce.rep_short_id), 1, LENGTH(TO_CHAR(srce.rep_short_id)) - 3) || '<new repository ID>'
                  --AS rep_short_id_prefix_number
              /*
            , SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1)
                  AS rep_short_id_repo_suffix_numbr
              */
         FROM snp_loc_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
 WHERE targ.rep_short_id =
       (
       SELECT srce.rep_short_id
              /*
              SUBSTR(TO_CHAR(srce.rep_short_id), 1, LENGTH(TO_CHAR(srce.rep_short_id)) - 3) || '<new repository ID>'
                  --AS rep_short_id_prefix_number
            , SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1)
                  AS rep_short_id_repo_suffix_numbr
              */
         FROM snp_loc_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
;

UPDATE snp_loc_repw targ
   SET targ.rep_short_id =
       (
       SELECT /*
              srce.rep_short_id
              */
              SUBSTR(TO_CHAR(srce.rep_short_id), 1, LENGTH(TO_CHAR(srce.rep_short_id)) - 3) || '<new repository ID>'
                  --AS rep_short_id_prefix_number
              /*
            , SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1)
                  AS rep_short_id_repo_suffix_numbr
              */
         FROM snp_loc_repw srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
 WHERE targ.rep_short_id =
       (
       SELECT srce.rep_short_id
              /*
              SUBSTR(TO_CHAR(srce.rep_short_id), 1, LENGTH(TO_CHAR(srce.rep_short_id)) - 3) || '<new repository ID>'
                  --AS rep_short_id_prefix_number
            , SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1)
                  AS rep_short_id_repo_suffix_numbr
              */
         FROM snp_loc_repw srce
        WHERE SUBSTR(TO_CHAR(srce.rep_short_id), LENGTH(TO_CHAR(srce.rep_short_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_short_id = targ.rep_short_id
       )
;

UPDATE snp_rem_rep targ
   SET targ.rep_id =
       (
       SELECT /*
              srce.rep_id
              */
              SUBSTR(TO_CHAR(srce.rep_id), 1, LENGTH(TO_CHAR(srce.rep_id)) - 3) || '<new repository ID>'
                  --AS rep_id_prefix_number
              /*
            , SUBSTR(TO_CHAR(srce.rep_id), LENGTH(TO_CHAR(srce.rep_id)) - 3 + 1)
                  AS rep_id_repo_suffix_numbr
              */
         FROM snp_rem_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_id), LENGTH(TO_CHAR(srce.rep_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_id = targ.rep_id
       )
 WHERE targ.rep_id =
       (
       SELECT srce.rep_id
              /*
              SUBSTR(TO_CHAR(srce.rep_id), 1, LENGTH(TO_CHAR(srce.rep_id)) - 3) || '<new repository ID>'
                  --AS rep_id_prefix_number
            , SUBSTR(TO_CHAR(srce.rep_id), LENGTH(TO_CHAR(srce.rep_id)) - 3 + 1)
                  AS rep_id_repo_suffix_numbr
              */
         FROM snp_rem_rep srce
        WHERE SUBSTR(TO_CHAR(srce.rep_id), LENGTH(TO_CHAR(srce.rep_id)) - 3 + 1) = '<old repository ID>'
          AND srce.rep_id = targ.rep_id
       )
;

SELECT 'ALTER TABLE ' || table_name || ' ENABLE CONSTRAINT ' || constraint_name || ';'
  FROM user_constraints
 WHERE constraint_type = 'R'
   AND status = 'DISABLED'
;