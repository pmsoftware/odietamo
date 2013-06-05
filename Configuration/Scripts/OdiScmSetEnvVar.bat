@echo off
REM ===============================================
REM Set an environment variable for the OdiScm configuration
REM that will be used by the system.
REM
REM Note that for this script to have any useful effect it must be
REM executed with CALL and passed the /B switch.
REM ===============================================
set FN=OdiScmSetEnvVar
set IM=%FN%: INFO:
set EM=%FN%: ERROR:
set WM=%FN%: WARNING:

REM
REM BEWARE of SETLOCAL. We need to ensure that variable value assignments survive the exit from this script
REM for them to be useful.
REM

REM
REM Determine how to exit the script.
REM
if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

REM ===============================================
REM Verify parameter arguments specified.
REM ===============================================
if "%1" == "" (
	echo %EM% no configuration INI file section specified
	call :ShowUsage
	goto ExitFail
)

set PINISECTION=%1

if "%2" == "" (
	echo %EM% no configuration INI file key specified
	call :ShowUsage
	goto ExitFail
)

set PINIKEY=%2

if "%3" == "" (
	echo %EM% no envrionemnt variable name specified
	call :ShowUsage
	goto ExitFail
)

set PENVVAR=%3

REM ===============================================
REM Verify minimum requirements - ODI_SCM_HOME must be defined.
REM ===============================================
if "%ODI_SCM_HOME%" == "" (
	echo %EM% OdiScm home directory environment variable ODI_SCM_HOME is not set
	goto ExitFail
)

REM ===============================================
REM Verify minimum requirements - ODI_SCM_INI must be defined.
REM ===============================================
if "%ODI_SCM_INI%" == "" (
	echo %EM% OdiScm configuration INI file environment variable ODI_SCM_INI is not set
	goto ExitFail
)

REM ===============================================
REM Check presence of dependencies.
REM ===============================================
sed --help >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% command ^<sed^> not available
	echo %EM% check UNXUTILS are installed and are included in the system command PATH
	goto ExitFail
)

REM
REM Define a temporary work directory.
REM
if "%TEMP%" == "" goto NoTempDir
set TEMPDIR=%TEMP%
goto GotTempDir

:NoTempDir
if "%TMP%" == "" goto NoTmpDir
set TEMPDIR=%TMP%
goto GotTempDir

:NoTmpDir
set TEMPDIR=%CD%

:GotTempDir
REM
REM Define a temporary work file.
REM
set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmSetEnv.txt

REM ===============================================
REM Set the environment from the INI file.
REM ===============================================
call :SetConfig %PINISECTION% %PINIKEY% %PENVVAR%
if ERRORLEVEL 1 (
	echo %EM% setting environment variable ^<%PENVVAR%^>
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1

REM ===============================================
REM S U B R O U T I N E S
REM ===============================================

:SetConfig
REM ===============================================
REM Set an environment variable from a configuration file key.
REM ===============================================
echo %IM% processing configuration section ^<%1^> key ^<%2^>

set ENVVARVAL=
type NUL >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% initialising temporary working file ^<%TEMPFILE%^>
	goto SetConfigExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat" %1 %2 >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<%1^> key ^<%2^>
	goto SetConfigExitFail
)
set /p ENVVARVAL=<"%TEMPFILE%"
echo %IM% setting environment variable ^<%3^> to value ^<%ENVVARVAL%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set SetEnvVarCmd=set "%3=%ENVVARVAL%"

%SetEnvVarCmd%
if ERRORLEVEL 1 (
	echo %EM% cannot set value for environment variable ^<%3^>
	goto SetConfigExitFail
)

exit /b 0
:SetConfigExitFail
exit /b 1