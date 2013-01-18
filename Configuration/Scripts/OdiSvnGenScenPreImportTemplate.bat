@echo off

set EXITSTATUS=0
set FILENO=%RANDOM%
set EMPTYFILE=C:\MOI\Configuration\EmptyFileDoNotDelete.txt

call :SetDateTimeStrings

set STDOUTFILE=<GenScriptRootDir>\odisvn_genscen_10_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\odisvn_genscen_10_jisql_stderr_%YYYYMMDD%_%HHMM%.txt

call C:\MOI\Configuration\Scripts\MoiJisqlRepo.bat C:\MOI\Configuration\Scripts\odisvn_genscen_10_initialise.sql %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto BatchFileNotOk10
goto BatchFileOk10

:BatchFileNotOk10
echo OdiSvn_GenScen_PreImport: ERROR: Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
echo OdiSvn_GenScen_PreImport: INFO: StdErr content:
type %STDERRFILE%

set EXITSTATUS=1
goto ExitFail

:BatchFileOk10

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo OdiSvn_GenScen_PreImport: INFO: Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL

if ERRORLEVEL 1 goto StdErrNotEmpty10
goto StdErrEmpty10

:StdErrNotEmpty10
echo OdiSvn_GenScen_PreImport: INFO: StdErr content:
type %STDERRFILE%
set EXITSTATUS=1
goto ExitFail

:StdErrEmpty10

echo OdiSvn_GenScen_PreImport: INFO: StdOut content:
type %STDOUTFILE%

echo OdiSvn_GenScen_PreImport: Scenario generation initialisation completed successfully.
goto Exit

:ExitFail

:Exit
exit /b %EXITSTATUS%

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