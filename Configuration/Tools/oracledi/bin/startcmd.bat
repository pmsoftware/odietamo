@echo off
setlocal
for %%a in ("/HELP" "/help" "-HELP" "-help") do if %%a == "%1" goto HELPTEXT
goto STARTCOMMAND

:HELPTEXT
echo.
echo (c) Copyright Oracle.  All rights reserved.
echo. 
echo PRODUCT
echo    Oracle Data Integrator
echo.  
echo FILENAME
echo    startcmd.bat
echo.  
echo DESCRIPTION
echo    Starts a Oracle Data Integrator command. See Oracle Data Integrator documentation for the detailed 
echo    syntax.
echo.    
echo SYNTAX
echo     startcmd ^<Command Name^> ["<command parameter>"]*
echo.  
echo PREREQUISITES
echo    Some commands require a repository connection.
echo    The REPOSITORY CONNECTION INFORMATION section of odiparams.bat should be
echo    completed before running this script.
echo. 
goto ENDCOMMAND

:STARTCOMMAND
if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo OracleDI: Starting Command %*

rem The list of connected commands is specified below
for %%a in (SnpsExportObject SnpsReinitializeSeq SnpsExportScen SnpsGenerateAllScen SnpsDeleteScen SnpsImportScen SnpsPingAgent SnpsPurgeLog SnpsReverseGetMetaData SnpsReverseResetTable SnpsReverseSetMetaData SnpsStartScen SnpsWaitForChildSession ) do if %%a == %1 goto CONNECTED_COMMAND
for %%a in (OdiExportObject OdiReinitializeSeq OdiExportScen OdiGenerateAllScen OdiDeleteScen OdiImportScen OdiPingAgent OdiPurgeLog OdiReverseGetMetaData OdiReverseResetTable OdiReverseSetMetaData OdiStartScen OdiWaitForChildSession ) do if %%a == %1 goto CONNECTED_COMMAND
for %%a in (SnpsImportObject OdiImportObject) do if %%a == %1 goto CONNECTED_COMMAND_WITHOUT_WORK_REP

rem Unconnected command : No odiparams.bat parameter is required
%ODI_JAVA_START% com.sunopsis.dwg.tools.%*
goto ENDCOMMAND

:CONNECTED_COMMAND_WITHOUT_WORK_REP
%ODI_JAVA_START% com.sunopsis.dwg.tools.%* -SECURITY_DRIVER=%ODI_SECU_DRIVER% -SECURITY_URL=%ODI_SECU_URL% -SECURITY_USER=%ODI_SECU_USER% -SECURITY_PWD=%ODI_SECU_ENCODED_PASS% -USER=%ODI_USER% -PASSWORD=%ODI_ENCODED_PASS% -WORK_REP_NAME=%ODI_SECU_WORK_REP%
goto ENDCOMMAND

:CONNECTED_COMMAND
rem Connected command : The odiparams.bat parameters are used
%ODI_JAVA_START% com.sunopsis.dwg.tools.%* -SECURITY_DRIVER=%ODI_SECU_DRIVER% -SECURITY_URL=%ODI_SECU_URL% -SECURITY_USER=%ODI_SECU_USER% -SECURITY_PWD=%ODI_SECU_ENCODED_PASS% -USER=%ODI_USER% -PASSWORD=%ODI_ENCODED_PASS% -WORK_REP_NAME=%ODI_SECU_WORK_REP%

:ENDCOMMAND