@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts
echo on
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat" /t
if ERRORLEVEL 1 (
	echo %EM% definining temporary working directory 1>&2
	goto ExitFail
)

for /f "tokens=1" %%g in ('%ODI_SCM_TOOLS_UNXUTILS_HOME%\usr\local\wbin\find "%TEMPDIR%" -maxdepth 1 -type d -mtime +7 -print') do (
	echo %IM% deleting directory tree ^<%%g^>
	rd /s /q "%%g"
	if ERRORLEVEL 1 (
		echo %EM% deleting directory tree ^<%%g^> 1>&2
		goto ExitFail
	)
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1