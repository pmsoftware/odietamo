@echo off
setlocal
REM
REM Execute a SQL script against the ODI repository.
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

if EXIST "%ARGV1%" goto ScriptExists
echo %EM% cannot access script file ^<%ARGV1%^>
goto ExitFail

:ScriptExists
set SCRIPTFILE=%ARGV1%

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^>
	goto ExitFail
)

set TEMPJARFILE=%TEMPDIR%\%PROC%.jar

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat^" /p %TEMPJARFILE%
if ERRORLEVEL 1 (
	echo %EM% creating ODI class path helper JAR file
	goto ExitFail
)

rem
rem Run the script file. Pass through any StdOut and StdErr capture file paths/names.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat^" /p %ODI_SECU_USER% %ODI_SECU_PASS% %ODI_SECU_DRIVER% %ODI_SECU_URL% %SCRIPTFILE% %TEMPJARFILE% %ARGV2% %ARGV3%
if ERRORLEVEL 1 goto RunScriptFail
goto RunScriptOk

:RunScriptFail
echo %EM% executing script file ^<%SCRIPTFILE%^>
goto ExitFail

:RunScriptOk

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1