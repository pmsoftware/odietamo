@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% output file path/name not specified 1>&2
	echo %EM% usage: %PROC% ^<output file^> 1>&2
	goto ExitFail
)

set OUTEMPTYFILE=%ARGV1%

type NUL >%OUTEMPTYFILE%
if ERRORLEVEL 1 (
	echo %EM% creating empty file ^<%OUTEMPTYFILE%^>
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1

REM ===============================================
REM ==            S U B R O U T I N E S          ==
REM ===============================================
