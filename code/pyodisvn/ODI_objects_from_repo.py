#

'''
Overview
=========
I want to extract from Database (and each Scenrio)
the data underlying a scenraio, so i can fingerpinrt compare them all

JUst starting with packages, I should be able to build a complete view

* Package  (MUT001W)
  * Step  (BUILD_ADHI)              | TRT | treatment 
  * Task  (BUILD_ADHI INS_MLCO)
  * Text of Task

A package could also represent a Interface, which is very difficult as
scenrio will hold SQL while dbase will prob not.


-- Scenario named MUT001W and PAckage of same name
-- Thats a good start to fidning scen and packages?

SELECT * FROM "$DBSCHEMA"."SNP_SCEN" where SCEN_NO = 11081
-- mut001W

SELECT * FROM SNP_PACKAGE where 
PACK_NAME LIKE 'MUT001W'
-- I_PACKAGE
-- 2,243,101


-- list the steps in the above pakage

SELECT I_TRT, STEP_NAME FROM SNP_STEP where 
I_PACKAGE = 2243101
-- I_TRT	STEP_NAME
-- 1,128,101	UTL_SCENARIO_SESSION_WRITER
-- 337,101	BUILD_ADHI

-- for a step(TRT) in the pacjkage, get the tasks
SELECT distinct I_TRT, ORD_TRT, SQL_NAME from 
        SNP_LINE_TRT WHERE I_TRT =337101
-- I_TRT	ORD_TRT	SQL_NAME
-- 337,101	120	INS_MLCO
-- 337,101	140	UPD_MLCO_GET_NEXT



-- get a step name
SELECT I_TRT, TRT_NAME from 
        SNP_TRT WHERE I_TRT =337101

-- get the text that belongs to a given task, in order

                                   SELECT I_TRT as stepNo, ORD_TRT as ord_trt, SQL_NAME as TaskName, Def_LSCHEMA_NAME,
                         TXT_ORD, TXT
                              FROM SNP_LINE_TRT LINE 
                               INNER JOIN  SNP_TXT
                                   ON LINE.DEF_I_TXT = SNP_TXT.I_TXT
                                   WHERE LINE.I_TRT  =  337101
                                   AND ORD_TRT = 140 
                                   ORDER BY ORD_TRT, TXT_ORD

-- STEPNO	ORD_TRT	TASKNAME	DEF_LSCHEMA_NAME	TXT_ORD	TXT
-- 337,101	140	UPD_MLCO_GET_NEXT	MOI_B_UKM_DATA	0	UPDATE <%=snpRef.getSchemaName("MOI_B_UKM_DATA",...



                SnpScenStep - [0 UTL_SCENARIO_SESSION_WRITER 11081]
                          Nno, StepName, ScenNo
                          Nno == i_trt

            SnpScenTask - [2 120 1 BUILD_ADHI INS_MLCO 11081]
                           ScenTaskNo OrdTrt Nno TaskName2  TaskName3 ScenNo

                         ScenTaskNo - global id
                         OrdTrt - ordering within the step parent
                         Nno - step parent FK
                         TaskName2 - parent stepName
                         TaskName3 - this task name
                         ScenNo - grandparent fk


Bug3:

Complete the ability to build a package as OO style

IDs from SNP_STEP:
I_TRT, I_POP, I_MOD, I_VAR, I_TXT_ACTION

STEP_TYPE
---------

V     I_VAR
VE    I_VAR 
VD    I_VAR
VS    I_VAR

SE    Scenario Exec
T     TRT
OE   
F    POP

-- TRT: 33008, 2020101 TYPE = T
-- POP: 696010 TYPE = F



SELECT I_STEP, I_VAR, STEP_TYPE FROM SNP_STEP
WHERE STEP_TYPE like 'V%'


SELECT * FROM SNP_VAR
WHERE I_VAR = 82101


SELECT * FROM SNP_TXT
WHERE I_TXT = 67816101

'''
import mx.ODBC.Manager
from mikado.common.db import tdlib
import md5 
import os
import sys
import string
import datetime
import shutil

#use someproper write approach
class txtwriter_step(object):
    def __init__(self, stp):
        self.stp = stp

    def writeout(self, fpath):
        ''' '''
        fo = open(fpath, "a")
        fo.write("*** %s ")


def chksum(txt):
    chksum = CHKSUM_VERSION + "-" + md5.new(txt).hexdigest()
    return chksum


def get_trt_description(i_txt_trt_txt, conn):
    '''SNP_TRT links to the description field via i_txt_trt_txt
    '''
    concat_txt = ''
    SQL2 = """SELECT TXT FROM SNP_TXT WHERE I_TXT = %s
    order by TXT_ORD"""  % i_txt_trt_txt
    rs2 = tdlib.runQuery(conn, SQL2)
    for row2 in rs2:
        concat_txt += row2[0]
    return ''#concat_txt  #testing decompiler



class snp_trt(object):
    ''' '''
    def __init__(self, conn, i_trt):

        try:
            sql = '''SELECT I_TRT, TRT_NAME, LAST_DATE from     
            SNP_TRT WHERE I_TRT = %s'''  % i_trt
            rs = tdlib.runQuery(conn, sql)
            if len(rs) == 0:
                self.stepname = "Unknown"
                return 
        except:
                self.stepname = "Unknown"
                return 
            
            
        self.stepname = rs[0][1]
        self.last_date = rs[0][2]

        self.tasks = []
        SQL = """SELECT DISTINCT ORD_TRT, SQL_NAME from 
        SNP_LINE_TRT WHERE I_TRT = %s order by ORD_TRT""" % i_trt
        rs_of_tasks = tdlib.query2obj(conn, SQL)
        if len(rs_of_tasks) == 0:
            return 
        #defend against step having no steps;..

        self.stepid = i_trt
        self.i_step = i_trt
        self.i_trt = i_trt

        for row in rs_of_tasks:
            # for each ord_trt (or task) in the step,
            # go get its text
            #### QUESTION - is this text per line (ie many text one task)
            sql2 = ''' SELECT 
                              I_TRT as "step_no", 
                              ORD_TRT as "ord_trt",
                              SQL_NAME as "task_name", 
                              DEF_LSCHEMA_NAME,
                              TXT_ORD, 
                              TXT
                              FROM 
                               SNP_LINE_TRT LINE 
                                INNER JOIN  
                               SNP_TXT
                                ON LINE.DEF_I_TXT = SNP_TXT.I_TXT
                                   WHERE LINE.I_TRT  =  %s
                                   AND ORD_TRT = %s 
                                 ORDER BY TXT_ORD''' % (i_trt, row.ORD_TRT)
            rs2 = tdlib.query2obj(conn, sql2)
            thistasktxt = ''
            thistask = ''
            schema_name = ''
            for row2 in rs2:
                thistasktxt += row2.TXT
                thistask = row2.task_name
                schema_name = row2.DEF_LSCHEMA_NAME

            self.tasks.append(snp_task(row.ORD_TRT, thistask, schema_name, thistasktxt))  
    
    def __repr__(self):
        ''' '''
        return '''Trt:%s_%s_%s_tasks <a href="../comparebyname/%s">trt</a>''' % (self.i_trt, self.stepname, len(self.tasks), self.stepname)

class snp_dbase(object):
    '''represents the dbase entries in tbl_fingerprint

    Needs some thought...
    '''
    def __init__(self, conn, id):
        pass
    
class snp_se(object):
    '''This is a sort of call to a command line
     toto will prbably need ordering soon
      '''

    def __init__(self, conn, i_txt_action):

        sql = '''SELECT I_TXT, TXT from 
        SNP_TXT WHERE I_TXT = %s'''  % i_txt_action
        try: 
            rs = tdlib.query2obj(conn, sql)
            for row in rs:
                self.txt = row.TXT

            self.command = self.txt
        except:
            self.command = "Failed"
            self.txt = "failed"
            print "failed on %s" % i_txt_action
            
    def __repr__(self):
        return "SE: %s..." % self.txt


class snp_pop(object):
    '''This is a sort of call to a command line
     toto will prbably need ordering soon
      '''

    def __init__(self, conn, i_pop):

        sql = '''SELECT * from 
        SNP_POP WHERE I_POP = %s'''  % i_pop
        try:
            rs = tdlib.query2obj(conn, sql)

            for row in rs:
                self.__dict__.update(row.__dict__)
            
            if len(rs) == 0:
                self.POP_NAME = "Unknown"

        except:
            print "failed on %s" % i_pop
            self.POP_NAME = "Failed"


    def __repr__(self):
        return '''POP: %s <a href="../comparebyname/%s">pop</a>''' % (self.POP_NAME, self.POP_NAME)

class snp_var(object):
    '''This is a sort of call to a command line
     toto will prbably need ordering soon
      '''

    def __init__(self, conn, i_pop):

        sql = '''SELECT I_TXT, TXT from 
        SNP_TXT WHERE I_TXT = %s'''  % i_pop
        try:
            rs = tdlib.query2obj(conn, sql)
            for row in rs:
                self.txt = row.TXT
                self.command = self.txt
        except:
            print "failed on %s" % i_pop
            self.txt = 'Failed'
            self.command = 'Failed'
            
    def __repr__(self):
        return "SE: %s..." % self.txt[:20]

class snp_step(object):
    ''' merely a container object to hold a "real" snp_obj of type F, or T or etc'''
    def __init__(self, nno, i_step, name, ok_next_step_id):
        self.nno = nno
        self.container = None #a pointer that will get set 
        self.stepid = i_step
        self.name = name
        self.ok_next_step_id = ok_next_step_id
        
    def __repr__(self):
        return '''%s (%s) %s <a href="../comparebyname/%s">step</a>''' % (self.nno, self.stepid, self.name, self.name)

def snp_step_dispatcher(conn, I_STEP, NNO, STEP_NAME, STEP_TYPE,
    I_TRT, I_POP, I_MOD, I_VAR, I_TXT_ACTION, OK_NEXT_STEP):

    '''
    Given n i_step id, (BUILD_ADHI, xxx)
    get all the smaller tasks inside it,
    and store them with the text ordered correctly

    new init
    I_STEP, NNO, STEP_NAME, STEP_TYPE,
    I_TRT, I_POP, I_MOD, I_VAR, I_TXT_ACTION
    
    '''

    thisstep = snp_step(NNO, I_STEP, STEP_NAME, OK_NEXT_STEP)

    if STEP_TYPE == 'SE': #scenario Execution
        #we are an SE - so build and return that object
        if not I_TXT_ACTION: return thisstep 
        thisstep.container = snp_se(conn, I_TXT_ACTION)
    elif STEP_TYPE == 'T': #TRT
        if not I_TRT: return thisstep
        thisstep.container = snp_trt(conn, I_TRT)
    elif STEP_TYPE == 'F': #POP
        if not I_POP: return thisstep
        thisstep.container = snp_pop(conn, I_POP)
    elif STEP_TYPE == 'V': #???
        if not I_VAR: return thisstep
        thisstep.container = snp_var(conn, I_VAR)
    else:
        thisstep
        
    return thisstep
    #No idea what maps to rest of these indicators

class snp_task(object):
    def __init__(self, ord_trt, TaskName, Def_LSCHEMA_NAME, thistasktxt):
        self.taskname = TaskName
        self.txt = thistasktxt
        self.schema_name = Def_LSCHEMA_NAME
        self.ord_trt = ord_trt 

    def __repr__(self):
        return "%s %s %s" % (self.ord_trt, self.taskname, self.txt[:15]+"...")
    
    



class snp_package(object):
    '''
    '''
    def __init__(self, conn, i_package):

     #   SQL4 = """SELECT I_TRT, pk.I_PACKAGE, pk.PACK_NAME, pk.I_TXT_PACK,
       #    stp.I_STEP, stp.STEP_NAME, stp.NNO
      #  FROM SNP_PACKAGE pk INNER JOIN 
      #  SNP_STEP stp ON pk.I_PACKAGE = stp.I_PACKAGE
      #  where pk.I_PACKAGE = %s
      #  order by pk.I_PACKAGE, stp.NNO """ % i_package

        self.steps = []
        self.tasks = []

        SQL4 = """SELECT pkg.I_PACKAGE, SNP_FOLDER.I_FOLDER, SNP_PROJECT.I_PROJECT, 
      pkg.PACK_NAME, SNP_FOLDER.FOLDER_NAME,SNP_PROJECT.PROJECT_NAME,
      pkg.LAST_DATE, pkg.I_TXT_PACK 
 
FROM SNP_PACKAGE pkg
     LEFT OUTER JOIN 
     SNP_FOLDER ON pkg.I_FOLDER = SNP_FOLDER.I_FOLDER
     LEFT OUTER JOIN 
     SNP_PROJECT ON SNP_FOLDER.I_PROJECT = SNP_PROJECT.I_PROJECT
where 
                   pkg.I_PACKAGE = %s""" % i_package 

        ## find out name of package ...
        rs4 = tdlib.query2obj(conn, SQL4)
        assert len(rs4) == 1  #package id should match one and only one
        for row4 in rs4:
            self.package_name = row4.PACK_NAME
            self.name = self.package_name
            self.i_package = row4.I_PACKAGE
            self.last_date = row4.LAST_DATE
            self.__dict__.update(row4.__dict__) #hacky
            
        #pbrian hack - just stop here
#        if len(rs4) == 0:
#            self.package_name = "THis Id %s not found in this connection %s" (i_package, str(conn))
#            
#        return

        #get all lines that make up this package
        SQL3 = """SELECT I_STEP, NNO, STEP_NAME, STEP_TYPE,
                  I_TRT, I_POP, I_MOD, I_VAR, I_TXT_ACTION,
                  OK_NEXT_STEP
                  FROM SNP_STEP where 
                  I_PACKAGE = %s
                  ORDER BY NNO """  % i_package
        rs3 = tdlib.runQuery(conn, SQL3)
        for row3 in rs3:
            try:
                self.steps.append(snp_step_dispatcher(conn, *row3))
            except AssertionError, e:
                print "This step has null id ", I_TRT, STEP_NAME

    def __repr__(self):
        return "%s %s" % (self.i_package, self.package_name)

    

def run(repo_string):

    conn = tdlib.getConn(dsn=repo_string)  

    
    SQL4 = """SELECT pk.I_PACKAGE, pk.PACK_NAME
              FROM SNP_PACKAGE pk

WHERE I_PACKAGE in (2910101, 33008, 2020101, 696010)"""
    
    rs4 = tdlib.runQuery(conn, SQL4)
    pkgs = []
    for row4 in rs4:
        
        i_package, pack_name = row4
        print pack_name, i_package
        pkg = snp_package( conn, i_package )
        #write_pkg(pkg)
        pkgs.append(pkg)
        
    tdlib.close_conn(conn)
    return pkgs

def write_pkg(pkg):

    tgtxml = os.path.join(TGTFOLDER, pkg.package_name+".fromdbase")
    concattxt = ''

    for stp in pkg.steps:
        for tsk in stp.tasks:
            ordtrt = "%.0f" % tsk.ord_trt
            concattxt += "\n*** %s %s/%s ***\n" % (ordtrt, stp.stepname, tsk.taskname)
            concattxt += tsk.txt
            concattxt += "\n*** %s %s/%s ***\n" % (ordtrt, stp.stepname, tsk.taskname)
    open(tgtxml,'w').write(concattxt)


         
if __name__ ==  '__main__':

    
    CHKSUM_VERSION = "ODISVN_V1.0"

    #HOST_LOGIN 


    repos = {
"$DBCONNREF" : "Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIDEV1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIDEV1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIDEV1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODISYS1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODISYS1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODISYS1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIUAT1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIUAT1)));Uid=$DBSCHEMA;Pwd=$DBPASSW_UATZ;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIUAT1)));Uid=$DBUSER;Pwd=$DBPASS;",


"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIUAT1)));Uid=$DBSCHEMA;Pwd=$DBPASSW_UATA;",
"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODISYS1)));Uid=$DBUSER;Pwd=$DBPASS;",
"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIDEV1)));Uid=$DBUSER;Pwd=$DBPASS;",

"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=voidodi2)));Uid=$DBSCHEMA;Pwd=A0ODIWKCODE;",
"$DBCONNREF": "Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=voidodi4)));Uid=$DBUSER;Pwd=$DBPASS;",
}

    test_repos = {
#"$DBCONNREF": "Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=voidodi4)));Uid=$DBUSER;Pwd=$DBPASS;",
"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIUAT1)));Uid=$DBSCHEMA;Pwd=$DBPASSW_UATZ;",
#"$DBCONNREF":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODISYS1)));Uid=$DBUSER;Pwd=$DBPASS;",

}

    TGTFOLDER = r'C:\ODICodeForComparison\direct_compare_results\test_decompile\ODI Scens Prod'
    for repo_name in test_repos:
 
        packages = run(test_repos[repo_name])
