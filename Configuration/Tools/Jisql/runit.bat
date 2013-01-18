rem java -classpath lib/jisql.jar;lib/jopt-simple-3.2.jar;lib/javacsv.jar;C:/Oracle/product/10.1.0/Client_1/jdbc/lib/ojdbc14.jar com.xigole.util.sql.Jisql -user scott -password blah -driver oraclethin -cstring jdbc:oracle:thin:@hostname.tld:1521:orasid -c ;


set JAVA_HOME=C:\Program Files\Java\jdk1.6.0_26
set PATH=%JAVA_HOME%\bin
java -classpath lib/jisql.jar;lib/jopt-simple-3.2.jar;lib/javacsv.jar;C:/MOI_06/Configuration/Tools/odi/drivers/ojdbc14.jar com.xigole.util.sql.Jisql -user aoetl -pass a0etl -driver oraclethin -cstring jdbc:oracle:thin:@vhcuddbop02:1526:voidodi3 -c / -formatter default -delimiter="," -noheader -trim -input c:/temp/myplsqlscript.sql