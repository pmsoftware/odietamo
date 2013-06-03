@echo off
rem
rem Run a batch file in a child/forked cmd.exe so that we avoid all issues of trying to
rem manage local/global variable scope.
rem
rem This batch file should be run using "CALL <path-to>\OdiScmExec.bat <command-and-args>".
rem The called batch file can exit with with "EXIT" or "EXIT /B".
rem

rem
rem Ensure this batch file doesn't alter any variables' values in the calling process.
rem
setlocal

::echo in outer bat
::tasklist | grep cmd.exe
::echo running child using ^<%*^>
rem
rem Run the passed command in a new cmd.exe.
rem
cmd.exe /c %*
set EXITSTATUS=%ERRORLEVEL%
rem echo got back EL of %errorlevel%
::echo back from child
::tasklist | grep cmd.exe
rem
rem Return the passed command's exit status to the calling batch file.
rem
exit /b %EXITSTATUS%