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
echo    agent.bat
echo.
echo DESCRIPTION
echo    Starts an agent. See Oracle Data Integrator documentation for the detailed 
echo    syntax.
echo.  
echo SYNTAX
echo     agent ["-PORT=<port>"] ["-NAME=<agent_name>"] ["-V=<trace_level>"]
echo.    
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

%ODI_JAVA_START% oracle.odi.Agent %*

:ENDCOMMAND