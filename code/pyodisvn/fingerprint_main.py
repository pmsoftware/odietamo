
import fingerprint_lib

import mx.ODBC.Manager
from mikado.common.db import tdlib
from mikado.common import mikado_log as log
import md5 
import os
import sys
import string
import datetime
import shutil
import MOI_user_passwords

if __name__ == '__main__':


    repos = [ '$DBCONNREF', '$WELLKNOWNINSURERDEV4', '$DBCONNREF', '$DBCONNREF', '$DBCONNREF',
              '$DBCONNREF', '$DBCONNREF',  '$DBCONNREF',
              '$DBCONNREF', '$DBCONNREF', '$DBCONNREF',  '$DBCONNREF', '$DBCONNREF', 
              '$DBCONNREF',  '$DBCONNREF', '$DBCONNREF', '$DBCONNREF']
    
    short_repos = ['$DBCONNREF', '$WELLKNOWNINSURERDEV4', '$DBCONNREF', '$DBCONNREF']


    if sys.argv[1:][0] == 'short':
        repos = short_repos
    else:
        repos = repos

    ###################         

    print "Fingerprinting ... %s" % ", ".join(repos)
    repo_root = r"C:\ODICodeForComparison\direct_compare_results"

    ### clear down the hashes
    hashbkup = os.path.join(repo_root, "bkup_%s" % datetime.datetime.today().strftime("%Y%m%d%H%M"))
    os.mkdir(hashbkup)
    hashes = [f for f in os.listdir(repo_root) if f.find(".hashes") >= 0]
    for f in hashes:
        shutil.move(os.path.join(repo_root,f), hashbkup)


    
    BATCH_START_TIME = datetime.datetime.today().isoformat()
    context = {}
    context['BATCH_START_TIME'] = BATCH_START_TIME

    #replace old style conn string with the dispatcher style
    #connwrite = tdlib.getConn(dsn="Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$WELLKNOWNINSURER11X714J.internal.$WELLKNOWNINSURER.co.uk)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)));Uid=fingerprint;Pwd=fingerprint;")
    connwrite = tdlib.getConn(MOI_user_passwords.get_dsn_details('FINGERPRINT'))

    for repo_name in repos:
        log.log("Starting %s" % repo_name)

        ## cleaning up 
        tdlib.exec_query(connwrite, "ANALYZE TABLE TBL_FINGERPRINT ESTIMATE STATISTICS") 
        open(r"C:\ODICodeForComparison\direct_compare_results\timer.txt", "a").write("\n%s -> %s" % (repo_name, datetime.datetime.today().isoformat()))
        fingerprint_lib.run(repo_name, connwrite, context)
        open(r"C:\ODICodeForComparison\direct_compare_results\timer.txt", "a").write(" -> %s\n" % ( datetime.datetime.today().isoformat()))

    #fixes bug #6 - duplicate results appearing in comparebyname
    #is not a complete fix - more a workaround
    clean_up_commands = ["""INSERT INTO tbl_fingerprint_current_batch
                                (SELECT MAX(BATCH_START_TIME) as curr_batch_start_time
                                FROM TBL_FINGERPRINT        
                                )  """,
                         
                         '''DELETE  FROM TBL_FINGERPRINT_CURRENT_BATCH
                            WHERE CURR_BATCH_START_TIME <>
                                  (SELECT MAX(CURR_BATCH_START_TIME) FROM TBL_FINGERPRINT_CURRENT_BATCH)''',

                         '''INSERT INTO TBL_FINGERPRINT_ARCHIVE
                            SELECT * FROM TBL_FINGERPRINT
                            WHERE BATCH_START_TIME <>
                            (SELECT MAX(CURR_BATCH_START_TIME) FROM TBL_FINGERPRINT_CURRENT_BATCH)''',

                         '''DELETE FROM TBL_FINGERPRINT_ARCHIVE
                            WHERE BATCH_START_TIME <>
                            (SELECT MAX(CURR_BATCH_START_TIME) FROM TBL_FINGERPRINT_CURRENT_BATCH)'''
                         ]
    for cmd  in clean_up_commands:
        tdlib.exec_query(connwrite, cmd) 
        connwrite.commit()


        

