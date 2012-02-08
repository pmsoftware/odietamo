#!/usr/local/bin/python
#! -*- coding: utf-8 -*-

import mx.ODBC.Manager

import md5 
import os
import sys
import string
import datetime
import shutil

from mikado.common.db import tdlib
import MOI_user_passwords
import ODI_objects_from_repo as odi_lib

'''
interactive playpen
'''


#fingerconn = tdlib.getConn(dsn=MOI_user_passwords.DSNSTRINGS['FINGERPRINT'])
#conn = tdlib.getConn(dsn=MOI_user_passwords.DSNSTRINGS['$DBCONNREF'])
d = MOI_user_passwords.get_dsn_details('$DBCONNREF')
print d

conn = tdlib.getConn(MOI_user_passwords.get_dsn_details('$DBCONNREF'))

d = MOI_user_passwords.get_dsn_details('$DBCONNREF')
print d
conn1 = tdlib.getConn(MOI_user_passwords.get_dsn_details('$DBCONNREF'))

#pkg = odi_lib.snp_package(sys2_conn, 2243101)
pkg = odi_lib.snp_package(conn, 5007)

def write_pkg_html(pkg):
    '''given snp_package class instance, produce it all as HTML '''
    html = "<h4>%s:%s</h4><table>" % (pkg.i_package, "/".join([pkg.PROJECT_NAME, pkg.FOLDER_NAME,pkg.name]))
    for step in pkg.steps:
        html += "<tr><td>%s</td></tr>" % str(step)
        html += "<tr><td>&nbsp;</td> <td>%s</td></tr>" % str(step.container)
    html += "</table>"
    return html

print "pkg == ", pkg
