from mikado.common.db import tdlib
import MOI_user_passwords

conn = tdlib.getConn(dsn=MOI_user_passwords.get_dsn_details("$DBCONNREF"))

rs = tdlib.query2obj(conn, """SELECT TABLE_NAME FROM dba_tables
Where OWNER = '$DBUSER' """)

l = []

for row in rs:
    l.append("ANALYZE TABLE %s estimate statistics" % row.TABLE_NAME)

for stmt in l:
    print stmt,
    tdlib.exec_query(conn, stmt)

    