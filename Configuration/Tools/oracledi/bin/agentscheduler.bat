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
echo    agentscheduler.bat
echo.
echo DESCRIPTION
echo    Starts a scheduler agent. See Oracle Data Integrator documentation for the 
echo    detailed syntax.
echo.
echo SYNTAX
echo     agentscheduler ["-PORT=<port>"] ["-NAME=<agent name>"] ["-V=<trace level>"]
echo. 
echo PREREQUISITES
echo   The REPOSITORY CONNECTION INFORMATION section of odiparams.bat should be
echo   completed before running this script.
echo.
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo OracleDI: Starting Scheduler Agent ...

%ODI_JAVA_START% oracle.odi.Agent %ODI_REPOSITORY_PARAMS% %*

:ENDCOMMAND