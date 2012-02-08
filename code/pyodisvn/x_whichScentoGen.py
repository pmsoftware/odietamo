#!/usr/local/bin/python
#! -*- coding: utf-8 -*-

import mx.ODBC.Manager
from mikado.common.db import tdlib
import md5 
import os
import sys
import string
import datetime
import shutil
import MOI_user_passwords
import ODI_objects_from_repo as odi_lib


import x_export_objects
from decompile_config import COMPARISONFLDR


'''

Given a list of scen, what is the originating object, and so what
folder and project does it sit in and so what can I dientify in same
folder - what scenarios can I blow away and what rebuild


Also:

Backing up The WHole $DBCONNREF Database
login to $HOSTNAME



Process
-------

* login to $HOSTNAME


0. get the connection striing for the CLEAN repo (in all_connections.txt)

    "$DBUSER/$DBPASS@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$HOSTNAME)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=$DBSERVICE)))"


1. Delete all scnearios from the CLEAN repo

   $ delete_all_scenarios_quick.sh "$DBUSER/$DBPASS@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$HOSTNAME)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=$DBSERVICE)))"

2. regenerate the markersfor which scento generate

   $ generate_markup_MOIRECONCILLIATION.sh "$DBUSER/$DBPASS@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$HOSTNAME)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=$DBSERVICE)))"
      
2. run this to work out which scenarios we want to re-generate

   

3. paste the output into $HOSTNAME:/apps/tdmoi/code_baselining/gen_$DBCONNREF_scenarios.sh
4. run the above


5. exporting the generated scens
   - x_export_all_scen.py
   -> /tmp/pbrian_allscen/  is the dir where the XML exported scens go
   -> passwords etc are hardcoded
   -> probably does not save time limiting the projects to those affected - runs in a few mins

6. tar up and move to $WELLKNOWNINSURER11X714J,

   $ tar_and_feather.sh

   > pscp brianp@vhcddbop02:/tmp/export_scen.tar.gz ./


7. overwrite the scens in there, and regenerate using run_decompile.bat




SELECT * FROM SNP_SCEN 
WHERE SCEN_NAME = 'CAMPAIGNS'


SELECT I_FOLDER FROM SNP_POP
WHERE I_POP = 3833101

SELECT PROJ.I_PROJECT,
       PROJ.PROJECT_NAME, 
       PROJ.PROJECT_CODE,
       FLDR.I_FOLDER,
       FLDR.FOLDER_NAME 
FROM 
 SNP_FOLDER FLDR
INNER JOIN
 SNP_PROJECT PROJ
ON FLDR.I_PROJECT = PROJ.I_PROJECT
WHERE FLDR.I_FOLDER = 126101


###########
DELETE FROM SNP_SCEN_TXT;
DELETE FROM SNP_SCEN_TASK;
DELETE FROM SNP_SCEN_STEP ;
DELETE FROM SNP_VAR_SCEN ;
DELETE FROM SNP_SCEN ;
###########


--
-- Clear down the previous object markings.
-- This section of code can also be run to clear the markers at the end of the
-- reconcilliation process.
--
DELETE
  FROM snp_obj_state
 WHERE i_state
    IN (
       SELECT i_state
         FROM snp_state2
        WHERE state_code = 'MOI_CODE_RECONCILLIATION'
          AND i_grp_state
           IN (
              SELECT i_grp_state
                FROM snp_grp_state
               WHERE grp_state_code  = 'MOI_CODE_RECONCILLIATION'
              )
       )
;

ANALYZE TABLE snp_obj_state ESTIMATE STATISTICS;

DELETE
  FROM snp_state2
 WHERE i_grp_state
    IN (
       SELECT i_grp_state
         FROM snp_grp_state
        WHERE grp_state_code  = 'MOI_CODE_RECONCILLIATION'
       )
;

ANALYZE TABLE snp_state2 ESTIMATE STATISTICS;

DELETE
  FROM snp_grp_state
 WHERE grp_state_code = 'MOI_CODE_RECONCILLIATION'
;

ANALYZE TABLE snp_grp_state ESTIMATE STATISTICS;


'''




def get_folder_data(table, col, id):

    SQL = '''SELECT I_FOLDER FROM %s WHERE %s = %s ''' % (table, col, id) 
    rs = tdlib.query2obj(conn, SQL)
    for row in rs:
        folderid = row.I_FOLDER
        


    sql = '''SELECT PROJ.I_PROJECT,
       PROJ.PROJECT_NAME, 
       PROJ.PROJECT_CODE,
       FLDR.I_FOLDER,
       FLDR.FOLDER_NAME 
FROM 
 SNP_FOLDER FLDR
INNER JOIN
 SNP_PROJECT PROJ
ON FLDR.I_PROJECT = PROJ.I_PROJECT
WHERE FLDR.I_FOLDER = %s''' % folderid

    rs = tdlib.query2obj(conn, sql)
    for row in rs:
        return row


def deleteallscen(conn):
    '''delete all scen - but not the ODISVN project'''

    SQL_template = '''
                DELETE
                  FROM %s
                 WHERE scen_no
                   NOT
                    IN (
                       SELECT scen_no
                         FROM snp_scen
                        WHERE i_trt
                           IN (
                              SELECT i_trt
                                FROM snp_trt
                               WHERE i_folder
                                  IN (
                                     SELECT i_folder
                                       FROM snp_folder
                                      WHERE i_project
                                         IN (
                                            SELECT i_project
                                              FROM snp_project
                                             WHERE project_name = 'ODI-SVN'
                                               AND project_code = 'OS'
                                            )
                                     )
                              )
                       )
                '''    
    lst_tables_to_delete = [ 'SNP_STEP_REPORT', 'SNP_SCEN_REPORT',
                'snp_scen_txt', 'snp_scen_task',
                'snp_scen_step', 'snp_var_scen',
                'snp_scen']

    for tbl in lst_tables_to_delete:
        sql = SQL_template % tbl
        print "deleteing %s" % tbl
        tdlib.exec_query(conn, sql)
        conn.commit()
        
                


def regenerate_specific_scen():

    SQL_get_objtype_id = '''
    SELECT  SCEN_NAME,
    I_POP, I_TRT, I_PACKAGE
    FROM moi_scen_sources

    where
    SCEN_NAME IN( 

    %s

    )
    ''' % x_export_objects.SCENLIST

    rs = tdlib.query2obj(conn, SQL_get_objtype_id)
    objtype = ''

    scens_list = []
    for row in rs:
        if row.I_POP is not None:
            table = 'SNP_POP'
            rowobj = get_folder_data(table, 'I_POP', row.I_POP)
        elif row.I_TRT is not None:
            table = 'SNP_TRT'
            rowobj = get_folder_data(table, 'I_TRT', row.I_TRT)
        elif row.I_PACKAGE is not None:
            table = 'SNP_PACKAGE'
            rowobj = get_folder_data(table, 'I_PACKAGE', row.I_PACKAGE)
        else:
            print "Err", row.__dict__
            

        scens_list.append(rowobj)# "::", data.I_PROJECT, data.PROJECT_NAME, data.PROJECT_CODE, data.I_FOLDER, data.FOLDER_NAME

    return scens_list

def build_generateScen_cmds(scens_list, marker_name):
    '''I sometimes want to generate one or two scens, sometimes everyone.

    as such I provide the Project and Folder that at least one Scen sits in,
    and run OdiGenerateAllScen over that.

    so pass in a list (set?) of (I_PROJECT, I_FOLDER), (I_PROJECT, I_FOLDER), ....
    Outputs (on windows) a folder full of .bat files, one per command (ODI seems to raise sys.exit() again)

    scens_list seems to be a list of rowobjs from a query.  not sure its great...    
    '''
    ################# 
    cmds = []
    sh_file_hdr_unix = '''cd $HOME/code_baselining/ODI_$DBCONNREF/oracledi/bin\n'''
    sh_file_hdr_win = r'''cd /d C:\ODI\$DBCONNREF_oracledi_10.1.3.4.2\oracledi\bin'''
    #################
    
    cmd_files_path = COMPARISONFLDR


    for rowobj in scens_list: # (i_project, i_folder)
        
        cmd1 = '''\n#  %s\nstartcmd.sh OdiGenerateAllScen -PROJECT=%s -FOLDER=%s -MODE=CREATE -GRPMARKER=MOI_adhoc_baseline -MARKER=MOI_adhoc_baseline -GENERATE_PACK=YES -GENERATE_POP=YES -GENERATE_TRT=YES -GENERATE_VAR=YES'''
        cmdwin = '''\n\nREM %s\n%s\ncall startcmd.bat OdiGenerateAllScen -PROJECT=%s -FOLDER=%s -MODE=CREATE -GRPMARKER=%s -MARKER=%s -GENERATE_PACK=YES -GENERATE_POP=YES -GENERATE_TRT=YES -GENERATE_VAR=YES'''
        cmd1 = cmdwin

        executecmd = cmd1 % (rowobj.PROJECT_CODE + "/" + rowobj.FOLDER_NAME,
                             sh_file_hdr_win,
                             int(rowobj.I_PROJECT), int(rowobj.I_FOLDER),
                             marker_name, marker_name)


        cmds.append(executecmd)



    fo = open(os.path.join(cmd_files_path,
                           "generate_all.bat"), 'w')    
    for cmd in cmds:
        fo.write(str(cmd))
    fo.close()



def regenerate_everything():
    ##note CREATE - assumes all scens deleted

    sql = """SELECT PROJ.I_PROJECT,
       PROJ.PROJECT_NAME, 
       PROJ.PROJECT_CODE,
       FLDR.I_FOLDER,
       FLDR.FOLDER_NAME 
        FROM 
         SNP_FOLDER FLDR
        INNER JOIN
         SNP_PROJECT PROJ
        ON FLDR.I_PROJECT = PROJ.I_PROJECT
        WHERE PROJECT_NAME != 'ODI-SVN'
        AND PROJECT_CODE != 'OS'
        """

    rs = tdlib.query2obj(conn, sql)
    scens_list = [row for row in rs]
    return scens_list

def export_all_scen():
    ''' '''
    conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))

    cmd_codework = '''./startcmd.sh OdiExportAllScen -TODIR=/tmp/pbrian_allscen/ -FROM_PROJECT=%(projectid)s -SECURITY_URL=jdbc:oracle:thin:@$HOSTNAME:1526:$DBSERVICE -SECURITY_USER=$DBUSER -SECURITY_PWD=MCJFJLNLNFHAHBHDHEHJDBGBGFDGGH -WORK_REP_NAME=$DBCONNREF -USER=SUPERVISOR -PASSWORD=fDyXaToFHt4edhdrAIIr -SECURITY_DRIVER=oracle.jdbc.driver.OracleDriver -EXPORT_PACK=yes -EXPORT_POP=yes -EXPORT_TRT=yes -EXPORT_VAR=yes -RECURSIVE_EXPORT=yes'''


    cmd_$WELLKNOWNINSURERdev4 = '''./startcmd.sh OdiExportAllScen -TODIR=/tmp/pbrian_allscen/ -FROM_PROJECT=%(projectid)s  -EXPORT_PACK=yes -EXPORT_POP=yes -EXPORT_TRT=yes -EXPORT_VAR=yes -RECURSIVE_EXPORT=yes -WORK_REP_NAME=$DBCONNREF'''

    cmd_codework_win = '''\nREM %(projname)s\nstartcmd.bat OdiExportAllScen -TODIR=c:\\temp\\allscen -FROM_PROJECT=%(projectid)s -SECURITY_URL=jdbc:oracle:thin:@$HOSTNAME:1526:$DBSERVICE -SECURITY_USER=$DBUSER -SECURITY_PWD=MCJFJLNLNFHAHBHDHEHJDBGBGFDGGH -WORK_REP_NAME=$DBCONNREF -USER=SUPERVISOR -PASSWORD=fDyXaToFHt4edhdrAIIr -SECURITY_DRIVER=oracle.jdbc.driver.OracleDriver -EXPORT_PACK=yes -EXPORT_POP=yes -EXPORT_TRT=yes -EXPORT_VAR=yes -RECURSIVE_EXPORT=yes'''



    cmd_file_path = os.path.join(COMPARISONFLDR, 'exportscen')
    cmd = cmd_codework_win

    sql = """SELECT I_PROJECT, PROJECT_NAME FROM SNP_PROJECT """
    rs = tdlib.query2obj(conn, sql)

    fcmd = open(os.path.join(cmd_file_path,
                               "runall.bat"), 'w')
    for row in rs:
        fo = open(os.path.join(cmd_file_path,
                               row.PROJECT_NAME + ".bat"), 'w')
        fo.write(r'''cd /d C:\odi\$DBCONNREF_oracledi_10.1.3.4.2\oracledi\bin''' + "\n")

        fo.write(cmd % {'projectid': int(row.I_PROJECT),
                     'projname': row.PROJECT_NAME})

        fcmd.write(r'cd /d %s' % cmd_file_path + "\n")
        fcmd.write('call %s' % row.PROJECT_NAME + ".bat\n")
    fcmd.close()



if __name__ == '__main__':

    conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))

    ##scens_list_specific = regenerate_specific_scen()
    scens_list_all = regenerate_everything()

    action = sys.argv[1:][0]
    if action in ("deleteallscen", "outputregenall", "outputexportall"):
        pass
    else:
        print "wrong argument"
        sys.exit()

    if action == "deleteallscen":
        ## delete all scens
        deleteallscen(conn)

    elif action == "outputregenall":
        marker_name = 'MOI_CODE_RECONCILLIATION'
        build_generateScen_cmds(scens_list_all, marker_name)

    elif action == "outputexportall":
        export_all_scen()
        


    #regenerate_everything()
    ## delete all scens
    ##deleteallscen(conn)


    #clear down the folders
    #doall
    ##marker_name = 'MOI_adhoc_baseline'
##    marker_name = 'MOI_CODE_RECONCILLIATION'
    ##build_generateScen_cmds(scens_list_all, marker_name)
    

