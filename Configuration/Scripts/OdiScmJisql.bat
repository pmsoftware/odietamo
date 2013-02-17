@echo off
setlocal
REM
REM Execute a SQL script against the passed data server.
REM
set FN=OdiScmJisql
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

echo %IM% starts

echo %IM% UserName is ^<%1^>
echo %IM% PassWord is ^<%2^>
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
if "%JAVA_HOME%" == "" goto NoJavaHomeError
echo %IM% using JAVA_HOME ^<%JAVA_HOME%^>
goto JavaHomeOk

:NoJavaHomeError
echo %EM% environment variable JAVA_HOME is not set
exit /b 1

:JavaHomeOk
if "%ODI_HOME%" == "" goto NoOdiHomeError
goto OdiHomeOk

:NoOdiHomeError
echo %EM% environment variable ODI_HOME is not set
exit /b 1

:OdiHomeOk
set PATH="%JAVA_HOME%\bin";%PATH%
set JISQL_LIB=%ODI_SCM_JISQL_HOME%\lib

REM
REM Build the class path.
REM
REM echo %IM% adding files from Jisql lib directory ^<%JISQL_LIB%^> to class path
set JISQL_CLASS_PATH=
setlocal enabledelayedexpansion
for /f %%f in ('dir /b %JISQL_LIB%') do (
	REM echo %IM% adding file ^<%%f^>
	if "!JISQL_CLASS_PATH!" == "" (
		set JISQL_CLASS_PATH=%JISQL_LIB%\%%f
	) else (
		set JISQL_CLASS_PATH=%JISQL_LIB%\%%f;!JISQL_CLASS_PATH!
	)
)

REM echo %IM% adding files from OracleDI drivers directory ^<%ODI_HOME%	^> to class path

for /f %%f in ('dir /b %ODI_HOME%\drivers') do (
	REM echo %IM% adding file ^<%%f^>
	if "!JISQL_CLASS_PATH!" == "" (
		set JISQL_CLASS_PATH=%ODI_HOME%\drivers\%%f
	) else (
		set JISQL_CLASS_PATH=%ODI_HOME%\drivers\%%f;!JISQL_CLASS_PATH!
	)
)
echo %IM% Jisql class path ^<%JISQL_CLASS_PATH%^>

echo %IM% executing command ^<java -classpath %JISQL_CLASS_PATH% com.xigole.util.sql.Jisql -user %1 -pass %2 -driver %3 -cstring %4 -c / -formatter default -delimiter=" " -noheader -trim -input %5^>
java -classpath %JISQL_CLASS_PATH% com.xigole.util.sql.Jisql -user %1 -pass %2 -driver %3 -cstring %4 -c / -formatter default -delimiter=" " -noheader -trim -input %5 >%STDOUTFILE% 2>%STDERRFILE%