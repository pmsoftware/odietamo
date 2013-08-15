@echo off

rem ==========================================================================
rem Drop and rebuild and ODI repository.
rem ==========================================================================

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

rem
rem Define temporary build notification Powershell script files.
rem
set TEMPPSSCRIPTFILESTART=%TEMPDIR%\OdiScmAutoRebuildBuildStartNotify.ps1
if EXIST "%TEMPPSSCRIPTFILESTART%" (
	del /f "%TEMPPSSCRIPTFILESTART%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working Powershell script file ^<%TEMPPSSCRIPTFILESTART%^>
		goto ExitFail
	)
)

echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has started" -smtpserver %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has started" -priority low >"%TEMPPSSCRIPTFILESTART%"

set TEMPPSSCRIPTFILEFINISH=%TEMPDIR%\OdiScmAutoRebuildBuildFinishNotify.ps1
if EXIST "%TEMPPSSCRIPTFILEFINISH%" (
	del /f "%TEMPPSSCRIPTFILEFINISH%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working Powershell script file ^<%TEMPPSSCRIPTFILEFINISH%^>
		goto ExitFail
	)
)

echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has finished with result: $($args[0])" -smtpserver %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has finished with result: $($args[0])" -priority $args[1] >"%TEMPPSSCRIPTFILEFINISH%"

rem
rem Send a start of build notification.
rem
set NOTIFYBUILD=FALSE

if /i "%ODI_SCM_NOTIFY_ON_BUILD_STATUS%" == "fail" (
	set NOTIFYBUILD=TRUE
)

if /i "%ODI_SCM_NOTIFY_ON_BUILD_STATUS%" == "success" (
	set NOTIFYBUILD=TRUE
)

if /i "%ODI_SCM_NOTIFY_ON_BUILD_STATUS%" == "both" (
	set NOTIFYBUILD=TRUE
)

if "%NOTIFYBUILD%" == "TRUE" (
	powershell -file "%TEMPPSSCRIPTFILESTART%"
	if ERRORLEVEL 1 (
		echo %EM% executing start of build notification PowerShell script file ^<%TEMPPSSCRIPTFILESTART%^>
		goto ExitFail
	)
)

rem
rem Check for a TFS workspace name, if appropriate.
rem
if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "TFS" (
	if "%ODI_SCM_SCM_SYSTEM_WORKSPACE_NAME%" == "" (
		echo %EM% no TFS workspace name specified in environment variable ODI_SCM_SCM_SYSTEM_WORKSPACE_NAME 1>&2
		goto ExitFail
	)
)

rem
rem Get the local working copy path.
rem
set WCROOT=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT:/=\%

if "%WCROOT%" == "" (
	echo %EM% no working copy path specified in environment variable ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT 1>&2
	goto ExitFail
)

set ODI_MAJOR_VERSION=%ODI_SCM_ORACLEDI_VERSION:~0,3%

setlocal enabledelayedexpansion

if "%ODI_MAJOR_VERSION%" == "10." (
	set ODI_REPO_BACKUP=%ODI_SCM_MISC_RESOURCES_ROOT%\%ODI_SCM_ORACLEDI_SECU_USER%_REPID_%ODI_SCM_ORACLEDI_REPOSITORY_ID%_empty_master_work_%ODI_SCM_ORACLEDI_VERSION%.dmp
	if not EXIST "!ODI_REPO_BACKUP!" (
		echo %EM% empty master/work repository backup file ^<!ODI_REPO_BACKUP!^> does not exist 1>&2
		goto ExitFail
	)
) else (
	set ODI_REPO_BACKUP=
)

rem
rem Check that a configuration INI file can be accessed.
rem Although we're running from the current environment variable values the OdiScmGet process needs a configuration file to update.
rem
if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI 1>&2
	goto ExitFail
)

if not EXIST "%ODI_SCM_INI%" (
	echo %EM% configuration INI file ^<%ODI_SCM_INI%^> cannot be accessed 1>&2
	goto ExitFail
)

rem
rem Make a copy of the configuration INI file that can be updated and discard after use.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

call :FileNameAndExtFromPath "%ODI_SCM_INI%"
set ORIG_INI=%ODI_SCM_INI%
set ODI_SCM_INI=%TEMPDIR%\%OUTFILEANDEXT%

copy "%ORIG_INI%" "%ODI_SCM_INI%" 1>NUL
if ERRORLEVEL 1 (
	echo %EM% copying configuration INI file ^<%ORIG_INI%^> to ^<%ODI_SCM_INI%^>
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY %ODI_SCM_SCM_SYSTEM_WORKSPACE_NAME%
if ERRORLEVEL 1 (
	echo %EM% re/creating working copy
	goto ExitFail
)

rem
rem Drop contents of existing repository schema.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat^" /p %ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownOracleSchema.sql
if ERRORLEVEL 1 (
	echo %EM% tearing down Oracle database schema ^<%ODI_SCM_ORACLEDI_SECU_USER%^> at ^<%ODI_SCM_ORACLEDI_SECU_URL%^>
	goto ExitFail
)

rem
rem Create the empty master and work repositories either from an Oracle export backup (10g) or using the ODI SDK (11g).
rem
if "%ODI_MAJOR_VERSION%" == "10." (
	rem
	rem Import empty master/work repository from export backup.
	rem
	"%ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe" %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% FILE=%ODI_REPO_BACKUP% FULL=Y
	if ERRORLEVEL 1 (
		echo %EM% importing ODI empty master/work repository from backup file ^<%ODI_REPO_BACKUP%^>
		goto ExitFail
	)
) else (
	rem
	rem Create the repository using the ODI SDK.
	rem
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository^" /p %ODI_SCM_ORACLEDI_REPOSITORY_ID%
	if ERRORLEVEL 1 (
		echo %EM% creating ODI empty master/work repository
		goto ExitFail
	)
)

rem
rem Archive the previous ODI-SCM output directory and recreate it.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"

if EXIST "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%" (
	echo %IM% renaming previous ODI-SCM output directory ^<%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%^>
	move /y "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%" "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%_%YYYYMMDD%_%HHMMSSFF%" 1>NUL
	if ERRORLEVEL 1 (
		echo echo %EM% renaming previous ODI-SCM output directory ^<%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%^>
		goto ExitFail
	)
)

rem
rem Execute the OdiScmGet process.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat^"
if ERRORLEVEL 1 (
	echo %EM% executing OdiScmGet process
	goto ExitFail
)

rem
rem Execute the OdiScmGet generated output script.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%\OdiScmBuild_%ODI_SCM_GENERATE_OUTPUT_TAG%.bat^" /p
if ERRORLEVEL 1 (
	echo %EM% executing generated ODI-SCM build script
	goto ExitFail
)

:ExitOk
rem
rem Send an end of build *success* notification.
rem
set NOTIFYBUILD=FALSE

if /i "%ODI_SCM_NOTIFY_ON_BUILD_STATUS%" == "success" (
	set NOTIFYBUILD=TRUE
)

if /i "%ODI_SCM_NOTIFY_ON_BUILD_STATUS%" == "both" (
	set NOTIFYBUILD=TRUE
)

if "%NOTIFYBUILD%" == "TRUE" (
	powershell -file "%TEMPPSSCRIPTFILEFINISH%" succeeded low
	if ERRORLEVEL 1 (
		echo %EM% executing PowerShell script file ^<%TEMPPSSCRIPTFILEFINISH%^>
		goto ExitFail
	)
)

exit %IsBatchExit% 0

:ExitFail
rem
rem Send an end of build *failure* notification.
rem
set NOTIFYBUILD=FALSE

if /i "%ODI_SCM_NOTIFY_ON_BUILD_STATUS%" == "fail" (
	set NOTIFYBUILD=TRUE
)

if /i "%ODI_SCM_NOTIFY_ON_BUILD_STATUS%" == "both" (
	set NOTIFYBUILD=TRUE
)

if "%NOTIFYBUILD%" == "TRUE" (
	powershell -file "%TEMPPSSCRIPTFILEFINISH%" failed high
	if ERRORLEVEL 1 (
		echo %EM% executing PowerShell script file ^<%TEMPPSSCRIPTFILEFINISH%^>
		goto ExitFail
	)
)

exit %IsBatchExit% 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

:NormalisePath
rem
rem Convert a relative path to an absolute path.
rem
set "OUTPATH=%~f1"
goto :eof

:FileNameAndExtFromPath
rem
rem Extract the file name and extension from a path and file name string.
rem
set OUTFILEANDEXT=%~nx1