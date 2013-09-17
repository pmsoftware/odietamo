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
rem Determine if we're rebuilding from the SCM or from the existing working copy.
rem
if "%ARGC%" == "0" (
	echo %IM% defaulting to using the SCM System as the rebuild source
	set REBUILDSOURCE=SCM
) else (
	if "%ARGC%" == "1" (
		if /i "%ARGV1%" == "FromSCM" (
			echo %IM% using the SCM System as the rebuild source
			set REBUILDSOURCE=SCM
		) else (
			if /i "%ARGV1%" == "FromWorkingCopy" (
				echo %IM% using the existing working copy as the rebuild source
				set REBUILDSOURCE=WC
			) else (
				echo %EM% invalid rebuild type argument 1>&2
				call :ShowUsage
				goto ExitFail
			)
		)
	) else (
		echo %EM% invalid arguments 1>&2
		call :ShowUsage
		goto ExitFail
	)
)

rem
rem Ensure an output tag has been specified (we require a predictable import script name
rem to ensure we can execute the import script).
rem
if "%ODI_SCM_GENERATE_OUTPUT_TAG%" == "" (
	echo %EM% no output tag specified in environment variable ODI_SCM_GENERATE_OUTPUT_TAG
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
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
) else (
	set ODI_REPO_BACKUP=
)

if "%ODI_MAJOR_VERSION%" == "10." (
	if not EXIST "%ODI_REPO_BACKUP%" (
		echo %EM% empty master/work repository backup file ^<%ODI_REPO_BACKUP%^> does not exist 1>&2
		goto ExitFail
	)
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
rem Make a copy of the configuration INI file that can be updated and discarded after use.
rem
call :FileNameFromPath "%ODI_SCM_INI%"
rem
rem Batch file calls to labels seem suspect (at least in XP). Let's just put a dirty check in for now.
rem
if "%OUTFILEANDEXT%" == "" (
	echo %EM% extracting INI file name from path and name 1>&2
	goto ExitFail
)

set ORIG_INI=%ODI_SCM_INI%
set ODI_SCM_INI=%TEMPDIR%\%OUTFILEANDEXT%

copy "%ORIG_INI%" "%ODI_SCM_INI%" 1>NUL
if ERRORLEVEL 1 (
	echo %EM% copying configuration INI file ^<%ORIG_INI%^> to ^<%ODI_SCM_INI%^> 1>&2
	goto ExitFail
)

rem
rem Create/Recreate the working copy if rebuilding from an SCM system.
rem
if "%REBUILDSOURCE%" == "SCM" (
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY %ODI_SCM_SCM_SYSTEM_WORKSPACE_NAME%
	if ERRORLEVEL 1 (
		echo %EM% re/creating working copy 1>&2
		goto ExitFail
	)
)

rem
rem Drop contents of existing repository schema.
rem
set TEARDOWNSCRIPT=%ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownOracleSchema.sql
set TEARDOWNREPOSCRIPT=%TEMPDIR%\OdiScmTearDownRepoOracleSchema.sql
cat "%TEARDOWNSCRIPT%" | sed s/"<OdiScmPhysicalSchemaName>"/"%ODI_SCM_ORACLEDI_SECU_USER%"/g > %TEARDOWNREPOSCRIPT%
if ERRORLEVEL 1 (
	echo %EM% creating Oracle repository schema tear down script ^<%TEARDOWNREPOSCRIPT%^> 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" /p "%TEARDOWNREPOSCRIPT%"
if ERRORLEVEL 1 (
	echo %EM% tearing down Oracle database schema ^<%ODI_SCM_ORACLEDI_SECU_USER%^> at ^<%ODI_SCM_ORACLEDI_SECU_URL%^> 1>&2
	goto ExitFail
)

rem
rem Create the empty master and work repositories either from an Oracle export backup (10g) or using the ODI SDK (11g).
rem
if "%ODI_MAJOR_VERSION%" == "10." (
	rem
	rem Import empty master/work repository from export backup.
	rem
	set TEMPSTDERRFILE=%TEMPDIR%\%PROC%_imp_stderr.txt
	"%ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe" %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% FILE=%ODI_REPO_BACKUP% FULL=Y 2>!TEMPSTDERRFILE!
	set EXITSTATUS=!ERRORLEVEL!
	echo %IM% start of IMP output ^(stderr^) text ^<
	cat !TEMPSTDERRFILE!
	echo %IM% ^> end of IMP output ^(stderr^) text
	
	if not "!EXITSTATUS!" == "0" (
		echo %EM% importing ODI empty master/work repository from backup file ^<%ODI_REPO_BACKUP%^> 1>&2
		goto ExitFail
	)
) else (
	rem
	rem Create the repository using the ODI SDK.
	rem
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository^" /p %ODI_SCM_ORACLEDI_REPOSITORY_ID%
	if ERRORLEVEL 1 (
		echo %EM% creating ODI empty master/work repository 1>&2
		goto ExitFail
	)
)

rem
rem Archive the previous ODI-SCM output directory and recreate it.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"

if DEFINED ODI_SCM_GENERATE_OUTPUT_TAG (
	rem
	rem A fixed output tag has been specified.
	rem
	if EXIST "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%" (
		echo %IM% renaming previous ODI-SCM output directory ^<%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%^>
		move /y "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%" "%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%_%YYYYMMDD%_%HHMMSSFF%" 1>NUL
		if ERRORLEVEL 1 (
			echo echo %EM% renaming previous ODI-SCM output directory ^<%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%^> 1>&2
			goto ExitFail
		)
	)
)

rem
rem Execute either the OdiScmGet or OdiScmImport process depending upon the build source.
rem
if "%REBUILDSOURCE%" == "SCM" (
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat^" /p
	if ERRORLEVEL 1 (
		echo %EM% executing OdiScmGet process 1>&2
		goto ExitFail
	)
) else (
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImport.bat^" /p
	if ERRORLEVEL 1 (
		echo %EM% executing OdiScmImport process 1>&2
		goto ExitFail
	)
)

rem
rem Execute the OdiScmGet generated output script.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\%ODI_SCM_GENERATE_OUTPUT_TAG%\OdiScmBuild_%ODI_SCM_GENERATE_OUTPUT_TAG%.bat^" /p
if ERRORLEVEL 1 (
	echo %EM% executing generated ODI-SCM build script 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends
exit %IsBatchExit% 1

REM ===============================================
REM ==           S U B R O U T I N E S           ==
REM ===============================================

REM -----------------------------------------------
:FileNameFromPath
REM -----------------------------------------------
rem
rem Extract the file name and extension from a path and file name string.
rem
set OUTFILEANDEXT=%~nx1
exit /b

REM -----------------------------------------------
:ShowUsage
REM -----------------------------------------------
echo %EM% usage: %PROC% ^<FromSCM ^| FromWorkingCopy^> 1>&2