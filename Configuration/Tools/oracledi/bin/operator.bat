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
echo    operator.bat
echo.
echo DESCRIPTION
echo    Starts Operator
echo.  
echo SYNTAX
echo     operator [-CONSOLE]
echo.    
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo OracleDI: Starting Operator ...

if "%1" == "-CONSOLE" %ODI_JAVA_START% oracle.odi.Operator
if not "%1" == "-CONSOLE" %ODI_JAVAW_START% oracle.odi.Operator

:ENDCOMMAND