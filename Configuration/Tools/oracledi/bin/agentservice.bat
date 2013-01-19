@echo off
setlocal
for %%a in ("/HELP" "/help" "-HELP" "-help") do if %%a == "%1" goto HELPTEXT
goto STARTCOMMAND

:HELPTEXT
echo.
echo (c) Copyright Oracle.  All rights reserved.
echo.
echo PRODUCT
echo    Oracle
echo.
echo FILENAME
echo    agentservice.bat
echo.
echo DESCRIPTION
echo    Installs or removes the Agent or Agent scheduler as a Service.
echo.
echo SYNTAX
echo    agentservice ^-i^|^-r ^-s^|^-a [^<agent_name^> [^<agent_port^> [^<wrapper_configuration_file^>]]]
echo.
echo PARAMETERS
echo    ^-i^|^-r       : (i)nstalls or (r)emoves the agent from the services.
echo    ^-s^|^-a       : installs an agent scheduler (^-s) or listener (^-a).
echo    ^<agent_name^>: Name of the physical agent declared in the repository. 
echo                  a valid ^<agent_name^> is mandatory for a scheduler 
echo                  agent.
echo    ^<agent_port^>: listening port for the agent.
echo    ^<wrapper_configuration_file^>: 
echo                  Name of the wrapper configuration file.
echo                  This file is stored in the /tools/wrapper/conf directory.
echo. 
echo PREREQUISITES
echo   The REPOSITORY CONNECTION INFORMATION section of odiparams.bat should be
echo   completed before running this script.
echo.
echo NOTES
echo    A agentservice.log file logging the agent service events and errors is 
echo    generated in the /bin directory. Refer to this file if the agent does 
echo    not start correctly.
echo.
goto ENDCOMMAND

:STARTCOMMAND
if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo.
echo Agentservice.bat
echo.
echo (c) Copyright Oracle.  All rights reserved.
echo.

rem resetting parameters
set _APP_HOME=
set _WRAPPER_CONF=

rem Setting the parameters
if %3!==! (set AGENT_NAME=) else (set AGENT_NAME=%3) 
if %3!==! (set AGENT_NAME_PARAM="wrapper.app.parameter.3=") else (set AGENT_NAME_PARAM="wrapper.app.parameter.3=-NAME=%3")
if %5!==! (set WRAPPER_CONF_FILE=snpsagent.conf) else (set WRAPPER_CONF_FILE=%5)
if %4!==! (set PORT_PARAM="wrapper.app.parameter.2=") else (set PORT_PARAM="wrapper.app.parameter.2=-PORT=%4")

rem finds the wrapper application home
if "%OS%"=="Windows_NT" goto nt
echo This is not NT, so please edit this script and set ODI_WRAPPER_HOME manually
set ODI_WRAPPER_HOME=..\tools\wrapper
goto conf

:nt
rem %~dp0 is name of current script under NT
set ODI_TMP_DIR=%~dp0..
set ODI_WRAPPER_HOME=%ODI_TMP_DIR%\tools\wrapper

rem finds the temp conf file
:conf
set ODI_WRAPPER_CONF="..\conf\%WRAPPER_CONF_FILE%"

rem finds the wrapper application home
set ODI_WRAPPER_EXE=%ODI_WRAPPER_HOME%\bin\wrapper.exe

rem testing the first parameter
if /i "%1" EQU "-i" goto agent_type_choice
if /i "%1" EQU "-r" goto agent_type_choice
goto error

:agent_type_choice
rem testing the second parameter : choice of agent to install
if /i "%2" EQU "-s" goto install_agent_scheduler
if /i "%2" EQU "-a" goto install_agent
goto error

:install_agent
rem runs wrapper for the agent
"%ODI_WRAPPER_EXE%" %1 %ODI_WRAPPER_CONF% wrapper.java.command=%ODI_JAVA_EXE% wrapper.java.initmemory=%ODI_INIT_HEAP% wrapper.java.maxmemory=%ODI_MAX_HEAP% %PORT_PARAM% %AGENT_NAME_PARAM% "wrapper.ntservice.name=SnpsAgent%AGENT_NAME%" "wrapper.ntservice.displayname=OracleDI Agent %AGENT_NAME%" "wrapper.ntservice.description=Execution agent for Oracle DI sessions"
goto ENDCOMMAND

:install_agent_scheduler
rem runs wrapper for the scheduler agent. The agent_name is mandatory.
if %3!==! (     echo agentservice.bat: a valid ^<agent_name^> is mandatory for a scheduler agent.
        goto error )
"%ODI_WRAPPER_EXE%" %1 %ODI_WRAPPER_CONF% wrapper.java.command=%ODI_JAVA_EXE% wrapper.java.initmemory=%ODI_INIT_HEAP% wrapper.java.maxmemory=%ODI_MAX_HEAP% %PORT_PARAM% %AGENT_NAME_PARAM% "wrapper.app.parameter.4=-SECU_DRIVER=%ODI_SECU_DRIVER%" "wrapper.app.parameter.5=-SECU_URL=%ODI_SECU_URL%" "wrapper.app.parameter.6=-SECU_USER=%ODI_SECU_USER%" "wrapper.app.parameter.7=-SECU_PASS=%ODI_SECU_ENCODED_PASS%" "wrapper.app.parameter.8=-WORK_REPOSITORY=%ODI_SECU_WORK_REP%" "wrapper.app.parameter.9=-SNPS_USER=%ODI_USER%" "wrapper.app.parameter.10=-SNPS_PASS=%ODI_ENCODED_PASS%" "wrapper.ntservice.name=SnpsAgentScheduler%AGENT_NAME%" "wrapper.ntservice.displayname=OracleDI Agent Scheduler %AGENT_NAME%" "wrapper.ntservice.description=Scheduler and execution agent for Oracle DI sessions"
goto ENDCOMMAND

:error
echo.
echo agentservice.bat: Syntax Error !
echo Please type 'agentservice -HELP' for complete help.
echo.
goto ENDCOMMAND




:ENDCOMMAND