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
echo    startdemo.bat
echo.
echo DESCRIPTION
echo    Starts the demonstration environment. See Oracle Data Integrator documentation for 
echo    more information.
echo.  
echo SYNTAX
echo    startdemo [ SRC ^| TRG ^| REPO [^<language code^>] ^| ALL [^<language code^>] ]
echo    default option is ALL en
echo    Supported language codes : en (default), fr
echo.    
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

set ODI_LANG=en
if /i "%2"=="FR" set ODI_LANG=fr

rem starting all repositories
if /i "%1"=="ALL" goto STARTALL
if /i "%1"=="" goto STARTALL

rem starting unitarily databases
if /i "%1"=="SRC" goto STARTSRC
if /i "%1"=="TRG" goto STARTTRG
if /i "%1"=="REPO" goto STARTREPO

echo Invalid Command Option.
goto HELPTEXT


rem 
:STARTALL
start "OracleDI Demo - Repository" /MIN %ODI_HOME%\bin\startdemo.bat repo %ODI_LANG% -x
start "OracleDI Demo - Source Data Server" /MIN %ODI_HOME%\bin\startdemo.bat src -x
start "OracleDI Demo - Target Data Server" /MIN %ODI_HOME%\bin\startdemo.bat trg -x
goto ENDCOMMAND

:STARTSRC
echo OracleDI: Starting Demo Source Data Server ...
%ODI_JAVA_START% org.hsqldb.Server -database %ODI_HOME%/demo/hsql/demo_src -port 20001
goto ENDCOMMAND


:STARTTRG
echo OracleDI: Starting Demo Target Data Server ...
%ODI_JAVA_START% org.hsqldb.Server -database %ODI_HOME%/demo/hsql/demo_trg -port 20002
goto ENDCOMMAND

:STARTREPO
echo OracleDI: Starting Demo Repository Server (%ODI_LANG%) ...
%ODI_JAVA_START% org.hsqldb.Server -database %ODI_HOME%/demo/hsql/demo_repository_%ODI_LANG%
goto ENDCOMMAND

:ENDCOMMAND
if /i "%3"=="-x" exit
if /i "%2"=="-x" exit