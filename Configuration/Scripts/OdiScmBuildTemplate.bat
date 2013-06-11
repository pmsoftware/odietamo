@echo off
set FN=OdiScmBuild
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

echo %IM% starts

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

set ODI_HOME=<OdiHomeDir>
set ODI_JAVA_HOME=<OdiJavaHomeDir>
set ODI_SCM_INI=<OdiScmIniFile>
set ODI_SCM_HOME=<OdiScmHomeDir>
set ODI_SCM_JISQL_HOME=<OdiScmJisqlHomeDir>
set ODI_SCM_JISQL_JAVA_HOME=<OdiScmJisqlJavaHomeDir>
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmRepositoryBackUpBat>"
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiScm pre ODI object import script "<OdiScmGenScenPreImportBat>"
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmGenScenPreImportBat>"
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiScm ODI import script "<OdiImportScriptFile>"
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiImportScriptFile>"
if ERRORLEVEL 1 goto MainExitFail

set MSG=executing OdiScm ODI repository integrity validation script "<OdiScmValidateRepositoryIntegritySql>"
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\OdiScmValidateRepositoryIntegrity_StdOut_%YYYYMMDD%_%HHMM%.log
set STDERRFILE=<GenScriptRootDir>\OdiScmValidateRepositoryIntegrity_StdErr_%YYYYMMDD%_%HHMM%.log
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" /b <OdiScmValidateRepositoryIntegritySql> %STDOUTFILE% %STDERRFILE%
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiScmRestoreRepositoryIntegritySql> %STDOUTFILE% %STDERRFILE%
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
if not ERRORLEVEL 1 goto MainOdiScmOdiStandardsCheck

echo %IM% StdErr content:
type %STDERRFILE%

goto MainExitFail

:MainOdiScmOdiStandardsCheck
rem
rem Execute any user specified ODI standards check/report script.
rem Note that the user might build the script to intentionally cause the build to fail.
rem
if not "<OdiStandardsCheckScript>" == "None" (
	set MSG=executing user defined ODI standards check/report script "<OdiStandardsCheckScript>"
	echo %IM% %MSG%
	rem
	call :SetDateTimeStrings
	set STDOUTFILE=<GenScriptRootDir>\OdiScmStandardsCheck_StdOut_%YYYYMMDD%_%HHMM%.log
	set STDERRFILE=<GenScriptRootDir>\OdiScmStandardsCheck_StdErr_%YYYYMMDD%_%HHMM%.log
	rem
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiStandardsCheckScript> %STDOUTFILE% %STDERRFILE%
	if ERRORLEVEL 1 (
		echo %EM% Batch file ^<<OdiScmJisqlRepoBat>^> returned non-zero ERRORLEVEL
		echo %IM% whilst running ODI standards check/report SQL script ^<<OdiStandardsCheckScript>^>
		echo %IM% StdErr content:
		type %STDERRFILE%
		goto MainExitFail
	)
	rem
	rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
	rem 
	rem echo %IM% Batch file ^<<OdiScmJisqlRepoBat>^> returned zero ERRORLEVEL
	fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %IM% StdErr content:
		type %STDERRFILE%
		goto MainExitFail
	)
)

rem
rem Execute the post import Scenario generation script.
rem
:MainOdiScmRestoreRepoIntegOk
set MSG=executing OdiScm ODI scenario generation script "<OdiScmGenScenPostImportBat>"
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmGenScenPostImportBat>"
if ERRORLEVEL 1 goto MainExitFail

set MSG=updating OdiScm local workspace metadata
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetIni.bat" ImportControls OracleDIImportedRevision <OdiScmLatestChangeSet>
if ERRORLEVEL 1 goto MainExitFail

set MSG=updating OdiScm repository ChangeSet metadata
echo %IM% %MSG%
call :SetDateTimeStrings
set STDOUTFILE=<GenScriptRootDir>\OdiScm_set_next_import_jisql_stdout_%YYYYMMDD%_%HHMM%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScm_set_next_import_jisql_stderr_%YYYYMMDD%_%HHMM%.txt
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiScmSetNextImportSql> %STDOUTFILE% %STDERRFILE%
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
echo %IM% ends
exit %IsBatchExit% 0

:MainExitFail
echo %EM% failure executing OdiScm build process
echo %EM% %MSG%
echo %IM% ends
exit %IsBatchExit% 1

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