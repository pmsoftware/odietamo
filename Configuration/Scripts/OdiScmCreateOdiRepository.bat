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

if "%ARGV1%" == "" (
	echo %EM% master/work repository ID must be specified
	echo %IM% usage: %PROC% ^<master/work repository ID^>
	goto ExitFail
)

REM
REM Check basic environment requirements.
REM
if "%ODI_SCM_HOME%" == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_HOME is not set
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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" %ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat %TEMPJARFILE%
if ERRORLEVEL 1 (
	echo %EM% creating ODI class path helper JAR file
	goto ExitFail
)

set ODI_SCM_CLASS_PATH=%ODI_SCM_CLASS_PATH%;%TEMPJARFILE%

rem
rem We use the CLASSPATH environment variable just for a change!
rem
echo %IM% using class path of ^<%ODI_SCM_CLASS_PATH%^>
set CLASSPATH=%ODI_SCM_CLASS_PATH%

echo %IM% running command ^<"%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" odietamo.OdiScm.CreateRepository %ODI_SCM_ORACLEDI_USER% %ODI_SCM_ORACLEDI_PASS% %ODI_SCM_ORACLEDI_SECU_URL% %ODI_SCM_ORACLEDI_SECU_DRIVER% %ODI_SCM_ORACLEDI_SECU_USER% %ODI_SCM_ORACLEDI_SECU_PASS% %ARGV1% %ODI_SCM_ORACLEDI_SECU_WORK_REP% %ODI_SCM_ORACLEDI_ADMIN_USER% %ODI_SCM_ORACLEDI_ADMIN_PASS%^>

"%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" odietamo.OdiScm.CreateRepository %ODI_SCM_ORACLEDI_USER% %ODI_SCM_ORACLEDI_PASS% %ODI_SCM_ORACLEDI_SECU_URL% %ODI_SCM_ORACLEDI_SECU_DRIVER% %ODI_SCM_ORACLEDI_SECU_USER% %ODI_SCM_ORACLEDI_SECU_PASS% %ARGV1% %ODI_SCM_ORACLEDI_SECU_WORK_REP% %ODI_SCM_ORACLEDI_ADMIN_USER% %ODI_SCM_ORACLEDI_ADMIN_PASS%
if ERRORLEVEL 1 (
	echo %EM% creating Master/Work repository
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1