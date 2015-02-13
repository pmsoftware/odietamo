@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME
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
	echo %EM% missing Session name argument 1>&2
	call :ShowUsage
	goto ExitFail
)

set LASTARG=1
set OTHERARGS=%ARGVALL%

echo %IM% using execution context ^<%ODI_SCM_TEST_ORACLEDI_CONTEXT%^> from environment
set EXECONTEXT=%ODI_SCM_TEST_ORACLEDI_CONTEXT%

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set RESTARTSSSBAT=%TEMPDIR%\%PROC%_RestartSess.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenRestartSess.bat^" /p %RESTARTSESSBAT%
if ERRORLEVEL 1 (
	echo %EM% creating RestartSess batch script file ^<%RESTARTSESSBAT%^> 1>&2
	goto ExitFail
)

set /a ODIFIRSTVAR=%LASTARG% + 1
set OUTSTRING=

setlocal enabledelayedexpansion
set VARORVAL=VAR

for /l %%n in (%ODIFIRSTVAR%, 1, %ARGC%) do (
	set VARNAME=ARGV%%n
	if "!OUTSTRING!" == "" (
		set OUTSTRING="
	) else (
		set OUTSTRING=!OUTSTRING! "
	)
	call :AppendStringDynamic !VARNAME!
	set OUTSTRING=!OUTSTRING!"
)

set ODIVARVALS=%OUTSTRING%

echo %DM% using RestartSess script of %RESTARTSESSBAT%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%RESTARTSESSBAT%" "%ARGV1%" "%ARGV2%" "%ARGV3%" "%ARGV4%" "%ARGV5%" "%ARGV6%" "%ARGV7%" "%ARGV8%" "%ARGV9%"
if ERRORLEVEL 1 (
	echo %EM% restarting ODI Session ^<%ARGV1%^> 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1

rem ===============================================
rem ==           S U B R O U T I N E S           ==
rem ===============================================

rem -----------------------------------------------
:ShowUsage
rem -----------------------------------------------
echo %EM% usage: %PROC% ^<ODI Scenario Name^>  [^<ODI Execution Context^>] [^<ODI Scenario Version^>] [[^<ODI Variable Assignment 1^>]...[^<ODI Variable Assignment N>]] 1>&2
echo %EM%      : default ODI Execution Context is value of environment variable ODI_SCM_TEST_ORACLEDI_CONTEXT 1>&2
echo %EM%      : default ODI Scenario Version is -1 1>&2
echo %EM%      : NOTE: variable assignments are specified as VAR=VAL and must be enclosed in double quotes 1>&2
goto :eof

rem -----------------------------------------------
:AppendStringDynamic
rem -----------------------------------------------
set VARNAME=%1
set VARVAL=%%%VARNAME%%%
call set OUTSTRING=%OUTSTRING%%VARVAL%
goto :eof