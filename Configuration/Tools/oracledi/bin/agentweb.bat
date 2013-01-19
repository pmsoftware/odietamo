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
echo    agentweb.bat
echo.
echo DESCRIPTION
echo    Starts a web agent. See Oracle Data Integrator documentation for the 
echo    detailed syntax.
echo.
echo SYNTAX
echo     agentweb ["-PORT=<port>"] ["-NAME=<agent name>"] ["-V=<trace level>"] ["-WEB_PORT=<http port>"]
echo. 
echo PREREQUISITES
echo   The REPOSITORY CONNECTION INFORMATION section of odiparams.bat should be
echo   completed before running this script.
echo.
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo OracleDI: Starting Web Agent ...

%ODI_JAVA_START% oracle.odi.Agent %ODI_REPOSITORY_PARAMS% -WEB_SERVER=1 -SCHEDULER=0 %*

:ENDCOMMAND