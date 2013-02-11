@echo off
set FN=OdiScmImportOracleDIDemo
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

echo %IM% starting import of demo objects

if "%ODI_HOME%" == "" goto NoOdiHomeError
goto OdiHomeOk

:NoOdiHomeError
echo %EM% environment variable ODI_HOME is not set.
exit /b 1

:OdiHomeOk
echo %IM% using ODI_HOME directory ^<%ODI_HOME%^>

set THISDIR=%CD%
cd /d %ODI_HOME%\bin

REM Data Servers.
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\CON_FILE_GENERIC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\CON_HSQL_LOCALHOST_20001.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\CON_HSQL_LOCALHOST_20002.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\CON_SUNOPSIS_MEMORY_ENGINE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\CON_XML_GEO_DIM.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail

REM Physical schemata.
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\PS_FILE_GENERIC____demo_file.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\PS_HSQL_LOCALHOST_20001_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\PS_HSQL_LOCALHOST_20002_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\PS_SUNOPSIS_MEMORY_ENGINE_Default.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\PS_XML_GEO_DIM_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail

REM Logical schemeta.
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\LS_FILE_DEMO_SRC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\LS_HSQL_DEMO_SRC.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\LS_HSQL_DEMO_TARG.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\LS_XML_DEMO_GEO.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\LS__SUNOPSIS_MEMORY_ENGINE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail

REM Models.
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\MOD_Orders_Application_-_HSQL.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\MOD_Parameters_-_FILE.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\MOD_Sales_Administration_-_HSQL.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail

REM Projects.
call startcmd.bat OdiImportObject "-FILE_NAME=%THISDIR%\PROJ_Demo.xml" -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto ExitFail

echo %IM% import of demo objects completed successfully
cd /d %THISDIR%
exit /b 0

:ExitFail
echo %IM% import of demo objects failed
cd /d %THISDIR%
exit /b 1