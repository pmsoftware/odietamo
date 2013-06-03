@echo off
REM ==========================================================================
REM Drop and rebuild and ODI respository from an empty repository Oracle export back-up file
REM and a source code repository.
REM
REM Usage: OdiScmAutoRebuild <working copy path> <empty master/work repo backup file> [<TFS workspace name>]
REM
REM ==========================================================================
call :SetMsgPrefixes

REM TODO: put paths to these tools into the OdiScm.ini file.
set PATH=C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE;%PATH%
set PATH=C:\MOI\Configuration\Tools\Sysinternals;%PATH%
REM TODO: put notification user name and email addresses into the OdiScm.ini file.
set ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS=mattenm@bupa.com
set ODI_SCM_NOTIFY_USER_NAME=Mark Matten
set ODI_SCM_NOTIFY_SMTP_SERVER=gbstaex04

REM --------------------------------------------------------------------------
REM Get parameter arguments.
REM --------------------------------------------------------------------------

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
if not "%3" == "" (
	set WS_NAME=%3
) 

REM
REM Check basic environment requirements.
REM
if "%ODI_SCM_HOME%" == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI
	goto ExitFail
) else (
	echo %IM% using source configuration INI file ^<%ODI_SCM_INI%^> 
)

REM
REM Destroy and recreate the working copy root directory.
REM
if EXIST "%WC_ROOT%" (
	echo %IM% deleting existing working copy directory tree ^<%WC_ROOT%^>
	rd /s /q %WC_ROOT% >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working copy directory tree ^<%WC_ROOT%^>
		goto ExitFail
	)
)

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

copy "%ODI_SCM_INI%" "%WC_ROOT%\OdiScm.ini" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying source configuration INI file ^<%ODI_SCM_INI%^> to disposable target
	echo %EM% configuration INI file ^<%%WC_ROOT%\OdiScm.ini%^>
	goto ExitFail
)

set ODI_SCM_INI=%WC_ROOT%\OdiScm.ini

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
set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmAutoRebuild.txt
if EXIST "%TEMPFILE%" (
	del /f "%TEMPFILE%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working file ^<%TEMPFILE%^>
		goto ExitFail
	)
)

REM
REM Set the environment from the configuration INI file.
REM
echo %IM% setting environment variables from configuration INI file ^<%ODI_SCM_INI%^> 
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b
set EXITSTATUS=%ERRORLEVEL%
call :SetMsgPrefixes
if %EXITSTATUS% geq 1 (
	echo %EM% setting environment variables from configuration INI file ^<%ODI_SCM_INI%^>
	goto ExitFail
)

REM
REM Get the OdiScm fixed output tag.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat" Generate OutputTag >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<Generate^> key ^<OutputTag^>
	goto ExitFail
)

set /p OUTPUT_TAG=<"%TEMPFILE%"
echo %IM% setting environment variable ^<OUTPUT_TAG^> to ^<%OUTPUT_TAG%^>

REM
REM Get the SCM system type.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat" SCMSystem SCMSystemTypeName >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<SCMSystem^> key ^<SCMSystemTypeName^>
	goto ExitFail
)

set /p SCM_SYSTEM_NAME=<"%TEMPFILE%"
echo %IM% setting environment variable ^<SCM_SYSTEM_NAME^> to ^<%SCM_SYSTEM_NAME%^>

if "%SCM_SYSTEM_NAME%" == "TFS" (
	if "%WS_NAME%" == "" (
		echo %EM% no TFS workspace name specified
		call :ShowUsage
		goto ExitFail
	)
) else (
	echo %IM% SCM system in configuration INI file is not TFS
	echo %IM% ignoring specified TFS workspace name
)

REM
REM Get the SCM system URL.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat" SCMSystem SCMSystemUrl >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<SCMSystem^> key ^<SCMSystemUrl^>
	goto ExitFail
)
rem pause
set /p SCM_SYSTEM_URL=<"%TEMPFILE%"
echo %IM% setting environment variable ^<SCM_SYSTEM_URL^> to ^<%SCM_SYSTEM_URL%^>

REM
REM Get the SCM system branch URL.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIni.bat" SCMSystem SCMBranchUrl >"%TEMPFILE%" 2>&1
if ERRORLEVEL 1 (
	echo %EM% cannot get value for section ^<SCMSystem^> key ^<SCMBranchUrl^>
	goto ExitFail
)

set /p SCM_BRANCH_URL=<"%TEMPFILE%"
echo %IM% setting environment variable ^<SCM_BRANCH_URL^> to ^<%SCM_BRANCH_URL%^>

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
svn checkout %SCM_SYSTEM_URL%/%SCM_BRANCH_URL%
if ERRORLEVEL 1 (
	echo %EM% creating working copy for branch URL ^<%SCM_BRANCH_URL%^>
	echo %EM% in working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

:DoneWc

REM
REM Drop contents of existing repository schema.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat" /b %ODI_SECU_USER% %ODI_SECU_PASS% %ODI_SECU_DRIVER% %ODI_SECU_URL% %ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownOracleSchema.sql
if ERRORLEVEL 1 (
	echo %EM% dropping ODI repository objects
	goto ExitFail
)

REM
REM Import empty master/work repository from export backup.
REM
imp %ODI_SECU_USER%/%ODI_SECU_PASS%@%ODI_SECU_URL_HOST%:%ODI_SECU_URL_PORT%/%ODI_SECU_URL_SID% FILE=%ODI_REPO_BACKUP% FULL=Y
if ERRORLEVEL 1 (
	echo %EM% importing ODI empty master/work repository from backup file ^<%ODI_REPO_BACKUP%^>
	goto ExitFail
)

REM
REM Archive the previous OdiScm output directory and recreate it.
REM
call :SetDateTimeStrings
if EXIST "%ODI_SCM_HOME%\Logs\%OUTPUT_TAG%" (
	echo %IM% renaming previous OdiScm output directory "%ODI_SCM_HOME%\Logs\%OUTPUT_TAG%"
	move "%ODI_SCM_HOME%\Logs\%OUTPUT_TAG%" "%ODI_SCM_HOME%\Logs\%OUTPUT_TAG%_%YYYYMMDD%_%HHMM%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo echo %EM% renaming previous OdiScm output directory "%ODI_SCM_HOME%\Logs\%OUTPUT_TAG%"
		goto ExitFail
	)
)

REM
REM Define a temporary Powershell script file.
REM
set TEMPPSSCRIPTFILE=%TEMPDIR%\%RANDOM%_OdiScmAutoRebuild.ps1
if EXIST "%TEMPPSSCRIPTFILE%" (
	del /f "%TEMPPSSCRIPTFILE%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working Powershell script file ^<%TEMPPSSCRIPTFILE%^>
		goto ExitFail
	)
)

REM
REM Execute the main OdiScmGet process.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat"
if ERRORLEVEL 1 (
	echo %EM% executing OdiScmGet process
	goto ExitNotifyFail
)

REM
REM Execute the OdiScmGet process output script.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecBat.bat" "%ODI_SCM_HOME%\Logs\%OUTPUT_TAG%\OdiScmBuild_%OUTPUT_TAG%.bat"
if ERRORLEVEL 1 (
	echo %EM% executing main OdiScm output build script
	goto ExitNotifyFail
)

echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%SCM_SYSTEM_URL%/%SCM_BRANCH_URL%> has succeeded" -smtp %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Branch <NP_Stable> has succeeded" >"%TEMPPSSCRIPTFILE%"
powershell -file "%TEMPPSSCRIPTFILE%"

goto ExitOk

:ExitNotifyFail
echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%SCM_SYSTEM_URL%/%SCM_BRANCH_URL%> has failed" -smtp %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Branch <NP_Stable> has failed" >"%TEMPPSSCRIPTFILE%"
powershell -file "%TEMPPSSCRIPTFILE%"

:ExitOk
exit /b 0

:ExitFail
exit /b 1

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

goto :eof

:ShowUsage
REM
REM Display command usage.
REM
echo %IM% usage: %PROC% ^<local working copy directory^> ^<repository export backup file^> [TFS workspace name]
goto :eof

:SetMsgPrefixes
set PROC=OdiScmAutoRebuild
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:
goto :eof