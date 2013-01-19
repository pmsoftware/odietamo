@echo off

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
echo    startscen.bat
echo.  
echo DESCRIPTION
echo    Starts a scenario. See Oracle Data Integrator documentation for the detailed 
echo    syntax.
echo.    
echo SYNTAX
echo     startscen ^<name^> ^<version^> ^<context_code^> [^<log_level^>] ["-SESSION_NAME=<session_name>"] ["-KEYWORDS=<keywords>"] ["-NAME=<agent_name>"] ["-v=<trace_level>"] ["<variable>=<value>"]*
echo.  
echo PREREQUISITES
echo   The REPOSITORY CONNECTION INFORMATION section of odiparams.bat should be
echo   completed before running this script.
echo. 
goto ENDCOMMAND

:STARTCOMMAND
if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo OracleDI: Starting scenario %1 %2 in context %3 ...

%ODI_JAVA_START% oracle.odi.Agent %ODI_REPOSITORY_PARAMS% ODI_START_SCEN %*

:ENDCOMMAND