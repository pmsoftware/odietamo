--
-- Validate the 'last used entity ID' tables contents for both the master
-- repository (SNP_ENT_ID) and the work repository (SNP_ID) against the
-- objects in the repository tables.
--
-- We run this to check for integrity issues and prevent corruption in the
-- repository before it occurs.
--

--
-- Master Repository tables.
--
------------------------------This script is now report only - don't cause an error.
------------------------------SELECT TO_DATE('99991231','YYYYMMDD') + 1
------------------------------           AS cause_an_error
------------------------------  FROM (
       SELECT objs.table_name
            , NVL(snid.id_next,0)
            , objs.max_obj_seq
         FROM (
              SELECT table_name
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
         LEFT -- LOJ as we need to ensure that we consider missing entries in SNP_ID (e.g. where a reused repository has not
        OUTER -- has its SNP_ID/SNP_ENT_ID contents correctly preserved.
         JOIN snp_ent_id snid
           ON objs.table_name = snid.id_tbl
        WHERE objs.max_obj_seq > NVL(snid.id_next,0)
------------------------------       ) errs
/

--
-- Work Repository tables.
--
------------------------------This script is now report only - don't cause an error.
------------------------------SELECT TO_DATE('99991231','YYYYMMDD') + 1
------------------------------           AS cause_an_error
------------------------------  FROM (
       SELECT objs.table_name
            , NVL(snid.id_next,0)
            , objs.max_obj_seq
         FROM (
              SELECT table_name
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
-----------------------------UNION
---------------------------- For some reason the last session ID doesn't seem to get tracked in SNP_ID so we don't validate this.
---------------------------- Presumably, ODI just takes the highest value from SNP_SESSION and adds 1 for the next ID.
----------------------------SELECT 'SNP_SESS'
---------------------------------, sess_no
------------------------------FROM snp_session
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
         LEFT -- LOJ as we need to ensure that we consider missing entries in SNP_ID (e.g. where a reused repository has not
        OUTER -- has its SNP_ID/SNP_ENT_ID contents correctly preserved.
         JOIN snp_id snid
           ON objs.table_name = snid.id_tbl
        WHERE objs.max_obj_seq > NVL(snid.id_next,0)
------------------------------       )
/