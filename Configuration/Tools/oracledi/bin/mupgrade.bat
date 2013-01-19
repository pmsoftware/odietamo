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
echo    mupgrade.bat
echo.
echo DESCRIPTION
echo    Starts the Master Repository Upgrade wizard.
echo.  
echo SYNTAX
echo     mupgrade
echo.    
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

echo OracleDI: Starting Master Repository Upgrade wizard ...

%ODI_JAVA_START%  com.sunopsis.wizards.MasterRepositoryPatchWizard

:ENDCOMMAND