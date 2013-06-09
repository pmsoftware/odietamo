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
REM set ODI_MASTER_ENCODED_PASS=b9yXdq4ffjI6As5.VP4Ulleuf
REM set ODI_SECU_WORK_REP=WORKREP
REM set ODI_USER=SUPERVISOR
REM set ODI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH

set PROC=OdiScmDemoExport
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

if "%ODI_HOME%" == "" (
	echo %EM% environment variable ODI_HOME is not set
	goto ExitFail
)

if not EXIST "%ODI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_HOME directory ^<%ODI_HOME%\bin^>
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpModel -I_OBJECT=2002 -FILE_NAME=MOD_Orders_Application_-_HSQL.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpModel -I_OBJECT=3002 -FILE_NAME=MOD_Parameters_-_FILE.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpModel -I_OBJECT=4002 -FILE_NAME=MOD_Sales_Administration_-_HSQL.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpProject -I_OBJECT=2002 -FILE_NAME=PROJ_Demo.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=0 -FILE_NAME=CON_Security_Connection.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=5999 -FILE_NAME=CON_HSQL_LOCALHOST_20001.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=6999 -FILE_NAME=CON_HSQL_LOCALHOST_20002.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=7999 -FILE_NAME=CON_FILE_GENERIC.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=8999 -FILE_NAME=CON_SUNOPSIS_MEMORY_ENGINE.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=9999 -FILE_NAME=CON_XML_GEO_DIM.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=15000 -FILE_NAME=CON_WORKREP.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=15999 -FILE_NAME=CON_MEMORY_ENGINE.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=2999 -FILE_NAME=CTX_Global.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=4999 -FILE_NAME=LS_HSQL_DEMO_SRC.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=5999 -FILE_NAME=LS_HSQL_DEMO_TARG.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=6999 -FILE_NAME=LS_FILE_DEMO_SRC.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=7999 -FILE_NAME=LS__SUNOPSIS_MEMORY_ENGINE.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=8999 -FILE_NAME=LS_XML_DEMO_GEO.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=12999 -FILE_NAME=LS_File_Server_for_SAP_ABAP.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=13999 -FILE_NAME=LS__MEMORY_ENGINE.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpPschema -I_OBJECT=5999 -FILE_NAME=PS_HSQL_LOCALHOST_20001_Default.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpPschema -I_OBJECT=6999 -FILE_NAME=PS_HSQL_LOCALHOST_20002_Default.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpPschema -I_OBJECT=7999 -FILE_NAME=PS_FILE_GENERICdemofile.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpPschema -I_OBJECT=8999 -FILE_NAME=PS_SUNOPSIS_MEMORY_ENGINE_Default.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)


"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpPschema -I_OBJECT=9999 -FILE_NAME=PS_XML_GEO_DIMGEO.xmlif ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

"%ODI_HOME%\bin\startcmd.bat" OdiExportObject -CLASS_NAME=SnpPschema -I_OBJECT=15999 -FILE_NAME=PS_MEMORY_ENGINE_Default.xml
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)


:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1
