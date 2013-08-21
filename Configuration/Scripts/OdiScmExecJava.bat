@echo off

rem
rem Execute an OdiScm Java binary.
rem

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

if "%ARGC%" == "0" (
	echo %IM% usage: %PROC% ^<Java class^> [^<command arguments^>]
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_JAVA_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_JAVA_HOME is not set
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^>
	goto ExitFail
)

set TEMPJARFILE=%TEMPDIR%\%PROC%.jar

setlocal enabledelayedexpansion

set ODI_SCM_CLASS_PATH=%ODI_SCM_HOME%\Configuration\bin\OdiScm.jar

rem
rem We use the CLASSPATH environment variable just for a change!
rem
echo %IM% using class path of ^<%ODI_SCM_CLASS_PATH%^>
set CLASSPATH=%ODI_SCM_CLASS_PATH%;%CLASSPATH%

echo %IM% running command ^<"%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" %*^>

"%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" %*%
if ERRORLEVEL 1 (
	echo %EM% executing OdiScm Java binary
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1