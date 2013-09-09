@echo off
rem
rem Run a command or batch file in a child/forked cmd.exe so that we avoid all issues of trying to
rem manage local/global variable scope.
rem
rem This batch file should be run using "CALL <path-to>\OdiScmFork.bat <command-and-args>".
rem If running a batch file then it should be exitted with "EXIT [exit status]" instead
rem of "EXIT /B [exit status]" so that the exit status is accessible to the calling process.
rem

rem
rem Ensure this batch file doesn't alter any variables' values in the calling process.
rem Note that forked (i.e. child) shells (cmd.exe) will still inherit the environment.
setlocal

if not DEFINED ODI_SCM_CMDLVL (
	set ODI_SCM_CMDLVL=0
)

set /a ODI_SCM_CMDLVL=%ODI_SCM_CMDLVL% + 1 >NUL

set ODI_SCM_CMD=%*

rem echo =============================================================================
rem echo == about to exec command: %*
rem echo =============================================================================
rem echo CMDLVL=%ODI_SCM_CMDLVL%
rem
rem Run the passed command in a new cmd.exe.
rem
cmd.exe /c "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork2.bat"
set EXITSTATUS=%ERRORLEVEL%
rem echo =============================================================================
rem echo == back from command: %*
rem echo =============================================================================
rem echo CMDLVL=%ODI_SCM_CMDLVL%
rem
rem Return the passed command's exit status to the calling batch file.
rem
exit /b %EXITSTATUS%