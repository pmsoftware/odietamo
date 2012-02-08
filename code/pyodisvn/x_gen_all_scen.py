#steal ing bits from Marks SWQL code - that makes assumption is runningon PLSQL to output cmdlines,

'''
--
-- Generate the scenario generation commands.
--
DECLARE
BEGIN
    FOR c_project IN (
                     SELECT p.i_project
                          , f.i_folder
                       FROM snp_project p
                      INNER
                       JOIN snp_folder f
                         ON p.i_project = f.i_project
                      ORDER
                         BY p.i_project
                          , f.i_folder
                     )
    LOOP
        dbms_output.put_line('startcmd.sh OdiGenerateAllScen -PROJECT=' || c_project.i_project || ' -FOLDER=' || c_project.i_folder
                          || ' -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=MOI_CODE_RECONCILLIATION -GENERATE_PACK=YES '
                          || '-GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=NO');
        dbms_output.put_line('startcmd.sh OdiGenerateAllScen -PROJECT=' || c_project.i_project || ' -FOLDER=' || c_project.i_folder
                          || ' -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=MOI_CODE_RECONCILLIATION -GENERATE_PACK=NO '
                          || '-GENERATE_POP=YES -GENERATE_TRT=NO -GENERATE_VAR=NO');
        dbms_output.put_line('startcmd.sh OdiGenerateAllScen -PROJECT=' || c_project.i_project || ' -FOLDER=' || c_project.i_folder
                          || ' -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=MOI_CODE_RECONCILLIATION -GENERATE_PACK=NO '
                          || '-GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO');
        /***
        dbms_output.put_line('startcmd.sh OdiGenerateAllScen -PROJECT=' || c_project.i_project || '-FOLDER=' || c_project.i_folder
                          || '-MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=MOI_CODE_RECONCILLIATION -GENERATE_PACK=NO '
                          || '-GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=YES'); 
        ***/
    END LOOP;
END;
/
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
import ODI_objects_from_repo_new as odi_lib

conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))

sql = """SELECT p.i_project as i_project
                          , f.i_folder as i_folder
                          , gs.GRP_STATE_NAME
                       FROM snp_project p
                      INNER
                       JOIN snp_folder f
                         ON p.i_project = f.i_project
                      INNER JOIN
                            snp_grp_state gs
                         ON p.i_project = gs.i_project
                      WHERE gs.GRP_STATE_NAME = 'MOI_CODE_RECONCILLIATION'
                      ORDER
                         BY p.i_project
                          , f.i_folder
                          """
rs = tdlib.query2obj(conn, sql)
cmds = []

for row in rs:

       cmd1 = '''startcmd.sh OdiGenerateAllScen -PROJECT=%s -FOLDER=%s -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=MOI_CODE_RECONCILLIATION -GENERATE_PACK=YES -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=NO'''
       cmd2 = '''startcmd.sh OdiGenerateAllScen -PROJECT=%s -FOLDER=%s -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=MOI_CODE_RECONCILLIATION -GENERATE_PACK=NO -GENERATE_POP=YES -GENERATE_TRT=NO -GENERATE_VAR=NO'''
       cmd3 = '''startcmd.sh OdiGenerateAllScen -PROJECT=%s -FOLDER=%s -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=MOI_CODE_RECONCILLIATION -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO'''

       cmds.append(cmd1 % (row.I_PROJECT, row.I_FOLDER))
       cmds.append(cmd2 % (row.I_PROJECT, row.I_FOLDER))
       cmds.append(cmd3 % (row.I_PROJECT, row.I_FOLDER))


for cmd in cmds:
    print cmd
    