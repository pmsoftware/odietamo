@echo off

REM
REM Set up your OdiScm configuration INI file to contain the standad ODI Hypersonic SQL (HSQL)
REM demo repository connection details.
REM
REM For ODI 10g: -
REM (Note null password encoded with "agent.bat encode")
REM ODI_SECU_DRIVER=org.hsqldb.jdbcDriver
REM ODI_SECU_URL=jdbc:hsqldb:hsql://localhost
REM ODI_SECU_USER=sa
REM ODI_SECU_ENCODED_PASS=dTyp9sae2kd8phQdZtwE
REM ODI_SECU_WORK_REP=WORKREP
REM ODI_USER=SUPERVISOR
REM ODI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH
REM
REM For ODI 11g: -
REM (Note null password encoded with "encode.bat")
REM
REM ODI_MASTER_DRIVER=org.hsqldb.jdbcDriver
REM ODI_MASTER_URL=jdbc:hsqldb:hsql://localhost
REM ODI_MASTER_USER=sa
REM ODI_MASTER_ENCODED_PASS=bQyprtMRerZs8o.O3mkA6Jk
REM ODI_SECU_WORK_REP=WORKREP
REM ODI_USER=SUPERVISOR
REM ODI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH
REM ODI_SUPERVISOR=SUPERVISOR
REM ODI_SUPERVISOR_ENCODED_PASS=a7ypkyTouerpM2OSBUM0oDZhy

call :SetMsgPrefixes

echo %IM% starts

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

REM
REM Check basic environment requirements.
REM
if "%ODI_SCM_HOME%" == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI
	goto ExitFail
) else (
	echo %IM% using source configuration INI file ^<%ODI_SCM_INI%^> 
)

REM
REM Check parameter arguments.
REM
if "%1" == "" (
	echo %EM% no source directory specified
	echo %IM% usage: %PROC% ^<import source directory^> ^<10G ^| 11G^>
	goto ExitFail
)

if not EXIST "%1" (
	echo %EM% specified source directory ^<%1^> does not exist. Specify a valid source directory path to be used
	goto ExitFail
)

REM
REM Set the environment from the configuration INI file.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b
set EXITSTATUS=%ERRORLEVEL%
call :SetMsgPrefixes
if not "%EXITSTATUS%" == "0" (
	echo %EM% setting environment from configuration INI file
	goto ExitFail
)

REM if "%ODI_HOME%" == "" (
	REM echo %EM% environment variable ODI_HOME is not set
	REM goto ExitFail
REM )

if not EXIST "%ODI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_HOME directory ^<%ODI_HOME%\bin^>
	goto ExitFail
)

REM
REM Define a temporary work directory and file.
REM
if not "%TEMP%" == "" (
	set TEMPDIR=%TEMP%
) else (
	if not "%TMP%" == "" (
		set TEMPDIR=%TMP%
	) else (
		set TEMPDIR=%CD%
	)
)

set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmImportOracleDIDemo_StartCmd.bat

REM
REM Make a startcmd.bat specific to this environment.
REM
echo %IM% creating OracleDI environment wrapper script ^<%TEMPFILE%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat" %TEMPFILE%
if ERRORLEVEL 1 (
	echo %EM% generating startcmd.bat script for current environment
	goto ExitFail
)

REM Data Servers.
rem call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\CONN_FILE_GENERIC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\CONN_HSQL_LOCALHOST_20001.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\CONN_HSQL_LOCALHOST_20002.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\CONN_SUNOPSIS_MEMORY_ENGINE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\CONN_XML_GEO_DIM.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM Physical schemata.
REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\PSC_FILE_GENERIC____demo_file.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\PSC_HSQL_LOCALHOST_20001_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\PSC_HSQL_LOCALHOST_20002_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\PSC_SUNOPSIS_MEMORY_ENGINE_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\PSC_XML_GEO_DIM_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\PSC_XML_GEO_DIM_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM Logical schemeta.
call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\LSC_FILE_DEMO_SRC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\LSC_HSQL_DEMO_SRC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\LSC_HSQL_DEMO_TARG.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\LSC_XML_DEMO_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\LSC__SUNOPSIS_MEMORY_ENGINE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM Models.
call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\MOD_Orders_Application_-_HSQL.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\MOD_Parameters_-_FILE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\MOD_Sales_Administration_-_HSQL.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM Projects.
call "%TEMPFILE%" OdiImportObject "-FILE_NAME=%1\PROJ_Demo.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

echo %IM% standard demo import completed successfully
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************
:SetMsgPrefixes
set PROC=OdiScmImportOracleDIDemo
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING: