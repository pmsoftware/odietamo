@echo off
setlocal
set FN=OdiScmGenScenPostImport
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

set EXITSTATUS=0
set FILENO=%RANDOM%

call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set EMPTYFILE=%TEMPDIR%\%RANDOM%_OdiScm_PreImport_EmptyFile.txt

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateEmptyFile.bat" "%EMPTYFILE%"
if ERRORLEVEL 1 (
	echo %EM% creating empty file ^<%EMPTYFILE%^> 1>&2
	goto ExitFail
)

set TLSOutput=
set TSOutput=

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\OdiScmGenScen20_Jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScmGenScen20_Jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiScmGenScenDeleteOldSql> %STDOUTFILE% %STDERRFILE%
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
	call :ExecBatchCommand %TSOutput%
)
endlocal enabledelayedexpansion
echo %IM% Completed execution of batch file commands with ^<%BATCHFILEERRCOUNT%^> errors
if %BATCHFILEERRCOUNT%==0 goto BatchFileCompleted20

set EXITSTATUS=1
goto ExitFail

:BatchFileCompleted20

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\OdiScmGenScen30_Jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScmGenScen30_Jisql_stderr_%YYYYMMDD%_%HHMM%.txt

set TEMPSCRIPT=%TEMPDIR%\OdiScmGenScen30MarkUpSourceObjects.sql
type "<OdiScmHomeDir>\Configuration\Scripts\OdiScmGenScen30MarkUpSourceObjects.sql" | sed s/"<OdiScmScenarioSourceMarkers>"/"%ODI_SCM_GENERATE_SCENARIO_SOURCE_MARKERS%"/g >%TEMPSCRIPT%
if ERRORLEVEL 1 (
	echo %EM% creating Scenario source object marking script file ^<%TEMPSCRIPT%^> 1>&2
	goto ExitFail
)

call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" "%TEMPSCRIPT%" %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 (
	echo %EM% Batch file OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL 1>&2
	echo %EM% Check StdOut content in file ^<%STDOUTFILE%^> 1>&2
	echo %EM% Check StdErr content in file ^<%STDERRFILE%^> 1>&2
	echo %EM% StdErr content: 1>&2
	type %STDERRFILE% 1>&2
	set EXITSTATUS=1
	goto ExitFail
)

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if ERRORLEVEL 1 goto StdErrNotEmpty30
goto StdErrEmpty30

:StdErrNotEmpty30
echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:StdErrEmpty30

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\OdiScmGenScen40_Jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScmGenScen40_Jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiScmGenScenNewSql> %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto BatchFileNotOk40
goto BatchFileOk40

:BatchFileNotOk40
echo %EM% Batch file OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL
echo %EM% Check StdOut content in file ^<%STDOUTFILE%^>
echo %EM% Check StdErr content in file ^<%STDERRFILE%^>
echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:BatchFileOk40

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if ERRORLEVEL 1 goto StdErrNotEmpty40
goto StdErrEmpty40

:StdErrNotEmpty40
echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:StdErrEmpty40

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
endlocal enabledelayedexpansion
echo %IM% Completed execution of batch file commands with ^<%BATCHFILEERRCOUNT%^> errors
if %BATCHFILEERRCOUNT%==0 goto BatchFileCompleted40

set EXITSTATUS=1
goto ExitFail

:BatchFileCompleted40

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\OdiScmGenScen50_Jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScmGenScen50_Jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiScmHomeDir>\Configuration\Scripts\OdiScmGenScen50Terminate.sql %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto BatchFileNotOk50
goto BatchFileOk50

:BatchFileNotOk50
echo %EM% Batch file OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL
echo %EM% Check StdOut content in file ^<%STDOUTFILE%^>
echo %EM% Check StdErr content in file ^<%STDERRFILE%^>
echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:BatchFileOk50

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto StdErrEmpty50

echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:StdErrEmpty50

echo %IM% Scenario Generation completed successfully
goto Exit

:ExitFail
echo %EM% Scenario build process has failed.
echo %EM% Check contents of the StdOut and StdErr files

:Exit
exit %IsBatchExit% %EXITSTATUS%

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

rem *************************************************************
:SetDateTimeStrings
rem *************************************************************
rem
rem Define unique file name suffixes.
rem
for /f "tokens=1,2,3 delims=/ " %%A in ('date /t') do ( 
	set Day=%%A
	set Month=%%B
	set Year=%%C
	set YYYYMMDD=%%C%%B%%A
)
rem
rem Remove trailing spaces.
rem
for /f "tokens=1 delims= " %%X in ('echo %YYYYMMDD%') do set YYYYMMDD=%%X

for /f "tokens=1,2,3 delims=:,. " %%A in ('echo %time%') do (
	set Hour=%%A  
	set Min=%%B  
	set HHMM=%%A%%B  
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
:TrimLeadingSpace
rem *************************************************************
set TrimLeadingSpaceOutput=%~1
setlocal enabledelayedexpansion
for /f "tokens=* delims= " %%g in ("%TrimLeadingSpaceOutput%") do set TrimLeadingSpaceOutput=%%g
for /l %%g in (1,1,100) do if "!TrimLeadingSpaceOutput:~0,1!"==" " set TrimLeadingSpaceOutput=!TrimLeadingSpaceOutput:~0!
endlocal enabledelayedexpansion
set TLSOutput=%TrimLeadingSpaceOutput%
goto :eof

rem *************************************************************
:TrimSpace
rem *************************************************************
set TrimSpaceOutput=%*
set TSOutput=%TrimSpaceOutput%
goto :eof

rem *************************************************************
:ExecBatchCommand
rem *************************************************************
rem
rem Execute a batch command read from a generated batch file.
rem 
echo %IM% ExecBatchCommand: Received command: %*
%*
if  ERRORLEVEL 1 goto ExecBatchCommandNotSuccess
goto ExecBatchCommandSuccess

:ExecBatchCommandNotSuccess
echo %EM% ExecBatchCommand: Command returned non-zero ERRORLEVEL
set /a BATCHFILEERRCOUNT=%BATCHFILEERRCOUNT%+1
goto ExecBatchCommandExit

:ExecBatchCommandSuccess
echo %IM% ExecBatchCommand: Command returned zero ERRORLEVEL

:ExecBatchCommandExit
rem
rem Exit the subroutine.
rem
goto :eof