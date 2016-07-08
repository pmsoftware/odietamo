@echo off
rem
rem Run the DNTL-MOI load one package scenario at at time - for development/test purposes.
rem

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

if "%ODI_SCM_ORACLEDI_HOME%" == "" (
	echo ERROR: variable ODI_SCM_ORACLEDI_HOME not set 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% missing Analysis Services database name 1>&2
	goto ExitFail
)

rem
rem Source the working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

rem
rem Execute SSIS package to refresh the SSAS database.
rem
rem First get the Analysis Services server and database names.
rem
set KEYNAME=ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_%ARGV1%
call :GetStringDynamic %KEYNAME%
set KEYVAL=%OUTSTRING%

for /f "tokens=2,4 delims=+" %%g in ("%KEYVAL%") do (
	set ASSERVERKEY=%%g
	set ASDBNAME=%%h
)

set KEYNAME=ODI_SCM_DATA_SERVERS_%ASSERVERKEY%
call :GetStringDynamic %KEYNAME%
set KEYVAL=%OUTSTRING%

for /f "tokens=2,4 delims=+" %%g in ("%KEYVAL%") do (
	set ASSERVERTYPE=%%g
	set ASSERVERNAME=%%h
)

if not "%ASSERVERTYPE%" == "sqlserverAS" (
	echo %EM% unexpected server type in configuration key ^<%ASSERVERTYPE%^>
	echo %EM% expected server type is ^<sqlserverAS^>
	goto ExitFail
)

if "%ASSERVERNAME%" == "" (
	echo %EM% missing AS server name in configuration key ^<%ASSERVERKEY%^>
	goto ExitFail
)

if "%ASDBNAME%" == "" (
	echo %EM% missing AS database name in configuration key ^<%ASDBNAME%^>
	goto ExitFail
)

rem
rem Ideally we'd call OdiScmExecSsisPackage.bat for this call but getting escaped double quotes passed through to it is seemingly impossible.
rem
set DTEXECCMD=dtexec /ISServer "\SSISDB\%ODI_SCM_TEST_ORACLEDI_CONTEXT%\MOICommonUtilities\MOIProcessASDatabaseFull.dtsx" /Server "%ASSERVERNAME%" /Parameter "$ServerOption::SYNCHRONIZED(Boolean)";True /Parameter "$Project::ASServerName";"\"%ASSERVERNAME%\"" /Parameter "$Project::ASDatabaseName";"\"%ASDBNAME%\"" 
%DTEXECCMD%
set EL=%ERRORLEVEL%

if %EL% GTR 0 (
	echo %EM% processing SSAS database 1>&2
	if %EL% == 6 (
		echo %EM% The utility encountered an internal error of syntactic or semantic errors in the command line 1>&2
		goto ExitFail
	) else (
		if %EL% == 5 (
			echo %EM% The utility was unable to load the requested package. The Package could not be loaded 1>&2
			goto ExitFail
		) else (
			if %EL% == 4 (
				echo %EM% The utility was unable to locate the requested package. The Package could not be found 1>&2
				goto ExitFail
			) else (
				if %EL% == 3 (
					echo %EM% The Package was cancelled by user 1>&2
					goto ExitFail
				) else (
					if %EL% == 1 (
						echo %EM% The Package failed 1>&2
						goto ExitFail
					) else (
						if %EL% GTR 0 (
							echo %EM% Unrecognised exit status ^<%EL%^> 1>&2
							goto ExitFail
						)
					)
				)
			)
		)
	)
)

echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1

rem -----------------------------------------------
:GetStringDynamic
rem -----------------------------------------------
set VARNAME=%1
set VARVAL=%%%VARNAME%%%
call set OUTSTRING=%VARVAL%
goto :eof