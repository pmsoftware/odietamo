@echo off
rem
rem Build the Java system properties string for starting FitNesse processes with access to logical-to-physical
rem schema mappings.
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

if "%ARGV1%" == "" (
	echo %EM% missing output batch file path/name argument 1>&2
	call :ShowUsage
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating working directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%PROC%_EnvVarsList.txt
set ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_ > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% extracting logical-to-physical schema mapping environment variables to working file ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

set JAVA_SYSTEM_PROPERTIES_STRING=

setlocal enabledelayedexpansion
rem
rem Example environment variable format: -
rem    HSQL_DEMO_SRC=Data Server+DS_HSQL_DEMO_SRC+Database++Schema+PUBLIC+
rem
for /f "tokens=1,2 delims==" %%g in (%TEMPFILE%) do (
	set ENV_VAR_NAME=%%g
	set ENV_VAR_VAL=%%h
	set ENV_VAR_VAL=!ENV_VAR_VAL:++=+ +!
	set LOGICAL_SCHEMA_NAME=!ENV_VAR_NAME:ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_=!
	rem
	rem Extract the physical database and/or schema name from the environment variable value.
	rem
	for /f "tokens=1,2,3,4,5,6,7 delims=+" %%i in ("!ENV_VAR_VAL!") do (
		set DATABASE_NAME=%%l
		set SCHEMA_NAME=%%n
	)
	set JAVA_SYSTEM_PROPERTY_VALUE=

	if not "!DATABASE_NAME!" == " " (
		set JAVA_SYSTEM_PROPERTY_VALUE=!DATABASE_NAME!
		if not "!SCHEMA_NAME!" == " " (
			set JAVA_SYSTEM_PROPERTY_VALUE=!JAVA_SYSTEM_PROPERTY_VALUE!.!SCHEMA_NAME!
		)
	) else (
		if not "!SCHEMA_NAME!" == " " (
			set JAVA_SYSTEM_PROPERTY_VALUE=!SCHEMA_NAME!
		)
	)
	if not "!JAVA_SYSTEM_PROPERTY_VALUE!" == "" (
		set JAVA_SYSTEM_PROPERTIES_STRING=!JAVA_SYSTEM_PROPERTIES_STRING! -D!LOGICAL_SCHEMA_NAME!=!JAVA_SYSTEM_PROPERTY_VALUE!
	)
)

echo %JAVA_SYSTEM_PROPERTIES_STRING%> "%ARGV1%"
if ERRORLEVEL 1 (
	echo %EM% writing system properties string to output file ^<%ARGV1%^> 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1