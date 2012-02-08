

'''
FInger print DAtabases - extract the USER View, base view and CREAT TABLE stmts,
flush them
and then md5hash them
Add to same fingerprint table


>>> import fingerprint_dbases
>>> from mikado.common.db import tdlib
>>> import MOI_user_passwords
>>> connfinger = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details('FINGERPRINT'))
>>> fingerprint_dbases.get_batch_start_time(connfinger)
'2011-12-05T09:49:08.584000'
>>>


'''

import MOI_user_passwords
from mikado.common.db import tdlib
import md5
import datetime
import os, sys
import pprint

CHKSUM_VERSION = "FINGERPRINTDB_V1.0"


class ODIFingerprintError(Exception):
    pass


def chksum(txt):
    chksum = CHKSUM_VERSION + "-" + md5.new(txt).hexdigest()
    return chksum

def extract_sql_definition_fromdbase(conn, extractsqlstmt):
    '''just splitting out two distinct functions '''
    try:
        rs = tdlib.query2obj(conn, extractsqlstmt)
    except Exception, e:
        raise ODIFingerprintError("Unable to complete command. Probably user permissions. Error: %s on %s %s" % (str(e), repr(conn), extractsqlstmt))
    if len(rs) != 1:
        raise ODIFingerprintError("Must be one and only one table definition in database. %s %s" % (repr(conn), extractsqlstmt))
    else:
        return "\n".join([getattr(row, "Request Text") for row in rs]) #this is still v teradata specific...
    

def extract_sql_definition(conn, dbname, tablename, tabletype, dbasetype):
    '''
    I am using this to extract valid table and view defitnions from "any" database.
    Currently only support Teradata

    {    dbasetype:{tabletype:tmpl, tabletype:tmpl

     

    in Teradata tabletype == TableKind in dbc.tables 
    Teradata TableKind in dbc.tables:

       E - unknown + unsupported
       F - unknown + unsupported
       I - unknown + unsupported
       M - unknown + unsupported
       P - Stored Procedure
       R - unknown + unsupported
       T - table
       V - view 


    '''
    lookup = {
              'teradata': {'T': '''SHOW TABLE %(databasename)s.%(tablename)s''',
                           'V': '''SHOW VIEW %(databasename)s.%(tablename)s''',
                           'P': '''SHOW PROCEDURE %(databasename)s.%(tablename)s''',
                           
                          },

              'sqlserver': {'T': '''--NOT SUPPORTED SHOW TABLE %(database)s.%(tablename)s''',
                            'V': '''--NOT SUPPORTED SHOW VIEW %(database)s.%(tablename)s''',
                          },
              'oracle':    {'T': '''--NOT SUPPORTED SHOW TABLE %(database)s.%(tablename)s''',
                            'V': '''--NOT SUPPORTED SHOW VIEW %(database)s.%(tablename)s''',
                          },
              }

    #this needs to handle unknown tabletypes like G, also no good fro SQLSVR
    tmpl = lookup[dbasetype][tabletype]
    SQL = tmpl % {"databasename": dbname, "tablename": tablename}
    try:
        return extract_sql_definition_fromdbase(conn, SQL)
    except Exception, e:
        #log this !
        open("log.log", "a").write(str(e))
        return "Failed to get Data Defintion. See Logs"
        
def get_tables(conn, dbname):
    SQL = """SELECT DatabaseName, TableName, TableKind as TableType from dbc.tables
             where DatabaseName = '%s' AND TableKind in ('T', 'V', 'P')
             ORDER BY TableName""" % dbname
    rs = tdlib.query2obj(conn, SQL)
    return [(row.DatabaseName, row.TableName, row.TableType) for row in rs]


def sanitise_sql(dbname, sqltext):

    dumbreplacelist = ["UAT1_", "UAT2_", "UAT3_", "UAT4_",
                       "SYS1_", "SYS2_", "SYS3_", "SYS4_",
                       "DEV1_", "DEV2_", "DEV3_", "DEV4_",
                       "PROD_"]

    for txt in dumbreplacelist:
        try:
            sqltext = sqltext.replace(txt, '${context}_')
        except AttributeError:
            sqltext = ''
            
#    return sqltext.lower().replace(dbname.lower(), "{context}")
    return sqltext.lower()


def write_to_file(dbname, tablename, sqltext, batch_start_time, chk,conntype):
    ''' '''
    folder = os.path.join(r'C:\ODICodeForComparison\direct_compare_results', dbname)
    txt = """%s::%s::%s::%s
******************
%s
******************
""" % (dbname, tablename, batch_start_time, chk, sqltext)
    try:
        open(os.path.join(folder, tablename + ".txt"),'w').write(txt)
    except IOError:
        os.makedirs(folder)
        open(os.path.join(folder, tablename + ".txt"),'w').write(txt)
    
def store_results(connfinger, dbname, tablename, sqltext, batch_start_time,conntype):
    ''' '''
    chk = chksum(sqltext)
    insert_sql = '''INSERT INTO tbl_fingerprint
             (batch_start_time, repo, objecttype, snp_id, snp_name, chksum)
             VALUES ('%s', '%s', '%s', %s, '%s', '%s')''' % (batch_start_time,
                                                             dbname, 'dbase',
                                                             1, tablename, chk)


            
    tdlib.exec_query(connfinger, insert_sql)

    write_to_file(dbname, tablename, sqltext, batch_start_time, chk, conntype)    

def get_batch_start_time(connfinger):
    ''' THis is still a hack - to make sure both dbases and odi have same "current batch" '''
    #return datetime.datetime.today().isoformat()
    rs = tdlib.query2obj(connfinger, "SELECT MAX(BATCH_START_TIME) as BATCH_START_TIME from TBL_FINGERPRINT")
    #what if table empty - fail and return current time
    try:
        return rs[0].BATCH_START_TIME
    except:
        return datetime.datetime.today().isoformat()


def main():
    ''' '''

    #batch_start_time = datetime.datetime.today().isoformat()
    
    connfinger = tdlib.getConn(MOI_user_passwords.get_dsn_details('FINGERPRINT'))
    batch_start_time = get_batch_start_time(connfinger)
    #conn = tdlib.getConn()

    #conntype = "'$DBCONNREF'"
    #dbasetype = "teradata"
    #conntype = "UAT3"

    td_dbtypes = ['%s_B_UKM_DATA', '%s_B_UKM_USER_VIEWS', '%s_B_UKM_WORK']
    td_dbtypes = ['%s_A_BHA_TARTAN_BASE_VIEWS',
'%s_A_BHA_TARTAN_DATA',
'%s_A_BHA_TARTAN_USER_VIEWS',
'%s_A_BHA_TARTAN_WORK',
'%s_A_UKM_BADM_BASE_VIEWS',
'%s_A_UKM_BADM_CODE',
'%s_A_UKM_BADM_DATA',
'%s_A_UKM_BADM_USER_VIEWS',
'%s_A_UKM_BADM_WORK',
'%s_A_UKM_BASS_BASE_VIEWS',
'%s_A_UKM_BASS_DATA',
'%s_A_UKM_BASS_USER_VIEWS',
'%s_A_UKM_BASS_WORK',
'%s_A_UKM_BWA_BASE_VIEWS',
'%s_A_UKM_BWA_DATA',
'%s_A_UKM_BWA_USER_VIEWS',
'%s_A_UKM_CSS_WORK',
'%s_A_UKM_EQFX_BASE_VIEWS',
'%s_A_UKM_EQFX_DATA',
'%s_A_UKM_EQFX_USER_VIEWS',
'%s_A_UKM_EQFX_WORK',
'%s_A_UKM_ERP_WORK',
'%s_A_UKM_IBS_BASE_VIEWS',
'%s_A_UKM_IBS_DATA',
'%s_A_UKM_IBS_USER_VIEWS',
'%s_A_UKM_IBS_WORK',
'%s_A_UKM_MCRY_BASE_VIEWS',
'%s_A_UKM_MCRY_DATA',
'%s_A_UKM_MCRY_USER_VIEWS',
'%s_A_UKM_MCRY_WORK',
'%s_A_UKM_MGNT_BASE_VIEWS',
'%s_A_UKM_MGNT_DATA',
'%s_A_UKM_MGNT_USER_VIEWS',
'%s_A_UKM_MGNT_WORK',
'%s_A_UKM_OTHR_BASE_VIEWS',
'%s_A_UKM_OTHR_DATA',
'%s_A_UKM_OTHR_WORK',
'%s_A_UKM_PNT_BASE_VIEWS',
'%s_A_UKM_PNT_DATA',
'%s_A_UKM_PNT_IDX',
'%s_A_UKM_PNT_USER_VIEWS',
'%s_A_UKM_PNT_WORK',
'%s_A_UKM_PSFT_BASE_VIEWS',
'%s_A_UKM_PSFT_DATA',
'%s_A_UKM_PSFT_SW_BASE_VIEWS',
'%s_A_UKM_PSFT_SW_DATA',
'%s_A_UKM_PSFT_SW_USER_VIEWS',
'%s_A_UKM_PSFT_SW_WORK',
'%s_A_UKM_PSFT_USER_VIEWS',
'%s_A_UKM_PSFT_WORK',
'%s_A_UKM_RMX_BASE_VIEWS',
'%s_A_UKM_RMX_DATA',
'%s_A_UKM_RMX_USER_VIEWS',
'%s_A_UKM_RMX_WORK',
'%s_A_UKM_SWFT_BASE_VIEWS',
'%s_A_UKM_SWFT_CODE',
'%s_A_UKM_SWFT_DATA',
'%s_A_UKM_SWFT_IDX',
'%s_A_UKM_SWFT_RLSE',
'%s_A_UKM_SWFT_USER_VIEWS',
'%s_A_UKM_SWFT_WORK',
'%s_B_UKM_BASE_VIEWS',
'%s_B_UKM_BHA_BASE_VIEWS',
'%s_B_UKM_BHA_DATA',
'%s_B_UKM_BHA_USER_VIEWS',
'%s_B_UKM_BHA_WORK',
'%s_B_UKM_CODE',
'%s_B_UKM_DATA',
'%s_B_UKM_USER_VIEWS',
'%s_B_UKM_WORK',
'%s_E_CODE',
        ]
    ######### This is the biggie
    td_contexts = ["dev2", "sys3", "dev4",
                    "uat3", "sys2",
                   ]
    #for prod fingerprinting
#    td_contexts = ["prod",]
    
    dbases_to_parse = []
    for context in td_contexts:
        for dbtype in td_dbtypes:
            dbases_to_parse.append( (dbtype % context.upper(),
                                     "td_%s_brianp" % context.lower(),
                                     "teradata"))
            
                      # Database name,     Connection name   Database type
    pprint.pprint(dbases_to_parse)
    

    for dbname, conntype, dbasetype in dbases_to_parse:

        print
        print "Extracting for ", dbasetype, dbname, conntype
        conn = tdlib.getConn(MOI_user_passwords.get_dsn_details(conntype))
        tables = get_tables(conn, dbname)
        
  
        for dbname, tablename, tabletype in tables:
            print "\r", tablename,    
            tablename = tablename.strip()
            dbname = dbname.strip()
           
            sqltext = extract_sql_definition(conn, dbname, tablename, tabletype, dbasetype)
            sqltext = sanitise_sql(dbname, sqltext)
            store_results(connfinger, dbname, tablename, sqltext, batch_start_time, conntype)

if __name__ == '__main__':
    main()
