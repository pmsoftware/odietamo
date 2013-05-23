set PROC=OdiScmAutoRebuild
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:

REM TODO: put paths to these tools into the OdiScm.ini file.
set PATH=C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE;%PATH%
set PATH=C:\MOI\Configuration\Tools\Sysinternals;%PATH%

REM
REM Check basic environment requirements.
REM
if %ODI_SCM_HOME% == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

if %ODI_SCM_INI% == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI
	goto ExitFail
)

call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat /b
if ERRORLEVEL 1 (
	echo %EM% setting environment variables from configuration INI file ^<%ODI_SCM_INI%^>
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
del /f %TEMPFILE% >NUL 2>NUL

REM
REM Extract the ODI repository server/port/SID from the URL.
REM
echo %ODI_SECU_URL% | cut -f4 -d: | sed s/@// >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract server name from ODI repository URL ^<%ODI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_REPO_SERVER=<%TEMPFILE%

echo %ODI_SECU_URL% | cut -f5 -d: >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract listener port from ODI repository URL ^<%ODI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_REPO_PORT=<%TEMPFILE%

echo %ODI_SECU_URL% | cut -f6 -d: >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot extract SID from ODI repository URL ^<%ODI_SECU_URL%^>
	goto ExitFail
)

set /p ODI_REPO_SID=<%TEMPFILE%

REM
REM Get the OdiScm fixed output tag.
REM
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat /b Generate OutputTag >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<Generate^> key ^<OutputTag^>
	goto ExitFail
)

set /p OUTPUT_TAG=<%TEMPFILE%

REM
REM Get the SCM system type.
REM
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat /b SCMSystem SCMSystemTypeName >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<SCMSystem^> key ^<SCMSystemTypeName^>
	goto ExitFail
)

set /p SCM_SYSTEM_NAME=<%TEMPFILE%

REM
REM Get the SCM system URL.
REM
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat /b SCMSystem SCMSystemUrl >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<SCMSystem^> key ^<SCMSystemUrl^>
	goto ExitFail
)

set /p SCM_SYSTEM_URL=<%TEMPFILE%

REM
REM Get the SCM system branch URL.
REM
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat /b SCMSystem SCMBranchUrl >%TEMPFILE% 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<SCMSystem^> key ^<SCMBranchUrl^>
	goto ExitFail
)

set /p SCM_BRANCH_URL=<%TEMPFILE%

REM
REM Get the local working copy path.
REM
if "%1" == "" (
	echo %EM% no local working copy path specified
	call :ShowUsage
	goto ExitFail
) else (
	set WC_ROOT=%1
)

REM
REM Get ODI empty master/work repository backup file.
REM
if "%2" == "" (
	echo %EM% no ODI empty master/work repository backup file specified
	call :ShowUsage
	goto ExitFail
) else (
	set ODI_REPO_BACKUP=%2
)

REM
REM Get the TFS workspace name.
REM
if "%SCM_SYSTEM_NAME%" == "TFS" (
	if "%3" == "" (
		echo %EM% no TFS workspace name specified
		call :ShowUsage
		goto ExitFail
	) else (
		set WS_NAME=%3
	) 
)

REM
REM Destroy and recreate the working copy root directory.
REM
rd /s /q %WC_ROOT% >NUL 2>NUL
md %WC_ROOT%
if ERRORLEVEL 1 (
	echo %EM% creating working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

cd %WC_ROOT%
if ERRORLEVEL 1 (
	echo %EM% changing working directory to working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

REM
REM Copy the source configuration INI file to the working copy root directory.
REM
if "%ODI_SCM_INI%" == "%WC_ROOT%\OdiScm.ini" (
	echo %EM% the source configuration INI file path and name ^<%ODI_SCM_INI%^> is the same
	echo %EM% file as the intended disposable target copy file ^<%WC_ROOT%\OdiScm.ini^>
	echo %IM% move or rename the source configuration INI file
	goto ExitFail
)

copy "%ODI_SCM_INI%" "%WC_ROOT%\OdiScm.ini"
if ERRORLEVEL 1 (
	echo %EM% copying source configuration INI file ^<%ODI_SCM_INI%^> to disposable target
	echo %EM% configuration INI file ^<%%WC_ROOT%\OdiScm.ini%^>
	goto ExitFail
)

set ODI_SCM_INI=%WC_ROOT%\OdiScm.ini

REM
REM Destroy and recreate TFS workspaces.
REM
if "%SCM_SYSTEM_NAME%" == "SVN" (
	goto DoWcSVN
)

tf workspace /collection:%SCM_SYSTEM_URL% /delete %WS_NAME% /noprompt
if ERRORLEVEL 1 (
	echo %EM% deleting existing workspace ^<%WS_NAME%^>
	goto ExitFail
)

tf workspace /new /noprompt %WS_NAME% /collection:%SCM_SYSTEM_URL% /permission:Private
if ERRORLEVEL 1 (
	echo %EM% creating workspace ^<%WS_NAME%^>
	goto ExitFail
)

tf workfold /unmap /collection:%SCM_SYSTEM_URL% /workspace:%WS_NAME% $/
if ERRORLEVEL 1 (
	echo %EM% removing default workspace mapping for workspace ^<%WS_NAME%^>
	goto ExitFail
)

tf workfold /map %SCM_BRANCH_URL% %WC_ROOT% /collection:%SCM_SYSTEM_URL% /workspace:%WS_NAME%
if ERRORLEVEL 1 (
	echo %EM% creating workspace mapping for branch URL ^<%SCM_BRANCH_URL%^>
	echo %EM% for workspace ^<%WS_NAME%^> to working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

goto DoneWc

:DoWcSVN
svn checkout %SCM_SYSTEM_URL%\%SCM_BRANCH_URL%
if ERRORLEVEL 1 (
	echo %EM% creating working copy for branch URL ^<%SCM_BRANCH_URL%^>
	echo %EM% in working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

:DoneWc

REM
REM Drop contents of existing repository schema.
REM
call OdiScmJisql.bat /b %ODI_SECU_USER% %ODI_SECU_PASS% oracle.jdbc.driver.OracleDriver %ODI_SECU_URL% %ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownOracleSchema.sql
if ERRORLEVEL 1 (
	echo %EM% dropping ODI repository objects
	goto ExitFail
)

REM
REM Import empty master/work repository from export backup.
REM
imp %ODI_SECU_USER%/%ODI_SECU_PASS%@%ODI_REPO_SERVER%:%ODI_REPO_PORT%/%ODI_REPO_SID% FILE=%ODI_REPO_BACKUP% FULL=Y
if ERRORLEVEL 1 (
	echo %EM% importing ODI empty master/work repository from backup file ^<%ODI_REPO_BACKUP%^>
	goto ExitFail
)

REM
REM Archive the previous OdiScm output directory and recreate it.
REM
call :SetDateTimeStrings
move %ODI_SCM_HOME%\Logs\%OUTPUT_TAG% %ODI_SCM_HOME%\Logs\%OUTPUT_TAG%_%YYYYMMDD%_%HHMM% >NUL 2>NUL

REM
REM Execute the main OdiScmGet process.
REM
call OdiScmGet.bat
if ERRORLEVEL 1 (
	echo %EM% executing main OdiScmGet process
	goto ExitFail
)

REM
REM Execute the OdiScmGet process output script.
REM
call %ODI_SCM_HOME%\Logs\%OUTPUT_TAG%\OdiScmBuild_%OUTPUT_TAG%.bat
if ERRORLEVEL 1 (
	echo %EM% executing main OdiScm output build script
	goto ExitFail
)

echo send-mailmessage -from "MOIConfig <mattenm@bupa.com>" -to "MOIConfig <mattenm@bupa.com>" -subject "MOI Auto Build For Branch <NP_Stable> has succeeded" -smtp gbstaex02 -body "MOI Auto Build For Branch <NP_Stable> has succeeded" >%TEMPFILE%
powershell -file %TEMPFILE%

goto ExitOk

:ExitFail
echo send-mailmessage -from "MOIConfig <mattenm@bupa.com>" -to "MOIConfig <mattenm@bupa.com>" -subject "MOI Auto Build For Branch <NP_Stable> has failed" -smtp gbstaex02 -body "MOI Auto Build For Branch <NP_Stable> has failed" >%TEMPFILE%
powershell -file %TEMPFILE%
exit -b 1

:ExitOk
exit /b 0

REM *************************************************************
REM **                    S U B R O U T I N E S                **
REM *************************************************************

:SetDateTimeStrings
REM
REM Define unique file name suffixes.
REM
for /f "tokens=1,2,3 delims=/ " %%A in ('date /t') do ( 
	set Day=%%A
	set Month=%%B
	set Year=%%C

	)
for /f "tokens=1,2 delims=: " %%A in ('time /t') do ( 
	set Hour=%%A
	set Minute=%%B
	set HHMM=%%B%%A
)
echo Done setting date and time strings
goto :eof

:ShowUsage
REM
REM Display command usage.
REM
echo %IM% usage: %PROC% ^<local working copy directory^> ^<repository export backup file^> [TFS workspace name]
goto :eof