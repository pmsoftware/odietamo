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

if "%ODI_SCM_SSIS_SERVER_NAME%" == "" (
	echo %EM% variable ODI_SCM_SSIS_SERVER_NAME not set 1>&2
	goto ExitFail
)

if "%ODI_SCM_SSIS_CATALOGUE_PATH%" == "" (
	echo %EM% variable ODI_SCM_SSIS_CATALOGUE_PATH not set 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% missing solution path argument 1>&2
	call :ShowUsage
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

xcopy /i /s "%ARGV1%" "%TEMPDIR%\solution" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% copying solution files to temporary working directory 1>&2
	goto ExitFail
)

set BUILDFILE=%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSsisBuildTemplate.proj
set BUILDLOG=%TEMPDIR%\OdiScmISProjectBuild.log

echo %IM% executing command ^<msbuild "%BUILDFILE%" /target:build /property:solutionPath="%TEMPDIR%\solution" /property:env="OdiScm"^>
msbuild "%BUILDFILE%" /target:build /property:solutionPath="%TEMPDIR%\solution" /property:env="OdiScm" >"%BUILDLOG%" 2>&1
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
rem E.g.: dtutil /file CreateSalesForecastInput.dtsx /copy SQL;CreateSalesForecastInput /destserver "SERVERNAME\INSTANCENAME".
set DEPLOYLOG=%TEMPDIR%\OdiScmISProjectDeploy.log

echo %IM% executing command ^<msbuild "%BUILDFILE%" /target:deploy /property:buildPath="%TEMPDIR%\solution" /property:deployServer="%ODI_SCM_SSIS_SERVER_NAME%" /property:deployFolder="%ODI_SCM_SSIS_CATALOGUE_PATH%"^>
msbuild "%BUILDFILE%" /target:deploy /property:buildPath="%TEMPDIR%\solution" /property:deployServer="%ODI_SCM_SSIS_SERVER_NAME%" /property:deployFolder="%ODI_SCM_SSIS_CATALOGUE_PATH%" >%DEPLOYLOG% 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to deploy Integration Services project 2>&1
	echo %EM% check log file ^<%DEPLOYLOG%^> for details 2>&1
	goto ExitFail
)

grep "0 Error(s)" "%DEPLOYLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to deploy Integration Services project - msbuild errors detected 2>&1
	echo %EM% check log file ^<%DEPLOYLOG%^> for details 2>&1
	goto ExitFail
)

grep "0 Warning(s)" "%DEPLOYLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to deploy Integration Services project - msbuild warnings detected 2>&1
	echo %EM% check log file ^<%DEPLOYLOG%^> for details 2>&1
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
