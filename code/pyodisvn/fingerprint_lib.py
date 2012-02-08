#!/usr/local/bin/python
#! -*- coding: utf-8 -*-


'''

:author: pbrian <paul@mikadosoftware.com>





Summary
-------

Lib file for fingerprinting a ODI database.
Supplies series of functions to connect to and fingerprint "objects" represented as database entries in a ODI repo.
Eventually will need to cover the full range of objects in a repo (see SNP_ENTITY)


Supplies doc_test tests as well.
Database is not stubbed out - will run against "clean" repo of $DBCONNREF for now, expect to fix that using static data asap.



Tests
-----

general set up

>>> from mikado.common.db import tdlib
>>> import MOI_user_passwords
>>> import ODI_objects_from_repo as odi_lib
>>> test_conn = tdlib.getConn(MOI_user_passwords.get_dsn_details('$DBCONNREF'))


testing package creation 
------------------------

Create a package as an object - frankly I think I should use these objects as basis for fingerprinting...

>>> pkg = odi_lib.snp_package(test_conn, 2952101)
>>> print pkg.PROJECT_NAME, pkg.FOLDER_NAME, pkg.name
MOI RECONCILATION BUILD PKG_MOI_RECONCILATION


Testing fingerprints
--------------------

### TRT

>>> txt = get_fingerprint_trt(test_conn, 107021)
>>> print txt
Date: 16-09-2011
Author: Rohit Singh
This procedure updates the value of column PREVIOUS_EXTRACT_FROM_TS & EXTRACT_FROM_TS in MOI_LOAD_CONTROL table for table 'CC_SCV_PERSON'.
*** 20.0 UPD_MLCO_SET_EXTRACT_FROM_TS ***
UPDATE <%=snpRef.getSchemaName("MOI_A_UKM_MDM_DATA","D")%>.MOI_LOAD_CONTROL
SET Last_Extract_From_Timestamp = Extract_From_Timestamp ,
Extract_From_Timestamp = Last_Extract_From_Timestamp
WHERE table_name = 'CC_SCV_PERSON';
<BLANKLINE>
<BLANKLINE>
<BLANKLINE>


>>> print chksum(txt)
ODISVN_V1.1-203e47a1eaeb51bb106bcda43ab718f8


>>> txt = get_fingerprint_trt(test_conn, 10010)
>>> #print txt

>>> print chksum(get_datastore(test_conn, 2484101))
ODISVN_V1.1-6ba66c73fd973e15d1e12e8fd2b642bb

>>> print chksum(get_interface_signature(test_conn, 3439101))


Notes
=====


SELECT Name FROM SNP_ENTITY
---------------------------
SNP_VAR_DATA
SNP_VAR_SCEN
SNP_UFUNC
SNP_UFUNC_IMPL
SNP_VAR_PLAN_AGENT
SNP_HOST
SNP_CONNECT
SNP_JOIN_COL
SNP_LANG_ELT
SNP_PLAN_AGENT
SNP_SEQ_SCEN
SNP_SOURCE_TAB
SNP_STEP_REPORT
SNP_USER_EXIT
SNP_VAR_SESS
SNP_SOLUTION
SNP_SOL_ELT
SNP_UFUNC_TECHNO
SNP_AGENT
SNP_ALLOC_AGENT
SNP_COL
SNP_COND
SNP_CONTEXT
SNP_CONV_DT
SNP_DT
SNP_FOLDER
SNP_JOIN
SNP_KEY
SNP_KEY_COL
SNP_LAGENT
SNP_LANG
SNP_LINE_TRT
SNP_LINE_TRT_UE
SNP_LSCHEMA
SNP_MODEL
SNP_ORIG_TXT
SNP_PACKAGE
SNP_POP
SNP_POP_CLAUSE
SNP_POP_COL
SNP_POP_CONSTRAINT
SNP_PROJECT
SNP_PSCHEMA
SNP_PSCHEMA_CONT
SNP_SCEN
SNP_SCEN_REPORT
SNP_SCEN_STEP
SNP_SCEN_TASK
SNP_SEQUENCE
SNP_SEQ_DATA
SNP_ACTION
SNP_DIAGRAM
SNP_GRP_ACTION
SNP_GRP_STATE
SNP_LANG_TECHNO
SNP_LINE_ACTION
SNP_METHOD
SNP_MOD_FOLDER
SNP_OBJECT
SNP_PROFILE
SNP_REM_REP
SNP_SESS_FOLDER
SNP_STATE2
SNP_SUB_LANG
SNP_SCEN_FOLDER
SNP_SEQ_SESS
SNP_SESSION
SNP_SESS_TASK_LOG
SNP_SRC_SET
SNP_STEP
SNP_STEP_LOG
SNP_SUB_MODEL
SNP_TABLE
SNP_TECHNO




SELECT BATCH_START_TIME, ROWNUM FROM 
(
SELECT BATCH_START_TIME, COUNT(*)
FROM TBL_FINGERPRINT
GROUP BY BATCH_START_TIME

ORDER BY BATCH_START_TIME DESC
)
WHERE ROWNUM < 10


SELECT COUNT(*) FROM TBL_FINGERPRINT WHERE
BATCH_START_TIME IN(
'2011-11-22T07:36:44.675000',
'2011-11-22T03:05:12.977000',
'2011-11-21T14:55:16.775000',
'2011-11-20T06:50:41.653000'
)

Extract from dbase underlying each repo:

Package details as a string and md5 hash them
the details of each treatment
details of each interface





TODO
* Add Package Description to the concat hash
SELECT * FROM SNP_PACKAGE where 
PACK_NAME LIKE 'MUT002W'

SELECT  * FROM SNP_TXT
where I_TXT = 109214101


* Handle encoding issues
* some unit tests
* Getting interfaces printed out
* using a diff tool effectively across the various environments
* Given a specfic ODI object, show an HTML report that gives
  - hashes in each environment
  - diffs
  - links to the output them selves
  - timings

That will do for now.


CREATE TABLE tbl_fingerprint
(
repo VARCHAR2(32),
objecttype VARCHAR2(32),
snp_id INT,
snp_name VARCHAR2(64),
chksum VARCHAR2(128),
insert_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
batch_start_time VARCHAR(64)
)

'''


import mx.ODBC.Manager
from mikado.common.db import tdlib
import md5 
import os
import sys
import string
import datetime
import shutil

import MOI_user_passwords


##############CONSTANTS
CHKSUM_VERSION = "ODISVN_V1.1"
odi_version_number="10.1.3.4.2"
##############



def fingerprint_engine_status():
    '''     What are the main we are doing ok status checks to run?'''
    SQL = '''SELECT DISTINCT BATCH_START_TIME
            FROM TBL_FINGERPRINT '''
    fingerconn = tdlib.getConn(MOI_user_passwords.get_dsn_details('FINGERPRINT'))

    
    s = ''
    s += tdlib.query_as_html_table(fingerconn, SQL)

    SQL = '''SELECT count(*) as "ct", BATCH_START_TIME, REPO FROM TBL_FINGERPRINT
            WHERE BATCH_START_TIME = (SELECT MAX(CURR_BATCH_START_TIME)
                                       FROM tbl_fingerprint_current_batch)
             GROUP BY BATCH_START_TIME, REPO 
             ORDER BY REPO'''
    s += tdlib.query_as_html_table(fingerconn, SQL)
    return s
    
def consistent_dict_printer(dict):
    '''always output the contents of a dict in the same way '''
    txt = ''
    cols = 3
    for k in sorted(dict.keys()):
        txt += "%s::%s\n" % (k, dict[k])
    return txt
    

def chksum(txt):
    '''Given txt return the md5 hash as hexdigest, with flag indiciating the version number '''
    chksum = CHKSUM_VERSION + "-" + md5.new(txt).hexdigest()
    return chksum


def safe_file_name(s, i_trt):
    '''
    '''
    ok = string.ascii_letters + string.digits + "_" + "-"
    new_str = ''
    for char in s:
        if char not in ok:
            new_str += "_"
        else:
            new_str += char
    return str(i_trt) + "_" + new_str



def write_to_db(connwrite, msg, context):
    '''dumb write to dbase just to get soemthing workign '''

    repo, snptype, I_TRT, TRT_NAME, chksum, concat_txt = msg
    SQL = '''INSERT INTO tbl_fingerprint (batch_start_time, repo, objecttype, snp_id, snp_name, chksum)
             VALUES ('%s', '%s', '%s', %s, '%s', '%s')''' % (context['BATCH_START_TIME'], os.path.basename(repo), 
                                                             snptype, I_TRT, TRT_NAME, chksum)
    #TODO do that online register graphile  thing here
    tdlib.exec_query(connwrite, SQL)
    #TODO ignore return value - wjat ifg I fail?
    #TODO where is logging?
    #TODO evrything is serial here , get some hand offs !

  


def write_txt(repo, snptype, I_TRT, TRT_NAME, chksum, concat_txt, connwrite=None, context=None):
    ''' '''
    
    d = datetime.datetime.today().isoformat()
 
    write_to_db(connwrite, [repo, snptype, I_TRT, TRT_NAME, chksum, concat_txt], context)

    
    fo = open(os.path.join(repo.replace(os.path.basename(repo), ""), "%s.hashes" % os.path.basename(repo)), "a")
    fo.write("%s::%s::%s::%s::%s\n" % (snptype, I_TRT, TRT_NAME, chksum, d))
    fo.close()

    f1o = open(os.path.join(repo, "%s.log" %  safe_file_name(TRT_NAME, I_TRT))
                           , "w")
    f1o.write("%s::%s::%s::%s::%s\n\n%s" % (snptype, I_TRT,  TRT_NAME, chksum, d, concat_txt))
    f1o.close()


def get_datastore(conn, i_table):
    '''A datastore is a database table or a file, with columns
    '''
    SQL_table = '''
                SELECT I_TABLE, I_MOD, I_SUB_MODEL, 
                RES_NAME, TABLE_NAME, TABLE_ALIAS,
                TABLE_TYPE, WS_NAME, FILE_FORMAT
                FROM SNP_TABLE where
                I_TABLE = %s
                 ''' % i_table
    rs = tdlib.query2obj(conn, SQL_table)
    table_txt = '***\n'
    for row in rs:
        table_txt += """%(I_TABLE)s - %(I_MOD)s - %(I_SUB_MODEL)s 
%(RES_NAME)s -%(TABLE_NAME)s - %(TABLE_ALIAS)s - %(TABLE_TYPE)s 
%(WS_NAME)s - %(FILE_FORMAT)s"""  % row.__dict__
        
    SQL_col = '''
              SELECT I_COL, I_TABLE, COL_NAME, COL_HEADING, COL_DESC, SOURCE_DT,
              LONGC, SCALEC, COL_FORMAT, FILE_POS, BYTES
              FROM SNP_COL WHERE I_TABLE = %s 
              ORDER BY I_TABLE, POS
              ''' % i_table
    cols_txt = '===\n'
    rs = tdlib.query2obj(conn, SQL_col)
    for row in rs:
        cols_txt += """%(COL_NAME)s:: %(I_COL)s -  %(I_TABLE)s -  %(COL_HEADING)s -  %(COL_DESC)s -  
                       %(SOURCE_DT)s -  %(LONGC)s -  %(SCALEC)s - 
                       %(COL_FORMAT)s -  %(FILE_POS)s -  %(BYTES)s """ % row.__dict__
    table_txt += cols_txt       


    queries = ['''SELECT j.i_table_fk
     , j.i_join
     , j.fk_name
     , j.fk_type
     , j.i_table_pk
     , j.pk_i_mod
     , j.pk_catalog
     , j.pk_schema
     , j.pk_table_name
     , j.pk_table_alias
     , j.i_txt_complex
     , j.i_txt_complex
     , j.check_stat
     , j.check_flow
     , j.ind_active
     , jc.i_col_fk 
     , jc.i_join
     , jc.pos
     , jc.i_col_pk
     , jc.pk_col_name
     FROM snp_join j
      LEFT OUTER JOIN snp_join_col jc 
                     ON j.i_join = jc.i_join

     WHERE j.i_table_fk = %s
     ORDER BY j.i_join, jc.i_col_fk ''' % i_table

     ,
     '''SELECT k.i_key
     , k.i_table
     , k.key_name
     , k.cons_type
     , k.ind_active
     , k.ind_db
     , k.check_flow
     , k.check_stat

     , kc.i_key
     , kc.i_col
     , kc.pos

     FROM snp_key k LEFT OUTER JOIN snp_key_col kc ON k.i_key = kc.i_key
     WHERE k.i_table = %s
     ORDER BY k.i_key, kc.i_col, kc.pos
     ''' % i_table

     ]

    for query in queries:
        rs = tdlib.query2obj(conn, query)
        txt_from_mark = '\n'
        for row in rs:
            ### really needs improving
            txt_from_mark += "\nKey Data: " + consistent_dict_printer(row.__dict__)        
        table_txt += txt_from_mark


    table_txt += "***\n"

    return table_txt


########################## TRT

def get_fingerprint_trt(conn, i_trt):
    ''' given i_trt, return the fingerprint 
    Just howmuch should I move this intot he object module'''
    
    concat_txt = ''

    SQL = """ SELECT I_TRT, TRT_NAME, I_TXT_TRT_TXT
     FROM 
     SNP_TRT WHERE I_TRT = %s """ % i_trt
    rs = tdlib.query2obj(conn, SQL)
    if rs[0].I_TXT_TRT_TXT  is not None:
        concat_txt += get_trt_description(conn, rs[0].I_TXT_TRT_TXT )

    concat_txt += get_trt_code(conn, i_trt)
    return concat_txt


def get_trt_description(conn, i_txt_trt_txt):
    '''SNP_TRT links to the description field via i_txt_trt_txt
    '''
    concat_txt = ''
    SQL2 = """SELECT TXT FROM SNP_TXT WHERE I_TXT = %s
    order by TXT_ORD"""  % i_txt_trt_txt
    rs2 = tdlib.runQuery(conn, SQL2)
    for row2 in rs2:
        concat_txt += row2[0]
    return concat_txt  

def get_trt_code(conn, i_trt):
    '''
    '''
    concat_txt = ''
    
    #get all lines that make up this TRT
    SQL3 = """SELECT I_TRT, ORD_TRT, SQL_NAME, DEF_I_TXT, I_TXT, TXT_ORD, TXT
              FROM SNP_LINE_TRT LINE INNER JOIN  SNP_TXT
                   ON LINE.DEF_I_TXT = SNP_TXT.I_TXT
              WHERE  
               I_TRT =  %s
              ORDER BY ORD_TRT, TXT_ORD"""  % i_trt

    rs3 = tdlib.runQuery(conn, SQL3)
    sql_name = ''
    for row3 in rs3:
        i_trt3, ord_trt3, sql_name3, def_i_txt3, i_txt3, txt_ord3, txt3 = row3
        if sql_name != sql_name3:
            concat_txt += "\n*** " + str(ord_trt3) + " " + sql_name3 + " ***\n" #I_trt and ord_trt is a unique id for the sql of this step.
            sql_name = sql_name3
            
        concat_txt += txt3


    sql = '''SELECT i_trt
            , ue_name
           ,i_user_exit
           , position
           , ue_type
           , ue_sdesc
           , i_txt_ue_help

         FROM snp_user_exit
         WHERE I_TRT = %s 
         ORDER BY i_user_exit, ue_name, position''' % i_trt

    rs = tdlib.query2obj(conn, sql)
    txt_from_mark = '\n'
    for row in rs:
        txt_from_mark += "\nsnp_user_exit: " + consistent_dict_printer(row.__dict__)

    concat_txt += txt_from_mark


    return concat_txt


####################################################

def get_package_steps(i_package, conn):
    '''
    '''
    concat_txt = ''
    SQL4 = """SELECT pk.I_PACKAGE, pk.PACK_NAME, pk.I_TXT_PACK,
       stp.I_STEP, stp.STEP_NAME, stp.NNO, stp.OK_NEXT_STEP
    FROM SNP_PACKAGE pk INNER JOIN 
    SNP_STEP stp ON pk.I_PACKAGE = stp.I_PACKAGE
    where pk.I_PACKAGE = %s
    order by pk.I_PACKAGE, stp.NNO """ % i_package
    rs4 = tdlib.runQuery(conn, SQL4)
    package_name = ''
    PACK_NAME = 'BLANK' #in case I have no rows returned
    
    for row4 in rs4:
        I_PACKAGE, PACK_NAME, I_TXT_PACK,I_STEP, STEP_NAME, NNO, OK_NEXT_STEP = row4
        if package_name != PACK_NAME:
            concat_txt += "\n*** " + PACK_NAME + " ***\n"
            package_name = PACK_NAME
        concat_txt += "%s - %s::%s -> %s\n" % (NNO, I_STEP, STEP_NAME, OK_NEXT_STEP) #NNO added for v1.1 - added OK_NEXT_STEP for v1.2

    concat_txt += "\n*** " + PACK_NAME + " ***"
    return concat_txt


def get_interface_signature(conn, i_pop):
    '''pop = interface
    '''
    concat_txt = ''
    ### The below links all aspects of a interface (POP) 
    ### taken fromm http://odiexperts.com/interface-mapping-query
    SQL4 = """SELECT DISTINCT
SNP_PROJECT.PROJECT_NAME    AS PROJECT_NAME,
SNP_FOLDER.FOLDER_NAME      AS FOLDER_NAME,
SNP_POP.POP_NAME            AS INTERFACE_NAME,
SNP_POP_COL.I_POP_COL,
CASE
WHEN SNP_POP.WSTAGE='E' THEN 'TABLE_TO_TABLE_INF'
ELSE 'TEMP_INTERFACE' END   AS INTERFACE_TYPE,
SNP_POP.LSCHEMA_NAME        AS TARGET_SCHEMA,
SNP_POP.TABLE_NAME          AS TARGET_TABLE,
SNP_POP_COL.COL_NAME        AS TARGET_COLUMN,
CASE
WHEN SNP_POP.WSTAGE='E' THEN T_COL.SOURCE_DT||' ('||T_COL.LONGC||')'
ELSE SNP_POP_COL.SOURCE_DT||' ('||SNP_POP_COL.LONGC||')'
END AS TRG_DATATYPE,
SNP_SOURCE_TAB.LSCHEMA_NAME AS SOURCE_SCHEMA,
SNP_TABLE.TABLE_NAME        AS SOURCE_TABLE,
SNP_COL.COL_NAME            AS SOURCE_COLUMN ,
SNP_COL.SOURCE_DT||' ('||SNP_COL.LONGC||')' AS SRC_DATATYPE,
SNP_TXT.TXT AS COLUMN_MAPPING
FROM SNP_PROJECT
LEFT OUTER JOIN SNP_FOLDER ON SNP_FOLDER.I_PROJECT=SNP_PROJECT.I_PROJECT
LEFT OUTER JOIN SNP_POP ON SNP_POP.I_FOLDER=SNP_FOLDER.I_FOLDER
LEFT OUTER JOIN SNP_POP_COL ON SNP_POP_COL.I_POP=SNP_POP.I_POP
LEFT OUTER JOIN SNP_POP_CLAUSE ON SNP_POP_CLAUSE.I_POP=SNP_POP.I_POP
LEFT OUTER JOIN SNP_TXT S_TXT ON S_TXT.I_TXT=SNP_POP_CLAUSE.I_TXT_SQL
LEFT OUTER JOIN SNP_TXT ON SNP_TXT.I_TXT= SNP_POP_COL.I_TXT_MAP
LEFT OUTER JOIN SNP_SOURCE_TAB ON SNP_SOURCE_TAB.I_POP=SNP_POP.I_POP
LEFT OUTER JOIN SNP_TXT_CROSSR ON SNP_TXT_CROSSR.I_TXT=SNP_TXT.I_TXT
LEFT OUTER JOIN SNP_COL ON SNP_COL.I_COL=SNP_TXT_CROSSR.I_COL
LEFT OUTER JOIN SNP_TABLE ON SNP_TABLE.I_TABLE= SNP_COL.I_TABLE
LEFT OUTER JOIN SNP_COL T_COL ON T_COL.I_COL=SNP_POP_COL.I_COL
WHERE
-- SNP_PROJECT.PROJECT_NAME='POINT-MOI'
-- and 
SNP_POP.I_POP = %s
ORDER BY SNP_POP.POP_NAME, SNP_POP_COL.I_POP_COL

   """ % i_pop
    rs4 = tdlib.runQuery(conn, SQL4)
    curr_pop_name = ''
    pop_ref = ''
    for row4 in rs4:
        project_name, folder_name, interface_name, i_pop_col, \
        interface_type, target_schema, target_table, target_column, \
        trg_datatype, source_schema, source_table, source_column,\
        src_datatype, column_mapping = row4

        #Thereference name for a interface - once per interface
        pop_ref = "%s/%s/%s/%s" % (project_name, folder_name, 
                                   interface_name, interface_type)

        if curr_pop_name != pop_ref:
            concat_txt += "\n*** " + pop_ref + " ***\n"
            curr_pop_name = pop_ref

        #the mapping of this tgt col from these src col(s)
        map_def = "%s.%s.%s (%s) <- %s.%s.%s (%s) [%s]\n\n" % (
                          target_schema, target_table, 
                          target_column, trg_datatype,
                          source_schema, source_table,
                          source_column, src_datatype,
                          str(column_mapping) 
                          )
        concat_txt += map_def


    ########### Now get the various settings for the interface

    SQL_KM = '''SELECT p.I_POP, p.POP_NAME,  
                p.I_TABLE, p.LSCHEMA_NAME, 
      p.I_TRT_KIM, p.I_TRT_KLM, p.I_TRT_KCM, 
      p.I_FOLDER, p.opt_ctx_code, p.key_name, 
      p.distinct_rows, p.table_name,
      ti.TRT_NAME as KIM_NAME, ti.TRT_TYPE as KIM_TYPE,
      tc.TRT_NAME as KCM_NAME, tc.TRT_TYPE as KCM_TYPE

      FROM SNP_POP p

      LEFT outer join snp_trt ti on p.i_trt_kim = ti.i_trt
      LEFT outer join snp_trt tc on p.i_trt_kcm = tc.i_trt
      WHERE I_POP = %s ''' % i_pop

    pretxt = ''

    # in order to get the KLM names we need --select * from snp_src_set
    rs = tdlib.query2obj(conn, SQL_KM)
    for row in rs:
        #should beonly one row           
        pretxt = """Settings:: (%(I_POP)s-%(POP_NAME)s)
Datastore: %(I_TABLE)s
Logical Schema: %(LSCHEMA_NAME)s
KIM: %(I_TRT_KIM)s %(KIM_NAME)s %(KIM_TYPE)s
KIM: %(I_TRT_KCM)s %(KCM_NAME)s %(KCM_TYPE)s
Folder: %(I_FOLDER)s
OPT_CTX_CODE: %(OPT_CTX_CODE)s
Tgt Table KeyName: %(TABLE_NAME)s 
Distinct rows:%(DISTINCT_ROWS)s           
""" % row.__dict__

    concat_txt += pretxt

    ###very very hacky - just grabbing the data and stuffing into a string
    sql_from_mark = '''SELECT i_pop
            , i_pop_col
            , col_name
            , i_col
            , i_src_set
            , i_source_tab
            , exe_db
            , ind_enable
            , i_txt_map
            , i_txt_map_txt
            , ind_ins
            , ind_upd
            , ind_key_upd
            , ind_ud1
            , ind_ud2
            , ind_ud3
            , ind_ud4
            , ind_ud5
            , check_not_null
         FROM snp_pop_col 
         WHERE i_pop = %s 
         ORDER BY i_pop_col, i_src_set''' % i_pop

    rs = tdlib.query2obj(conn, sql_from_mark)
    txt_from_mark = '\n'
    for row in rs:
        txt_from_mark += "\nsnp_pop_col: " + consistent_dict_printer(row.__dict__)

    concat_txt += txt_from_mark

    ### JOIN OCNidtions - interfaces specifty the joins and filters
    sql_join_conditions = '''SELECT pc.i_pop
     , pc.i_pop_clause
     , pc.i_txt_sql
     , t.txt
     , pc.clause_type
     , pc.ind_enable
     , NVL(pc.ord_clause, -1)
           AS ord_clause
     , pc.exe_db
     , pc.i_table1
     , pc.ind_outer1
     , NVL(pc.i_table2,-1)
           AS i_table2
     , NVL(pc.i_src_set,-1) as srcset
     , pc.join_type
  FROM snp_pop_clause pc
 INNER
  JOIN snp_txt t
    ON pc.i_txt_sql = t.i_txt
 WHERE pc.I_POP = %s 
ORDER BY pc.i_pop_clause
     , pc.i_txt_sql''' % i_pop

    rs = tdlib.query2obj(conn, sql_join_conditions )
    txt_from_mark = '\n'
    for row in rs:
        txt_from_mark += "\njoin conditions: " + consistent_dict_printer(row.__dict__)

    concat_txt += txt_from_mark


    sql_KM_option_values_used = '''SELECT p.i_pop
     , ue.i_trt
     , ueu.i_user_exit
     , ueu.short_value
     , t.txt
  FROM snp_ue_used ueu
 INNER
  JOIN snp_user_exit ue
    ON ueu.i_user_exit = ue.i_user_exit
 INNER
  JOIN snp_trt t
    ON ue.i_trt = t.i_trt
 INNER
  JOIN snp_pop p
    ON ueu.i_instance = p.i_pop
  LEFT
 OUTER
  JOIN snp_txt t
    ON ueu.i_txt_value = t.i_txt
 WHERE ueu.i_ue_orig IN
       (
       SELECT i_ue_orig
         FROM snp_ue_orig
        WHERE orig_name IN ('Interface', 'Source set') 
       )
 AND p.i_pop = %s
 ORDER
    BY ue.i_trt
     , ueu.i_user_exit ''' % i_pop


    rs = tdlib.query2obj(conn, sql_KM_option_values_used)
    txt_from_mark = '\n'
    for row in rs:
        txt_from_mark += "\nKM Option Values Used: " + consistent_dict_printer(row.__dict__)

    concat_txt += txt_from_mark


    concat_txt += "\n*** " + pop_ref + " ***"    
    return concat_txt
    

def run(repo_name, connwrite, context):
    '''context - context dict holds:
       'BATCH_START_TIME - could hold other things too. '''

    repo_path = r"C:\ODICodeForComparison\direct_compare_results\%s" % repo_name
    repo_root = r"C:\ODICodeForComparison\direct_compare_results"

    if not os.path.isdir(repo_path):
        os.mkdir(repo_path)

    conn = tdlib.getConn(MOI_user_passwords.get_dsn_details(repo_name))

    ####### trt (procedures or KMs)
    
    all_trt_in_repo_SQL = """
     SELECT I_TRT, TRT_NAME, I_TXT_TRT_TXT
     FROM 
     SNP_TRT """    
    
    rs = tdlib.query2obj(conn, all_trt_in_repo_SQL)

    for row in rs:
        concat_txt = get_fingerprint_trt(conn, row.I_TRT)
        write_txt(repo_path, "trt", row.I_TRT, row.TRT_NAME, chksum(concat_txt), concat_txt, connwrite, context)


###### Packages
    SQL4 = """SELECT pk.I_PACKAGE, pk.PACK_NAME
              FROM SNP_PACKAGE pk"""
    rs4 = tdlib.runQuery(conn, SQL4)
    print
    print "Packages",
    for row4 in rs4:
        
        i_package, pack_name = row4
        concat_txt = ''
        print ".",
        concat_txt += get_package_steps(i_package, conn)
        write_txt(repo_path, "pkg", i_package, pack_name, chksum(concat_txt), concat_txt, connwrite, context)  

##### Interfaces
    SQL5 = """SELECT pop.I_POP, pop.POP_NAME
              FROM SNP_POP pop"""
    rs5 = tdlib.runQuery(conn, SQL5)
    print
    print "Interfaces",
    for row5 in rs5:
        i_pop, pop_name = row5
        concat_txt = ''
        print ".",
        concat_txt += get_interface_signature(conn, i_pop)
        write_txt(repo_path, "pop", i_pop, pop_name, chksum(concat_txt), concat_txt, connwrite, context)  

    #### datastores
    SQL_tables = '''SELECT I_TABLE, TABLE_NAME from SNP_TABLE '''
    rs_tables = tdlib.query2obj(conn, SQL_tables)
    for row in rs_tables:
        concat_txt = ''
        print ".",
        concat_txt += get_datastore(conn, row.I_TABLE)
        write_txt(repo_path, "datastore", row.I_TABLE, row.TABLE_NAME, chksum(concat_txt), concat_txt, connwrite, context)



    tdlib.close_conn(conn)
    
         
#if __name__ ==  '__main__':

    #1.0 - original version
    #1.1 - added I_STEP id to a step in a package - same name of a step can have diff internal ids - occurs a lot if using name of a step to be uniquer across folders
    #added datastores
    #TODO: add pkg linked lists - pkgs steps (usually) have OK_NEXT_STEP ids
    #Interface JOIN conditions.
    


if __name__ == "__main__":
    import doctest
    doctest.testmod()


    #HOST_LOGIN 

