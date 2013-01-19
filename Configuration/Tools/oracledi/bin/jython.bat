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
echo    jython.bat
echo.
echo DESCRIPTION
echo    Starts a Jython Console. See Oracle Data Integrator documentation for Jython
echo    information.
echo.  
echo SYNTAX AND PARAMETERS
echo.
set ARGS=--help

goto :ENDARGSLOOP

:STARTCOMMAND
echo OracleDI: Starting Jython ...

:ARGSLOOP
set ARGS=%*

:ENDARGSLOOP

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

%ODI_JAVA_START% org.python.util.jython "-Dpython.home=%ODI_HOME%/lib/scripting" %ARGS%

:ENDCOMMAND