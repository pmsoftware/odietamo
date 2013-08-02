rem
rem Remember if we need to use SETLOCAL then use with caution in this script as we need to return variable
rem values to the caller.
rem

rem
rem Set standard switch variable values.
rem
set IsBatchExit=/b
set BeVerbose=FALSE

set DiscardStdOut=
set DiscardStdErr=

:DoNextSwitch
rem
rem First look for standard switches and set corresponding variables.
rem
rem echo DEBUG: OdiScmProcessScriptArgs: processing arg ^<%1^>

if /i "%~1" == "/b" (
	set IsBatchExit=/b
	rem shift
	rem goto DoNextSwitch
)

if /i "%~1" == "/batch" (
	set IsBatchExit=/b
	rem shift
	rem goto DoNextSwitch
)

if /i "%~1" == "/p" (
	set IsBatchExit=
	rem echo DEBUG: OdiScmProcessScriptArgs: got /p switch >CON
	rem shift
	rem goto DoNextSwitch
)

if /i "%~1" == "/process" (
	set IsBatchExit=
	rem echo DEBUG: OdiScmProcessScriptArgs: got /process switch >CON
	rem shift
	rem goto DoNextSwitch
)

if /i "%~1" == "/v" (
	set BeVerbose=TRUE
	set DiscardStdOut=1^>NUL
	set DiscardStdErr=2^>NUL
	rem shift
	rem goto DoNextSwitch
)

if /i "%~1" == "/verbose" (
	set BeVerbose=TRUE
	set DiscardStdOut=1^>NUL
	set DiscardStdErr=2^>NUL
	rem shift
	rem goto DoNextSwitch
)

rem
rem First look for any switch and set a corresponding SWITCH<switch> variable.
rem
set ARGV=%1
if /i "%ARGV:~0,1%" == "/" (
	call set SWITCH%ARGV:~1,%=TRUE
	rem echo DEBUG: OdiScmProcessScriptArgs: got a switch: %ARGV% >CON
	shift
	goto DoNextSwitch
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