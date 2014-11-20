--
-- Correct the 'last used entity ID' tables contents for both the master
-- repository (SNP_ENT_ID) and the work repository (SNP_ID) against the
-- objects in the repository tables.
--
-- We run this fix integrity issues and prevent corruption in the
-- repository before it occurs.
--

--
-- First identify the actual last used IDs present in the repository.
--
TRUNCATE TABLE odiscm_last_actual_ids
/

INSERT
  INTO odiscm_last_actual_ids
       (
       repo_type_ind
     , table_name
     , max_obj_seq
       )
SELECT objs.repo_type_ind
     , objs.table_name
     , objs.max_obj_seq     -- Although the column is called 'next' it appears to be used for 'last'.
  FROM (
       SELECT 'M' AS repo_type_ind
            , table_name
            , source_repo_id
            , MAX(obj_seq)
                  AS max_obj_seq
         FROM (
              SELECT table_name
                   , SUBSTR(TO_CHAR(obj_id),-3)
                         AS source_repo_id
                   , TO_NUMBER(SUBSTR(TO_CHAR(obj_id),1,LENGTH(TO_CHAR(obj_id))-3))
                         AS obj_seq
                FROM (
                     SELECT 'SNP_AGENT'
                                AS table_name
                          , i_agent
                                AS obj_id
                       FROM snp_agent
                      UNION
                     SELECT 'SNP_CONNECT'
                          , i_connect
                       FROM snp_connect
                      WHERE i_connect <> 0
                      UNION
                     SELECT 'SNP_CONTEXT'
                          , i_context
                       FROM snp_context
                      UNION
                     SELECT 'SNP_HOST'
                          , i_host
                       FROM snp_host      
                      UNION
                     SELECT 'SNP_LAGENT'
                          , i_lagent
                       FROM snp_lagent
                      UNION
                     SELECT 'SNP_LSCHEMA'
                          , i_lschema
                       FROM snp_lschema
                      UNION
                     SELECT 'SNP_MTXT'
                          , i_txt
                       FROM snp_mtxt
                      UNION         
                     SELECT 'SNP_PSCHEMA'
                          , i_pschema
                       FROM snp_pschema    
                      UNION         
                     SELECT 'SNP_PWD_POLICY'
                          , i_pwd_policy
                       FROM snp_pwd_policy  
                      UNION         
                     SELECT 'SNP_PWD_RULE'
                          , i_pwd_rule
                       FROM snp_pwd_rule  
                      UNION         
                     SELECT 'SNP_SUB_LANG'
                          , i_sub_lang
                       FROM snp_sub_lang
                      UNION         
                     SELECT 'SNP_USER'
                          , i_wuser
                       FROM snp_user
                     )
              )
        GROUP
           BY table_name
            , source_repo_id
       ) objs
 INNER
  JOIN snp_loc_rep slre
    ON objs.source_repo_id = LPAD(slre.rep_short_id,3,'0')
 UNION
SELECT objs.repo_type_ind
     , objs.table_name
     , objs.max_obj_seq
  FROM (
       SELECT 'W' AS repo_type_ind
            , table_name
            , source_repo_id
            , MAX(obj_seq)
                  AS max_obj_seq
         FROM (
              SELECT table_name
                   , SUBSTR(TO_CHAR(obj_id),-3)
                         AS source_repo_id
                   , TO_NUMBER(SUBSTR(TO_CHAR(obj_id),1,LENGTH(TO_CHAR(obj_id))-3))
                         AS obj_seq
                FROM (
                     SELECT 'SNP_COL'
                                AS table_name
                          , i_col
                                AS obj_id
                       FROM snp_col
                      UNION
                     SELECT 'SNP_EXP_TXT'
                          , i_txt
                       FROM snp_exp_txt
                      UNION
                     SELECT 'SNP_FOLDER'
                          , i_folder
                       FROM snp_folder
                      UNION
                     SELECT 'SNP_GRP_STATE'
                          , i_grp_state
                       FROM snp_grp_state
                      UNION
                     SELECT 'SNP_JOIN'
                          , i_join
                       FROM snp_join
                      UNION
                     SELECT 'SNP_KEY'
                          , i_key
                       FROM snp_key
                      UNION
                     SELECT 'SNP_MODEL'
                          , i_mod
                       FROM snp_model
                      UNION
                     SELECT 'SNP_OBJ_STATE'
                          , i_obj_state
                       FROM snp_obj_state
                      UNION
                     SELECT 'SNP_OBJ_TRACE'
                          , i_obj_trace
                       FROM snp_obj_trace
                      UNION
                     SELECT 'SNP_ORIG_TXT'
                          , i_txt_orig
                       FROM snp_orig_txt
                      UNION
                     SELECT 'SNP_PACKAGE'
                          , i_package
                       FROM snp_package
                      UNION
                     SELECT 'SNP_POP'
                          , i_pop
                       FROM snp_pop
                      UNION
                     SELECT 'SNP_POP_CLAUSE'
                          , i_pop_clause
                       FROM snp_pop_clause
                      UNION
                     SELECT 'SNP_POP_COL'
                          , i_pop_col
                       FROM snp_pop_col
                      UNION
                     SELECT 'SNP_PROJECT'
                          , i_project
                       FROM snp_project
                      UNION
                     SELECT 'SNP_SCEN'
                          , scen_no
                       FROM snp_scen
                      UNION
                     SELECT 'SNP_SESS'
                          , sess_no
                       FROM snp_session
                      UNION
                     SELECT 'SNP_SOURCE_TAB'
                          , i_source_tab
                       FROM snp_source_tab
                      UNION
                     SELECT 'SNP_SRC_SET'
                          , i_src_set
                       FROM snp_src_set
                      UNION
                     SELECT 'SNP_STATE2'
                          , i_state
                       FROM snp_state2
                      UNION
                     SELECT 'SNP_STEP'
                          , i_step
                       FROM snp_step
                      UNION
                     SELECT 'SNP_SUB_MODEL'
                          , i_smod
                       FROM snp_sub_model
                      UNION
                     SELECT 'SNP_TABLE'
                          , i_table
                       FROM snp_table
                      UNION
                     SELECT 'SNP_TRT'
                          , i_trt
                       FROM snp_trt
                      UNION
                     SELECT 'SNP_TXT'
                          , i_txt
                       FROM snp_txt
                      UNION
                     SELECT 'SNP_UE_ORIG'
                          , i_ue_orig
                       FROM snp_ue_orig
                      UNION
                     SELECT 'SNP_USER_EXIT'
                          , i_user_exit
                       FROM snp_user_exit
                      UNION
                     SELECT 'SNP_VAR'
                          , i_var
                       FROM snp_var
                     --
                     -- We won't bother with variable context values.
                     -- In fact I dont' even know if these can be imported
                     -- from other repositories or if these are even in SnpVar
                     -- export files.
                     -- UNION
                     --SELECT 'SNP_VAR_DATA'
                     --     , svda.i_val || LPAD(slrw.rep_short_id,3,'0')
                     --  FROM snp_var_data svda
                     -- CROSS
                     --  JOIN snp_loc_repw slrw
                     --
                     )
              )
        GROUP
           BY table_name
            , source_repo_id
       ) objs
 INNER
  JOIN snp_loc_repw slrw
    ON objs.source_repo_id = LPAD(slrw.rep_short_id,3,'0')
/

ANALYZE TABLE odiscm_last_actual_ids ESTIMATE STATISTICS
/

--
-- Handle any new tables in ODI 11g.
--
DECLARE
    l_count                 PLS_INTEGER := 0;
    l_sql_full              VARCHAR2(20000);
    l_sql                   VARCHAR2(5000) := 'INSERT '
                                           || '  INTO odiscm_last_actual_ids'
                                           || '       ('
                                           || '       repo_type_ind'
                                           || '     , table_name'
                                           || '     , max_obj_seq'
                                           || '       ) '
                                           || 'SELECT ''W'''
                                           || '     , objs.table_name'
                                           || '     , objs.max_obj_seq'
                                           || '  FROM ('
                                           || '       SELECT table_name'
                                           || '            , source_repo_id'
                                           || '            , MAX(obj_seq)'
                                           || '                  AS max_obj_seq'
                                           || '         FROM ('
                                           || '              SELECT table_name'
                                           || '                   , SUBSTR(TO_CHAR(obj_id),-3)'
                                           || '                         AS source_repo_id'
                                           || '                   , TO_NUMBER(SUBSTR(TO_CHAR(obj_id),1,LENGTH(TO_CHAR(obj_id))-3))'
                                           || '                         AS obj_seq'
                                           || '                FROM ('
                                           || '                     SELECT ';
    -- We insert the TABLE_NAME here.
    l_sql2                  VARCHAR2(5000) := '                                AS table_name'
                                           || '                          , ';
    -- We insert the internal ID column name here.
    l_sql3                  VARCHAR2(5000) := '                                AS obj_id'
                                           || '                       FROM snp_txt_header'
                                           || '                     )'
                                           || '              )'
                                           || '        GROUP'
                                           || '           BY table_name'
                                           || '            , source_repo_id'
                                           || '       ) objs'
                                           || ' INNER'
                                           || '  JOIN snp_loc_repw slrw'
                                           || '    ON objs.source_repo_id = LPAD(slrw.rep_short_id,3,''0'')';
BEGIN
    SELECT COUNT(*)
      INTO l_count
      FROM user_tables
     WHERE table_name
        IN (
           'SNP_TXT_HEADER'
           )
    ;
    
    IF l_count > 0
    THEN
        BEGIN
            l_sql_full := l_sql || '''SNP_TXT_HEADER''' || l_sql2 || 'I_TXT' || l_sql3;
            dbms_output.put_line('l_sql_full: ' || l_sql_full);
            EXECUTE IMMEDIATE l_sql_full;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error(-20000, 'Cannot insert data for SNP_TXT_HEADER into table ODISCM_LAST_ACTUAL_IDS');
        END;
    END IF;
END;
/

COMMIT
/

--------------------------------------------------------------------------------
-- Master Repository tables.
--------------------------------------------------------------------------------

--
-- Update incorrect values.
-- 
UPDATE snp_ent_id seid
   SET id_next =
       (
       SELECT olai.max_obj_seq
         FROM odiscm_last_actual_ids olai
        WHERE olai.table_name = seid.id_tbl
          AND olai.repo_type_ind = 'M'
       )
 WHERE id_next <
       (
       SELECT max_obj_seq
         FROM odiscm_last_actual_ids olai
        WHERE olai.table_name = seid.id_tbl
          AND olai.repo_type_ind = 'M'        
       )
/

--
-- Create missing entries.
--
INSERT
  INTO snp_ent_id
       (
       id_seq
     , id_tbl
     , id_next
       )     
SELECT 1
     , table_name
     , max_obj_seq              -- Although the column is called 'next' it appears to be used for 'last'.
  FROM odiscm_last_actual_ids
 WHERE repo_type_ind = 'M'
   AND table_name
   NOT
    IN (
       SELECT id_tbl
         FROM snp_ent_id
       )
/

--------------------------------------------------------------------------------
-- Work Repository tables.
--------------------------------------------------------------------------------

--
-- Update incorrect values.
-- 
UPDATE snp_id snid
   SET id_next =
       (
       SELECT olai.max_obj_seq
         FROM odiscm_last_actual_ids olai
        WHERE olai.table_name = snid.id_tbl
          AND olai.repo_type_ind = 'W'
       )
 WHERE id_next <
       (
       SELECT max_obj_seq
         FROM odiscm_last_actual_ids olai
        WHERE olai.table_name = snid.id_tbl
          AND olai.repo_type_ind = 'W'        
       )
/

--
-- Create missing entries.
--
INSERT
  INTO snp_id
       (
       id_seq
     , id_tbl
     , id_next
       )     
SELECT 1
     , table_name
     , max_obj_seq              -- Although the column is called 'next' it appears to be used for 'last'.
  FROM odiscm_last_actual_ids
 WHERE repo_type_ind = 'W'
   AND table_name
   NOT
    IN (
       SELECT id_tbl
         FROM snp_id
       )
/

COMMIT
/
