@echo off
setlocal
REM
REM Execute a SQL script against the passed data server.
REM

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

echo %IM% UserName is ^<%ARGV1%^>
echo %IM% PassWord is ^<%ARGV2%^>
echo %IM% Driver is ^<%ARGV3%^>
echo %IM% Url is ^<%ARGV4%^>
echo %IM% Script is ^<%ARGV5%^>
echo %IM% Class Path Base is ^<%ARGV6%^>
echo %IM% StdOutFile is ^<%ARGV7%^>
echo %IM% StdErrFile is ^<%ARGV8%^>

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

if "%ARGV7%"=="" (
	echo %IM% No StdOut file specified
	set STDOUTFILE=
	set STDOUTREDIR=
) else (
	echo %IM% StdOut file specified is ^<%ARGV7%^>
	set STDOUTFILE=%ARGV7%
	set STDOUTREDIR=1^>!STDOUTFILE!
	set STDOUTREDIRDISP=1^^^>!STDOUTFILE!
)

if "%ARGV8%"=="" (
	echo %IM% No StdErr file specified
	set STDERRFILE=
	set STDERRREDIR=
) else (
	echo %IM% StdErr file specified is ^<%ARGV8%^>
	set STDERRFILE=%ARGV8%
	set STDERRREDIR=2^>%!STDERRFILE!
	set STDERRREDIRDISP=2^^^>!STDERRFILE!
)

:RunIt
if "%ODI_SCM_TOOLS_JISQL_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_TOOLS_JISQL_HOME is not set
	goto ExitFail
)

if "%ODI_SCM_TOOLS_JISQL_JAVA_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_TOOLS_JISQL_JAVA_HOME is not set
	goto ExitFail
)

echo %IM% using ODI_SCM_TOOLS_JISQL_JAVA_HOME ^<%ODI_SCM_TOOLS_JISQL_JAVA_HOME%^>
set JISQL_LIB=%ODI_SCM_TOOLS_JISQL_HOME%\lib

REM
REM Build the class path.
REM
set JISQL_CLASS_PATH=

if not "%ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH%" == "" (
	echo %IM% using additional class path from environment variable ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH
	set JISQL_CLASS_PATH=%ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH%
) else (
	echo %IM% no additional class path specified in environment variable ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH
)

echo %IM% adding files from Jisql lib directory ^<%JISQL_LIB%^> to class path
for /f %%f in ('dir /b %JISQL_LIB%') do (
	echo %IM% adding file ^<%%f^>
	if "!JISQL_CLASS_PATH!" == "" (
		set JISQL_CLASS_PATH=%JISQL_LIB%\%%f
	) else (
		set JISQL_CLASS_PATH=%JISQL_LIB%\%%f;!JISQL_CLASS_PATH!
	)
)

rem
rem Clear Java options environment variables as their presence gets reported to stderr.
rem
set JAVA_TOOL_OPTIONS=
set _JAVA_OPTIONS=

rem echo %IM% Jisql class path ^<%JISQL_CLASS_PATH%^>
echo %IM% executing command ^<"%ODI_SCM_TOOLS_JISQL_JAVA_HOME%\bin\java" -classpath %JISQL_CLASS_PATH%;%ARGV6% com.xigole.util.sql.Jisql -user %ARGV1% -pass %ARGV2% -driver %ARGV3% -cstring %ARGV4% -c / -formatter default -delimiter=" " -noheader -trim -input %ARGV5% 1^>%STDOUTWORKFILE% 2^>%STDERRWORKFILE%^>

"%ODI_SCM_TOOLS_JISQL_JAVA_HOME%\bin\java" -classpath %JISQL_CLASS_PATH%;%ARGV6% com.xigole.util.sql.Jisql -user %ARGV1% -pass %ARGV2% -driver %ARGV3% -cstring %ARGV4% -c / -formatter default -delimiter=" " -noheader -trim -input %ARGV5% 1>%STDOUTWORKFILE% 2>%STDERRWORKFILE%

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
	echo %EM% executing SQL script ^<%ARGV5%^>
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