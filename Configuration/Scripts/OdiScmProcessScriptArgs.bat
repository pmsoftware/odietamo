@echo off
rem
rem Remember we need to use SETLOCAL with caution in this script as we need to return variable
rem values to the caller.
rem

:DoNextSwitch
set IsBatchExit=
set IsBatchExit=FALSE

if /i "%~1" == "/b" (
	set IsBatchExit=/b
	goto :DoNextSwitch
)

if /i "%~1" == "/v" (
	set BeVerbose=TRUE
	goto DoNextSwitch
)

set ARGV=%1
if /i "%ARGV:~0,1%" == "/" (
	call set SWITCH%ARGV:~1,%=TRUE
	shift
)

rem
rem Now process regular parameters and populate ARGV1...ARGVn and ARGC.
rem
set ARGC=0
set /a ParamNo=0

:DoNextParam
set /a ParamNo=%ParamNo% + 1
call set ARGN=%%~%ParamNo%

if "%ARGN%" == "" (
	goto ExitOk
)

call set ARGV%ParamNo%=%ARGN%
set /a ARGC=%ARGC% + 1
goto DoNextParam

:ExitOk
exit /b 0

:ExitFail
exit /b 1