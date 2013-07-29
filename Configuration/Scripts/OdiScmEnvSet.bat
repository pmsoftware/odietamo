@echo off
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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set SETENVSCRIPT=%TEMPDIR%\%PROC%.bat

PowerShell -file "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateSetEnvScript.ps1" "%SETENVSCRIPT%"
if ERRORLEVEL 1 (
	echo %EM% creating temporary script file ^<%SETENVSCRIPT%^> 1>&2
	goto ExitFail
)

call "%SETENVSCRIPT%"
if ERRORLEVEL 1 (
	echo %WM% executing temporary script file ^<%SETENVSCRIPT%^> 1>&2
)

:ExitOk
exit /b 0

:ExitFail
exit /b 1