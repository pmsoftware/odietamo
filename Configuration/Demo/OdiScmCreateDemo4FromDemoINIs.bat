@echo off

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
rem Source the working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set DEMO_ENV1_INI=%TEMPDIR%\OdiScmImportStandardOdiDemoRepo1.ini

copy "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini" "%DEMO_ENV1_INI%" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying demo environment 1 configuration INI file to ^<%DEMO_ENV1_INI%^> 1>&2
	goto ExitFail
)

set DEMO_ENV2_INI=%TEMPDIR%\OdiScmImportStandardOdiDemoRepo2.ini

copy "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo2.ini" "%DEMO_ENV2_INI%" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying demo environment 2 configuration INI file to temporary working directory ^<%DEMO_ENV2_INI%^> 1>&2
	goto ExitFail
)

set ODI_DEMO_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmExportStandardOdiDemo.ini

if "%BeVerbose%" == "TRUE" (
	set VerboseSwitch=/v
) else (
	set VerboseSwitch=
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Demo\OdiScmDemo1FastForward.bat^" /p %VerboseSwitch% %DEMO_ENV1_INI% %DEMO_ENV2_INI% %ODI_DEMO_INI%
if ERRORLEVEL 1 (
	echo %EM% executing demo 1 Fast Forward script 1>&2
	goto ExitFail
)

rem
rem Execute the unit tests from demo environment 1 (the environment last updated by the demo).
rem
set ODI_SCM_INI=%DEMO_ENV1_INI%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" /b
if ERRORLEVEL 1 (
	echo %EM% setting environment for demo environment 2 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmExecUnitTests_DemoEnvironment2.bat^" /p
if ERRORLEVEL 1 (
	echo %EM% executing demo environment 2 unit tests 1>&2
	rem goto ExitFail
)

echo shelling out for debugging...be sure to EXIT when done
cmd

echo %IM% demo creation completed successfully 
exit %IsBatchExit% 0

:ExitFail
echo %EM% demo creation failed 1>&2
exit %IsBatchExit% 1