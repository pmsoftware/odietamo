@echo off
set PROC=OdiScmRedirCmd
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:

rem
rem Validate parameter arguments.
rem
if "%~1" == "" goto ErrParamNoCmd
if "%~2" == "" goto ErrParamNoOutFile
goto ParamOk

:ErrParamNoCmd
echo %EM% no command specified
goto ShowUsage

:ErrParamNoOutFile
echo %EM% no output file stub specified
goto ShowUsage

:ShowUsage
echo %EM% usage: %PROC% ^<command^> ^<file-name-stub-to-redirect-stdout-and-stderr^> ^<command-arguments^>
goto ExitFail

:ParamOk
set ARGCOMMAND=%~1
shift
set ARGREDIRFILESTUB=%~1
shift
set ARGCOMMANDARGS=%1 %2 %3 %4 %5 %6 %7 %8 %9
if "%ARGCOMMANDARGS%" == "" echo %IM% no command parameter arguments supplied

echo %IM% command to execute: ^<%ARGCOMMAND%^>
echo %IM% file to redirect standard output to ^<%ARGREDIRFILESTUB%.stdout^>
echo %IM% file to redirect standard error to: ^<%ARGREDIRFILESTUB%.stderr^>
echo %IM% command arguments ^<%ARGCOMMANDARGS%^>
rem echo %IM% full command line to be executed: "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" %ARGCOMMAND% %ARGCOMMANDARGS% ^>"%ARGREDIRFILESTUB%.stdout" 2^>"%ARGREDIRFILESTUB%.stderr"
echo %IM% full command line to be executed: %ARGCOMMAND% %ARGCOMMANDARGS% ^>"%ARGREDIRFILESTUB%.stdout" 2^>"%ARGREDIRFILESTUB%.stderr"

rem "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" %ARGCOMMAND% %ARGCOMMANDARGS% >"%ARGREDIRFILESTUB%.stdout" 2>"%ARGREDIRFILESTUB%.stderr"
"%ARGCOMMAND%" %ARGCOMMANDARGS% >"%ARGREDIRFILESTUB%.stdout" 2>"%ARGREDIRFILESTUB%.stderr"
rem "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ARGCOMMAND%" %ARGCOMMANDARGS% >"%ARGREDIRFILESTUB%.stdout" 2>"%ARGREDIRFILESTUB%.stderr"
if ERRORLEVEL 1 goto ExitFail

:ExitOk
exit /b 0

:ExitFail
exit /b 1