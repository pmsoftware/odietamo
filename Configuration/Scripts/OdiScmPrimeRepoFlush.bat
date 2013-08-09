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

set PRIMEMASTERFLUSH=
set PRIMEWORKFLUSH=

if not "%ARGC%" == "1" (
	echo %EM% invalid number of arguments
	call :ShowUsage
	goto ExitFail
)

if /i "%ARGV1%" == "both" (
	set PRIMEMASTERFLUSH=TRUE
	set PRIMEWORKFLUSH=TRUE
	goto ArgsOk
)

if /i "%ARGV1%" == "master" (
	set PRIMEMASTERFLUSH=TRUE
	goto ArgsOk
)

if /i "%ARGV1%" == "work" (
	set PRIMEWORKFLUSH=TRUE
	goto ArgsOk
)

echo %EM% invalid argument ^<%ARGV1%^>
call :ShowUsage
goto ExitFail

:ArgsOk
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	set %EM% defining temporary working directory
	goto ExitFail
)

setlocal enabledelayedexpansion

if DEFINED PRIMEMASTERFLUSH (
	set MSG=priming Master repository flush control metadata
	echo %IM% !MSG!
	call :PrimeExportControl Master %DiscardStdOut%
	if ERRORLEVEL 1 (
		echo %EM% %MSG% 1>&2
		goto ExitFail
	)
)

if DEFINED PRIMEWORKFLUSH (
	set MSG=priming Work repository flush control metadata
	echo %IM% !MSG!
	call :PrimeExportControl Work %DiscardStdOut%
	if ERRORLEVEL 1 (
		echo %EM% %MSG% 1>&2
		goto ExitFail
	)
)

echo %IM% priming of ODI-SCM ODI repository flush metadata completed successfully
echo %IM% ends

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

rem *************************************************************
:PrimeExportControl
rem *************************************************************
set REPOTYPE=%1
set TEMPFILE=%TEMPDIR%\OdiScmPrimeExportNow%REPOTYPE%_%ODI_SCM_ORACLEDI_USER%.sql

cat "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmPrimeExportNow%REPOTYPE%.sql" | sed s/"<OdiScmUserName>"/%ODI_SCM_ORACLEDI_USER%/g > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% generating creating temporary script ^<%TEMPFILE%^> to prime export mechanism
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat^" /p %TEMPFILE%
if ERRORLEVEL 1 (
	echo %EM% priming ODI-SCM export metadata for ^<%REPOTYPE%^> Repository
	exit /b 1
)

exit /b 0

rem *************************************************************
:ShowUsage
rem *************************************************************
echo %IM% usage: %PROC% ^<master ^| work ^| both^>

exit /b 0