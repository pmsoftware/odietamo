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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

rem
rem Create a StartCmd.bat for the current environment.
rem
set TEMPSTARTCMD=%TEMPDIR%\%RANDOM%_%PROC%_StartCmd.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat^" /p %TEMPSTARTCMD% %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating StartCmd wrapper script 1>&2
	goto ExitFail
)

echo %IM% executing command ^<call ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat^" ^^^"%TEMPSTARTCMD%^^^" OdiStartScen -SCEN_NAME=OSFLUSH_REPOSITORY -SCEN_VERSION=-1 -CONTEXT=GLOBAL^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiStartScen -SCEN_NAME=OSFLUSH_REPOSITORY -SCEN_VERSION=-1 -CONTEXT=GLOBAL %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% executing repository flush process 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% repository flush completed successfully 
exit %IsBatchExit% 0

:ExitFail
echo %EM% repository flush failed
exit %IsBatchExit% 1