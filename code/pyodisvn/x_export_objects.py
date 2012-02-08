#!/usr/local/bin/python
#! -*- coding: utf-8 -*-

import mx.ODBC.Manager
from mikado.common.db import tdlib
from mikado.common import mikado_log
import md5 
import os
import sys
import string
import datetime
import shutil
import MOI_user_passwords
import ODI_objects_from_repo as odi_lib
from odi_common import PyODIError

'''
Want to get OdiExportObject working
OdiExportObject -CLASS_NAME=<class_name> -I_OBJECT=<I_Object> -FILE_NAME=<FileName> [-FORCE_OVERWRITE=<yes|no>] [-RECURSIVE_EXPORT=<yes|no>] [-XML_VERSION=<1.0>] [-XML_CHARSET=<charset>] [-JAVA_CHARSET=<charset>]



Object Class Name

Column SnpCol
Condition/Filter SnpCond
Context SnpContext
Data Server SnpConnect
Datastore SnpTable
Folder SnpFolder
Interface SnpPop
Language SnpLang
Model SnpModel
Package SnpPackage
Physical Schema SnpPschema
Procedure or KM SnpTrt 
Procedure or KM Option SnpUserExit
Project SnpProject
Reference SnpJoin
Scenario SnpScen
Sequence SnpSequence
Step SnpStep
Sub-Model SnpSubModel
Technology SnpTechno
User Functions SnpUfunc 
Variable SnpVar
'''


def emit_sql_to_get_id_from_nameandtype(objname, objtype, extras):
    '''A common idiom seems to be to want to get back the defitnions of a
    object from its ID or from just a name.
    Errr ----
    actually there is a dispatching need 

    Anyway this returns the SQL needed to get the most SNPID from objectnameAndType
    '''

    #I want to use the SNP Objectfs, but each constructir expects I_pop which is what I am looking for 
    #PROJECT

    mapper = {
     'SnpProject': '''SELECT I_PROJECT as ID, 
                      PROJECT_NAME as NAME 
                      FROM SNP_PROJECT
                      WHERE UPPER(PROJECT_NAME) = '%(objname)s' ''',

     'SnpTrt': '''SELECT I_TRT as ID, TRT_NAME as NAME
                     FROM SNP_TRT trt 
                     INNER JOIN  SNP_PROJECT pj 
                                 ON trt.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(trt.TRT_NAME) = '%(objname)s' ''',

    'SnpTable': '''SELECT I_TABLE as ID, TABLE_NAME as NAME
                    FROM SNP_TABLE tbl INNER JOIN SNP_MODEL mdl ON tbl.I_MOD = mdl.I_MOD
                WHERE 
                MOD_NAME = '%(mod_name)s'
                AND 
                UPPER(tbl.TABLE_NAME)
                = '%(objname)s'
                ''',     

    'SnpPop': '''SELECT I_POP as ID, POP_NAME as NAME
                     FROM SNP_POP pop 
                     INNER JOIN  SNP_FOLDER fldr 
                                 ON pop.I_FOLDER = fldr.I_FOLDER

                    INNER JOIN SNP_PROJECT pj
                                 ON fldr.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(pop.POP_NAME) = '%(objname)s' ''',
     
    'SnpPackage': '''SELECT I_PACKAGE as ID, PACK_NAME as NAME
                     FROM SNP_PACKAGE pkg 
                     INNER JOIN  SNP_FOLDER fldr 
                                 ON pkg.I_FOLDER = fldr.I_FOLDER
                     INNER JOIN SNP_PROJECT pj
                                 ON fldr.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(pkg.PACK_NAME) = '%(objname)s'
                          ''',

    'SnpVar':  '''SELECT I_VAR as ID, VAR_NAME as NAME
                     FROM SNP_VAR var 
                     INNER JOIN SNP_PROJECT pj
                                 ON var.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(var.VAR_NAME) = '%(objname)s'
                          ''',    
        }

    try:
        sql_tmpl = mapper[objtype]
    except KeyError, e:
        raise e
        
    d = {'objname':objname.upper(),}
    d.update(extras)

    return sql_tmpl % d         



                 
def get_snpid_given_nameandtype(objname, objtype, extras):
    '''

    >>> 
    
      '''

    try:
        SQL = emit_sql_to_get_id_from_nameandtype(objname, objtype, extras)
    except Exception, e:
        print "cannot map that", e,objname, objtype
        raise e
        return ("Cannot map %s/%s to a object" % (objname, objtype),
                "Cannot map %s/%s to a object" % (objname, objtype))
    
    conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('$DBCONNREF'))

    rs = tdlib.query2obj(conn, SQL)

    if len(rs) == 0:
        raise PyODIError("must return at least one value - please review")
    if len(rs) > 1:
        raise PyODIError("must return only one value - please review")
    
    return rs[0].ID

def emit_export_str(objname, objid, objtype, tgt_dir): 
    '''Given details of an object, write out cmd to export it.
       
    >>> emit_export_str('MOI_UKM', 1234, 'SnpTrt', 'c:/temp')
    ('REM SnpTrt MOI_UKM 1234\\ncall startcmd.bat OdiExportObject -CLASS_NAME=SnpTrt -I_OBJECT=1234 -FILE_NAME="c:/temp/SnpTrt_1234_MOI_UKM.xml" -FORCE_OVERWRITE=yes -RECURSIVE_EXPORT=yes\\n', 'REM SnpTrt MOI_UKM 1234\\ncall startcmd.bat OdiImportObject  -FILE_NAME="c:/temp/SnpTrt_1234_MOI_UKM.xml" -WORK_REP_NAME=$DBCONNREF  -IMPORT_MODE=SYNONYM_INSERT_UPDATE\\n')

    '''

    export_str = ''
    import_str = ''
    objid = int(objid)
    
    #do we want to export children or not (oddly this should usually be no)
    if objtype in ('SnpTrt','SnpPop', 'SnpPackage'):
        recurse = "yes"
    else:
        recurse = "no"
  
    filename = "%s_%s_%s.xml" % (objtype, objid, objname)

    export_str += "REM %s %s %s\n" %(objtype, objname, objid)
    export_str += """call startcmd.bat OdiExportObject -CLASS_NAME=%s -I_OBJECT=%s -FILE_NAME="%s/%s" -FORCE_OVERWRITE=yes -RECURSIVE_EXPORT=%s\n""" % (
                          objtype, objid, tgt_dir, filename, recurse)

    import_str += "REM %s %s %s\n" %(objtype, objname, objid)
    import_str += """call startcmd.bat OdiImportObject  -FILE_NAME="%s/%s" -WORK_REP_NAME=$DBCONNREF  -IMPORT_MODE=SYNONYM_INSERT_UPDATE\n""" % (tgt_dir, filename)

    return (export_str, import_str)





if __name__ == '__main__':

    import doctest
    doctest.testmod()
