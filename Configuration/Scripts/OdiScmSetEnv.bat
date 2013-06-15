@echo off
REM ===============================================
REM Set environment variables for the OdiScm configuration
REM that will be used by the system.
REM
REM Note that for this script to have any useful effect it must be
REM executed with CALL and passed the /B switch.
REM ===============================================
call :SetMsgPrefixes

REM
REM BEWARE of SETLOCAL. We need to ensure that variable value assignments survive the exit from this script
REM for them to be useful.
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
REM Verify minimum requirements - ODI_SCM_HOME must be defined.
REM ===============================================
if not "%ODI_SCM_HOME%" == "" goto OdiScmHomeSet

REM echo %WM% OdiScm home directory environment variable ODI_SCM_HOME is not set
REM echo %WM% setting from this script's command path

echo %EM% OdiScm home directory environment variable ODI_SCM_HOME is not set
goto ExitFail

REM
REM Derive the directory from the path to this script.
REM NOTE: the configuration INI file is not used to specify a value for ODI_SCM_HOME.
REM
rem echo setting it to %CmdDrivePath%
rem set OdiScmHome=
rem echo set OdiScmHome=%CmdDrivePath%
rem echo OdiScmHome is %OdiScmHome%
rem set OdiScmHome=%CmdDrivePath%
rem echo set it to %OdiScmHome%
REM Remove the trailing back slash character.
rem set OdiScmHome=%OdiScmHome:~0,-1%
rem echo OdiScmHome is then %OdiScmHome%
rem set ODI_SCM_HOME=%OdiScmHome:\Configuration\Scripts=%
rem echo %IM% setting ODI_SCM_HOME to ^<%ODI_SCM_HOME%^>

:OdiScmHomeSet

REM ===============================================
REM Verify minimum requirements - ODI_SCM_INI must be defined.
REM ===============================================
if not "%ODI_SCM_INI%" == "" goto OdiScmIniSet

echo %EM% OdiScm configuration INI file environment variable ODI_SCM_INI is not set
goto ExitFail

rem echo %WM% OdiScm configuration INI file environment variable ODI_SCM_INI is not set
rem echo %WM% it is highly recommended to set this variable to explicitly set the configuration
rem if exist ".\OdiScm.ini" goto DeriveOdiScmIni

rem echo %EM% no configuration INI file ^<OdiScm.ini^> found in current working directory
rem goto ExitFail

rem :DeriveOdiScmIni
rem set ODI_SCM_INI=%CD%\OdiScm.ini
rem echo %IM% found configuration INI file ^<OdiScm.ini^> in current working directory
rem echo %IM% setting ODI_SCM_INI to ^<%ODI_SCM_INI%^>

:OdiScmIniSet

REM ===============================================
REM Show the configuration from the INI file.
REM ===============================================

set TEMPFILE2=%TEMPDIR%\%RANDOM%_OdiScmSetEnv.txt

REM
REM OdiScm configuration.
REM
rem echo %IM% looking for section ^<OdiScm^> key ^<ODI_SCM_HOME^> in configuration INI file

rem echo.>"%TEMPFILE%" 
rem if ERRORLEVEL 1 (
rem 	echo %EM% initialising temporary working file ^<%TEMPFILE%^>
rem 	goto ExitFail
rem )
rem set ENVVARVAL=
rem echo getting ini to file %TEMPFILE%
rem call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat /b OdiScm ODI_SCM_HOME >"%TEMPFILE%" 2>&1
rem if ERRORLEVEL 1 (
rem 	echo %EM% cannot get value for section ^<OdiScm^> key ^<ODI_SCM_HOME^>
rem 	goto ExitFail
rem )
rem echo on
rem echo getting val from file %TEMPFILE%
rem echo "file contains >>>"
rem type %TEMPFILE%
rem echo "<<<"
rem set /p ENVVARVAL=<"%TEMPFILE%"
rem echo got "%ENVVARVAL%"
rem if "%ENVVARVAL%" == "" (
rem 	echo %IM% configuration INI file does not contain entry for section ^<OdiScm^> key ^<ODI_SCM_HOME^>
rem 	goto NoOdiScmHomeInIni
rem )

rem echo %IM% found section ^<OdiScm^> key ^<ODI_SCM_HOME^> in configuration INI file
rem echo %IM% setting environment variable ^<ODI_SCM_HOME^> to value 
rem echo val is "%ENVVARVAL%"
rem set SetEnvVarCmd=set ODI_SCM_HOME=%ENVVARVAL%
rem %SetEnvVarCmd%
rem if ERRORLEVEL 1 (
rem 	echo %EM% cannot set value for environment variable ^<%1^>
rem 	got SetConfigExitFail
rem )
rem :NoOdiScmHomeInIni

REM
REM OracleDI configuration.
REM
echo %IM% processing configuration section ^<OracleDI^>
echo ODI_HOME>%TEMPFILE2%
echo ODI_JAVA_HOME>>%TEMPFILE2%
echo ODI_SECU_DRIVER>>%TEMPFILE2%
echo ODI_SECU_URL>>%TEMPFILE2%
echo ODI_SECU_USER>>%TEMPFILE2%
echo ODI_SECU_ENCODED_PASS>>%TEMPFILE2%
echo ODI_SECU_PASS>>%TEMPFILE2%
echo ODI_USER>>%TEMPFILE2%
echo ODI_ENCODED_PASS>>%TEMPFILE2%
echo ODI_SECU_WORK_REP>>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig OracleDI %%g %%g
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<OracleDI^> key ^<%%g^>
		goto ExitFail
	)
)

REM
REM Extract the ODI repository server/port/SID from the URL.
REM
echo %ODI_SECU_URL% | cut -f4 -d: | sed s/@// >"%TEMPFILE2%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract server name from ODI repository URL ^<%ODI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_SECU_URL_HOST=<"%TEMPFILE2%"
echo %IM% setting environment variable ^<ODI_SECU_URL_HOST^> to value ^<%ODI_SECU_URL_HOST%%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set "ODI_SECU_URL_HOST=%ODI_SECU_URL_HOST%"

echo %ODI_SECU_URL% | cut -f5 -d: >"%TEMPFILE2%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract listener port from ODI repository URL ^<%ODI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_SECU_URL_PORT=<"%TEMPFILE2%"
echo %IM% setting environment variable ^<ODI_SECU_URL_PORT^> to value ^<%ODI_SECU_URL_PORT%%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set "ODI_SECU_URL_PORT=%ODI_SECU_URL_PORT%"

echo %ODI_SECU_URL%: | cut -f6 -d: >"%TEMPFILE2%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract SID from ODI repository URL ^<%ODI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_SECU_URL_SID=<"%TEMPFILE2%"
echo %IM% setting environment variable ^<ODI_SECU_URL_SID^> to value ^<%ODI_SECU_URL_SID%%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set ODI_SECU_URL_SID=%ODI_SECU_URL_SID%

REM
REM Generation options.
REM
echo %IM% processing configuration section ^<Generate^>
echo OutputTag ODI_SCM_GENERATE_OUTPUT_TAG>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig Generate %%g %%h
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<Generate^> key ^<%%g^>
		goto ExitFail
	)
)

REM
REM SCM system configuration.
REM
echo %IM% processing configuration section ^<SCMSystem^>
echo SCMSystemTypeName ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_TYPE_NAME>%TEMPFILE2%
echo SCMSystemURL ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL>>%TEMPFILE2%
echo SCMBranchURL ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL>>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig SCMSystem %%g %%h
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<SCMSystem^> key ^<%%g^>
		goto ExitFail
	)
)

REM
REM Tools configuration.
REM
echo %IM% processing configuration section ^<Tools^>
echo ODI_SCM_JISQL_HOME>%TEMPFILE2%
echo ODI_SCM_JISQL_JAVA_HOME>>%TEMPFILE2%
echo ORACLE_HOME>>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig Tools %%g %%g
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<Tools^> key ^<%%g^>
		goto ExitFail
	)
)

REM
REM Notification configuration.
REM
echo %IM% processing configuration section ^<Notify^>
echo UserName ODI_SCM_NOTIFY_USER_NAME>%TEMPFILE2%
echo UserEmailAddress ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS>>%TEMPFILE2%
echo EmailSMTPServer ODI_SCM_NOTIFY_SMTP_SERVER>>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig Notify %%g %%h
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<Notify^> key ^<%%g^>
		goto ExitFail
	)
)

REM
REM Testing configuration.
REM
echo %IM% processing configuration section ^<Test^>
echo ODIStandardsScript ODI_SCM_TEST_ODI_STANDARDS_SCRIPT>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig Test %%g %%h
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<Test^> key ^<%%g^>
		goto ExitFail
	)
)

REM Set the command path if not already set.
REM call :SetPath %ODI_SCM_HOME%\Configuration\Scripts
REM if ERRORLEVEL 1 (
REM 	echo %EM% setting PATH environment variable for OdiScm scripts directory ^<%ODI_SCM_HOME%\Configuration\Scripts^>
REM 	goto ExitFail
REM )

call :SetPath %ORACLE_HOME%\bin
if ERRORLEVEL 1 (
	echo %EM% setting PATH environment variable for Oracle client bin directory ^<%ORACLE_HOME%\bin^>
	goto ExitFail
)

:ExitOk
REM if exist "%TEMPFILE%" del /f "%TEMPFILE%"
REM if exist "%TEMPFILE2%" del /f %TEMPFILE2%
exit %IsBatchExit% 0

:ExitFail
REM if exist "%TEMPFILE%" del /f "%TEMPFILE%"
REM if exist "%TEMPFILE2%" del /f %TEMPFILE2%
exit %IsBatchExit% 1

REM ===============================================
REM S U B R O U T I N E S
REM ===============================================

:SetConfig
REM ===============================================
REM Set an environment variable from a configuration file key.
REM ===============================================
echo %IM% processing configuration section ^<%1^> key ^<%2^>
if "%3" == "" (
	echo %EM% no target environment variable name passed to SetConfig
	goto SetConfigExitFail
)

set ENVVARVAL=
type NUL >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% initialising temporary working file ^<%TEMPFILE%^>
	goto SetConfigExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat" %1 %2 >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<%1^> key ^<%2^>
	goto SetConfigExitFail
)

set /p ENVVARVAL=<"%TEMPFILE%"
echo %IM% setting environment variable ^<%3^> to value ^<%ENVVARVAL%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
REM set SetEnvVarCmd=set "%3=OdiScmDummy"
set SetEnvVarCmd=set "%3=%ENVVARVAL%"

%SetEnvVarCmd%
if ERRORLEVEL 1 (
	if not "%ENVARVAL%" == "" (
		echo %EM% cannot set value for environment variable ^<%1^>
		goto SetConfigExitFail
	)
)

exit /b 0
:SetConfigExitFail
exit /b 1

:SetPath
REM ===============================================
REM Set the command path if it doesn't already contain the specfied directory.
REM ===============================================
REM Escape back slash characters for use with sed.
for /f "tokens=*" %%g in ('echo %1 ^| sed "s/\\/\\\\/g" ^| sed "s/ //g"') do (
	set DirNameEscaped=%%g
)
REM Remove spaces in PATH and look for the specified directory in the path string.
set DirNameInPath=
for /f "tokens=* eol=# delims=;" %%g in ('echo %PATH% ^| sed "s/ //g" ^| grep -i %DirNameEscaped%') do (
	set DirNameInPath=%%g
)
rem echo DirNameInPath=%DirNameInPath%

if "%DirNameInPath%" == "" goto SetDirNamePath

echo %IM% Directory ^<%1^> is in the command PATH
goto DirNamePathSet

:SetDirNamePath
echo %IM% Directory ^<%1^> is not in the command PATH environment variable
echo %IM% adding directory ^<%1^> to command PATH environment variable
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set "PATH=%1;%PATH%"

:DirNamePathSet
exit /b 0

:SetMsgPrefixes
set FN=OdiScmSetEnv
set IM=%FN%: INFO:
set EM=%FN%: ERROR:
set WM=%FN%: WARNING:
goto :eof