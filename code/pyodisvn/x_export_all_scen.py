#
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



cmd_codework = '''./startcmd.sh OdiExportAllScen -TODIR=/tmp/<replaceme2> -FROM_PROJECT=%(projectid)s -SECURITY_URL=jdbc:oracle:thin:@$HOSTNAME:1526:$DBSERVICE -SECURITY_USER=$DBUSER -SECURITY_PWD=MCJFJLNLNFHAHBHDHEHJDBGBGFDGGH -WORK_REP_NAME=$DBCONNREF -USER=SUPERVISOR -PASSWORD=fDyXaToFHt4edhdrAIIr -SECURITY_DRIVER=oracle.jdbc.driver.OracleDriver -EXPORT_PACK=yes -EXPORT_POP=yes -EXPORT_TRT=yes -EXPORT_VAR=yes -RECURSIVE_EXPORT=yes'''
conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))

cmd_$WELLKNOWNINSURERdev4 = '''./startcmd.sh OdiExportAllScen -TODIR=/tmp/pbrian_allscen/ -FROM_PROJECT=%(projectid)s  -EXPORT_PACK=yes -EXPORT_POP=yes -EXPORT_TRT=yes -EXPORT_VAR=yes -RECURSIVE_EXPORT=yes -WORK_REP_NAME=$DBCONNREF'''

cmd_codework_win = '''\nREM %(projname)s\nstartcmd.bat OdiExportAllScen -TODIR=c:\\temp\\allscen -FROM_PROJECT=%(projectid)s -SECURITY_URL=jdbc:oracle:thin:@$HOSTNAME:1526:$DBSERVICE -SECURITY_USER=$DBUSER -SECURITY_PWD=MCJFJLNLNFHAHBHDHEHJDBGBGFDGGH -WORK_REP_NAME=$DBCONNREF -USER=SUPERVISOR -PASSWORD=fDyXaToFHt4edhdrAIIr -SECURITY_DRIVER=oracle.jdbc.driver.OracleDriver -EXPORT_PACK=yes -EXPORT_POP=yes -EXPORT_TRT=yes -EXPORT_VAR=yes -RECURSIVE_EXPORT=yes'''



#cmd = cmd_codework_win
cmd = cmd_codework
#conn = tdlib.getConn(dsn=MOI_user_passwords.DSNSTRINGS['$WELLKNOWNINSURERDEV4'])

sql = """SELECT I_PROJECT, PROJECT_NAME FROM SNP_PROJECT """
rs = tdlib.query2obj(conn, sql)
for row in rs:
    fo = open(os.path.join(r'C:\Documents and Settings\brianp\Desktop\daily\exportscen', 'output.sh'), 'a')
    fo.write(r'''\ncd $HOME/code_baselining/<replaceme>/oracledi/bin''' + "\n")
    fo.write(cmd % {'projectid': int(row.I_PROJECT),
                 'projname': row.PROJECT_NAME})

