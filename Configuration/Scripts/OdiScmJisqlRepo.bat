@echo off
setlocal
REM
REM Execute a SQL script against the ODI repository.
REM
set FN=OdiScmJisqlRepo
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

set ISBATCHEXIT=

if "%1" == "/b" goto IsBatchExit
if "%1" == "/B" goto IsBatchExit

goto IsNotBatchExit

:IsBatchExit
set ISBATCHEXIT=/b
shift

:IsNotBatchExit
if "%ODI_SCM_HOME%" == "" goto NoOdiScmHomeError
echo %IM% using ODI_SCM_HOME directory ^<%ODI_SCM_HOME%^>
goto OdiScmHomeOk

:NoOdiScmHomeError
echo %EM% environment variable ODI_SCM_HOME is not set
goto ExitFail

:OdiScmHomeOk
if EXIST "%1" goto ScriptExists
echo %EM% cannot access script file ^<%1^>
goto ExitFail

:ScriptExists
set SCRIPTFILE=%1

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^>
	goto ExitFail
)

set TEMPJARFILE=%TEMPDIR%\%PROC%.jar

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" %ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat %TEMPJARFILE%
if ERRORLEVEL 1 (
	echo %EM% creating ODI class path helper JAR file
	goto ExitFail
)

rem
rem Run the script file. Pass through any StdOut and StdErr capture file paths/names.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat" %ODI_SECU_USER% %ODI_SECU_PASS% %ODI_SECU_DRIVER% %ODI_SECU_URL% %SCRIPTFILE% %TEMPJARFILE% %2 %3
if ERRORLEVEL 1 goto RunScriptFail
goto RunScriptOk

:RunScriptFail
echo %EM% executing script file ^<%SCRIPTFILE%^>
goto ExitFail

:RunScriptOk

:ExitOk
exit %ISBATCHEXIT% 0

:ExitFail
exit %ISBATCHEXIT% 1
