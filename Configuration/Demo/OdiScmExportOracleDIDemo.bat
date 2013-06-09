@echo off

REM
REM Set up your "odiparams.bat" script to contain the standad ODI Hypersonic SQL (HSQL)
REM demo repository connection details.
REM
REM For ODI 10g: -
REM
REM set ODI_SECU_DRIVER=org.hsqldb.jdbcDriver
REM set ODI_SECU_URL=jdbc:hsqldb:hsql://localhost
REM set ODI_SECU_USER=sa
REM set ODI_SECU_ENCODED_PASS=
REM set ODI_SECU_WORK_REP=WORKREP
REM set ODI_USER=SUPERVISOR
REM set ODI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH
REM
REM For ODI 11g: -
REM (Note null password encoded with "encode.bat")
REM
REM set ODI_MASTER_DRIVER=org.hsqldb.jdbcDriver
REM set ODI_MASTER_URL=jdbc:hsqldb:hsql://localhost
REM set ODI_MASTER_USER=sa
REM set ODI_MASTER_ENCODED_PASS=bQyprtMRerZs8o.O3mkA6Jk
REM set ODI_SECU_WORK_REP=WORKREP
REM set ODI_USER=SUPERVISOR
REM set ODI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH
REM set ODI_SUPERVISOR=SUPERVISOR
REM set ODI_SUPERVISOR_ENCODED_PASS=a7ypkyTouerpM2OSBUM0oDZhy

set PROC=OdiScmExportOracleDIDemo
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:

echo %IM% starts

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

if "%1" == "" (
	echo %EM% no target directory specified
	echo %IM% usage: %PROC% ^<export target directory^> ^<10G ^| 11G^>
	goto ExitFail
)

if EXIST "%1" (
	echo %EM% specified target directory ^<%1^> exists. Specify a directory path to be created
	goto ExitFail
)

if "%2" == "" (
	echo %EM% no OracleDI version specified. Specify either 10G or 11G
	echo %IM% usage: %PROC% ^<export target directory^> ^<10G ^| 11G^>
	goto ExitFail
)

if "%2" == "10G" (
	set EXPDIR1=
	set EXPDIR2=%1\
) else (
	if "%2" == "11G" (
		set EXPDIR1=-EXPORT_DIR=%1
		set EXPDIR2=
	) else (
		echo %EM% invalid OracleDI version specified. Specify either 10G or 11G
		echo %IM% usage: %PROC% ^<export target directory^> ^<10G ^| 11G^>
		goto ExitFail
	)
)

if "%ODI_HOME%" == "" (
	echo %EM% environment variable ODI_HOME is not set
	goto ExitFail
)

if not EXIST "%ODI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_HOME directory ^<%ODI_HOME%\bin^>
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=2002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Orders_Application_-_HSQL.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=3002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Parameters_-_FILE.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=4002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Sales_Administration_-_HSQL.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpProject -I_OBJECT=2002 %EXPDIR1% -FILE_NAME=%EXPDIR2%PROJ_Demo.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=0 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_Security_Connection.xml -RECURSIVE_EXPORT=yes
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_HSQL_LOCALHOST_20001.xml -RECURSIVE_EXPORT=no
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_HSQL_LOCALHOST_20002.xml -RECURSIVE_EXPORT=no
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_FILE_GENERIC.xml -RECURSIVE_EXPORT=no
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_SUNOPSIS_MEMORY_ENGINE.xml -RECURSIVE_EXPORT=no
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=9999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_XML_GEO_DIM.xml -RECURSIVE_EXPORT=no
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

REM call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=15000 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_WORKREP.xml -RECURSIVE_EXPORT=no
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

REM call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=15999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_MEMORY_ENGINE.xml
REM if ERRORLEVEL 1 (
REM	echo %EM% exporting demo object
REM	goto ExitFail
REM )

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpContext -I_OBJECT=2999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CTX_Global.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=4999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_HSQL_DEMO_SRC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_HSQL_DEMO_TARG.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_FILE_DEMO_SRC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC__SUNOPSIS_MEMORY_ENGINE.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_XML_DEMO_GEO.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=12999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_File_Server_for_SAP_ABAP.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=13999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC__MEMORY_ENGINE.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_HSQL_LOCALHOST_20001_Default.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_HSQL_LOCALHOST_20002_Default.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_FILE_GENERICdemofile.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_SUNOPSIS_MEMORY_ENGINE_Default.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=9999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_XML_GEO_DIMGEO.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_HOME%\bin\startcmd.bat" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=15999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_MEMORY_ENGINE_Default.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

:ExitOk
echo %IM% standard demo export completed successfully
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1
