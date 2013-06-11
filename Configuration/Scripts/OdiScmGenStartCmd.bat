@echo off
REM
REM Create a copy of the ODI startcmd.bat batch script with hard coded values for the repository
REM connection details.
REM
setlocal
set FN=OdiScmGenStartCmd.bat
set IM=%FN%: INFO:
set EM=%FN%: ERROR:
set WM=%FN%: WARNING:

set ISBATCHEXIT=

if "%1" == "/b" goto IsBatchExit
if "%1" == "/B" goto IsBatchExit

goto IsNotBatchExit

:IsBatchExit
set ISBATCHEXIT=/b
shift

:IsNotBatchExit
if "%1" == "" (
	echo %EM% usage: %FN% ^<output path and file name^>
	goto ExitFail
)

set OUTFILE=%1

if "%ODI_HOME%" == "" (
	echo %EM% environment variable ODI_HOME is not set
	goto ExitFail
)

if "%ODI_SECU_DRIVER%" == "" (
	echo %EM% environment variable ODI_SECU_DRIVER is not set
	goto ExitFail
)

if "%ODI_SECU_URL%" == "" (
	echo %EM% environment variable ODI_SECU_URL is not set
	goto ExitFail
)

if "%ODI_SECU_USER%" == "" (
	echo %EM% environment variable ODI_SECU_USER is not set
	goto ExitFail
)

REM
REM Null master repository passwords are allowed. Warn if so.
REM
if "%ODI_SECU_ENCODED_PASS%" == "" (
	echo %WM% environment variable ODI_SECU_ENCODED_PASS is not set
)

if "%ODI_USER%" == "" (
	echo %EM% environment variable ODI_USER is not set
	goto ExitFail
)

if "%ODI_ENCODED_PASS%" == "" (
	echo %EM% environment variable ODI_ENCODED_PASS is not set
	goto ExitFail
)

if "%ODI_SECU_WORK_REP%" == "" (
	echo %EM% environment variable ODI_SECU_WORK_REP is not set
	goto ExitFail
)

which cat.exe >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% checking for presence of cat command
	goto ExitFail
)

if not EXIST "%ODI_HOME%\bin\startcmd.bat" (
	echo %EM% ODI startcmd.bat batch script not found in directory ^<%ODI_HOME%\bin^>
	goto ExitFail
)

if "%TEMP%" == "" (
	if "%TMP%" == "" (
		set TEMPDIR=%CD%
	) else (
		set TEMPDIR=%TMP%
	)
) else (
	set TEMPDIR=%TEMP%
)

rem
rem Ensure the output file can be written to.
rem
if EXIST "%OUTFILE%" (
	del /f /q "%OUTFILE%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing output file ^<%OUTFILE%^>
		goto ExitFail
	)
)

powershell -file "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.ps1" "%OUTFILE%"
if ERRORLEVEL 1 (
	echo %EM% executing PowerShell script ^<%ODI_SCM_HOME\Configuration\Scripts\OdiScmGenStartCmd.ps1^>
	goto ExitFail
)

:ExitOk
exit %ISBATCHEXIT% 0

:ExitFail
exit %ISBATCHEXIT% 1
