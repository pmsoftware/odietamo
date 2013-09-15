@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

rem
rem Check parameter arguments.
rem
if "%ARGV1%" == "" (
	echo %EM% no target directory specified 1>&2
	call :ShowUsage
	goto ExitFail
)

if not EXIST "%ARGV1%" (
	echo %EM% specified target directory ^<%ARGV1%^> does not exist 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION%" == "" (
	echo %EM% no OracleDI version specified in environment variable ODI_SCM_ORACLEDI_VERSION 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%%" == "10." (
	rem NoOp.
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		rem NoOp.
	) else (
		echo %EM% invalid OracleDI version specified. Specify either 10.w.x.y.z or 11.w.x.y.z 1>&2
		goto ExitFail
	)
)

rem
rem Ensure we can identify the demo repository installation files.
rem
echo %IM% checking demo installation
if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	if not EXIST "%ODI_SCM_ORACLEDI_HOME%\bin\startdemo.bat" (
		echo %EM% startdemo.bat script not found in ODI bin directory ^<%ODI_SCM_ORACLEDI_HOME%\bin^> 1>&2
		goto ExitFail
	)
	if not EXIST "%ODI_SCM_ORACLEDI_HOME%\bin\stopdemo.bat" (
		echo %EM% stopdemo.bat script not found in ODI bin directory ^<%ODI_SCM_ORACLEDI_HOME%\bin^> 1>&2
		goto ExitFail
	)
	set ODI_DEMO_HOME=%ODI_SCM_ORACLEDI_HOME%\demo
	set ODI_DEMO_BIN=%ODI_SCM_ORACLEDI_HOME%\bin
) else (
	if not EXIST "%ODI_SCM_ORACLEDI_ORACLE_HOME%\oracledi\demo\bin\startdemo.bat" (
		echo %EM% startdemo.bat script not found in ODI demo bin directory ^<%ODI_SCM_ORACLEDI_ORACLE_HOME%\oracledi\demo\bin^> 1>&2
		goto ExitFail
	)
	if not EXIST "%ODI_SCM_ORACLEDI_ORACLE_HOME%\oracledi\demo\bin\stopdemo.bat" (
		echo %EM% stopdemo.bat script not found in ODI demo bin directory ^<%ODI_SCM_ORACLEDI_ORACLE_HOME%\oracledi\demo\bin^> 1>&2
		goto ExitFail
	)
	set ODI_DEMO_HOME=%ODI_SCM_ORACLEDI_ORACLE_HOME%\oracledi\demo
	set ODI_DEMO_BIN=!ODI_DEMO_HOME!\bin
)

rem
rem Copy the HSQL database files.
rem
copy "%ODI_DEMO_HOME%\hsql\*.*" "%ARGV1%" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying demo HSQL database files 1>&2
	goto ExitFail
)

rem
rem Clear up any HSQL server.properties file.
rem
if EXIST "%ARGV1%\server.properties" (
	del /f "%ARGV1%\server.properties"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing HSQL server properties file ^<%ARGV1%\server.properties^> 1>&2
		goto ExitFail
	)
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1

:ShowUsage
echo %EM% usage: %PROC% ^<target directory^> 1>&2
exit /b