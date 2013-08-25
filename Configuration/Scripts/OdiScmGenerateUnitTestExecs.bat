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

if not "%ARGC%" == "1" (
	echo %EM% usage: %PROC% ^<output batch file path and name^> 1>&2
	goto ExitFail
)

rem
rem Ensure that we have a working directory available for the PoSh routine.
rem
if "%TEMPDIR%" == "" (
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
	if ERRORLEVEL 1 (
		echo %EM% creating temporary working directory ^<%TEMPDIR%^> 1>&2
		goto ExitFail
	)
)

PowerShell -Command "& { %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenerateUnitTestExecs.ps1 %ARGV1%; exit $LASTEXITCODE }"
if ERRORLEVEL 1 (
	echo %EM% generating unit test execution script
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends
exit %IsBatchExit% 1