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

if not EXIST "%ODI_SCM_TOOLS_FITNESSE_HOME%\startFitnesse.bat" (
	echo %EM% cannot find FitNesse startup script ^<startFitnesse.bat^> in FitNesse home directory ^<%ODI_SCM_TOOLS_FITNESSE_HOME%^> 1>&2
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%PROC%_startFitNesse.bat
echo cd /d %ODI_SCM_TOOLS_FITNESSE_HOME%> "%TEMPFILE%"

for /f "tokens=* delims=¬" %%g in (%ODI_SCM_TOOLS_FITNESSE_HOME%\startFitnesse.bat) do (
	set INLINE=%%g
	if "!INLINE:~0,5!" == "java " (
		set OUTLINE=java %JAVA_SYSTEM_PROPERTIES_STRING% !INLINE:~5,9999!	
	) else (
		set OUTLINE=!INLINE!
	)
	echo !OUTLINE!>> "%TEMPFILE%"
	if ERRORLEVEL 1 (
		echo %EM% creating temporary FitNesse startup script file ^<%TEMPFILE%^> 1>&2
		goto ExitFail
	)
)

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