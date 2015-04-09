@echo off
rem
rem Start FitNesse with access to INI file logical/physical schema mapping system properties.
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

rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
rem if ERRORLEVEL 1 (
rem 	echo %EM% processing script arguments 1>&2
rem 	goto ExitFail
rem )

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating working directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
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

set TEMPFILE=%TEMPDIR%\%PROC%_startFitNesse.bat
echo cd /d %ODI_SCM_TOOLS_FITNESSE_HOME:/=\%> "%TEMPFILE%"
echo set PATH=%ODI_SCM_TOOLS_FITNESSE_JAVA_HOME%\bin;%PATH%>> "%TEMPFILE%"
echo set JAVA_HOME=%ODI_SCM_TOOLS_FITNESSE_JAVA_HOME%>> "%TEMPFILE%"
set CMDLINE="%ODI_SCM_TOOLS_FITNESSE_JAVA_HOME%\bin\java.exe" %JAVA_SYSTEM_PROPERTIES_STRING%
set CMDLINE=%CMDLINE% -cp "lib\*" %ODI_SCM_TOOLS_FITNESSE_CLASS_NAME% -p %ODI_SCM_TEST_FITNESSE_PORT% -e 0
if "%ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT%" == "" (
	set CMDLINE=%CMDLINE% -d "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%"
) else (
	set CMDLINE=%CMDLINE% -d "%ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT%"
)
set CMDLINE=%CMDLINE% -r "%ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME%"
rem Be sure to retain the space before the redirection here so that the command interpreter doesn't try to redirect stdin!
echo %CMDLINE% >> "%TEMPFILE%"

rem
rem Start up FitNesse using the temporary script.
rem
echo %IM% starting FitNesse using script ^<%TEMPFILE%^>
call "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% running temporary FitNesse startup script file ^<%TEMPFILE%^> 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1