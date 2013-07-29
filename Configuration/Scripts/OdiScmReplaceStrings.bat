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

if not "%ARGC%" == "2" (
	echo %EM% usage: %PROC% ^<from string^> ^<to string^>
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory
	goto ExitFail
)

pushd %ODI_SCM_HOME%\Configuration\Scripts

for /f %%g in ('find . -name OdiScm*.bat') do (
	cat %%g | sed s/%ARGV1%/%ARGV2%/g >%TEMPDIR%\%%g.1
	cat %TEMPDIR%\%%g.1 >%%g
)

for /f %%g in ('find . -name OdiScm*.ps1') do (
	cat %%g | sed s/%ARGV1%/%ARGV2%/g >%TEMPDIR%\%%g.1
	cat %TEMPDIR%\%%g.1 >%%g
)

popd
pushd %ODI_SCM_HOME%\Configuration\Demo

for /f %%g in ('find . -name OdiScm*.bat') do (
	cat %%g | sed s/%ARGV1%/%ARGV2%/g >%TEMPDIR%\%%g.1
	cat %TEMPDIR%\%%g.1 >%%g
)

for /f %%g in ('find . -name OdiScm*.ps1') do (
	cat %%g | sed s/%ARGV1%/%ARGV2%/g >%TEMPDIR%\%%g.1
	cat %TEMPDIR%\%%g.1 >%%g
)

popd

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1