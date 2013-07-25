@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI 1>&2
	goto ExitFail
) else (
	echo %IM% using source configuration INI file ^<%ODI_SCM_INI%^> 
)

REM
REM Check parameter arguments.
REM
if "%ARGV1%" == "" (
	echo %EM% no source directory specified
	echo %IM% usage: %PROC% ^<import source directory^> ^<10G ^| 11G^> 1>&2
	goto ExitFail
)

if not EXIST "%ARGV1%" (
	echo %EM% specified source directory ^<%ARGV1%^> does not exist. Specify a valid source directory path to be used
	goto ExitFail
)

if not EXIST "%ODI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_HOME directory ^<%ODI_HOME%\bin^> 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmImportOracleDIDemo_StartCmd.bat

REM
REM Make a startcmd.bat specific to this environment.
REM
echo %IM% creating OracleDI environment wrapper script ^<%TEMPFILE%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat" /p %TEMPFILE%
if ERRORLEVEL 1 (
	echo %EM% generating StartCmd script for current environment 1>&2
	goto ExitFail
)

REM Data Servers.
rem call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\CONN_FILE_GENERIC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\CONN_HSQL_LOCALHOST_20001.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\CONN_HSQL_LOCALHOST_20002.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\CONN_SUNOPSIS_MEMORY_ENGINE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\CONN_XML_GEO_DIM.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM Physical schemata.
REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\PSC_FILE_GENERIC____demo_file.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\PSC_HSQL_LOCALHOST_20001_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\PSC_HSQL_LOCALHOST_20002_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\PSC_SUNOPSIS_MEMORY_ENGINE_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\PSC_XML_GEO_DIM_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\PSC_XML_GEO_DIM_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM Logical schemeta.
call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\LSC_FILE_DEMO_SRC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\LSC_HSQL_DEMO_SRC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\LSC_HSQL_DEMO_TARG.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\LSC_XML_DEMO_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\LSC__SUNOPSIS_MEMORY_ENGINE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM Models.
call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\MOD_Orders_Application_-_HSQL.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\MOD_Parameters_-_FILE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\MOD_Sales_Administration_-_HSQL.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM Projects.
call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%ARGV1%\PROJ_Demo.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

echo %IM% standard demo import completed successfully
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1