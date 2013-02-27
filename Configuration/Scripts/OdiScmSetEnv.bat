@echo off
REM ===============================================
REM Set environment variables for the OdiScm configuration
REM that will be used by the system.
REM ===============================================
set FN=OdiScmSetEnv
set IM=%FN%: INFO:
set EM=%FN%: ERROR:
set WM=%FN%: WARNING:

REM
REM BEWARE of SETLOCAL. We need to ensure that variable value assignments survive the exit from this script.
REM

set CmdDrivePathFile=%0
rem echo CmdDrivePathFile is %CmdDrivePathFile%
set CmdDrivePath=%~dp0
rem echo CmdDrivePath is %CmdDrivePath%

REM
REM Determine how to exit the script.
REM
if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

REM
REM Check presence of dependencies.
REM
sed --help >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% command ^<sed^> not available. Check system PATH
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

REM
REM Verify else set ODI_SCM_HOME.
REM
if not "%ODI_SCM_HOME%" == "" goto OdiScmHomeSet

echo %WM% OdiScm home directory environment variable ODI_SCM_HOME is not set
echo %WM% setting from this script's command path

REM
REM Derive the directory from the path to this script.
REM NOTE: the configuration INI file is not used to specify a value for ODI_SCM_HOME.
REM
rem echo setting it to %CmdDrivePath%
set OdiScmHome=
rem echo set OdiScmHome=%CmdDrivePath%
rem echo OdiScmHome is %OdiScmHome%
set OdiScmHome=%CmdDrivePath%
rem echo set it to %OdiScmHome%
REM Remove the trailing back slash character.
set OdiScmHome=%OdiScmHome:~0,-1%
rem echo OdiScmHome is then %OdiScmHome%
set ODI_SCM_HOME=%OdiScmHome:\Configuration\Scripts=%
echo %IM% setting ODI_SCM_HOME to ^<%ODI_SCM_HOME%^>

:OdiScmHomeSet

REM ===============================================
REM Verify minimum requirements - ODI_SCM_INI must be defined or there must be
REM a configuration file in the CWD (Current Working Directory).
REM ===============================================
if not "%ODI_SCM_INI%" == "" goto OdiScmIniSet

echo %WM% OdiScm configuration INI file environment variable ODI_SCM_INI is not set
echo %WM% it is highly recommended to set this variable to explicitly set the configuration
if exist ".\OdiScm.ini" goto DeriveOdiScmIni

echo %EM% no configuration INI file ^<OdiScm.ini^> found in current working directory
goto ExitFail

:DeriveOdiScmIni
set ODI_SCM_INI=%CD%\OdiScm.ini
echo %IM% found configuration INI file ^<OdiScm.ini^> in current working directory
echo %IM% setting ODI_SCM_INI to ^<%ODI_SCM_INI%^>

:OdiScmIniSet

REM ===============================================
REM Set the command path if not already set.
REM ===============================================
REM Escape back slash characters for use with sed.
for /f "tokens=*" %%g in ('echo %ODI_SCM_HOME%\Configuration\Scripts ^| sed "s/\\/\\\\/g" ^| sed "s/ //g"') do (
	set OdiScmHomeEscaped=%%g
)
REM Remove spaces in PATH and look for Scripts directory in the path string.
set OdiScmInPath=
for /f "tokens=* eol=# delims=;" %%g in ('echo %PATH% ^| sed "s/ //g" ^| grep -i %OdiScmHomeEscaped%') do (
	set OdiScmInPath=%%g
)
rem echo OdiScmInPath=%OdiScmInPath%

if "%OdiScmInPath%" == "" goto SetOdiScmPath

echo %IM% OdiScm scripts directory ^<%ODI_SCM_HOME%\Configuration\Scripts^> is in the command PATH
goto OdiScmPathSet

:SetOdiScmPath
echo %IM% OdiScm scripts directory is not in the command PATH environment variable
echo %IM% adding directory ^<%ODI_SCM_HOME%\Configuration\Scripts^> to command PATH environment variable
set PATH=%PATH%;%ODI_SCM_HOME%\Configuration\Scripts

:OdiScmPathSet

REM ===============================================
REM Show the configuration from the INI file.
REM ===============================================

set TEMPFILE2=%TEMPDIR%\%RANDOM%_OdiScmSetEnv.txt

REM
REM OdiScm configuration.
REM
echo %IM% looking for section ^<OdiScm^> key ^<ODI_SCM_HOME^> in configuration INI file

echo.>%TEMPFILE% 
if ERRORLEVEL 1 (
	echo %EM% initialising temporary working file ^<%TEMPFILE%^>
	goto ExitFail
)
set ENVVARVAL=
rem echo getting ini to file %TEMPFILE%
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat /b OdiScmx ODI_SCM_HOME >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<OdiScm^> key ^<ODI_SCM_HOME^>
	goto ExitFail
)
rem echo on
rem echo getting val from file %TEMPFILE%
rem echo "file contains >>>"
rem type %TEMPFILE%
rem echo "<<<"
set /p ENVVARVAL=<%TEMPFILE%
rem echo got "%ENVVARVAL%"
if "%ENVVARVAL%" == "" (
	echo %IM% configuration INI file does not contain entry for section ^<OdiScm^> key ^<ODI_SCM_HOME^>
	goto NoOdiScmHomeInIni
)

echo %IM% found section ^<OdiScm^> key ^<ODI_SCM_HOME^> in configuration INI file
echo %IM% setting environment variable ^<ODI_SCM_HOME^> to value 
echo val is "%ENVVARVAL%"
set SetEnvVarCmd=set ODI_SCM_HOME=%ENVVARVAL%
%SetEnvVarCmd%
if ERRORLEVEL 1 (
	echo %EM% cannot set value for environment variable ^<%1^>
	got SetConfigExitFail
)
:NoOdiScmHomeInIni

REM
REM OracleDI configuration.
REM
echo %IM% processing configuration section ^<OracleDI^>
echo ODI_HOME>%TEMPFILE2%
echo ODI_JAVA_HOME>>%TEMPFILE2%
echo ODI_SECU_DRIVER>>%TEMPFILE2%
echo ODI_SECU_URL>>%TEMPFILE2%
echo ODI_SECU_ENCODED_PASS>>%TEMPFILE2%
echo ODI_SECU_PASS>>%TEMPFILE2%
echo ODI_USER>>%TEMPFILE2%
echo ODI_ENCODED_PASS>>%TEMPFILE2%

for /f %%g in (%TEMPFILE2%) do (
	call :SetConfig OracleDI %%g
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<OracleDI^> key ^<%%g^>
		goto ExitFail
	)
)

REM
REM Tools configuration.
REM
echo %IM% processing configuration section ^<Tools^>
echo JAVA_HOME>%TEMPFILE2%
echo ODI_SCM_JISQL_HOME>>%TEMPFILE2%
echo UNXUTILS_HOME>>%TEMPFILE2%

for /f %%g in (%TEMPFILE2%) do (
	call :SetConfig Tools %%g
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<Tools^> key ^<%%g^>
		goto ExitFail
	)
)

:ExitFail
REM if exist "%TEMPFILE%" del /f %TEMPFILE%
REM if exist "%TEMPFILE2%" del /f %TEMPFILE2%
exit %IsBatchExit% 1

:ExitOk
REM if exist "%TEMPFILE%" del /f %TEMPFILE%
REM if exist "%TEMPFILE2%" del /f %TEMPFILE2%
exit %IsBatchExit% 0

REM ===============================================
REM S U B R O U T I N E S
REM ===============================================
:SetConfig
echo %IM% processing configuration section ^<%1^> key ^<%2^>

set ENVVARVAL=
type NUL >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% initialising temporary working file ^<%TEMPFILE%^>
	goto SetConfigExitFail
)

call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat /b %1 %2 >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<%1^> key ^<%2^>
	goto SetConfigExitFail
)
set /p ENVVARVAL=<%TEMPFILE%
echo %IM% setting environment variable ^<%2^> to value ^<%ENVVARVAL%^>
set SetEnvVarCmd=set %2=%ENVVARVAL%

%SetEnvVarCmd%
if ERRORLEVEL 1 (
	echo %EM% cannot set value for environment variable ^<%1^>
	goto SetConfigExitFail
)

exit /b 0
:SetConfigExitFail
exit /b 1