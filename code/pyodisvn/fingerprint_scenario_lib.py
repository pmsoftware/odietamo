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
import tempfile
import difflib
from odi_common import PyODIError

__doc__ = '''
:author: pbrian

Go directly to the ODI repo and read off the generated scenario
I am ignoring things like versins, just give me an ID, and I output that ID.
We order steps by NNO

I think I should offer match on SCEN_NAME 

scen_by_id
latest_scen_by_name
scen_by_name_version


### below tests are v v brittle... 


>>> scen_no = 19823111
>>> conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))
>>> txt = extract_scen(conn, scen_no)
>>> print txt[:50]
<BLANKLINE>
*** 142 SS_0/Implement jython methods ***
#
# Thi

>>> txt = latest_scen_by_name('$DBCONNREF', 'BUSINESS_OBJECT_FULFILMENTS')
>>> print txt[:50]
<BLANKLINE>
*** 142 SS_0/Implement jython methods ***
#
# Thi


>>> diff_scenarios('$DBCONNREF', 'BUSINESS_OBJECT_FULFILMENTS', '$DBCONNREF', 'BUSINESS_OBJECT_FULFILMENTS')

'''


#task type - links to ORDTYPE? etc means something important - but what???



def emit_scens_to_print():
    ''' '''
    SQL = '''SELECT s.SCEN_NO, s.SCEN_NAME 
             FROM SNP_SCEN s left outer join moi_scen_sources ms ON s.scen_name = ms.SCEN_NAME
             WHERE s.SCEN_NAME not like 'OSUTL%'
             and s.SCEN_NAME like 'COMPLAINT%' '''

    conn = tdlib.getConn(MOI_user_passwords.get_dsn_details('$DBCONNREF'))
    rs = tdlib.query2obj(conn, SQL)
    return [row for row in rs]


def latest_scen_by_name(repo_name, scen_name):
    ''' return latest version of scenario matching the given name in the given repo.'''
    SQL = '''SELECT * FROM SNP_SCEN
                WHERE SCEN_NAME =  '%s'
                AND ROWNUM = 1
                ORDER BY SCEN_VERSION DESC
          '''   % scen_name 

    conn = tdlib.getConn(MOI_user_passwords.get_dsn_details(repo_name))
    rs = tdlib.query2obj(conn, SQL)
    if len(rs) == 1:
        scen_no = int(rs[0].SCEN_NO)
    elif len(rs) == 0:
        raise PyODIError("No match found for Scenario Name %s in repo %s. But check other repo too. SQL: %s" % (scen_name, repo_name, SQL))
    else:
        raise PyODIError("Too many matches found for Scenario Name %s in repo %s" % (scen_name, repo_name))

    return extract_scen(conn, scen_no)


def extract_scen(conn, scen_no):

    '''This extracts scnearios from th ODI repo.  It alters the output
       slightly to be compatible with output from the xml file based
       decompiler.  I suspect this needs rethinking - offer with or without backwards compatibility.

       only extracts based on id - so otehr helper modules need to find id based on name for example
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
            txt += txtrow.TXT.decode("iso-8859-1")#.replace(" ?>", "%>").replace("<?", "<%")
        txt += "\n*** %s %s/%s ***\n" % (ord_trt, taskrow.TASK_NAME2, taskname3)
    return txt

def diff_scenarios(l_repo_name, l_scen_name, 
                   r_repo_name, r_scen_name):
    lscentxt = latest_scen_by_name(l_repo_name, l_scen_name)
    rscentxt = latest_scen_by_name(r_repo_name, r_scen_name)
     
#    lscentxto = tempfile.NamedTemporaryFile(mode='w',prefix=r'c:\temp\\', delete=False)
#    lscentxto.write(lscentxt.encode("iso-8859-1"))
#    lscentxt_name = lscentxto.name
#    lscentxto.close()

#    rscentxto = tempfile.NamedTemporaryFile(mode='w',prefix=r'c:\temp\\', delete=False)
#    rscentxto.write(rscentxt.encode("iso-8859-1"))
#    rscentxt_name = rscentxto.name
#    rscentxto.close()


    d = difflib.Differ()
#    result = list(d.compare(lscentxt.splitlines(), rscentxt.splitlines()))
    hd = difflib.HtmlDiff(wrapcolumn=80)
    #compare left right, give them names in output 
    output = hd.make_file(lscentxt.splitlines(),
                          rscentxt.splitlines(),
                          fromdesc=l_repo_name + "-" + l_scen_name,
                          todesc=r_repo_name + "-" + r_scen_name)
    return output
    
    output = ''
    for row in  result:
        if row.find("? ")==0:
            #awful hacks here - rethink this rubbish
            output += '''_ODIREPLACELT_font color="red"_ODIREPLACEGT_''' + row + "_ODIREPLACELT_/font_ODIREPLACEGT_\n"
        else:
            output += row + "\n"
    return output

#scen_nos = emit_scens_to_print()
#for scen in scen_nos:
#    write_scen(scen.SCEN_NO, scen.SCEN_NAME)


if __name__ == '__main__':

    import doctest
    doctest.testmod()
