@echo off

set IM=OdiSvnGenScenPostImport: INFO:
set EM=OdiSvnGenScenPostImport: ERROR:

set ODI_HOME=C:\MOI\Configuration\Tools\odi

set EXITSTATUS=0
set FILENO=%RANDOM%
set EMPTYFILE=C:\MOI\Configuration\EmptyFileDoNotDelete.txt
set TLSOutput=
set TSOutput=

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\odisvn_genscen_20_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\odisvn_genscen_20_jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call C:\MOI\Configuration\Scripts\MoiJisqlRepo.bat C:/MOI/Configuration/Scripts/odisvn_genscen_20_delete_old_scen_script.sql %STDOUTFILE% %STDERRFILE%
if not ERRORLEVEL 1 goto BatchFileOk20

echo %EM% Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
echo %EM% Check StdOut content in file ^<%STDOUTFILE%^>
echo %EM% Check StdErr content in file ^<%STDERRFILE%^>
echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:BatchFileOk20

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto StdErrEmpty20

echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

set /a BATCHFILEERRCOUNT=0

:StdErrEmpty20

set /a BATCHFILEERRCOUNT=0 >NUL 2>NUL

rem
rem Read the contents of the generated batch file and execute each line one at at time.
rem
setlocal enabledelayedexpansion
for /f "tokens=1 delims=" %%g in (%STDOUTFILE%) do (
	call :TrimSpace %%g
	echo %IM% Read command from stdout ^<%TSOutput%^>
	call :ExecBatchCommand %TSOutput%
)
endlocal enabledelayedexpansion
echo %IM% Completed execution of batch file commands with ^<%BATCHFILEERRCOUNT%^> errors
if %BATCHFILEERRCOUNT%==0 goto BatchFileCompleted20

set EXITSTATUS=1
goto ExitFail

:BatchFileCompleted20

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\odisvn_genscen_30_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\odisvn_genscen_30_jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call C:\MOI\Configuration\Scripts\MoiJisqlRepo.bat C:\MOI\Configuration\Scripts\odisvn_genscen_30_markup_source_objects.sql %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto BatchFileNotOk30
goto BatchFileOk30

:BatchFileNotOk30
echo %EM% Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
echo %EM% Check StdOut content in file ^<%STDOUTFILE%^>
echo %EM% Check StdErr content in file ^<%STDERRFILE%^>
echo %IM% StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:BatchFileOk30

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
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

set STDOUTFILE=<GenScriptRootDir>\odisvn_genscen_40_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\odisvn_genscen_40_jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call C:\MOI\Configuration\Scripts\MoiJisqlRepo.bat C:\MOI\Configuration\Scripts\odisvn_genscen_40_new_scen_script.sql %STDOUTFILE% %STDERRFILE%
if  ERRORLEVEL 1 goto BatchFileNotOk40
goto BatchFileOk40

:BatchFileNotOk40
echo %EM% Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
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
echo %IM% Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if  ERRORLEVEL 1 goto StdErrNotEmpty40
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
for /f "tokens=1 delims=" %%g in (%STDOUTFILE%) do (
	call :TrimSpace %%g
	echo %IM% Read command from stdout ^<%TSOutput%^>
	call :ExecBatchCommand %%g
)
endlocal enabledelayedexpansion
echo %IM% Completed execution of batch file commands with ^<%BATCHFILEERRCOUNT%^> errors
if %BATCHFILEERRCOUNT%==0 goto BatchFileCompleted40

set EXITSTATUS=1
goto ExitFail

:BatchFileCompleted40

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\odisvn_genscen_50_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\odisvn_genscen_50_jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call C:\MOI\Configuration\Scripts\MoiJisqlRepo.bat C:\MOI\Configuration\Scripts\odisvn_genscen_50_terminate.sql %STDOUTFILE% %STDERRFILE%
if  ERRORLEVEL 1 goto BatchFileNotOk50
goto BatchFileOk50

:BatchFileNotOk50
echo %EM% Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
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
echo %IM% Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
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
echo OdiSvnGenScenPostImport: Scenario build process has failed.
echo OdiSvnGenScenPostImport: Check contents of the StdOut and StdErr files

:Exit
exit /b %EXITSTATUS%

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
echo TrimSpace
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
pushd %ODI_HOME%\bin
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
popd
rem
rem Exit the subroutine.
rem
goto :eof