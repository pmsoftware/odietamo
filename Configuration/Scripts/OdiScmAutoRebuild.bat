@echo off
REM ==========================================================================
REM Drop and rebuild and ODI respository from an empty repository Oracle export back-up file
REM and a source code repository.
REM
REM Usage: OdiScmAutoRebuild <working copy path> <empty master/work repo backup file> [<TFS workspace name>]
REM
REM ==========================================================================

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

set PATH=C:\MOI\Configuration\Tools\Sysinternals;%PATH%

REM --------------------------------------------------------------------------
REM Get parameter arguments.
REM --------------------------------------------------------------------------

REM
REM Get the local working copy path.
REM
if "%ARGV1%" == "" (
	echo %EM% no local working copy path specified
	call :ShowUsage
	goto ExitFail
) else (
	call :NormalisePath %ARGV1%
	echo %IM% specified local working copy path directory ^<%OUTPATH%^>
	if /i "%OUTPATH%" == "%CD%" (
		echo %EM% cannot run this command from the root of the working copy to be rebuilt
		goto ExitFail
	)
	set WC_ROOT=%ARGV1%
)

REM
REM Get ODI empty master/work repository backup file.
REM
if "%ARGV2%" == "" (
	echo %EM% no ODI empty master/work repository backup file specified
	call :ShowUsage
	goto ExitFail
) else (
	set ODI_REPO_BACKUP=%ARGV2%
)

REM
REM Get the TFS workspace name.
REM
if not "%ARGV3%" == "" (
	set WS_NAME=%ARGV3%
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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

REM
REM Set the environment from the configuration INI file.
REM
echo %IM% setting environment variables from configuration INI file ^<%ODI_SCM_INI%^> 
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" /b
set EXITSTATUS=%ERRORLEVEL%
call :SetMsgPrefixes
if %EXITSTATUS% geq 1 (
	echo %EM% setting environment variables from configuration INI file ^<%ODI_SCM_INI%^>
	goto ExitFail
)

REM
REM If using TFS as the SCM system then check for a passed workspace name.
REM
if "%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_TYPE_NAME%" == "TFS" (
	if "%WS_NAME%" == "" (
		echo %EM% no TFS workspace name specified
		call :ShowUsage
		goto ExitFail
	) else (
		echo %IM% using passed TFS workspace name ^<%WS_NAME%^>
	)
) else (
	echo %IM% SCM system in configuration INI file is not TFS
	echo %IM% ignoring specified TFS workspace name
)

REM
REM Destroy and recreate TFS workspaces.
REM
if "%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_TYPE_NAME%" == "SVN" (
	goto DoWcSVN
)

rem echo %IM% checking for an existing workspace ^<%WS_NAME%^>
rem tf workspaces "%WS_NAME%" >NUL 2>NUL
rem if not ERRORLEVEL 1 (
rem 	echo %IM% no existing TFS workspace ^<%WS_NAME%^>
rem ) else (
rem 	echo %IM% found existing TFS workspace ^<%WS_NAME%^>. Deleting...
echo %IM% deleting any existing TFS workspace ^<%WS_NAME%^>
tf workspace /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% /delete %WS_NAME% /noprompt >NUL 2>NUL
rem 	if ERRORLEVEL 1 (
rem 		echo %EM% deleting existing workspace ^<%WS_NAME%^>
rem 		goto ExitFail
rem 	)
rem 	echo %IM% ...done
rem )

echo %IM% creating new workspace ^<%WS_NAME%^>
tf workspace /new /noprompt %WS_NAME% /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% /permission:Private
if ERRORLEVEL 1 (
	echo %EM% creating workspace ^<%WS_NAME%^>
	goto ExitFail
)

echo %IM% deleting default workspace mappings for workspace ^<%WS_NAME%^>
tf workfold /unmap /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% /workspace:%WS_NAME% $/
if ERRORLEVEL 1 (
	echo %EM% removing default workspace mapping for workspace ^<%WS_NAME%^>
	goto ExitFail
)

REM
REM Don't create a workspace / folder as "workspace /new" creates one for the current workiing directory.
REM
echo %IM% creating workspace mapping for workspace ^<%WS_NAME%^>
tf workfold /map %ODI_SCM_SCM_SYSTEM_BRANCH_URL% %WC_ROOT% /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% /workspace:%WS_NAME%
if ERRORLEVEL 1 (
	echo %EM% creating workspace mapping for branch URL ^<%ODI_SCM_SYSTEM_SCM_BRANCH_URL%^>
	echo %EM% for workspace ^<%WS_NAME%^> to working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

goto DoneWc

:DoWcSVN
svn checkout %ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%
if ERRORLEVEL 1 (
	echo %EM% creating working copy for branch URL ^<%ODI_SCM_SCM_SYSTEM_BRANCH_URL%^>
	echo %EM% in working copy root directory ^<%WC_ROOT%^>
	goto ExitFail
)

:DoneWc

REM
REM Drop contents of existing repository schema.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat" /p %ODI_SCM_ORACLEDI_SECU_USER% %ODI_SCM_ORACLEDI_SECU_PASS% %ODI_SCM_ORACLEDI_SECU_DRIVER% %ODI_SCM_ORACLEDI_SECU_URL% %ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownOracleSchema.sql
if ERRORLEVEL 1 (
	echo %EM% dropping ODI repository objects
	goto ExitFail
)

REM
REM Import empty master/work repository from export backup.
REM
imp %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% FILE=%ODI_REPO_BACKUP% FULL=Y
if ERRORLEVEL 1 (
	echo %EM% importing ODI empty master/work repository from backup file ^<%ODI_REPO_BACKUP%^>
	goto ExitFail
)

REM
REM Archive the previous OdiScm output directory and recreate it.
REM
call :SetDateTimeStrings
if EXIST "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%" (
	echo %IM% renaming previous OdiScm output directory ^<%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%^>
	move "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%" "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%_%YYYYMMDD%_%HHMM%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo echo %EM% renaming previous OdiScm output directory ^<%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%^>
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat"
if ERRORLEVEL 1 (
	echo %EM% executing OdiScmGet process
	goto ExitNotifyFail
)

REM
REM Execute the OdiScmGet process output script.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%\OdiScmBuild_%ODI_SCM_GENERATE_OUTPUT_TAG%.bat"
if ERRORLEVEL 1 (
	echo %EM% executing generated OdiScm build script
	goto ExitNotifyFail
)

echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has succeeded" -smtpserver %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has succeeded" >"%TEMPPSSCRIPTFILE%"
powershell -file "%TEMPPSSCRIPTFILE%"

goto ExitOk

:ExitNotifyFail
echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_USER_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has failed" -smtpserver %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has failed" >"%TEMPPSSCRIPTFILE%"
powershell -file "%TEMPPSSCRIPTFILE%"

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1

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

:NormalisePath
set "OUTPATH=%~f1"
goto :eof