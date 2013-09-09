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
rem Validate arguments.
rem
if "%ARGC%" gtr "1" (
	echo %EM% invalid number of arguments 1>&2
	call :ShowUsage
	goto ExitFail
)

set REBUILDSOURCE=SCM

if "%ARGC%" == "1" (
	if /i "%ARGV1%" == "FromWorkingCopy" (
		set REBUILDSOURCE=WorkingCopy
	) else (
		if /i "%ARGV1%" == "FromSCM" (
			set REBUILDSOURCE=SCM
		) else (
			echo %EM% invalid argument value 1>&2
			call :ShowUsage
			goto ExitFail
		)
	)
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set REBUILDLOGFILE=%TEMPDIR%\OdiScmAutoRebuild_%YYYYMMDD%_%HHMMSSFF%_LF.log
set REBUILDLOGFILECRLF=%TEMPDIR%\OdiScmAutoRebuild_%YYYYMMDD%_%HHMMSSFF%.log
type NUL > "%REBUILDLOGFILECRLF%"

rem
rem Define temporary build notification Powershell script files.
rem
set TEMPPSSCRIPTFILESTART=%TEMPDIR%\OdiScmAutoRebuildBuildStartNotify.ps1
if EXIST "%TEMPPSSCRIPTFILESTART%" (
	del /f "%TEMPPSSCRIPTFILESTART%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working Powershell script file ^<%TEMPPSSCRIPTFILESTART%^> 1>&2
		goto ExitFail
	)
)

echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has started" -smtpserver %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has started" -priority low >"%TEMPPSSCRIPTFILESTART%"

set TEMPPSSCRIPTFILEFINISH=%TEMPDIR%\OdiScmAutoRebuildBuildFinishNotify.ps1
if EXIST "%TEMPPSSCRIPTFILEFINISH%" (
	del /f "%TEMPPSSCRIPTFILEFINISH%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working Powershell script file ^<%TEMPPSSCRIPTFILEFINISH%^> 1>&2
		goto ExitFail
	)
)

echo send-mailmessage -from "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -to "%ODI_SCM_NOTIFY_USER_NAME% <%ODI_SCM_NOTIFY_EMAIL_ADDRESS%>" -subject "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has finished with result: $($args[0])" -smtpserver %ODI_SCM_NOTIFY_SMTP_SERVER% -body "Auto Build For Source URL <%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%> has finished with result: $($args[0])" -priority $args[1] -attachments "%REBUILDLOGFILECRLF%" >"%TEMPPSSCRIPTFILEFINISH%"

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
		echo %EM% executing start of build notification PowerShell script file ^<%TEMPPSSCRIPTFILESTART%^> 1>&2
		goto ExitFail
	)
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"

rem
rem Execute the rebuild process, capturing stdout and stderr to a log file.
rem
set TEMPEMPTYFILE=%TEMPDIR%\OdiScmRebuildOdiRepo.Empty.Txt
type NUL > %TEMPEMPTYFILE%
set TEMPSTDERR=%TEMPDIR%\OdiScmRebuildOdiRepo.StdErr.Txt

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmRebuildOdiRepo.bat^" /p 2>%TEMPSTDERR% | tee "%REBUILDLOGFILE%"
set EXITSTATUS=%ERRORLEVEL%

set ERROROCCURED=

fc "%TEMPEMPTYFILE%" "%TEMPSTDERR%" >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% stderr content detected from rebuild process 1>&2
	set ERROROCCURED=TRUE
)

if not "%EXITSTATUS%" == "0" (
	set ERROROCCURED=TRUE
)

if "%ERROROCCURED%" == "TRUE" (
	echo %EM% executing rebuild process 1>&2
	echo %EM% start of stderr from rebuild process ^< 1>&2
	cat "%TEMPSTDERR%" 1>&2
	echo %EM% ^> end of stderr from rebuild process 1>&2
	echo ************************************************************ >> "%REBUILDLOGFILE%"
	echo ** STDERR from command OdiScmRebuildOdiRepo.bat           ** >> "%REBUILDLOGFILE%"
	echo ************************************************************ >> "%REBUILDLOGFILE%"
	cat "%TEMPSTDERR%" >> "%REBUILDLOGFILE%"
	goto ExitFail
)

rem
rem Convert the output of tee to Windows format end-of-lines.
rem
cat "%REBUILDLOGFILE%" | sed s/$/\r/ > "%REBUILDLOGFILECRLF%"
if ERRORLEVEL 1 (
	echo %EM% reformatting line endings of log file ^<%REBUILDLOGFILE%^> 1>&2
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
		echo %EM% executing PowerShell script file ^<%TEMPPSSCRIPTFILEFINISH%^> 1>&2
		goto ExitFail
	)
)

echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
setlocal enabledelayedexpansion

rem
rem If we created the PowerShell script file before the error occured then execute it.
rem
if EXIST "%TEMPPSSCRIPTFILEFINISH%" (
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

	if "!NOTIFYBUILD!" == "TRUE" (
		powershell -file "%TEMPPSSCRIPTFILEFINISH%" failed high
		if ERRORLEVEL 1 (
			echo %EM% executing PowerShell script file ^<%TEMPPSSCRIPTFILEFINISH%^> 1>&2
		)
	)
)

echo %EM% ends 1>&2
exit %IsBatchExit% 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************
rem -------------------------------------------------------------
:ShowUsage
rem -------------------------------------------------------------
echo %EM% usage: %PROC% [ FromSCM ^| FromWorkingCopy ] 1>&2