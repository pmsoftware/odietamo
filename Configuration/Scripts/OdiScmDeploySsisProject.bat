@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% missing solution path argument 1>&2
	call :ShowUsage
	goto ExitFail
)

if "%ARGV2%" == "" (
	echo %EM% missing target database logical schema name 1>&2
	call :ShowUsage
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

rem
rem Get the Integration Services deployment project path from the logical schema mapping and
rem the target deployment server from the related data server.
rem
set KEYNAME=ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_%ARGV2%
call :GetStringDynamic %KEYNAME%
set KEYVAL=%OUTSTRING%

for /f "tokens=2,4,6 delims=+" %%g in ("%KEYVAL%") do (
	set TARGETDATASERVERKEYNAME=%%g
	set TARGETISDBNAME=%%h
	set TARGETISPATHNAME=%%i
)

if "%TARGETDATASERVERKEYNAME%" == "" (
	echo %EM% missing target data server key name in configuration key ^<%KEYNAME%^>
	goto ExitFail
)

if not "%TARGETISDBNAME%" == "SSISDB" (
	echo %EM% invalid target IS database name in configuration key ^<%KEYNAME%^>
	echo %EM% expecting target IS database name of ^<%SSISDB%^>
	goto ExitFail
)

if "%TARGETISPATHNAME%" == "" (
	echo %EM% missing target IS path name in configuration key ^<%KEYNAME%^>
	goto ExitFail
)

set KEYNAME=ODI_SCM_DATA_SERVERS_%TARGETDATASERVERKEYNAME%
call :GetStringDynamic %KEYNAME%
set KEYVAL=%OUTSTRING%

for /f "tokens=2,4 delims=+" %%g in ("%KEYVAL%") do (
	set TARGETISSERVERTYPE=%%g
	set TARGETISSERVERNAME=%%h
)

if not "%TARGETISSERVERTYPE%" == "sqlserverIS" (
	echo %EM% invalid data server type ^<%TARGETASSERVERTYPE%^> in configuration key ^<%KEYNAME%^> 1>&2
	echo %EM% expected data server type ^<sqlserverIS^> 1>&2
	goto ExitFail
)

if "%TARGETASSERVERNAME%" == "" (
	echo %EM% missing server name in configuration key ^<%KEYNAME%^> 1>&2
	goto ExitFail
)

echo %IM% using target deployment server name ^<%TARGETASSERVERNAME%^>
echo %IM% using target deployment path name ^<%TARGETISDBNAME%^>

rem
rem Copy the solution and modify......what??????????????????
rem
xcopy /i /s "%ARGV1%" "%TEMPDIR%\solution" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% copying solution files to temporary working directory 1>&2
	goto ExitFail
)

set BUILDFILE=%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSsisBuildTemplate.proj
set BUILDLOG=%TEMPDIR%\OdiScmISProjectBuild.log

echo %IM% executing command ^<msbuild "%BUILDFILE%" /target:build /property:solutionPath="%TEMPDIR%\solution" /property:env="OdiScm"^>
msbuild "%BUILDFILE%" /target:build /property:solutionPath="%TEMPDIR%\solution" /property:env="OdiScm" >%BUILDLOG% 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to build Integration Services project 2>&1
	echo %EM% check log file ^<%BUILDLOG%^> for details 2>&1
	goto ExitFail
)

grep "0 Error(s)" "%BUILDLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to build Integration Services project 2>&1
	goto ExitFail
)

grep "0 Warning(s)" "%BUILDLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %WM% warning messages detected in Integration Services build output 2>&1
	goto ExitFail
)

rem For package-model deployments use dtutil.exe.
rem E.g.: - dtutil /file CreateSalesForecastInput.dtsx /copy SQL;CreateSalesForecastInput /destserver "SERVERNAME\INSTANCENAME".
set DEPLOYLOG=%TEMPDIR%\OdiScmISProjectDeploy.log
echo %IM% executing command ^<msbuild "%BUILDFILE%" /target:deploy /property:buildPath="%TEMPDIR%\solution" /property:deployServer="%TARGETISSERVERNAME%" /property:deployFolder="%TARGETISPATHNAME%"^>
msbuild "%BUILDFILE%" /target:deploy /property:buildPath="%TEMPDIR%\solution" /property:deployServer="%TARGETISSERVERNAME%" /property:deployFolder="%TARGETISPATHNAME%" >%BUILDLOG% 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to deploy Integration Services project 2>&1
	echo %EM% check log file ^<%BUILDLOG%^> for details 2>&1
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1

rem ===============================================
rem ==           S U B R O U T I N E S           ==
rem ===============================================

rem -----------------------------------------------
:ShowUsage
rem -----------------------------------------------
echo %EM% usage: %PROC% ^<SSIS Solution Path^> ^<SSISDB Folder Logical Schema Name^> 1>&2
echo %EM%      : NOTE: ^<SSIS Solution Path^> is the directory containing the solution ^(*.sln^) file 1>&2
goto :eof

rem -----------------------------------------------
:GetStringDynamic
rem -----------------------------------------------
set VARNAME=%1
set VARVAL=%%%VARNAME%%%
call set OUTSTRING=%VARVAL%
goto :eof

rem -----------------------------------------------
:StringContainsTag
rem -----------------------------------------------
set INTEXT=%1
set INSTR=%2
set OUTIND=NO

echo %INTEXT% | gawk -f "%TEMPAWKNODQ%" | grep %INSTR% 1>NUL 2>&1
set EL=!ERRORLEVEL!

if "!EL!" GEQ "2" (
	echo %EM% searching source string ^<%INTEXT%^> for text ^<%INSTR%^> 1>&2
	set OUTIND=ERROR
	exit /b 1
) else (
	if not "!EL!" == "1" (
		set OUTIND=YES
	) else (
		set OUTIND=NO
	)
)

exit /b 0

rem -----------------------------------------------
:StringEscapeDedir
rem -----------------------------------------------
set INTEXT=%1
set INSTR=%2
set OUTVAR=%INTEXT:<=^<%
set OUTVAR=%OUTVAR:>=^>%
goto :eof

rem -----------------------------------------------
:RemoveTagsFromString
rem -----------------------------------------------
set INTEXT=%1
set TAG=%2
set OUTFILE=%3

echo %INTEXT% | sed "s/<%TAG%>//g" | sed "s/<\/%TAG%>//g" > %OUTFILE%
if ERRORLEVEL 1 (
	echo %EM% removing tag ^<%TAG%^> from input string 1>&2
	exit /b 1
)

exit /b 0

rem -----------------------------------------------
:RemoveQuotes
rem -----------------------------------------------
set REMOVEQUOTESTEMPFILE=%TEMPDIR%\OdiScmRemoveQuotes.txt

echo %1| sed s/\^"//g > "%REMOVEQUOTESTEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% splitting string to temporary file ^<%REMOVEQUOTESTEMPFILE%^> 1>&2
	exit /b 1
)

set /p OUTSTRING=<"%REMOVEQUOTESTEMPFILE%"
exit /b 0

rem -----------------------------------------------
:SplitStringToFile
rem -----------------------------------------------
set INTEXT=%1
set DELIM=%2
set OUTFILE=%3

call :RemoveQuotes %INTEXT%
if ERRORLEVEL 1 (
	echo %EM% removing quotes from string split input string ^<%INTEXT%^> 1>&2
	exit /b 1
)

set INTEXT=!OUTSTRING!

echo %INTEXT%| tr "%DELIM%" "\n" > "%OUTFILE%"
if ERRORLEVEL 1 (
	echo %EM% splitting string to temporary file ^<%OUTFILE%^> 1>&2
	exit /b 1
)

exit /b 0