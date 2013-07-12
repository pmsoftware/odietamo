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

setlocal enabledelayedexpansion

set ODI_SCM_CLASS_PATH=%ODI_SCM_HOME%\Configuration\Bin\OdiScm.jar

echo %IM% adding files from OracleDI drivers directory ^<%ODI_HOME%\drivers^> to class path
for /f %%f in ('dir /b %ODI_HOME%\drivers') do (
	REM echo %IM% adding file ^<%%f^>
	set ODI_SCM_CLASS_PATH=%ODI_HOME%\drivers\%%f;!ODI_SCM_CLASS_PATH!
)

if not "%ODI_COMMON%" == "" (
	echo %IM% adding OracleDI common directory ^<%ODI_COMMON%\odi^> to class path
	set ODI_SCM_CLASS_PATH=%ODI_COMMON%\odi;!ODI_SCM_CLASS_PATH!
	echo %IM% adding files from OracleDI common lib directory ^<%ODI_COMMON%\odi^> to class path
	for /f %%f in ('dir /b /s %ODI_COMMON%\odi\*.jar') do (
		echo %IM% adding file ^<%%f^>
		set ODI_SCM_CLASS_PATH=%%f;!ODI_SCM_CLASS_PATH!
	)
)

if not "%ODI_SDK%" == "" (
	echo %IM% adding files from OracleDI SDK lib directory ^<%ODI_SDK%^> to class path
	for /f %%f in ('dir /b /s %ODI_SDK%\lib\odi*.jar') do (
		echo %IM% adding file ^<%%f^>
		set ODI_SCM_CLASS_PATH=%%f;!ODI_SCM_CLASS_PATH!
	)
	for /f %%f in ('dir /b /s %ODI_SDK%\spring*.jar') do (
		echo %IM% adding file ^<%%f^>
		set ODI_SCM_CLASS_PATH=%%f;!ODI_SCM_CLASS_PATH!
	)
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\SchemaVersion.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\commons-lang-2.2.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\commons-logging-1.1.1.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\bsf.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\bsh-2.0b2.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\javolution.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\eclipselink.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\oracle.ucp_11.1.0.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\commons-collections-3.2.jar;!ODI_SCM_CLASS_PATH!
	set ODI_SCM_CLASS_PATH=%ODI_SDK%\lib\persistence.jar;!ODI_SCM_CLASS_PATH!
)

echo %IM% using class path of ^<%ODI_SCM_CLASS_PATH%^>
set CLASSPATH=%ODI_SCM_CLASS_PATH%
echo %CLASSPATH%>c:\temp\classpath.txt

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