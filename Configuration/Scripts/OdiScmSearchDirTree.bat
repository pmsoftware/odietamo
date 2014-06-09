@echo off
rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
:ParamCodeMissing
	echo %EM% no search expression supplied 1>&2
	echo %EM% usage: %PROC% ^<search expression^> 1>&2
	goto ExitFail
)

call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat
if ERRORLEVEL 1 (
	echo %EM% defining working directory 1>&2
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%PROC%_files.txt
set TEMPERRFILE=%TEMPDIR%\%PROC%_files.stderr

rem
rem Get a list of all files (no directories) that we'll handle later to deal with spaces.
rem
dir /s /a-d /b >%TEMPFILE% 2>NUL
if ERRORLEVEL 1 (
	echo %EM% getting list of directories and files 1>&2
	goto ExitFail
)

rem
rem Search each file.
rem
setlocal enabledelayedexpansion

for /f "tokens=*" %%A in (%TEMPFILE%) do (
	del "%TEMPERRFILE%" /q 2>NUL
	%windir%\system32\find /i "%1" "%%A" 1>NUL 2>"%TEMPERRFILE%"
	set EXITSTATUS=!ERRORLEVEL!
	fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% find command returned stderr text  1>&2
		goto ExitFail
	)
	rem if ERRORLEVEL was 1 and there was no stderr output then the find command didn't find the string.
	if "!EXITSTATUS!" == "0" (
		echo %IM% found search text in file ^<%%A^>
	)
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1