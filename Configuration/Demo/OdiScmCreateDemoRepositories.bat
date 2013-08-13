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

if "%BeVerbose%" == "TRUE" (
	set VerboseSwitch=/v
) else (
	set VerboseSwitch=
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Demo\OdiScmDemo1FastForward.bat^" %VerboseSwitch% %DEMO_ENV1_INI% %DEMO_ENV1_INI%
if ERRORLEVEL 1 (
	echo %EM% executing demo 1 Fast Foward script 1>&2
	goto ExitFail
)

echo %IM% demo creation completed successfully 
exit %IsBatchExit% 0

:ExitFail
echo %EM% demo creation failed 1>&2
exit %IsBatchExit% 1