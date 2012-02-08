

'''
Create a Repo comparison tool
- Given two repos, find the left outer, right outer and then inner non matches
- Now printthem out


Effective use of FIngerprinting:

1. compare across repositories, to find the mismatched code objects, 
   and report on this.

2. report: print out an obbject, given its ID number, 


-- FInd those that match - therefore have no problems
SELECT distinct SNP_ID FROM 

( SELECT SNP_ID, chksum, BATCH_START_TIME from TBL_FINGERPRINT
  WHERE REPO = '$DBCONNREF' ) LHS

INNER JOIN

( SELECT SNP_ID, chksum,  BATCH_START_TIME from TBL_FINGERPRINT
  WHERE REPO = '$DBCONNREF' ) RHS

ON LHS.SNP_ID = RHS.SNP_ID AND LHS.BATCH_START_TIME = RHS.BATCH_START_TIME



-- FInd non matching
SELECT * FROM 

( SELECT SNP_ID, chksum, BATCH_START_TIME from TBL_FINGERPRINT
  WHERE REPO = '$DBCONNREF' ) LHS

INNER JOIN

( SELECT SNP_ID, chksum,  BATCH_START_TIME from TBL_FINGERPRINT
  WHERE REPO = '$DBCONNREF' ) RHS

ON LHS.BATCH_START_TIME = RHS.BATCH_START_TIME AND LHS.SNP_ID = RHS.SNP_ID

WHERE

LHS.CHKSUM <> RHS.CHKSUM 

AND LHS.BATCH_START_TIME = (SELECT MAX(BATCH_START_TIME) FROM TBL_FINGERPRINT WHERE REPO = '$DBCONNREF')


--- LHS
SELECT * FROM 

( SELECT SNP_ID, chksum, BATCH_START_TIME from TBL_FINGERPRINT
  WHERE REPO = '$DBCONNREF' ) LHS

LEFT OUTER JOIN

( SELECT SNP_ID, chksum,  BATCH_START_TIME from TBL_FINGERPRINT
  WHERE REPO = '$DBCONNREF' ) RHS

ON LHS.BATCH_START_TIME = RHS.BATCH_START_TIME AND LHS.SNP_ID = RHS.SNP_ID

WHERE

RHS.CHKSUM IS NULL 

AND LHS.BATCH_START_TIME = (SELECT MAX(BATCH_START_TIME) FROM TBL_FINGERPRINT WHERE REPO = '$DBCONNREF')



--- RHS



I want to get ids, then convert to objects

* get_left
* get_right

'''

import MOI_user_passwords
import os, sys
import re
import pprint
from mikado.common.db import tdlib
from ODI_text_concate import safe_file_name
import ODI_objects_from_repo as olib
import datetime

def showdt(msg='?'):
    print msg, datetime.datetime.today().isoformat()

def all_fingerprints_all_repos(fingerconn):

    d = {}
    #find the batchnum here and inject into below sql
    sql_batch = '''SELECT MAX(BATCH_START_TIME) as BATCH_START_TIME FROM TBL_FINGERPRINT WHERE repo = '$DBCONNREF' '''
    rs = tdlib.query2obj(fingerconn, sql_batch)
    this_batch_start_time = rs[0].BATCH_START_TIME
    d['this_batch_start_time'] = this_batch_start_time


    SQL1 = """SELECT * FROM TBL_FINGERPRINT
             WHERE BATCH_START_TIME = '%(this_batch_start_time)s'
             ORDER BY SNP_NAME, SNP_ID, CHKSUM, REPO """ % d
    print SQL1

    rs = tdlib.query2obj(fingerconn, SQL1)
#    c = fingerconn.cursor()
#    c.close()
#    c = fingerconn.cursor()
#    c.execute(SQL1)
#    c.nextset()
#    c.nextset()
#    rs = c.fetchall()
#    print c.rowcount
    #rs = tdlib.runQuery(fingerconn, SQL)
    return rs





def main():
    fingerconn = tdlib.getConn(MOI_user_passwords.get_dsn_details('FINGERPRINT'))

    rs = all_fingerprints_all_repos(fingerconn)
    
    html = "<html><body>" 

    html += "<h2>Comparing all repos</h2>"
    html += """<p>This is an interim report (starting from 14 Nov)
    that helps developers to decide if the code they want to change (before starting development)
    is safe - that is if they version in the repo they are going to work on is same as that they are targetting.
    <p>
    It also is to help a similar problem of comparing across REPOs - to know if it is safe to migrate from one repo
    to another - but the compare_specific_objects app does this also.
    </p>""" 
    html += '<table border="1">'
    html += """<tr>
    <th>%s</th>
    <th>%s</th>
    <th>%s</th>
    <th>%s</th>
    <th>%s</th>
    <th>%s</th>
    <th>%s</th>

    </tr>""" % ("REPO", "OBJECTTYPE","SNP_ID","SNP_NAME","CHKSUM","INSERT_TS","BATCH_START_TIME")
    
    for row in rs:
        html += """<tr>
            <td>%(REPO)s</td>
            <td>%(OBJECTTYPE)s</td>
            <td>%(SNP_ID)s</td>
            <td>%(SNP_NAME)s</td>
            <td>%(CHKSUM)s</td>
            <td>%(INSERT_TS)s</td>
            <td>%(BATCH_START_TIME)s</td>

            </tr>""" % row.__dict__

    html += "</table>"

    fo =open(r"H:\_MOI_Release_Area\version_mgmt\full_fingerprint.html", "w")
    fo.write(html)
    fo.close()

if __name__ == '__main__':
    #CONST
    ROOTFOLDER = r'C:\ODICodeForComparison\direct_compare_results'
    m = main()
    