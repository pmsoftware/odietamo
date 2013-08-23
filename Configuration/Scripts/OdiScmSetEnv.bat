@echo off

REM ===============================================
REM Set environment variables for the OdiScm configuration
REM that will be used by the system.
REM
REM Note that for this script to have any useful effect it must be
REM executed with CALL and passed the /B switch.
REM
REM Also, beware of the call, in this script, to REM OdiScmProcessScriptArgs.bat
REM as this will repopulate ARGC and ARGVn
REM ===============================================

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

REM
REM BEWARE of SETLOCAL. We need to ensure that variable value assignments survive the exit from this script
REM for them to be useful.
REM

REM
REM Check presence of dependencies.
REM
sed --help >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% command ^<sed^> not available
	echo %EM% check UNXUTILS are installed and are included in the system command PATH
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmSetEnv.txt
set TEMPFILE2=%TEMPDIR%\%RANDOM%_OdiScmSetEnv.txt

REM
REM OracleDI configuration.
REM
echo %IM% processing configuration section ^<OracleDI^>
echo ODI_SCM_ORACLEDI_VERSION>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_HOME>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_JAVA_HOME>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_SECU_DRIVER>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_SECU_URL>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_SECU_USER>>%TEMPFILE2%
echo ODI_SCM_ENCODED_PASS>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_SECU_PASS>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_USER>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_PASS>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_ENCODED_PASS>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_SECU_WORK_REP>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_ADMIN_USER>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_ADMIN_PASS>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_COMMON>>%TEMPFILE2%
echo ODI_SCM_ORACLEDI_SDK>>%TEMPFILE2%

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
echo %ODI_SCM_ORACLEDI_SECU_URL% | cut -f4 -d: | sed s/@// >"%TEMPFILE2%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract server name from ODI repository URL ^<%ODI_SCM_ORACLEDI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_SCM_ORACLEDI_SECU_URL_HOST=<"%TEMPFILE2%"
echo %IM% setting environment variable ^<ODI_SCM_ORACLEDI_SECU_URL_HOST^> to value ^<%ODI_SCM_ORACLEDI_SECU_URL_HOST%%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set "ODI_SCM_ORACLEDI_SECU_URL_HOST=%ODI_SCM_ORACLEDI_SECU_URL_HOST%"

echo %ODI_SCM_ORACLEDI_SECU_URL% | cut -f5 -d: >"%TEMPFILE2%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract listener port from ODI repository URL ^<%ODI_SCM_ORACLEDI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_SCM_ORACLEDI_SECU_URL_PORT=<"%TEMPFILE2%"
echo %IM% setting environment variable ^<ODI_SCM_ORACLEDI_SECU_URL_PORT^> to value ^<%ODI_SCM_ORACLEDI_SECU_URL_PORT%%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set "ODI_SCM_ORACLEDI_SECU_URL_PORT=%ODI_SCM_ORACLEDI_SECU_URL_PORT%"

echo %ODI_SCM_ORACLEDI_SECU_URL%: | cut -f6 -d: >"%TEMPFILE2%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract SID from ODI repository URL ^<%ODI_SCM_ORACLEDI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_SCM_ORACLEDI_SECU_URL_SID=<"%TEMPFILE2%"
echo %IM% setting environment variable ^<ODI_SCM_ORACLEDI_SECU_URL_SID^> to value ^<%ODI_SCM_ORACLEDI_SECU_URL_SID%%^>
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set ODI_SCM_ORACLEDI_SECU_URL_SID=%ODI_SCM_ORACLEDI_SECU_URL_SID%

REM
REM Generation options.
REM
echo %IM% processing configuration section ^<Generate^>
echo OutputTag ODI_SCM_GENERATE_OUTPUT_TAG>%TEMPFILE2%
echo ExportRefPhysArchOnly ODI_SCM_GENERATE_EXPORT_REF_PHYS_ARCH_ONLY>>%TEMPFILE2%
echo ImportResetsFlushControl ODI_SCM_GENERATE_IMPORT_RESETS_FLUSH_CONTROL>>%TEMPFILE2%

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
echo SCMSystemURL ODI_SCM_SCM_SYSTEM_SYSTEM_URL>>%TEMPFILE2%
echo SCMBranchURL ODI_SCM_SCM_SYSTEM_BRANCH_URL>>%TEMPFILE2%
echo WorkingCopyRoot ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT>>%TEMPFILE2%
echo WorkingRoot ODI_SCM_SCM_SYSTEM_WORKING_ROOT>>%TEMPFILE2%

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
echo ODI_SCM_TOOLS_JISQL_HOME ODI_SCM_TOOLS_JISQL_HOME>%TEMPFILE2%
echo ODI_SCM_TOOLS_JISQL_JAVA_HOME ODI_SCM_TOOLS_JISQL_JAVA_HOME>>%TEMPFILE2%
echo ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH>>%TEMPFILE2%
echo ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME>>%TEMPFILE2%
echo UnxUtilsHome ODI_SCM_TOOLS_UNXUTILS_HOME>>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig Tools %%g %%h
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
echo ODIStandardsScript ODI_SCM_TESTING_ODI_STANDARDS_SCRIPT>%TEMPFILE2%

for /f "tokens=1,2" %%g in (%TEMPFILE2%) do (
	call :SetConfig Test %%g %%h
	if ERRORLEVEL 1 (
		echo %EM% getting configuration INI value for section ^<Test^> key ^<%%g^>
		goto ExitFail
	)
)

REM Configure PATH for the OdiScm script directory.
echo %IM% configuring PATH for OdiScm scripts directory ^<%ODI_SCM_HOME%\Configuration\Scripts^>
call :SetPath %ODI_SCM_HOME%\Configuration\Scripts
if ERRORLEVEL 1 (
	echo %EM% setting PATH environment variable for OdiScm scripts directory ^<%ODI_SCM_HOME%\Configuration\Scripts^>
	goto ExitFail
)

REM if "%ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME%" == "" (
	REM echo %IM% environment variable ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME not set. Skipping PATH configuration for Oracle bin directory
REM ) else (
	REM echo %IM% configuring PATH for Oracle bin directory ^<%ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME%\bin^>
	REM call :SetPath %ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME%\bin
	REM if ERRORLEVEL 1 (
		REM echo %EM% setting PATH environment variable for Oracle client bin directory ^<%ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME%\bin^>
		REM goto ExitFail
	REM )
REM )

REM
REM Create the OdiScm JAR file that will include all the JARs we need for all the Java commands we use.
REM Execute in the current shell environment to retain the value of ODI_SCM_JAR_FILE.
REM
REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateClassPathJar.bat" /b
REM if ERRORLEVEL 1 (
	REM echo %EM% creating OdiScm class path JAR file
	REM goto ExitFail
REM )

:ExitOk
REM if exist "%TEMPFILE%" del /f "%TEMPFILE%"
REM if exist "%TEMPFILE2%" del /f %TEMPFILE2%
echo %IM% starts
exit /b 0

:ExitFail
REM if exist "%TEMPFILE%" del /f "%TEMPFILE%"
REM if exist "%TEMPFILE2%" del /f %TEMPFILE2%
echo %EM% starts
exit /b 1

REM ===============================================
REM S U B R O U T I N E S
REM ===============================================

:SetConfig
REM ===============================================
REM Set an environment variable from a configuration file key.
REM ===============================================
rem echo on
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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat^" /p %1 %2 >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<%1^> key ^<%2^>
	goto SetConfigExitFail
)

rem echo set /p ENVVARVAL=^<"%TEMPFILE%" >CON
rem echo on
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
REM Also, remove brackets from the path to check for as these cause issues on the command line.

for /f "tokens=*" %%g in ('echo %1 ^| sed "s/(//g" ^| sed "s/)//g" ^| sed "s/\\/\\\\/g" ^| sed "s/ //g"') do (
	set DirNameEscaped=%%g
)

REM Remove spaces in PATH and look for the specified directory in the path string.
REM Also, remove brackets from the PATH for the comparison.
for /f "tokens=* eol=# delims=;" %%g in ('echo %%PATH%% ^| sed "s/(//g" ^| sed "s/)//g"') do (
	set PathNoBrackets=%%g
)

for /f "tokens=* eol=# delims=;" %%g in ('echo %PathNoBrackets% ^| sed "s/ //g" ^| grep -i %DirNameEscaped%') do (
	set DirNameInPath=%%g
)

if "%DirNameInPath%" == "" goto SetDirNamePath

echo %IM% directory ^<%1^> is already in the command PATH
goto DirNamePathSet

:SetDirNamePath
echo %IM% directory ^<%1^> is not in the command PATH environment variable
echo %IM% adding directory ^<%1^> to command PATH environment variable
REM Include quotes around the entire VAR=VAL string to deal with brackets in variable values.
REM E.g. C:\Program Files (x86)\...
set "PATH=%1;%PATH%"

:DirNamePathSet
exit /b 0