doc = '''SELECT * FROM SNP_PROJECT
where 

-- MOI-MDM 1021

SELECT  * FROM SNP_FOLDER
where I_PROJECT = 1021

-- I_FOLDER = 1021

SELECT I_TRT, TRT_NAME FROM SNP_TRT
WHERE I_FOLDER = 1021

SELECT I_POP, LSCHEMA_NAME, POP_NAME  FROM SNP_POP
WHERE I_FOLDER = 1021

SELECT I_PACKAGE, PACK_NAME FROM SNP_PACKAGE
WHERE I_FOLDER = 1021'''


class folder(object):
    
    def __init__(self, i_folder, folder_name):
        self.i_folder = i_folder
        self.folder_name = folder_name
        self.name = self.folder_name
        self.interfaces = []
        self.treatments = []
        self.packages = []

    def addall(self):
        sql_trt = '''SELECT I_TRT, TRT_NAME FROM SNP_TRT
                      WHERE I_FOLDER = %s
                      ORDER BY I_TRT''' % self.i_folder
        rs = tdlib.runQuery(conn, sql_trt)

        for row in rs:
            x = snptreatment(row[0], row[1])
            x.scen()
            self.treatments.append(x)

        sql_pop = '''SELECT I_POP, POP_NAME
                    FROM SNP_POP
                    WHERE I_FOLDER = %s
                    ORDER BY I_POP''' % self.i_folder
        rs = tdlib.runQuery(conn, sql_pop)

        for row in rs:
            x = snpinterface(row[0], row[1])
            x.scen()
            self.interfaces.append(x)


        sql_pkg = '''SELECT I_PACKAGE, PACK_NAME FROM SNP_PACKAGE
                     WHERE I_FOLDER = %s
                     ORDER BY I_PACKAGE''' % self.i_folder
        rs = tdlib.runQuery(conn, sql_pkg)

        for row in rs:
            x = snppackage(row[0], row[1])
            x.scen()
            self.packages.append(x)
            
            
class snpscen(object):
    def __init__(self, id, name):
        self.id = id
        self.name = name

    def __repr__(self):
        return "Scen: %s-%s" % (self.id,self.name)
        
class snpinterface(object):
    def __init__(self, id, name):
        self.id = id
        self.name = name
        self.scens = []
        
    def scen(self):
        sql = "SELECT  SCEN_NO, SCEN_NAME  FROM SNP_SCEN where I_POP = %s" % self.id
        rs = tdlib.runQuery(conn, sql)
        for row in rs:
            self.scens.append(snpscen(row[0], row[1]))
            
class snptreatment(object):
    def __init__(self, id, name):
        self.id = id
        self.name = name
        self.scens = []

    def scen(self):
        sql = "SELECT  SCEN_NO, SCEN_NAME  FROM SNP_SCEN where I_TRT = %s" % self.id
        rs = tdlib.runQuery(conn, sql)
        for row in rs:
            self.scens.append(snpscen(row[0], row[1]))
            

class snppackage(object):
    def __init__(self, id, name):
        self.id = id
        self.name = name
        self.scens = []
        
    def scen(self):
        sql = "SELECT  SCEN_NO, SCEN_NAME  FROM SNP_SCEN where I_PACKAGE = %s" % self.id
        rs = tdlib.runQuery(conn, sql)
        for row in rs:
            self.scens.append(snpscen(row[0], row[1]))

from mikado.common.db import tdlib
import mx.ODBC.Manager
#conn = TDlib.getConn(dsn="DSN=$DBCONNREF")
repo="Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODIUAT1)));Uid=$DBSCHEMA;Pwd=$DBPASSW_UATZ;"
#repo="Driver={Microsoft ODBC for Oracle};CONNECTSTRING=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$FQDN)(PORT=1526))(CONNECT_DATA=(SERVICE_NAME=ODISYS1)));Uid=$DBUSER;Pwd=$DBPASS;"
conn = tdlib.getConn(dsn=str(repo))

SQL = """SELECT I_PROJECT, PROJECT_NAME
         FROM SNP_PROJECT
         WHERE PROJECT_NAME IN ('MOI-MDM',
           'IBS-MDM', 'MAGENTA-MDM',
         'REMIX-MDM')
         ORDER BY PROJECT_NAME
         """

SQL = """SELECT I_PROJECT, PROJECT_NAME
         FROM SNP_PROJECT
         WHERE PROJECT_NAME IN ('MOI-UKM')
         ORDER BY PROJECT_NAME
         """


#rs = tdlib.runQuery(conn, SQL)
c = conn.cursor()
c.execute(SQL)
rs  = c.fetchall()

output = ""
output2 = ''
for row in rs:
    proj = row[0]
    projname = row[1]
    

    rs = tdlib.runQuery(conn, """SELECT  I_FOLDER, FOLDER_NAME FROM SNP_FOLDER
    where I_PROJECT = %s ORDER BY I_FOLDER""" % proj)
    fldrs = []
    for row in rs:
        #output += "\n%s - %s" % (proj, projname)
        fldr = folder(row[0], row[1])
        fldr.addall()
        fldrs.append(fldr)



    output += "\nProject %s-%s" % (proj, projname)
    for fldr in fldrs:
        output += "\n" 
        output +="\nfolder: %s" % fldr.folder_name
        output += "\n Packages"
        for package in fldr.packages:
            output += "\n  %s - %s" % ( package.id, package.name)
            output += "- %s" % repr(package.scens)
        output += "\n Treatments"
        for treatment in fldr.treatments:
            output += "\n  %s - %s" % (treatment.id, treatment.name)
            output += "- %s" % repr(treatment.scens)
        output += "\n Interfaces"
        for interface in fldr.interfaces:
            output += "\n  %s - %s" % ( interface.id, interface.name)
            output += "- %s" % repr(interface.scens)
        

    


    output2 += "\n\nProject %s-%s" % (proj, projname)
    for fldr in fldrs:
        for package in fldr.packages:
           if len(package.scens) > 0:
               for scen in package.scens:
                   output2 += "\n%s/%s/%s - %s" % (projname, fldr.name, package.name, scen.name)
                   
        for treatment in fldr.treatments:
           if len(treatment.scens) > 0:
               for scen in treatment.scens:
                   output2 += "\n%s/%s/%s - %s" % (projname, fldr.name, treatment.name, scen.name)
                   
        for interface in fldr.interfaces:
           if len(interface.scens) > 0:
               for scen in interface.scens:
                   output2 += "\n%s/%s/%s - %s" % (projname, fldr.name, interface.name, scen.name)


open("sys2wkhier.txt", "w").write(output)
                   
open("sys2wkhier2.txt", "w").write(output2)