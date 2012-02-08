#


import fingerprint_lib

import mx.ODBC.Manager
from mikado.common.db import tdlib
import MOI_user_passwords
import md5 
import os
import sys
import string
import datetime
import shutil

import fingerprint_scenario_lib as slib

def showfingerprint_km(conn, id):
    txt = fingerprint_lib.get_fingerprint_trt(conn, id)
    return txt

if __name__ == '__main__':
    conn = tdlib.getConn(dsn=MOI_user_passwords.DSNSTRINGS['$DBCONNREF'])
    print showfingerprint_km(conn, 793101)

#    conn = tdlib.getConn(dsn=MOI_user_passwords.DSNSTRINGS['$DBCONNREF'])
    slib.latest_scen_by_name('$DBCONNREF', 'MUT001W')
    