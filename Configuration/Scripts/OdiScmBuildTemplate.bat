@echo off
set PROG=OdiScmBuild.bat
set IM=%PROG%: INFO:
set EM=%PROG%: ERROR:

set ODI_HOME=<OdiHomeDir>
set ODI_JAVA_HOME=<OdiJavaHomeDir>
set JAVA_HOME=<JavaHomeDir>
set ODI_SCM_INI=<OdiScmIniFile>
set ODI_SCM_HOME=<OdiScmHomeDir>
set ODI_SCM_JISQL_HOME=<OdiScmJisqlHomeDir>
set ORACLE_HOME=<OracleHomeDir>

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
echo %IM% using temporary directory ^<%TEMPDIR%^>

set EMPTYFILE=%TEMPDIR%\%RANDOM%_OdiScm_Empty.txt
type nul > %EMPTYFILE% 2>&1
if ERRORLEVEL 1 goto CreateEmptyFileFail
echo %IM% created empty file ^<%EMPTYFILE%^>
goto CreateEmptyFileOk

:CreateEmptyFileFail
echo %EM% cannot create empty file ^<%EMPTYFILE%^>
goto MainExitFail

:CreateEmptyFileOk
set MSG=executing OdiScm pre ODI object import repository back-up script "<OdiScmRepositoryBackUpBat>"
echo %IM% %MSG%
call <OdiScmRepositoryBackUpBat>
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiScm pre ODI object import script "<OdiScmGenScenPreImportBat>"
echo %IM% %MSG%
call <OdiScmGenScenPreImportBat>
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiScm ODI import script "<OdiImportScriptFile>"
echo %IM% %MSG%
call <OdiImportScriptFile>
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiScm ODI repository integrity validation script "<OdiScmValidateRepositoryIntegritySql>"
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\OdiScmValidateRepositoryIntegrity_StdOut_%YYYYMMDD%_%HHMM%.log
set STDERRFILE=<GenScriptRootDir>\OdiScmValidateRepositoryIntegrity_StdErr_%YYYYMMDD%_%HHMM%.log
call <OdiScmJisqlRepoBat> /b <OdiScmValidateRepositoryIntegritySql> %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto MainOdiScmValidateRepoFail
goto MainOdiScmValidateRepoChkStdErr

:MainOdiScmValidateRepoFail
echo %EM% Batch file ^<<OdiScmJisqlRepoBat>^> returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto MainExitFail

:MainOdiScmValidateRepoChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file ^<<OdiScmJisqlRepoBat>^> returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto MainOdiScmValidateRepoOk

echo %IM% StdErr content:
type %STDERRFILE%

goto MainExitFail

:MainOdiScmValidateRepoOk
echo %IM% Displaying output of repository validation check report script
echo %IM% StdOut content:
type %STDOUTFILE%

set MSG=executing OdiScm ODI repository integrity restoration script "<OdiScmRestoreRepositoryIntegritySql>"
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\OdiScmRestoreRepositoryIntegrity_StdOut_%YYYYMMDD%_%HHMM%.log
set STDERRFILE=<GenScriptRootDir>\OdiScmRestoreRepositoryIntegrity_StdErr_%YYYYMMDD%_%HHMM%.log
call <OdiScmJisqlRepoBat> /b <OdiScmRestoreRepositoryIntegritySql> %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto MainOdiScmRestoreRepoIntegFail
goto MainOdiScmRestoreRepoIntegChkStdErr

:MainOdiScmRestoreRepoIntegFail
echo %EM% Batch file ^<<OdiScmJisqlRepoBat>^> returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto MainExitFail

:MainOdiScmRestoreRepoIntegChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file ^<<OdiScmJisqlRepoBat>^> returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto MainOdiScmRestoreRepoIntegOk

echo %IM% StdErr content:
type %STDERRFILE%

goto MainExitFail

:MainOdiScmRestoreRepoIntegOk
set MSG=executing OdiScm ODI scenario generation script "<OdiScmGenScenPostImportBat>"
echo %IM% %MSG%
call <OdiScmGenScenPostImportBat>
if ERRORLEVEL 1 goto MainExitFail

set MSG=updating OdiScm local workspace metadata
echo %IM% %MSG%
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetIni.bat /b ImportControls OracleDIImportedRevision <OdiScmLatestChangeSet>
if ERRORLEVEL 1 goto MainExitFail

set MSG=updating OdiScm repository ChangeSet metadata
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\OdiScm_set_next_import_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScm_set_next_import_jisql_stderr_%YYYYMMDD%_%HHMM%.txt
call <OdiScmJisqlRepoBat> /b <OdiScmSetNextImportSql> %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto MainOdiScmSetNextImportFail
goto MainOdiScmSetNextImportChkStdErr

:MainOdiScmSetNextImportFail
echo %EM% Batch file ^<<OdiScmJisqlRepoBat>^> returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto MainExitFail

:MainOdiScmSetNextImportChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file ^<<OdiScmJisqlRepoBat>^> returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto MainOdiScmSetNextImportOk

echo %IM% StdErr content:
type %STDERRFILE%

goto MainExitFail

:MainOdiScmSetNextImportOk
:MainExitOk
echo %IM% OdiScm build process completed successfully
exit /b 0

:MainExitFail
echo %EM% failure executing OdiScm build process
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