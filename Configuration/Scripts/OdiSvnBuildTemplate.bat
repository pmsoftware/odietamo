@echo off
set PROG=OdiSvnBuild.bat
set IM=%PROG%: INFO:
SET EM=%PROG%: ERROR:

set EMPTYFILE=C:\MOI\Configuration\EmptyFileDoNotDelete.txt

set MSG=executing OdiSvn pre ODI object import repository back-up script "<OdiSvnRepositoryBackUpBat>"
echo %IM% %MSG%
call <OdiSvnRepositoryBackUpBat>
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiSvn pre ODI object import script "<OdiSvnGenScenPreImportBat>"
echo %IM% %MSG%
call <OdiSvnGenScenPreImportBat>
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiSvn ODI import script "<OdiImportScriptFile>"
echo %IM% %MSG%
call <OdiImportScriptFile>
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiSvn ODI repository integrity validation script "<OdiSvnValidateRepositoryIntegritySql>"
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\OdiSvnValidateRepositoryIntegrity_StdOut_%YYYYMMDD%_%HHMM%.log
set STDERRFILE=<GenScriptRootDir>\OdiSvnValidateRepositoryIntegrity_StdErr_%YYYYMMDD%_%HHMM%.log
call <OdiScmJisqlRepoBat> /b <OdiSvnValidateRepositoryIntegritySql> %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto MainOdiSvnValidateRepoFail
goto MainOdiSvnValidateRepoChkStdErr

:MainOdiSvnValidateRepoFail
echo %EM% Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto MainExitFail

:MainOdiSvnValidateRepoChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto MainOdiSvnValidateRepoOk

echo %IM% StdErr content:
type %STDERRFILE%

goto MainExitFail

:MainOdiSvnValidateRepoOk
echo %IM% Displaying output of repository validation check report script
echo %IM% StdOut content:
type %STDOUTFILE%

set MSG=executing OdiSvn ODI repository integrity restoration script "<OdiSvnRestoreRepositoryIntegritySql>"
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\OdiSvnRestoreRepositoryIntegrity_StdOut_%YYYYMMDD%_%HHMM%.log
set STDERRFILE=<GenScriptRootDir>\OdiSvnRestoreRepositoryIntegrity_StdErr_%YYYYMMDD%_%HHMM%.log
call <OdiScmJisqlRepoBat> <OdiSvnRestoreRepositoryIntegritySql> %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto MainOdiSvnRestoreRepoIntegFail
goto MainOdiSvnRestoreRepoIntegChkStdErr

:MainOdiSvnRestoreRepoIntegFail
echo %EM% Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto MainExitFail

:MainOdiSvnRestoreRepoIntegChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto MainOdiSvnRestoreRepoIntegOk

echo %IM% StdErr content:
type %STDERRFILE%

goto MainExitFail

:MainOdiSvnRestoreRepoIntegOk
set MSG=executing OdiSvn ODI scenario generation script "<OdiSvnGenScenPostImportBat>"
echo %IM% %MSG%
call <OdiSvnGenScenPostImportBat>
if ERRORLEVEL 1 goto MainExitFail

set MSG=updating OdiSvn local workspace metadata
echo %IM% %MSG%
rem We use tee -a, from UnixUtils, so that we can write to a file without using CMD.EXE
rem stdout redirection because if an error occurs using this mechanism it cannot be detected
rem by checking ERRORLEVEL.
cat <SCMConfigurationFile> | awk <OdiScmUpdateIniAwk> -v KeyValue <OdiSvnLatestChangeSet> | tee <SCMConfigurationFile> >NUL 2>&1
if ERRORLEVEL 1 goto MainExitFail

set MSG=updating OdiSvn repository ChangeSet metadata
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\odisvn_set_next_import_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\odisvn_set_next_import_jisql_stderr_%YYYYMMDD%_%HHMM%.txt
call <OdiScmJisqlRepoBat> /b <OdiSvnSetNextImportSql> %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto MainOdiSvnSetNextImportFail
goto MainOdiSvnSetNextImportChkStdErr

:MainOdiSvnSetNextImportFail
echo %EM% Batch file MoiJisqlRepo.bat returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto MainExitFail

:MainOdiSvnSetNextImportChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file MoiJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto MainOdiSvnSetNextImportOk

echo %IM% StdErr content:
type %STDERRFILE%

goto MainExitFail

:MainOdiSvnSetNextImportOk
:MainExitOk
echo %IM% OdiSvn build process completed successfully
exit /b 0

:MainExitFail
echo %EM% failure executing OdiSvn build process
echo %EM% %MSG%
exit /b 1

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