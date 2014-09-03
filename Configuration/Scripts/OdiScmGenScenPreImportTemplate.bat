@echo off
setlocal
set FN=OdiScmGenScenPreImport
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

echo %IM% starts

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

set EXITSTATUS=0
set FILENO=%RANDOM%

if "%TEMP%" == "" goto NoTempDir
set TEMPDIR=%TEMP%
goto GotTempDir

:NoTempDir
if "%TMP%" == "" goto NoTmpDir
set TEMPDIR=%TMP%
goto GotTempDir

:NoTmpDir
set TEMPDIR=%CD%

:GotTempDir
set EMPTYFILE=%TEMPDIR%\%RANDOM%_OdiScm_PreImport_EmptyFile.txt

type NUL > %EMPTYFILE% 2>&1
if ERRORLEVEL 1 goto CreateEmptyFileFail
goto CreateEmptyFileOk

:CreateEmptyFileFail
echo %EM% creating empty file ^<%EMPTYFILE%^>
goto ExitFail

:CreateEmptyFileOk
call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\OdiScmGenScen10_Jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScmGenScen10_Jisql_stderr_%YYYYMMDD%_%HHMM%.txt

rem echo %IM% executing command: call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiScmHomeDir>\Configuration\Scripts\OdiScmGenScen10Initialise.sql %STDOUTFILE% %STDERRFILE%
call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiScmHomeDir>\Configuration\Scripts\OdiScmGenScen10Initialise.sql %STDOUTFILE% %STDERRFILE%
set EXITSTATUS=%ERRORLEVEL%
echo %IM% command exited with status ^<%EXITSTATUS%^>
if not "%EXITSTATUS%" == "0" goto BatchFileNotOk10
rem if ERRORLEVEL 1 goto BatchFileNotOk10
goto BatchFileOk10

:BatchFileNotOk10
echo %EM% OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:BatchFileOk10
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL

if ERRORLEVEL 1 goto StdErrNotEmpty10
goto StdErrEmpty10

:StdErrNotEmpty10
echo %IM% stdErr content:
type %STDERRFILE%
set EXITSTATUS=1
goto ExitFail

:StdErrEmpty10

echo %IM% stdOut content:
type %STDOUTFILE%

rem
rem Insert the IDs of source objects that will be imported and could have existing Scenarios.
rem
set STDOUTFILE=<GenScriptRootDir>\OdiScmGenScen15_Jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScmGenScen15_Jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" "<OdiScmGenScenPreImpDelOldSql>" %STDOUTFILE% %STDERRFILE%
set EXITSTATUS=%ERRORLEVEL%
echo %IM% command exited with status ^<%EXITSTATUS%^>
if not "%EXITSTATUS%" == "0" (
	goto ExitFail
)

rem
rem Generate batch file commands to delete any Scenarios for objects that will be imported and don't
rem have the marker to allow them to retain their Scenario on import/export.
rem
call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\OdiScmGenScen17_Jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScmGenScen17_Jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" "<OdiScmGenScenPreImpDelOldBatSql>" %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 (
	echo %EM% Batch file OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL 1>&2
	echo %EM% Check StdOut content in file ^<%STDOUTFILE%^> 1>&2
	echo %EM% Check StdErr content in file ^<%STDERRFILE%^> 1>&2
	echo %IM% StdErr content: 1>&2
	type %STDERRFILE% 1>&2
	set EXITSTATUS=1
	goto ExitFail
)

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% StdErr content: 1>&2
	type %STDERRFILE% 1>&2
	set EXITSTATUS=1
	goto ExitFail
)

set /a BATCHFILEERRCOUNT=0 >NUL 2>NUL

rem
rem Read the contents of the generated batch file and execute each line one at at time.
rem
setlocal enabledelayedexpansion
echo %IM% reading commands from file ^<%STDOUTFILE%^>
for /f "tokens=1 delims=" %%g in (%STDOUTFILE%) do (
	call :TrimSpace %%g
	echo %IM% Read command from stdout ^<!TSOutput!^>
	call :ExecBatchCommand !TSOutput!
)











echo %IM% pre import actions completed successfully.
goto Exit

:ExitFail

:Exit
exit %IsBatchExit% %EXITSTATUS%

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

:SetDateTimeStrings
rem
rem Define unique file name suffixes.
rem
for /f "tokens=1,2,3 delims=/ " %%A in ('date /t') do ( 
	set Day=%%A
	set Month=%%B
	set Year=%%C
	set YYYYMMDD=%%C%%B%%A
)
for /f "tokens=1,2 delims=: " %%A in ('time /t') do ( 
	set Hour=%%A
	set Minute=%%B
	set HHMM=%%B%%A
)
rem
rem Remove trailing spaces.
rem
for /f "tokens=1 delims= " %%X in ('echo %HHMM%') do set HHMM=%%X

rem
rem Exit the subroutine.
rem
goto :eof

rem *************************************************************
:ExecBatchCommand
rem *************************************************************
rem
rem Execute a batch command read from a generated batch file.
rem 
echo %IM% date ^<%date%^> time ^<%time%^>
echo %IM% subroutine ExecBatchCommand received command ^<%*^>

%*
if ERRORLEVEL 1 (
	echo %EM% ExecBatchCommand: Command returned non-zero ERRORLEVEL
	set /a BATCHFILEERRCOUNT=%BATCHFILEERRCOUNT%+1
	goto ExecBatchCommandExit
)

echo %IM% ExecBatchCommand: Command returned zero ERRORLEVEL

:ExecBatchCommandExit
rem
rem Exit the subroutine.
rem
goto :eof