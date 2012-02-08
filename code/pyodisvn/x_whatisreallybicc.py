#!/usr/local/bin/python
#! -*- coding: utf-8 -*-


import md5 
import os
import sys
import string
import datetime
import shutil


from mikado.common.db import tdlib
import MOI_user_passwords
import ODI_objects_from_repo as odi_lib

conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))
conn2 = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))

'''
Here I start with a huge bunch of object xml files, some of which are BICC changed some of which just happen to have been changed since 1 sept.
walk through all files and just choose those that are chaned since time dot and LAST user is a specific set of people

'''



mapper = {'SnpConnect':('SNP_CONNECT','I_CONNECT', 'CONNECT_NAME'),
          'SnpLschema':('SNP_LSCHEMA','I_LSCHEMA', ''),
          'SnpProject':('SNP_PROJECT','I_PROJECT','PROJECT_NAME'),
          'SnpPackage':('SNP_PACKAGE','I_PACKAGE','PACK_NAME'),
          'SnpFolder':('SNP_FOLDER','I_FOLDER','FOLDER_NAME'),
          'SnpPop':('SNP_POP','I_POP','POP_NAME'),
          'SnpJoin':('SNP_JOIN','I_JOIN','CONCAT(PK_SCHEMA, PK_TABLE_NAME)'),
          'SnpTable':('SNP_TABLE','I_TABLE','TABLE_NAME'),
          'SnpTrt':('SNP_TRT','I_TRT','TRT_NAME'),

#          'SnpObjState',
#          'SnpSequence',
          'SnpVar':('SNP_VAR','I_VAR','VAR_NAME'),
          'SnpModel':('SNP_MODEL','I_MOD','MOD_NAME'),
#           'SnpGrpState'          

          }

          
lst_of_files = []
f = r'C:\temp\BICC_Staging'

for root, dir, files in os.walk(f):
    lst_of_files.extend(files)

#print lst_of_files
d = {}
for f in lst_of_files:
    basename, extn = os.path.splitext(f)
    extn = extn.replace(".","")
    
    d.setdefault(extn, []).append(basename)

print d.keys()
c=1

fo = open('export.bat','w')
f1 = open('import.bat','w')
export_str = ''
import_str = ''
export_dir = r'c:\temp'


for extn in d.keys():
    if extn not in (#'SnpConnect',
                    #'SnpLschema',
                    'SnpProject',
                    'SnpPackage',
                    'SnpFolder',
                    'SnpPop',
                    'SnpJoin',
#                    'SnpLschema',
                    'SnpTrt',
                    'SnpPackage',
                    'SnpProject',
                    'SnpPop',
                    'SnpTable',
#                    'SnpObjState',
#                    'SnpSequence',
                    'SnpVar',
#                    'SnpConnect',
                    'SnpModel',
#                    'SnpGrpState'
          ): continue

    tbl, id, name = mapper[extn]
    #at this pioint should I be instantiating the py objects

    
    for snpid in d[extn]:
        
        try:
            SQL = """SELECT %s as SNP_ID, 
                     %s as SNP_NAME, 
                     LAST_DATE, 
                     LAST_USER FROM %s WHERE %s = %s""" % (id, name, tbl, id, snpid)
            rs = tdlib.query2obj(conn,SQL)
            
            rs_check = tdlib.runQuery(conn2, SQL)
            if rs_check == []:
                print "Fails", SQL
                synonym = 'INSERT'
            else:
                synonym = 'INSERT_UPDATE'
                
       
            if rs[0].LAST_USER not in ("SUPERVISOR", "MATTENM", "BRIANP", 'SKARIAS', 'KACHOLEH'):
                print extn, tbl, id, name, rs[0].LAST_USER, rs[0].SNP_ID, rs[0].SNP_NAME
                if extn in ('SnpTrt','SnpPop'):
                    recurse = "yes"
                else:
                    recurse = "no"
                    
                export_str += "REM %s %s %s\n" % (rs[0].SNP_NAME, extn, snpid)
                export_str += """call startcmd.bat OdiExportObject -CLASS_NAME=%s -I_OBJECT=%s -FILE_NAME="%s\%s.%s.xml" -FORCE_OVERWRITE=yes -RECURSIVE_EXPORT=%s\n""" % (
                          extn, snpid,  export_dir, rs[0].SNP_ID, rs[0].SNP_NAME, recurse)
                import_str += '''REM %s %s %s
call startcmd.bat OdiImportObject  -FILE_NAME="%s\%s.%s.xml" -WORK_REP_NAME=$DBCONNREF  -IMPORT_MODE=SYNONYM_%s
''' % (extn, rs[0].SNP_NAME,  snpid, export_dir, rs[0].SNP_ID, rs[0].SNP_NAME, synonym)

        except Exception, e:
            print SQL
            raise e

fo.write(export_str)
fo.close()

f1.write(import_str)
f1.close()


