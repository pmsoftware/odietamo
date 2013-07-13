@echo off
setlocal
REM
REM Execute a SQL script against the passed data server.
REM
set FN=OdiScmJisql
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

echo %IM% starts

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

echo %IM% UserName is ^<%1^>
echo %IM% PassWord is ^<%2^>
echo %IM% Driver is ^<%3^>
echo %IM% Url is ^<%4^>
echo %IM% Script is ^<%5^>
echo %IM% StdOutFile is ^<%6^>
echo %IM% StdErrFile is ^<%7^>

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating working directory ^<%TEMPDIR%^>
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEmptyFile.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary empty file ^<%EMPTYFILE%^>
	goto ExitFail
)

set RANDSTR=%RANDOM%
set STDOUTWORKFILE=%TEMPDIR%\OdiScmJisql_StdOut_%RANDSTR%.txt
set STDERRWORKFILE=%TEMPDIR%\OdiScmJisql_StdErr_%RANDSTR%.txt

setlocal enabledelayedexpansion

if "%6"=="" (
	echo %IM% No StdOut file specified
	set STDOUTFILE=
	set STDOUTREDIR=
) else (
	echo %IM% StdOut file specified is ^<%6^>
	set STDOUTFILE=%6
	set STDOUTREDIR=1^>!STDOUTFILE!
	set STDOUTREDIRDISP=1^^^>!STDOUTFILE!
)

if "%7"=="" (
	echo %IM% No StdErr file specified
	set STDERRFILE=
	set STDERRREDIR=
) else (
	echo %IM% StdErr file specified is ^<%7^>
	set STDERRFILE=%7
	set STDERRREDIR=2^>%!STDERRFILE!
	set STDERRREDIRDISP=2^^^>!STDERRFILE!
)

:RunIt
if "%ODI_SCM_JISQL_JAVA_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_JISQL_JAVA_HOME is not set
	goto ExitFail
) else (
	echo %IM% using ODI_SCM_JISQL_JAVA_HOME ^<%ODI_SCM_JISQL_JAVA_HOME%^>
)

if "%ODI_HOME%" == "" (
	echo %EM% environment variable ODI_HOME is not set
	goto ExitFail
)

if "%ODI_SCM_JISQL_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_JISQL_HOME is not set
	goto ExitFail
)

rem set PATH="%JAVA_HOME%\bin";%PATH%
set JISQL_LIB=%ODI_SCM_JISQL_HOME%\lib

REM
REM Build the class path.
REM
set JISQL_CLASS_PATH=

if not "%ODI_SCM_JISQL_ADDITIONAL_CLASSPATH%" == "" (
	echo %IM% using additional class path from environment variable ODI_SCM_JISQL_ADDITIONAL_CLASSPATH
	set JISQL_CLASS_PATH=%ODI_SCM_JISQL_ADDITIONAL_CLASSPATH%
) else (
	echo %IM% no additional class path specified in environment variable ODI_SCM_JISQL_ADDITIONAL_CLASSPATH
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

REM echo %IM% adding files from Jisql lib directory ^<%JISQL_LIB%^> to class path
for /f %%f in ('dir /b %JISQL_LIB%') do (
	REM echo %IM% adding file ^<%%f^>
	if "!JISQL_CLASS_PATH!" == "" (
		set JISQL_CLASS_PATH=%JISQL_LIB%\%%f
	) else (
		set JISQL_CLASS_PATH=%JISQL_LIB%\%%f;!JISQL_CLASS_PATH!
	)
)

REM echo %IM% Jisql class path ^<%JISQL_CLASS_PATH%^>
echo %IM% executing command ^<"%ODI_SCM_JISQL_JAVA_HOME%\bin\java" -classpath %JISQL_CLASS_PATH% com.xigole.util.sql.Jisql -user %1 -pass %2 -driver %3 -cstring %4 -c / -formatter default -delimiter=" " -noheader -trim -input %5 1^>%STDOUTWORKFILE% 2^>%STDERRWORKFILE%^>

"%ODI_SCM_JISQL_JAVA_HOME%\bin\java" -classpath %JISQL_CLASS_PATH% com.xigole.util.sql.Jisql -user %1 -pass %2 -driver %3 -cstring %4 -c / -formatter default -delimiter=" " -noheader -trim -input %5 1>%STDOUTWORKFILE% 2>%STDERRWORKFILE%
set EXITSTATUS=%ERRORLEVEL%

if "%STDOUTFILE%" == "" (
	type "%STDOUTWORKFILE%"
) else (
	type "%STDOUTWORKFILE%" > "%STDOUTFILE%"
)

if "%STDERRFILE%" == "" (
	type "%STDERRWORKFILE%" 1>&2
) else (
	type "%STDERRWORKFILE%" > "%STDERRFILE%"
)

if not "%EXITSTATUS%" == "0" (
	echo %EM% executing SQL script ^<%5^>
	goto ExitFail
)

fc "%EMPTYFILE%" "%STDERRWORKFILE%" >NUL
if ERRORLEVEL 1 (
	echo %EM% Jisql command returned stderr text
	goto ExitFail
)

exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1