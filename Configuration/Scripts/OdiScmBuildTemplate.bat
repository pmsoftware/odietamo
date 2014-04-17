@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

set ODI_SCM_ORACLEDI_HOME=<OdiHomeDir>
set ODI_SCM_ORACLEDI_JAVA_HOME=<OdiJavaHomeDir>
set ODI_SCM_INI=<OdiScmIniFile>
set ODI_SCM_HOME=<OdiScmHomeDir>
set ODI_SCM_TOOLS_JISQL_HOME=<OdiScmJisqlHomeDir>
set ODI_SCM_TOOLS_JISQL_JAVA_HOME=<OdiScmJisqlJavaHomeDir>
set ODI_SCM_TOOLS_ORACLE_HOME=<OracleHomeDir>

set ODI_SCM_TOOLS_FITNESSE_JAVA_HOME=<OdiScmFitNesseJavaHomeDir>
set ODI_SCM_TOOLS_FITNESSE_HOME=<OdiScmFitNesseHomeDir>
set ODI_SCM_TEST_FITNESSE_OUTPUT_FORMAT=<OdiScmFitNesseOutputFormat>
set ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT=<OdiScmFitNesseRootPageRoot>
set ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME=<OdiScmFitNesseRootPageName>
set ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME=<OdiScmFitNesseUnitTestPageName>

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"
set STDOUTFILE=<GenScriptRootDir>\OdiScmValidateRepositoryIntegrity_StdOut_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.log
set STDERRFILE=<GenScriptRootDir>\OdiScmValidateRepositoryIntegrity_StdErr_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.log
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"
set STDOUTFILE=<GenScriptRootDir>\OdiScmRestoreRepositoryIntegrity_StdOut_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.log
set STDERRFILE=<GenScriptRootDir>\OdiScmRestoreRepositoryIntegrity_StdErr_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.log
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
if ERRORLEVEL 1 (
	echo %IM% StdErr content:
	type %STDERRFILE%
	goto MainExitFail
)

rem
rem Execute the post import Scenario generation script.
rem
set MSG=executing OdiScm ODI scenario generation script "<OdiScmGenScenPostImportBat>"
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmGenScenPostImportBat>"
if ERRORLEVEL 1 goto MainExitFail

rem
rem Execute any user specified ODI standards check/report script.
rem Note that the user might build the script to intentionally cause the build to fail.
rem
setlocal enabledelayedexpansion
if not "<OdiStandardsCheckScript>" == "" (
	set MSG=executing user defined ODI standards check/report script "<OdiStandardsCheckScript>"
	echo %IM% %MSG%
	rem
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"
	set STDOUTFILE=<GenScriptRootDir>\OdiScmStandardsCheck_StdOut_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.log
	set STDERRFILE=<GenScriptRootDir>\OdiScmStandardsCheck_StdErr_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.log
	rem
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmJisqlRepoBat>" <OdiStandardsCheckScript> !STDOUTFILE! !STDERRFILE!
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
rem Generate the unit test execution script.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmHomeDir>\Configuration\Scripts\OdiScmGenerateUnitTestExecs.bat" /p "<OdiScmUnitTestExecBat>" "<OdiScmGenerateBuildTestScope>"
if ERRORLEVEL 1 (
	echo %EM% generating unit test execution script ^<OdiScmUnitTestExecBat^>
	goto MainExitFail
)

rem
rem Update the ODI repository flush control metadata after the import metadata if the user preference is set.
rem
set MSG=updating OdiScm flush control metadata
if /i "<OdiScmGenerateImportResetsFlushControl>" == "Yes" (
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"<OdiScmHomeDir>\Configuration\Scripts\OdiScmPrimeRepoFlush.bat^" /p both
	if ERRORLEVEL 1 (
		echo %EM% %MSG%
		goto ExitFail
	)
)

set MSG=updating OdiScm local working copy metadata
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"<OdiScmHomeDir>\Configuration\Scripts\OdiScmSetIni.bat^" /p Import$Controls OracleDI$Imported$Revision <OdiScmLatestChangeSet>
if ERRORLEVEL 1 goto MainExitFail

set MSG=updating OdiScm repository ChangeSet metadata
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"
set STDOUTFILE=<GenScriptRootDir>\OdiScm_set_next_import_jisql_stdout_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.txt
set STDERRFILE=<GenScriptRootDir>\OdiScm_set_next_import_jisql_stderr_%SDTSYYYYMMDD%_%SDTSHHMMSSFF%.txt
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
echo %IM% unit test execution script is ^<<OdiScmUnitTestExecBat>^>
echo %IM% ends
exit %IsBatchExit% 0

:MainExitFail
echo %EM% failure executing OdiScm build process
echo %EM% %MSG%
echo %IM% ends
exit %IsBatchExit% 1