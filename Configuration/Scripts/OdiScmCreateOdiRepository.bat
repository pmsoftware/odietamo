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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if not "%ARGC%" == "1" (
	echo %EM% master/work repository ID must be specified 1>&2
	echo %EM% usage: %PROC% ^<master/work repository ID^> 1>&2
	goto ExitFail
)

REM
REM Check basic environment requirements.
REM
if "%ODI_SCM_HOME%" == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_HOME is not set 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_JAVA_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_JAVA_HOME is not set 1>&2
	goto ExitFail
)

rem
rem Note that we redirect stderr to stdout when using the ODI SDK to create a repository.
rem For some reason info messages are written to stderr.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecJava.bat^" /p odietamo.OdiScm.CreateRepository %ODI_SCM_ORACLEDI_USER% %ODI_SCM_ORACLEDI_PASS% %ODI_SCM_ORACLEDI_SECU_URL% %ODI_SCM_ORACLEDI_SECU_DRIVER% %ODI_SCM_ORACLEDI_SECU_USER% %ODI_SCM_ORACLEDI_SECU_PASS% %ARGV1% %ODI_SCM_ORACLEDI_SECU_WORK_REP% %ODI_SCM_ORACLEDI_ADMIN_USER% %ODI_SCM_ORACLEDI_ADMIN_PASS% 2>&1
if ERRORLEVEL 1 (
	echo %EM% creating ODI repository 1>&2
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% starts
exit %IsBatchExit% 1