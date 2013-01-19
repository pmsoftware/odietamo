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
echo    stopdemo.bat
echo.
echo DESCRIPTION
echo    Stops the demonstration environment. See Oracle Data Integrator documentation for 
echo    more information.
echo.  
echo SYNTAX
echo    stopdemo [SRC ^| TRG ^| REPO ^| ALL] [-VERBOSE]
echo    default option is ALL
echo.    
goto ENDCOMMAND

:STARTCOMMAND

if "%ODI_HOME%" == "" set ODI_HOME=..
call "%ODI_HOME%\bin\odiparams.bat"

rem verbose mode
set ODI_ANT_VERBOSE=-quiet -logfile NUL 
if /i "%2"=="-VERBOSE" set ODI_ANT_VERBOSE=

rem starting all repositories
if /i "%1"=="ALL" goto STOPALL
if /i "%1"=="" goto STOPALL
if /i "%1"=="-VERBOSE" goto STOPALL

rem starting unitarily databases
if /i "%1"=="SRC" goto STOPSRC
if /i "%1"=="TRG" goto STOPTRG
if /i "%1"=="REPO" goto STOPREPO

echo Invalid Command Option.
goto HELPTEXT

rem 
:STOPALL

set ODI_ANT_VERBOSE=
if /i "%1"=="-VERBOSE" set ODI_ANT_VERBOSE=-VERBOSE
if /i "%2"=="-VERBOSE" set ODI_ANT_VERBOSE=-VERBOSE

call %ODI_HOME%\bin\stopdemo SRC %ODI_ANT_VERBOSE%
call %ODI_HOME%\bin\stopdemo TRG %ODI_ANT_VERBOSE%
call %ODI_HOME%\bin\stopdemo REPO %ODI_ANT_VERBOSE%
goto ENDCOMMAND

:STOPSRC
echo OracleDI: Stopping Demo Source Data Server ...
%ODI_JAVA_START% -Dant.home=. org.apache.tools.ant.Main %ODI_ANT_VERBOSE% -buildfile %ODI_HOME%/demo/hsql/demo_src_shutdown.xml
goto ENDCOMMAND

:STOPTRG
echo OracleDI: Stopping Demo Target Data Server ...
%ODI_JAVA_START% -Dant.home=. org.apache.tools.ant.Main %ODI_ANT_VERBOSE% -buildfile  %ODI_HOME%/demo/hsql/demo_trg_shutdown.xml
goto ENDCOMMAND

:STOPREPO
echo OracleDI: Stopping Demo Repository Server ...
%ODI_JAVA_START% -Dant.home=. org.apache.tools.ant.Main %ODI_ANT_VERBOSE% -buildfile %ODI_HOME%/demo/hsql/demo_repository_shutdown.xml
goto ENDCOMMAND

:ENDCOMMAND