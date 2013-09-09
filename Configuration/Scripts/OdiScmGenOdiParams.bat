@echo off
rem
rem Create a copy of the ODI odiparams.bat batch script with hard coded values for the repository
rem connection details.
rem

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

rem
rem Validate arguments.
rem
if "%ARGV1%" == "" (
	echo %EM% usage: %FN% ^<output path and file name^>
	goto ExitFail
)

set OUTFILE=%ARGV1%

rem
rem Check repository connection details environment.
rem
if "%ODI_SCM_ORACLEDI_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_HOME is not set
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_SECU_DRIVER%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_SECU_DRIVER is not set
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_SECU_URL%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_SECU_URL is not set
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_SECU_USER%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_SECU_USER is not set
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_SECU_ENCODED_PASS%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_SECU_ENCODED_PASS is not set
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_SECU_WORK_REP%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_SECU_WORK_REP is not set
	goto ExitFail
)

REM
REM Null master repository passwords are allowed. Warn if so.
REM
if "%ODI_SCM_ORACLEDI_ENCODED_PASS%" == "" (
	echo %WM% environment variable ODI_SCM_ORACLEDI_ENCODED_PASS is not set
)

if "%ODI_SCM_ORACLEDI_USER%" == "" (
	echo %EM% environment variable ODI_SCM_ORACLEDI_USER is not set
	goto ExitFail
)

if not EXIST "%ODI_SCM_ORACLEDI_HOME%\bin\odiparams.bat" (
	echo %EM% ODI odiparams.bat batch script not found in directory ^<%ODI_SCM_ORACLEDI_HOME%\bin^>
	goto ExitFail
)

rem
rem Ensure the output file can be written to.
rem
REM if EXIST "%OUTFILE%" (
	REM del /f /q "%OUTFILE%" >NUL 2>NUL
	REM if ERRORLEVEL 1 (
		REM echo %EM% deleting existing output file ^<%OUTFILE%^>
		REM goto ExitFail
	REM )
REM )

powershell -file "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenOdiParams.ps1" "%OUTFILE%"
if ERRORLEVEL 1 (
	echo %EM% executing PowerShell script ^<%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenOdiParams.ps1^>
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends
exit %IsBatchExit% 1