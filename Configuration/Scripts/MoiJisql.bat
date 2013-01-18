@echo off
setlocal

set IM=MoiJisql: INFO:
set EM=MoiJisql: ERROR:

echo %IM% UserName is ^<%1^>
echo %IM% PassWord is ^<%2
echo %IM% Driver is ^<%3^>
echo %IM% Url is ^<%4^>
echo %IM% Script is ^<%5^>
echo %IM% StdOutFile is ^<%6^>
echo %IM% StdErrFile is ^<%7^>

if not "%6"=="" goto StdOutPassed

echo %IM% No StdOut file specified
set STDOUTFILE=CON
goto StdErr

:StdOutPassed
echo %IM% StdOut file specified is ^<%6^>
set STDOUTFILE=%6

:StdErr
if not "%7"=="" goto StdErrPassed

echo %IM% No StdErr file specified
set STDERRFILE=CON
goto RunIt

:StdErrPassed
echo %IM% StdErr file specified is ^<%7^>
set STDERRFILE=%7

:RunIt

set JAVA_HOME=C:\MOI\Configuration\Tools\Java\jdk1.6.0_29
set PATH=%JAVA_HOME%\bin;%PATH%

set JISQL_HOME=C:/MOI/Configuration/Tools/jisql
set JISQL_LIB=%JISQL_HOME%/lib

echo %IM% executing command ^<java -classpath %JISQL_LIB%/jisql.jar;%JISQL_LIB%/jopt-simple-3.2.jar;%JISQL_LIB%/javacsv.jar;C:/MOI/Configuration/Tools/odi/drivers/ojdbc5.zip;C:/MOI/Configuration/Tools/odi/drivers/classes12.zip com.xigole.util.sql.Jisql -user %1 -pass %2 -driver %3 -cstring %4 -c / -formatter default -delimiter=" " -noheader -trim -input %5^>
java -classpath %JISQL_LIB%/jisql.jar;%JISQL_LIB%/jopt-simple-3.2.jar;%JISQL_LIB%/javacsv.jar;C:/MOI/Configuration/Tools/odi/drivers/ojdbc5.zip;C:/MOI/Configuration/Tools/odi/drivers/classes12.zip com.xigole.util.sql.Jisql -user %1 -pass %2 -driver %3 -cstring %4 -c / -formatter default -delimiter=" " -noheader -trim -input %5 >%STDOUTFILE% 2>%STDERRFILE%