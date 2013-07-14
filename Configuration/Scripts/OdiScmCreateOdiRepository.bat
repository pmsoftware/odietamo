@echo off

call :SetMsgPrefixes

echo %IM% starts

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

if "%1" == "" (
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

if "%ODI_HOME%" == "" (
	echo %EM% environment variable ODI_HOME is not set
	goto ExitFail
)

if "%ODI_JAVA_HOME%" == "" (
	echo %EM% environment variable ODI_JAVA_HOME is not set
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

echo %IM% running command ^<"%ODI_JAVA_HOME%\bin\java.exe" odietamo.OdiScm.CreateRepository %ODI_USER% %ODI_PASS% %ODI_SECU_URL% %ODI_SECU_DRIVER% %ODI_SECU_USER% %ODI_SECU_PASS% %1 %ODI_SECU_WORK_REP% %ODI_ADMIN_USER% %ODI_ADMIN_PASS%^>

"%ODI_JAVA_HOME%\bin\java.exe" odietamo.OdiScm.CreateRepository %ODI_USER% %ODI_PASS% %ODI_SECU_URL% %ODI_SECU_DRIVER% %ODI_SECU_USER% %ODI_SECU_PASS% %1 %ODI_SECU_WORK_REP% %ODI_ADMIN_USER% %ODI_ADMIN_PASS%
if ERRORLEVEL 1 (
	echo %EM% creating Master/Work repository
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

rem *************************************************************
:SetMsgPrefixes
rem *************************************************************
set PROC=OdiScmCreateOdiRepository
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:
set DEBUG=%PROC%: DEBUG:
goto :eof