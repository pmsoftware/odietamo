@echo off

REM
REM Set up your OdiScm configuration INI file to contain the standad ODI Hypersonic SQL (HSQL)
REM demo repository connection details.
REM
REM For ODI 10g: -
REM (Note null password encoded with "agent.bat encode")
REM ODI_SCM_ORACLEDI_SECU_DRIVER=org.hsqldb.jdbcDriver
REM ODI_SCM_ORACLEDI_SECU_URL=jdbc:hsqldb:hsql://localhost
REM ODI_SCM_ORACLEDI_SECU_USER=sa
REM ODI_SCM_ENCODED_PASS=dTyp9sae2kd8phQdZtwE
REM ODI_SCM_ORACLEDI_SECU_WORK_REP=WORKREP
REM ODI_SCM_ORACLEDI_USER=SUPERVISOR
REM ODI_SCM_ORACLEDI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH
REM
REM For ODI 11g: -
REM (Note null password encoded with "encode.bat")
REM
REM ODI_MASTER_DRIVER=org.hsqldb.jdbcDriver
REM ODI_MASTER_URL=jdbc:hsqldb:hsql://localhost
REM ODI_MASTER_USER=sa
REM ODI_MASTER_ENCODED_PASS=bQyprtMRerZs8o.O3mkA6Jk
REM ODI_SCM_ORACLEDI_SECU_WORK_REP=WORKREP
REM ODI_SCM_ORACLEDI_USER=SUPERVISOR
REM ODI_SCM_ORACLEDI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH
REM ODI_SUPERVISOR=SUPERVISOR
REM ODI_SUPERVISOR_ENCODED_PASS=a7ypkyTouerpM2OSBUM0oDZhy

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

if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI
	goto ExitFail
) else (
	echo %IM% using source configuration INI file ^<%ODI_SCM_INI%^> 
)

REM
REM Check parameter arguments.
REM
if "%ARGV1%" == "" (
	echo %EM% no target directory specified
	echo %IM% usage: %PROC% ^<export target directory^> ^<10G ^| 11G^>
	goto ExitFail
)

if EXIST "%ARGV1%" (
	echo %EM% specified target directory ^<%ARGV1%^> exists. Specify a directory path to be created
	goto ExitFail
)

if "%ARGV2%" == "" (
	echo %EM% no OracleDI version specified. Specify either 10G or 11G
	echo %IM% usage: %PROC% ^<export target directory^> ^<10G ^| 11G^>
	goto ExitFail
)

if "%ARGV2%" == "10G" (
	set EXPDIR1=
	set EXPDIR2=%ARGV1%\
) else (
	if "%ARGV2%" == "11G" (
		set EXPDIR1=-EXPORT_DIR=%ARGV1%
		set EXPDIR2=
	) else (
		echo %EM% invalid OracleDI version specified. Specify either 10G or 11G
		echo %IM% usage: %PROC% ^<export target directory^> ^<10G ^| 11G^>
		goto ExitFail
	)
)

if "%ARGV2%" == "10G" (
	REM Create the directory if not present.
	if not EXIST "%ARGV1%" (
		md "%ARGV1%"
		if ERRORLEVEL 1 (
			echo %EM% creating directory ^<%ARGV1%^>
			goto ExitFail
		)
	) else (
		echo %EM% target directory ^<%ARGV1%^> already exists. Specify a new target directory name
		goto ExitFail
	)
) else (
	REM Check that the directory does not already exist.
	if EXIST "%ARGV1%" (
		echo %EM% target directory ^<%ARGV1%^> already exists. Specify a new target directory name
		goto ExitFail
	)
)

REM
REM Set the environment from the configuration INI file.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
set EXITSTATUS=%ERRORLEVEL%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
if not "%EXITSTATUS%" == "0" (
	echo %EM% setting environment from configuration INI file
	goto ExitFail
)

if not EXIST "%ODI_SCM_ORACLEDI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_SCM_ORACLEDI_HOME directory ^<%ODI_SCM_ORACLEDI_HOME%\bin^>
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmExportOracleDIDemo_StartCmd.bat

REM
REM Make a startcmd.bat specific to this environment.
REM
echo %IM% creating OracleDI environment wrapper script ^<%TEMPFILE%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat" /p %TEMPFILE%
if ERRORLEVEL 1 (
	echo %EM% generating startcmd.bat script for current environment
	goto ExitFail
)

REM
REM Export the demo repository objects.
REM
call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=2002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Orders_Application_-_HSQL.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=3002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Parameters_-_FILE.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=4002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Sales_Administration_-_HSQL.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpProject -I_OBJECT=2002 %EXPDIR1% -FILE_NAME=%EXPDIR2%PROJ_Demo.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=0 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_Security_Connection.xml -RECURSIVE_EXPORT=yes
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_HSQL_LOCALHOST_20001.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_HSQL_LOCALHOST_20002.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_FILE_GENERIC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_SUNOPSIS_MEMORY_ENGINE.xml -RECURSIVE_EXPORT=no
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=9999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_XML_GEO_DIM.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=15000 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_WORKREP.xml -RECURSIVE_EXPORT=no
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=15999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_MEMORY_ENGINE.xml
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpContext -I_OBJECT=2999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CTX_Global.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=4999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_HSQL_DEMO_SRC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_HSQL_DEMO_TARG.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_FILE_DEMO_SRC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC__SUNOPSIS_MEMORY_ENGINE.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_XML_DEMO_GEO.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

if "%ARGV2%" == "11G" (
	call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=12999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_File_Server_for_SAP_ABAP.xml -RECURSIVE_EXPORT=yes
	if ERRORLEVEL 1 (
		echo %EM% exporting demo object
		goto ExitFail
	)
)

if "%ARGV2%" == "11G" (
	call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=13999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC__MEMORY_ENGINE.xml -RECURSIVE_EXPORT=yes
	if ERRORLEVEL 1 (
		echo %EM% exporting demo object
		goto ExitFail
	)
)

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_HSQL_LOCALHOST_20001_Default.xml -RECURSIVE_EXPORT=yes
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_HSQL_LOCALHOST_20002_Default.xml -RECURSIVE_EXPORT=yes
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_FILE_GENERICdemofile.xml -RECURSIVE_EXPORT=yes
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_SUNOPSIS_MEMORY_ENGINE_Default.xml -RECURSIVE_EXPORT=yes
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=9999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_XML_GEO_DIMGEO.xml -RECURSIVE_EXPORT=yes
REM if ERRORLEVEL 1 (
	REM echo %EM% exporting demo object
	REM goto ExitFail
REM )

REM if "%ARGV2%" == "11G" (
	REM call "%TEMPFILE%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=15999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_MEMORY_ENGINE_Default.xml -RECURSIVE_EXPORT=yes
	REM if ERRORLEVEL 1 (
		REM echo %EM% exporting demo object
		REM goto ExitFail
	REM )
REM )

:ExitOk
echo %IM% standard demo export completed successfully
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1