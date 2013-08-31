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
	echo %EM% missing Scenario name argument 1>&2
	call :ShowUsage
	goto ExitFail
)

set LASTARG=1
set OTHERARGS=%ARGVALL%

if not "%ARGV2%" == "" (
	echo %IM% execution context ^<%ARGV2%^> specified to override environment context ^<%ODI_SCM_TEST_ORACLEDI_CONTEXT%^>
	set EXECONTEXT=%ARGV2%
	set LASTARG=2
) else (
	echo %IM% using execution context ^<%ODI_SCM_TEST_ORACLEDI_CONTEXT%^> from environment
	set EXECONTEXT=%ODI_SCM_TEST_ORACLEDI_CONTEXT%
)

if not "%ARGV3%" == "" (
	echo %IM% Scenario version ^<%ARGV3%^> specified to override default of ^<-1^>
	set SCENVER=%ARGV3%
	set LASTARG=3
) else (
	echo %IM% using default Scenario version ^<-1^>
	set SCENVER=-1
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set STARTCMDBAT=%TEMPDIR%\%PROC%_StartCmd.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat^" /p %STARTCMDBAT%
if ERRORLEVEL 1 (
	echo %EM% creating StartCmd batch script file ^<%STARTCMDBAT%^> 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%STARTCMDBAT%^" OdiStartScen -SCEN_NAME=%ARGV1% -SCEN_VERSION=-1 -CONTEXT=%ODI_SCM_TEST_ORACLEDI_CONTEXT%
if ERRORLEVEL 1 (
	echo %EM% executing ODI Scenario ^<%ARGV1%^> in context ^<%ODI_SCM_TEST_ORACLEDI_CONTEXT%^> 1>&2
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
echo %EM% usage: %PROC% ^<ODI Scenario Name^>  [^<ODI Execution Context^>] [^<ODI Scenario Version^>] 1>&2
echo %EM%      : default ODI Execution Context is value of environment variable ODI_SCM_TEST_ORACLEDI_CONTEXT 1>&2
echo %EM%      : default ODI Scenario Version is -1 1>&2