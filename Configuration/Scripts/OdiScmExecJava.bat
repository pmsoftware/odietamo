@echo off
echo running with args: %*

rem
rem Execute an OdiScm Java binary.
rem

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

if "%ARGC%" == "0" (
	echo %EM% usage: %PROC% ^<Java class^> ^[^<command arguments^>^] 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_JAVA_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_JAVA_HOME is not set 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

set TEMPJARFILE=%TEMPDIR%\%PROC%.jar

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat^" /p %TEMPJARFILE% >NUL
if ERRORLEVEL 1 (
	echo %EM% creating temporary class path JAR file ^<%TEMPJARFILE%^> 1>&2
	goto ExitFail
)

set ODI_SCM_CLASS_PATH=%ODI_SCM_HOME%\Configuration\bin\OdiScm.jar;%TEMPJARFILE%

rem
rem We use the CLASSPATH environment variable just for a change!
rem
echo %IM% using class path of ^<%ODI_SCM_CLASS_PATH%^>
set CLASSPATH=%ODI_SCM_CLASS_PATH%;%CLASSPATH%

echo %IM% running command ^<"%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" %ARGVALL%^>

"%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" %ARGVALL%
if ERRORLEVEL 1 (
	echo %EM% executing OdiScm Java binary 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% starts
exit %IsBatchExit% 1