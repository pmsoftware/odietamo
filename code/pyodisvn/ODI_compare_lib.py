#!/usr/local/bin/python
#! -*- coding: utf-8 -*-


'''
ODI Repository comparison tool
==============================

Using the repository fingerprinting, given two repos, find the left outer,
 right outer and inner non-matches


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
from ODI_lib import safe_file_name
import ODI_objects_from_repo as olib
import datetime

def showdt(msg='?'):
    print msg, datetime.datetime.today().isoformat()

def get_rhs_ids(fingerconn, lhs_reponame, rhs_reponame):
    ''' '''
    d = {'lhs_reponame': lhs_reponame,
         'rhs_reponame': rhs_reponame
         }
    #find the batchnum here and inject into below sql
    sql_batch = '''SELECT MAX(BATCH_START_TIME) as BATCH_START_TIME FROM TBL_FINGERPRINT WHERE REPO = '%(rhs_reponame)s' ''' % d
    rs = tdlib.query2obj(fingerconn, sql_batch)
    this_batch_start_time = rs[0].BATCH_START_TIME

    d['this_batch_start_time'] = this_batch_start_time
    
    SQL = '''SELECT RHS.SNP_ID, RHS.CHKSUM, RHS.OBJECTTYPE, RHS.SNP_NAME FROM 

            ( SELECT SNP_ID, chksum, BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(lhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s') LHS

            RIGHT OUTER JOIN

            ( SELECT SNP_ID, chksum,  BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(rhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s') RHS

            ON LHS.BATCH_START_TIME = RHS.BATCH_START_TIME AND LHS.SNP_ID = RHS.SNP_ID  AND LHS.OBJECTTYPE = RHS.OBJECTTYPE

            WHERE

            LHS.CHKSUM IS NULL 

            AND RHS.BATCH_START_TIME = '%(this_batch_start_time)s' ''' % d
          
    rs = tdlib.query2obj(fingerconn, SQL)
    return [obj_dispatch(row.SNP_ID, row.OBJECTTYPE, rhs_reponame, row.CHKSUM, row.SNP_NAME) for row in rs]


def get_lhs_ids(fingerconn, lhs_reponame, rhs_reponame):
    ''' '''
    d = {'lhs_reponame': lhs_reponame,
         'rhs_reponame': rhs_reponame
         }
    #find the batchnum here and inject into below sql
    sql_batch = '''SELECT MAX(BATCH_START_TIME) as BATCH_START_TIME FROM TBL_FINGERPRINT WHERE REPO = '%(rhs_reponame)s' ''' % d
    rs = tdlib.query2obj(fingerconn, sql_batch)
    this_batch_start_time = rs[0].BATCH_START_TIME

    d['this_batch_start_time'] = this_batch_start_time

    
    SQL = '''SELECT LHS.SNP_ID, LHS.CHKSUM, LHS.OBJECTTYPE, LHS.SNP_NAME FROM 

            ( SELECT SNP_ID, chksum, BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(lhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s' ) LHS

            LEFT OUTER JOIN

            ( SELECT SNP_ID, chksum,  BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(rhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s' ) RHS

            ON LHS.BATCH_START_TIME = RHS.BATCH_START_TIME AND LHS.SNP_ID = RHS.SNP_ID AND LHS.OBJECTTYPE = RHS.OBJECTTYPE

            WHERE

            RHS.CHKSUM IS NULL 

            AND LHS.BATCH_START_TIME = '%(this_batch_start_time)s' ''' % d
                
    rs = tdlib.query2obj(fingerconn, SQL)
    return [obj_dispatch(row.SNP_ID, row.OBJECTTYPE, lhs_reponame, row.CHKSUM, row.SNP_NAME) for row in rs]

def get_mismatched_ids(fingerconn, lhs_reponame, rhs_reponame):
    ''' '''
    d = {'lhs_reponame': lhs_reponame,
         'rhs_reponame': rhs_reponame
         }
    #find the batchnum here and inject into below sql
    sql_batch = '''SELECT MAX(BATCH_START_TIME) as BATCH_START_TIME FROM TBL_FINGERPRINT WHERE REPO = '%(rhs_reponame)s' ''' % d
    rs = tdlib.query2obj(fingerconn, sql_batch)
    this_batch_start_time = rs[0].BATCH_START_TIME

    d['this_batch_start_time'] = this_batch_start_time

        
    SQL = '''SELECT LHS.SNP_ID, LHS.CHKSUM, LHS.OBJECTTYPE, LHS.SNP_NAME FROM 

            ( SELECT SNP_ID, chksum, BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(lhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s' ) LHS

            INNER JOIN

            ( SELECT SNP_ID, chksum,  BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(rhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s') RHS

            ON LHS.BATCH_START_TIME = RHS.BATCH_START_TIME AND LHS.SNP_ID = RHS.SNP_ID  AND LHS.OBJECTTYPE = RHS.OBJECTTYPE

            WHERE

            RHS.CHKSUM <> LHS.CHKSUM 

            AND LHS.BATCH_START_TIME ='%(this_batch_start_time)s' ''' % d


    SQLdb = '''SELECT LHS.SNP_ID, LHS.CHKSUM, LHS.OBJECTTYPE, LHS.SNP_NAME FROM 

            ( SELECT SNP_ID, chksum, BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(lhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s' ) LHS

            INNER JOIN

            ( SELECT SNP_ID, chksum,  BATCH_START_TIME, OBJECTTYPE, SNP_NAME from TBL_FINGERPRINT
              WHERE REPO = '%(rhs_reponame)s' and batch_start_time = '%(this_batch_start_time)s') RHS

            ON LHS.BATCH_START_TIME = RHS.BATCH_START_TIME AND LHS.SNP_NAME = RHS.SNP_NAME  AND LHS.OBJECTTYPE = RHS.OBJECTTYPE

            WHERE

            RHS.CHKSUM <> LHS.CHKSUM 

            AND LHS.BATCH_START_TIME ='%(this_batch_start_time)s' ''' % d

    #??? 
    if lhs_reponame.find("_UKM_") >=0:
        SQL = SQLdb
        
    rs = tdlib.query2obj(fingerconn, SQL)
    return [obj_dispatch(row.SNP_ID, row.OBJECTTYPE, lhs_reponame, row.CHKSUM, row.SNP_NAME) for row in rs]


def obj_dispatch(snp_id, objecttype, conntype, chksum, snp_name):
    '''go to work repo, retrieve the given id and obj type '''

    ### conntype is a failure here, need some logival face svaing but 
    ### bsically I am saying if its a dbase object (userview / create table)
    ### then go get a dummy object
    if objecttype == 'dbase':
        conn = None
        o = olib.snp_dbase(conn, snp_id)
        o.__dict__['chksum'] = chksum
        o.__dict__['objecttype'] = objecttype
        o.__dict__['name'] = snp_name
        o.__dict__['id'] = snp_id
        return o

    conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details(conntype))
    if objecttype == 'trt':
        o = olib.snp_trt(conn, snp_id)
        o.__dict__['chksum'] = chksum
        o.__dict__['objecttype'] = objecttype
        o.__dict__['name'] = o.stepname
        o.__dict__['id'] = snp_id

    elif objecttype == 'pkg':
        o = olib.snp_package(conn, snp_id)
        o.__dict__['chksum'] = chksum
        o.__dict__['objecttype'] = objecttype
        o.__dict__['name'] = o.package_name
        o.__dict__['id'] = snp_id
    elif objecttype == 'pop':
        o = olib.snp_pop(conn, snp_id)
        o.__dict__['chksum'] = chksum
        o.__dict__['objecttype'] = objecttype
        o.__dict__['name'] = o.POP_NAME
        o.__dict__['id'] = snp_id
    else:
        o = None

    return o


        
def compare_repo(lhs_reponame, rhs_reponame):

    '''
    What does this do????
    - connect to fingerprint, as lhs and rhs
    
    - lhs_ids : take the most recent batch, can return the LHS id that are missing, joining on ID and objecttype
    - rhs_ids : take the most recent batch, can return the RHS id that are missing, joining on ID and objecttype
    - get_mismatched_ids : take most recent batch, and return those that do not match

    objectlibrary is then used, creating an object per id above.
    This is brittle and needs improving especially as ai am dumpingin ids and chksums

    improvements:
    HTML cleanup
    More info can be shown from objects in HTML surely?
    linking to a diff - needs webserver.
    
    
    '''


    fingerconn = tdlib.getConn(MOI_user_passwords.get_dsn_details('FINGERPRINT'))
#    lhs_reponame = 'SYS3_B_UKM_DATA'
#    rhs_reponame = 'UAT3_B_UKM_DATA'

#    lhs_reponame = '$DBCONNREF'
#    rhs_reponame = '$DBCONNREF'

    
    print "RHS", showdt(),
    r = get_rhs_ids(fingerconn, lhs_reponame, rhs_reponame)
    print len(r), showdt()
    
    print "mismatch", showdt(),
    m= get_mismatched_ids(fingerconn, lhs_reponame, rhs_reponame)
    print len(m), showdt()
    
    print "LHS", showdt(),
    l = get_lhs_ids(fingerconn, lhs_reponame, rhs_reponame)
    print len(l), showdt()
    
    html = "<html><body>" 

    html += "<h2>Items in Left (%s) not Right (%s)</h2>" % (lhs_reponame, rhs_reponame)
    html += '<table border="1">'
    for item in l:
        if not item: continue
        html += "<tr><td>%s %s</td><td>%s</td></tr>" % (item.id, item.name, item.chksum)
    html += "</table>"
    
    html += "<h2>Items in RIght (%s) not left (%s)</h2>" % (rhs_reponame, lhs_reponame)
    html += '<table border="1">'
    for item in r:
        if not item: continue
        html += "<tr><td>%s %s</td><td>%s</td></tr>" % (item.id,item.name, item.chksum)
    html += "</table>"

    html += "<h2>Items in Both but mismatch</h2>"
    html += '<table border="1">'
    
    for item in m:
        if not item: continue
#        diff = 'diff %s %s' % (os.path.join(os.path.join(ROOTFOLDER, lhs_reponame),
#                                        '%s_%s.log' %  (item.id,item.name)),
#                               os.path.join(os.path.join(ROOTFOLDER, rhs_reponame),
#                                        '%s_%s.log' %  (item.id,item.name))
#                               )
        diff = "TBC"                                
        html += "<tr><td>%s %s</td><td>%s</td><td>%s</td></tr>" % (item.id,item.name, item.chksum, diff)
    html += "</table>"

    #fo =open(OUTPUTHTMLPATH, "w")
    #fo.write(html)
    #fo.close()

    return html

if __name__ == '__main__':
    #CONST
    dt = datetime.datetime.today().strftime("%Y%m%d-%H%M")
    LHS, RHS = ('$DBCONNREF', '$DBCONNREF')
    OUTPUTHTMLPATH = r"c:\repocompare_%s_%s_%s.html" % (LHS, RHS, dt)
    ROOTFOLDER = r'C:\ODICodeForComparison\direct_compare_results'
    m = compare_repo(LHS, RHS)
    open(OUTPUTHTMLPATH, 'w').write(m)
    
