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

from decompile_config import COMPARISONFLDR


'''
:author: pbrian

Go directly to the ODI repo and read off the generated scenario
I am ignoring things like versins, just give me an ID, and I output that ID.

I think I should offer match on SCEN_NAME 

scen_by_id
latest_scen_by_name
scen_by_name_version


>>> conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))
>>> txt = extract_scen(scen_no)
>>> print txt[:20]

'''


#task type - links to ORDTYPE? etc means something important - but what???



def emit_scens_to_print():
    ''' '''
    SQL = '''SELECT s.SCEN_NO, s.SCEN_NAME 
             FROM SNP_SCEN s left outer join moi_scen_sources ms ON s.scen_name = ms.SCEN_NAME
             WHERE s.SCEN_NAME not like 'OSUTL%'
             and s.SCEN_NAME like 'COMPLAINT%' '''

    conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))
    rs = tdlib.query2obj(conn, SQL)
    return [row for row in rs]

def extract_scen(scen_no):

    '''This extracts scnearios from th ODI repo.  It alters the output
       slightly to be compatible with output from the xml file based
       decompiler.  I suspect this needs rethinking - offer with or without backwards compatibility.
    '''

    SQL_task = '''SELECT * FROM SNP_SCEN_TASK 
    WHERE SCEN_NO = %s 
    ORDER BY NNO, SCEN_TASK_NO, TASK_TYPE '''

    SQL_txt = '''SELECT * FROM SNP_SCEN_TXT
    WHERE SCEN_NO = %s
    AND NNO = %s
    AND SCEN_TASK_NO = %s
    ORDER BY SCEN_TASK_NO, ORD_TYPE, TXT_ORD
     '''

    rs_task = tdlib.query2obj(conn, SQL_task % scen_no)
    txt = u''

    for taskrow in rs_task:

        ##### hacks to stay comparable to current decompiler - not really needed.
        ##### these hacks seem to be a result of how XML is generated, so I *could* remove them
        ##### Leave for now

        if taskrow.ORD_TRT == None:
            ord_trt = 'null'
        else:
            ord_trt = int(taskrow.ORD_TRT)
        ###very weird hack to keep *** null Oracle Data Integrator Command/null *** issue in line
        if taskrow.TASK_NAME3 == None:
            taskname3 = 'null'
        else:
            taskname3 = taskrow.TASK_NAME3

        txt += "\n*** %s %s/%s ***\n" % (ord_trt, taskrow.TASK_NAME2, taskname3)
        rs_txt = tdlib.query2obj(conn, SQL_txt % (scen_no, taskrow.NNO, taskrow.SCEN_TASK_NO))
        for txtrow in rs_txt:
            #'replace' probably should be removed. Dangerous - remove at same time from main decompiler. 
            txt += txtrow.TXT.replace(" ?>", "%>").replace("<?", "<%")
        txt += "\n*** %s %s/%s ***\n" % (ord_trt, taskrow.TASK_NAME2, taskname3)
    return txt


write_scen(18608111, "BUSOBJS")


#scen_nos = emit_scens_to_print()
#for scen in scen_nos:
#    write_scen(scen.SCEN_NO, scen.SCEN_NAME)


if __name__ == '__main__':

    import doctest
    doctest.testmod()
