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
echo    agentstop.bat
echo.
echo DESCRIPTION
echo    Stops an agent. See Oracle Data Integrator documentation for the detailed 
echo    syntax.
echo.  
echo SYNTAX
echo     agentstop ["-PORT=<port>"]
echo.
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo OracleDI: Stopping Agent ...

%ODI_JAVA_START% com.sunopsis.dwg.dbobj.SnpAgent %*

:ENDCOMMAND