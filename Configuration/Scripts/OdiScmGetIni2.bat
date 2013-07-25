@echo off
rem
rem Get a configuration INI file entry.
rem

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

rem echo %DM% starts >CON

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ODI_SCM_INI%" == "" (
	echo %EM% configuration INI file environment variable ODI_SCM_INI file is not set 1>&2
	goto ExitFail
)

set SectionStartLineNumber=

for /f %%g in ('wc -l %ODI_SCM_INI%') do (
	set TotalLineCount=%%g
)

for /f %%g in ('grep -n ^\[%ARGV1%\]$ %ODI_SCM_INI% ^| cut -f1 -d: ^| head -1') do (
	set SectionStartLineNumber=%%g
)

set /a IniFileLines=%TotalLineCount% - %SectionStartLineNumber% + 1

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\%PROC%.txt

tail -%IniFileLines% %ODI_SCM_INI% > %TEMPFILE%

for /f "tokens=1 delims=:" %%g in ('grep -n ^^%ARGV2%= %TEMPFILE% ^| head -1') do (
	set KeyStartLineNumber=%%g
)

for /f "tokens=* delims=;" %%g in ('head -%KeyStartLineNumber% %TEMPFILE% ^| tail -1 ^| cut -f2 -d^=') do (
	echo %%g
)

:ExitOk
rem echo %DM% exiting successfully >CON
exit %IsBatchExit% 0

:ExitFail
rem echo %DM% exiting with failure >CON
exit %IsBatchExit% 1