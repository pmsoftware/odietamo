@echo off
set CmdPath=%~dp0
set CmdPathLastTwo=%CmdPath:~-2%
set CmdPathLast=%CmdPath:~-1%
set CmdPath2ndLast=%CmdPathLastTwo:~0,1%

REM echo CmdPath is %CmdPath%
REM echo last 2 chars of path is %CmdPathLastTwo%
REM echo last char of path is %CmdPathLast%
REM echo 2nd last char of path is %CmdPath2ndLast%

set OdiScmHome=%CmdPath%
set OdiScmHome=%OdiScmHome:~0,-1%
set ODI_SCM_HOME=%OdiScmHome%
echo INFO: setting ODI_SCM_HOME to ^<%ODI_SCM_HOME%^>

echo INFO: adding directory ^<%ODI_SCM_HOME%\Configuration\Scripts^> to PATH
set PATH=%ODI_SCM_HOME%\Configuration\Scripts;%PATH%

REM Check for drive root path. 
REM if "%CmdPath2ndLast%" = ":" do (
REM	do something.
REM )
REM ) else (
REM	do something different.
REM )





