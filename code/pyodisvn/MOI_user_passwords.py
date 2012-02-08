#!/usr/local/bin/python
#! -*- coding: utf-8 -*-

from mikado.common.db import tdlib
import pprint

'''

example:

    from mikado.common.db import tdlib

    conn = tdlib.getConn(MOI_user_passwords.get_dsn_details("$DBCONNREF"))

RISKS

1. I am using exec
2. There are raw passwords in here.
3. whooops

move to $DBPASS user password
>>> c.execute("ALTER SESSION SET CURRENT_SCHEMA=AOODIMSTRCODE")

but

I need to track what is where, and what is running where
There is a big need for monitoring capabilities

Look in ODBC Driver for Teradata User Guide http://www.info.teradata.com/eDownload.cfm? itemid=082330030

In Chapter 4->ODBC Connection Functions->keywords for SQLDriverConnect() and SQLBrowseConnect(), 

there is a list of keywords you can use in connection-string. In-fact you can control every ODBC option thru these keywords.

Example : 

DRIVER={Teradata};DBCNAME=myhost;UID=username; PWD=password;QUIETMODE=YES;


I want some kind of mapping 
dsn_name to dsn_string


 
SQL SERVER ...

useage:
dsn = MOI_user_passwords.get_dsn_details('$DBCONNREF')
gets 
'DRIVER={Teradata};DBCNAME=$FQDN;UID=$DBPASS; PWD=$DBPASS;QUIETMODE=YES;'


'''
dsn_tmpls_old = {
"ms_oracle": '''\n"%(name)s":"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%(server)s)(PORT=%(port)s))(CONNECT_DATA=(SERVICE_NAME=%(dbase)s)));Uid=%(user)s;Pwd=%(pass)s;"''',
"teradata": '''\n"%(name)s":"DRIVER={Teradata};DBCNAME=%(server)s;UID=%(user)s; PWD=%(pass)s;QUIETMODE=YES;"''',
#"oracle": '''\n"%(name)s":"DRIVER={Oracle in OraClient10g_home2};Data Source=(DESCRIPTION=(CID=GTU_APP)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=%(server)s)(PORT=%(port)s)))(CONNECT_DATA=(SID=%(dbase)s)(SERVER=DEDICATED)));User Id=%(user)s;Password=%(pass)s;"''',
#"oracle": '''\n"%(name)s":"PROVIDER={Oracle in OraClient10g_home1};Data Source=(DESCRIPTION=(CID=GTU_APP)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=%(server)s)(PORT=%(port)s)))(CONNECT_DATA=(SID=%(dbase)s)));User Id=%(user)s;Password=%(pass)s;"''',
#"oracle": '''\n"%(name)s":"Driver={Oracle in XE};dbq=%(server)s:%(port)s/%(dbase)s;Uid=%(user)s;Pwd=%(pass)s;"''',

"oracle": '''\n"%(name)s":"Driver={Oracle in OraClient10g_home2};dbq=%(server)s:%(port)s/%(dbase)s;Uid=%(user)s;Pwd=%(pass)s;"''',

}


dsn_tmpls = {
"ms_oracle": '''"Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%(server)s)(PORT=%(port)s))(CONNECT_DATA=(SERVICE_NAME=%(dbase)s)));Uid=%(user)s;Pwd=%(pass)s;"''',
"teradata": '''DRIVER={Teradata};DBCNAME=%(server)s;UID=%(user)s; PWD=%(pass)s;QUIETMODE=YES;''',
#"oracle": '''\n"%(name)s":"DRIVER={Oracle in OraClient10g_home2};Data Source=(DESCRIPTION=(CID=GTU_APP)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=%(server)s)(PORT=%(port)s)))(CONNECT_DATA=(SID=%(dbase)s)(SERVER=DEDICATED)));User Id=%(user)s;Password=%(pass)s;"''',
#"oracle": '''\n"%(name)s":"PROVIDER={Oracle in OraClient10g_home1};Data Source=(DESCRIPTION=(CID=GTU_APP)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=%(server)s)(PORT=%(port)s)))(CONNECT_DATA=(SID=%(dbase)s)));User Id=%(user)s;Password=%(pass)s;"''',
#"oracle": '''\n"%(name)s":"Driver={Oracle in XE};dbq=%(server)s:%(port)s/%(dbase)s;Uid=%(user)s;Pwd=%(pass)s;"''',

"oracle": '''Driver={Oracle in OraClient10g_home2};dbq=%(server)s:%(port)s/%(dbase)s;Uid=%(user)s;Pwd=%(pass)s;''',

}


servers = [
    ####  $DBCONNREF  ####
    {
    'name' : '$DBCONNREF',
    'server' : '$FQDN',
    'port' : '1526',
    'dbase' : '$DBASE',
    'pass' : '$DBPASS',
    'user' : '$DBUSER',
    'CURRENT_SCHEMA' : '$DBUSER',
    'tmpl' : 'oracle',
    },

    ####  $DBCONNREF  ####
    {
    'name' : '$DBCONNREF',
    'server' : '$FQDN',
    'port' : 'XXX',
    'dbase' : 'XXX',
    'pass' : '$DBPASS',
    'user' : '$DBPASS',
    'CURRENT_SCHEMA' : '$DBPASS',
    'tmpl' : 'teradata',
    },

    #imput all reqd connections here

]


def build_dsn_strings():
    '''build in memory list of dsn strings from the above '''

    exclude_list = ['$DBCONNREF', 
                    '$DBCONNREF',
                    '$DBCONNREF',
                    '$DBCONNREF',
                    '$DBCONNREF',
                    '$DBCONNREF' ]

    alldsns = 'all_dsn_strings = {'
    for d_server in servers:
        if d_server["name"] in exclude_list: continue
        tmpl = dsn_tmpls[d_server["tmpl"]]
        mydsn = tmpl % d_server
        alldsns += mydsn + ", \n"
    alldsns += "}"
    exec alldsns
    return all_dsn_strings

#DSNSTRINGS = build_dsn_strings()

def get_dsn_details(name):
    '''return dsn, schema, rdbms '''
    exclude_list = ['$DBCONNREF', 
                '$DBCONNREF',
                '$DBCONNREF',
                '$DBCONNREF',
                '$DBCONNREF',
                '$DBCONNREF' ]

    for server in servers:
        if server["name"] in exclude_list: continue
        if server['name'] == name:
            thisserver = server
            break

    
    tmpl = dsn_tmpls[server["tmpl"]]
    mydsn = tmpl % server

    server['dsn'] = mydsn
        
    #basically return the login details...
    return server

def showservers():
    for server in servers:
        print "| %s | %s |" % (
                                       
                                       server['name'], 
                                       server['user'] )

        
#def showservers():
#    for server in servers:
#        hdr = ['name',  'server', 'port',  'dbase', 'pass', 'user', 'CURRENT_SCHEMA','tmpl',]
#        server['CURRENT_SCHEMA'] = server['user']##
#
#        print "    #### ", server['name'], ' ####\n    {'
#        for i in hdr:
#            print "    '%s' : '%s'," % (i, server[i])
#        print "    },"


def test_dbconn_servers():

    passed = []
    failed = []
    
    for server in servers:
        name = server['name']
        dsn_details = get_dsn_details(server['name'])
        print name
        try:
            conn = tdlib.getConn(get_dsn_details(server['name']))
            c = conn.cursor()
            if dsn_details['dsn'].lower().find("teradata") >= 0:
                c.execute("SELECT 1")
            else:
                c.execute("SELECT 1 FROM dual")
            passed.append(name)
        except Exception, e:
            print dsn_details['dsn']
            failed.append([name, e])

    print "******** PASSED *********"
    for name in passed:
        print name
    print "******** FAILED *********"
    for name, e in failed:
        print name
        print e
        print
        
            
def adhoc_query():
    ''' '''
    for dsn in DSNSTRINGS:

        if DSNSTRINGS[dsn].lower().find("teradata") == -1:
            try:
                conn = tdlib.getConn(dsn=DSNSTRINGS[dsn])#mx.ODBC.Windows.DriverConnect(str(DSNSTRINGS[dsn]))
                rs = tdlib.query2obj(conn, "SELECT REP_VERSION, REP_TYPE, REP_NAME, REP_SHORT_ID FROM snp_loc_repw")
                print dsn, rs[0].REP_VERSION, rs[0].REP_NAME, rs[0].REP_SHORT_ID

                rs = tdlib.query2obj(conn, """SELECT COUNT(*) as "ct" FROM snp_scen""")
                print dsn, rs[0].ct

                
            except Exception, e:
                print str(e)
                print "failed", dsn
        else:
            pass



if __name__ == '__main__':
    #showservers()
    test_dbconn_servers()
    #adhoc_query()
