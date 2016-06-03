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

if "%ODI_SCM_ORACLEDI_HOME%"=="" (
	echo ERROR: variable ODI_SCM_ORACLEDI_HOME not set 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% missing Analysis Services database name
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
echo KEYVAL ::: %KEYVAL%

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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecSsisPackage.bat" "MOICommonUtilities\MOIProcessASDatabaseFull.dtsx" "%ASSERVERNAME%" "%ODI_SCM_TEST_ORACLEDI_CONTEXT%" "$Package::ASConnection_InitialCatalog;%ASDBNAME%"

exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1

rem -----------------------------------------------
:GetStringDynamic
rem -----------------------------------------------
set VARNAME=%1
set VARVAL=%%%VARNAME%%%
call set OUTSTRING=%VARVAL%
goto :eof