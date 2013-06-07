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

REM REM
REM REM THESE VARIABLES ARE NOW SET BY THE CALL TO OdiScmSetEnv.bat.
REM REM
REM REM Get additional configuration INI file settings for build notification.
REM REM
REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnvVar.bat" /b Build UserEmailAddress ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS
REM if ERRORLEVEL 1 (
	REM echo %EM% getting build notification user email address from configuration INI file
	REM echo %EM% section ^<Build^> key ^<UserEmailAddress^>
	REM goto ExitFail
REM )

REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnvVar.bat" /b Build UserName ODI_SCM_NOTIFY_USER_NAME
REM if ERRORLEVEL 1 (
	REM echo %EM% getting build notification user name from configuration INI file
		REM echo %EM% section ^<Build^> key ^<UserName^>
	REM goto ExitFail
REM )

REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnvVar.bat" /b Build EmailSMTPServer ODI_SCM_NOTIFY_SMTP_SERVER
REM if ERRORLEVEL 1 (
	REM echo %EM% getting build notification email SMTP server from configuration INI file
	REM echo %EM% section ^<Build^> key ^<EmailSMTPServer^>
	REM goto ExitFail
REM )

REM
REM Destroy and recreate the working copy root directory.
REM
if EXIST "%WC_ROOT%" (
	echo %IM% deleting existing working copy directory tree ^<%WC_ROOT%^>
	rd /s /q "%WC_ROOT%" >NUL 2>NUL
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
REM If using TFS as the SCM system then check for a passed workspace name.
REM
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
REM Destroy and recreate TFS workspaces.
REM
if "%SCM_SYSTEM_NAME%" == "SVN" (
	goto DoWcSVN
)

rem echo %IM% checking for an existing workspace ^<%WS_NAME%^>
rem tf workspaces "%WS_NAME%" >NUL 2>NUL
rem if not ERRORLEVEL 1 (
rem 	echo %IM% no existing TFS workspace ^<%WS_NAME%^>
rem ) else (
rem 	echo %IM% found existing TFS workspace ^<%WS_NAME%^>. Deleting...
echo %IM% deleting any existing TFS workspace ^<%WS_NAME%^>
tf workspace /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% /delete %WS_NAME% /noprompt >NUL 2>NUL
rem 	if ERRORLEVEL 1 (
rem 		echo %EM% deleting existing workspace ^<%WS_NAME%^>
rem 		goto ExitFail
rem 	)
rem 	echo %IM% ...done
rem )

echo %IM% creating new workspace ^<%WS_NAME%^>
tf workspace /new /noprompt %WS_NAME% /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% /permission:Private
if ERRORLEVEL 1 (
	echo %EM% creating workspace ^<%WS_NAME%^>
	goto ExitFail
)

echo %IM% deleting default workspace mappings for workspace ^<%WS_NAME%^>
tf workfold /unmap /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% /workspace:%WS_NAME% $/
if ERRORLEVEL 1 (
	echo %EM% removing default workspace mapping for workspace ^<%WS_NAME%^>
	goto ExitFail
)

REM
REM Don't create a workspace / folder as "workspace /new" creates one for the current workiing directory.
REM
echo %IM% creating workspace mapping for workspace ^<%WS_NAME%^>
tf workfold /map %ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL% %WC_ROOT% /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% /workspace:%WS_NAME%
if ERRORLEVEL 1 (
	echo %EM% creating workspace mapping for branch URL ^<%ODI_SCM_SYSTEM_SCM_BRANCH_URL%^>
	echo %EM% for workspace ^<%WS_NAME%^> to working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

goto DoneWc

:DoWcSVN
svn checkout %ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL%
if ERRORLEVEL 1 (
	echo %EM% creating working copy for branch URL ^<%ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL%^>
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

echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%SCM_SYSTEM_URL%/%SCM_BRANCH_URL%> has succeeded" -smtp %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Branch <NP_Stable> has succeeded" >"%TEMPPSSCRIPTFILE%"
powershell -file "%TEMPPSSCRIPTFILE%"

goto ExitOk

:ExitNotifyFail
echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%SCM_SYSTEM_URL%/%SCM_BRANCH_URL%> has failed" -smtp %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Branch <NP_Stable> has failed" >"%TEMPPSSCRIPTFILE%"
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