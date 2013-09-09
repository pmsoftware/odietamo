@echo off

if not DEFINED ODI_SCM_CMDLVL (
	set ODI_SCM_CMDLVL=0
)

if not DEFINED ODI_SCM_CMD (
	echo OdiScmFork: ERROR: no command string passed
	exit /b 1
)

rem
rem Run the passed command.
rem
%ODI_SCM_CMD%
set EXITSTATUS=%ERRORLEVEL%

rem
rem Return the passed command's exit status to the calling batch file.
rem
exit %EXITSTATUS%