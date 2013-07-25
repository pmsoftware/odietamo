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

rem
rem Source the working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%PROC%.txt
type "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.sql" | sed s/"<OdiSecuUser>"/%ODI_SECU_USER%/g >%TEMPFILE%
if ERRORLEVEL 1 (
	echo %EM% creating database user deletion script 1>&2
	goto ExitFail
)

set PODI_SECU_USER=%ODI_SECU_USER%
set PODI_SECU_PASS=%ODI_SECU_PASS%

set ODI_SECU_USER=%ODI_ADMIN_USER%
set ODI_SECU_PASS=%ODI_ADMIN_PASS%

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" /p %TEMPFILE%
if ERRORLEVEL 1 (
	echo %EM% dropping repository database user
	goto ExitFail
)

rem
rem Restore variable values in case this script was CALLed directly (instead of forked).
rem
set ODI_SECU_USER=%PODI_SECU_USER%
set ODI_SECU_PASS=%PODI_SECU_PASS%

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1