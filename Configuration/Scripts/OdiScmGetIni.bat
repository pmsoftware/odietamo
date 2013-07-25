@echo off
setlocal
REM
REM Get a configuration INI file entry.
REM

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

rem echo %DM% starts >CON

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ODI_SCM_INI%" == "" (
	echo %EM% configuration INI file environment variable ODI_SCM_INI file is not set
	goto ExitFail
)

rem echo %DM% processing section name ^<%ARGV1%^> key name ^<%ARGV2%^> >CON

if "%ARGV1%" == "" (
	echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> 1>&2
	goto ExitFail
)

if "%ARGV2%" == "" (
	echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

REM
REM Check basic environment.
REM
if not EXIST "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIniTemplate.awk" (
	echo %EM% cannot find required OdiScm scripts in directory ^<%ODI_SCM_HOME%\Configuration\Scripts^>
	goto ExitFail
)

REM
REM Create an AWK script to extract the key.
REM
set TEMPSTR=%RANDOM%
set TEMPSCRIPT=%TEMPDIR%\%TEMPSTR%_OdiScmGetIni.awk
set TEMPSTDOUT=%TEMPDIR%\%TEMPSTR%_OdiScmGetIni.stdout

type "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIniTemplate.awk" | sed "s/<SectionName>/%ARGV1%/g" | sed "s/<KeyName>/%ARGV2%/g" > %TEMPSCRIPT%
if ERRORLEVEL 1 (
	echo %EM% creating AWK script
	goto ExitFail
)
rem echo on
rem echo %IM% using generated script file ^<%TEMPSCRIPT%^>
type %ODI_SCM_INI% | gawk -f "%TEMPSCRIPT%"
if ERRORLEVEL 1 (
	echo %EM% executing AWK script
	goto ExitFail
)

:ExitOk
rem echo %DM% exiting successfully >CON
exit %IsBatchExit% 0

:ExitFail
rem echo %DM% exiting with failure >CON
exit %IsBatchExit% 1