@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME
	set EXITSTATUS=1
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating working directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% missing FitNesse test path argument 1>&2
	call :ShowUsage
	goto ExitFail
)

if "%ARGV2%" == "" (
	echo %EM% missing FitNesse command argument 1>&2
	call :ShowUsage
	goto ExitFail
)

if not "%ARGV3%" == "" (
	set OUTDIR=%ARGV3%
) else (
	set OUTDIR=%TEMPDIR%
)

set TEMPSYSPROPFILE=%TEMPDIR%\%PROC%_JavaSystemProperties.txt
set JAVA_SYSTEM_PROPERTIES_STRING=

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateFitNesseSysPropsString.bat" /p "%TEMPSYSPROPFILE%"
if ERRORLEVEL 1 (
	echo %EM% creating Java system properties file ^<%TEMPSYSPROPFILE%^> 1>&2
	goto ExitFail
)

if not EXIST "%TEMPSYSPROPFILE%" (
	echo %EM% missing Java system property file ^<%TEMPSYSPROPFILE%^> 1>&2
	goto ExitFail
)

setlocal enabledelayedexpansion
for /f "tokens=* delims=¬" %%g in (%TEMPSYSPROPFILE%) do (
		set JAVA_SYSTEM_PROPERTIES_STRING=%%g
)

set FITNESSEHOMEDIR=%ODI_SCM_TOOLS_FITNESSE_HOME:/=\%

set FITNESSECMD="%ODI_SCM_TOOLS_FITNESSE_JAVA_HOME%\bin\java.exe" %JAVA_SYSTEM_PROPERTIES_STRING% -cp "%ODI_SCM_TOOLS_FITNESSE_HOME%\lib\*"
set FITNESSECMD=%FITNESSECMD% %ODI_SCM_TOOLS_FITNESSE_CLASS_NAME%
set FITNESSECMD=%FITNESSECMD% -d "%ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT%" -r "%ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME%"
set FITNESSECMD=%FITNESSECMD% -p %ODI_SCM_TEST_FITNESSE_PORT%
set FITNESSECMD=%FITNESSECMD% -c "%ARGV1%?%ARGV2%&format=%ODI_SCM_TEST_FITNESSE_OUTPUT_FORMAT%"

setlocal enabledelayedexpansion

rem
rem Create the specified output log root directory.
rem
if not EXIST "%OUTDIR%" (
	md "%OUTDIR%"
	if ERRORLEVEL 1 (
		echo %EM% creating FitNesse output log root directory ^<%OUTDIR%^> 1>&2
		goto ExitFail
	)
)

rem
rem Create the output log directory for the specified test path.
rem
set CMDOUTPUTLOGDIR=%OUTDIR:/=\%\%ARGV1:.=\%
echo %IM% FitNesse output will be written to log directory ^<!CMDOUTPUTLOGDIR!^> 1>&2
if not EXIST "!CMDOUTPUTLOGDIR!" (
	md "!CMDOUTPUTLOGDIR!"
	if ERRORLEVEL 1 (
		echo %EM% creating FitNesse output log directory ^<!CMDOUTPUTLOGDIR!^> 1>&2
		set EXITSTATUS=1
		goto ExitFail
	)
)

set FITNESSETEST=
for /f "tokens=*" %%g in ('echo %ARGV1% ^| sed "s/\./\n/g"') do (
	set FITNESSETEST=%%g
)

set FITNESSEOUTPUTLOG=!CMDOUTPUTLOGDIR!\!FITNESSETEST: =!.%ODI_SCM_TEST_FITNESSE_OUTPUT_FORMAT%
echo %IM% FitNesse output will be captured in log file ^<!FITNESSEOUTPUTLOG!^>

type NUL >"%FITNESSEOUTPUTLOG%.empty"
if ERRORLEVEL 1 (
	echo %EM% creating temporary empty file ^<%FITNESSEOUTPUTLOG%.empty^> 1>&2
	goto ExitFail
)

rem
rem Execute the FitNesse command.
rem
echo %IM% running command ^<%FITNESSECMD%^>
%FITNESSECMD% >"%FITNESSEOUTPUTLOG%" 2>"%FITNESSEOUTPUTLOG%.stderr.txt" 
set EXITSTATUS=%ERRORLEVEL%
echo %IM% FitNesse stdout output ^<
cat "%FITNESSEOUTPUTLOG%"
echo %IM% ^> end of FitNesse stdout output

fc "%FITNESSEOUTPUTLOG%.empty" "%FITNESSEOUTPUTLOG%.stderr.txt" 1>NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% FitNesse command returned stderr output ^<
	cat "%FITNESSEOUTPUTLOG%.stderr.txt"
	echo %EM% ^> end of FitNesse stderr outputs
	set STDERRTEXT=TRUE
) else (
	set STDERRTEXT=
)

rem
rem Exit with the non zero exit status from the FitNesse command in preference to a the value we use
rem when detecting output to stderr.
rem
if not "%EXITSTATUS%" == "0" (
	echo %EM% executing FitNesse command ^<%FITNESSECMD%^> 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
if not "%EXITSTATUS%" geq "1" (
	set EXITSTATUS=1
)

echo %EM% ends 1>&2
exit %IsBatchExit% %EXITSTATUS%

rem ===============================================
rem ==           S U B R O U T I N E S           ==
rem ===============================================

rem -----------------------------------------------
:ShowUsage
rem -----------------------------------------------
echo %EM% usage: %PROC% ^<FitNesse test path^> ^<FitNesse command^> [^<output log root directory^>] 1>&2
exit /b