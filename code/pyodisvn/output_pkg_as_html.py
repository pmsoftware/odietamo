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

'''
interactive playpen
'''


def write_pkg_html(pkg):
    '''given snp_package class instance, produce it all as HTML '''
    html = "<h4>%s:%s</h4><table>" % (pkg.i_package, "/".join([pkg.PROJECT_NAME, pkg.FOLDER_NAME,pkg.name]))
    for step in pkg.steps:
        html += "<tr><td>%s</td></tr>" % str(step)
        html += "<tr><td>&nbsp;</td> <td>%s</td></tr>" % str(step.container)
    html += "</table>"
    return html

def pkg_from_id(i_pkg):
    '''
    '''
    REPO = '$DBCONNREF'
    try:
        i_package = i_pkg
        #fingerconn = tdlib.getConn(dsn=MOI_user_passwords.DSNSTRINGS['FINGERPRINT'])
        sys2_conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details(REPO))
        pkg = odi_lib.snp_package(sys2_conn, i_package)
    except Exception, e:
        return "Must supply valid pkgid as only arg.  I am using repo %s" % REPO
    return "Using Repo:%s %s" % (REPO, write_pkg_html(pkg))    

if __name__ == '__main__':
    pass


