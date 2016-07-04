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

rem
rem Source the working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set DEMO_ENV1_INI=%TEMPDIR%\OdiScmImportStandardOdiDemoRepo1.ini

copy "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini" "%DEMO_ENV1_INI%" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying demo environment 1 configuration INI file to ^<%DEMO_ENV1_INI%^> 1>&2
	goto ExitFail
)

set DEMO_ENV2_INI=%TEMPDIR%\OdiScmImportStandardOdiDemoRepo2.ini

copy "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo2.ini" "%DEMO_ENV2_INI%" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying demo environment 2 configuration INI file to temporary working directory ^<%DEMO_ENV2_INI%^> 1>&2
	goto ExitFail
)

set ODI_DEMO_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmExportStandardOdiDemo.ini

if "%BeVerbose%" == "TRUE" (
	set VerboseSwitch=/v
) else (
	set VerboseSwitch=
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Demo\OdiScmDemo1FastForward.bat" /p %VerboseSwitch% "%DEMO_ENV1_INI%" "%DEMO_ENV2_INI%" "%ODI_DEMO_INI%"
if ERRORLEVEL 1 (
	echo %EM% executing demo 1 Fast Forward script 1>&2
	goto ExitFail
)

set DEMO_BASE=C:\OdiScmWalkThrough
set DEMO_HSQL_ROOT=%DEMO_BASE%\DemoHSQL

if EXIST "%DEMO_HSQL_ROOT%" (
	echo %IM% deleting existing demo HSQL root directory ^<%DEMO_HSQL_ROOT%^>
	rd /s /q "%DEMO_HSQL_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing demo HSQL root directory ^<%DEMO_HSQL_ROOT%^> 1>&2
		goto ExitFail
	)
)

md "%DEMO_HSQL_ROOT%\hsql"
if ERRORLEVEL 1 (
	echo %EM% creating demo HSQL hsql directory ^<%DEMO_HSQL_ROOT%\hsql^> 1>&2
	goto ExitFail
)

rem
rem Set the environment for the demo source system database.
rem
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\Demo4\OdiScmStandardOdiDemoSourceSystem.ini
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
set EXITSTATUS=%ERRORLEVEL%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

if not "%EXITSTATUS%" == "0" (
	echo %EM% setting environment for demo source system environment 1>&2
	goto ExitFail
)

rem
rem Copy the standard ODI demo files after setting the environment in this shell level (ODI_SCM_ORACLEDI_VERSION is required).
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Demo\OdiScmCopyOdiDemoDbFiles.bat" /p "%DEMO_HSQL_ROOT%\hsql"
if ERRORLEVEL 1 (
	echo %EM% copying ODI standard demo HSQL database files to demo hsql directory ^<%DEMO_HSQL_ROOT%\hsql^> 1>&2
	goto ExitFail
)

set TEMPJARFILE=%TEMPDIR%\%PROC%_ClassPath.jar
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat" /p "%TEMPJARFILE%" >NUL
if ERRORLEVEL 1 (
	echo %EM% creating class path JAR file for demo source system environment
	goto ExitFail
)

rem
rem Start the demo source system database.
rem Note that we use a "file:" based copy of the demo database instead of a "mem:" type so we get to show the tear down of the existing structure.
rem
start "Demo Source System" "%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" -classpath "%TEMPJARFILE%" org.hsqldb.Server -database.0 file:"%DEMO_HSQL_ROOT%\hsql\demo_src" -port 20001
if ERRORLEVEL 1 (
	echo %EM% starting demo source system database 1>&2
	goto ExitFail
)

rem
rem Pause, for a while, for the asynchronous database start up processes to complete.
rem
echo %IM% pausing for demo source system database start up asynchronous process
sleep 15

rem
rem Set the environment for the demo target system database.
rem
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\Demo4\OdiScmStandardOdiDemoTargetSystem.ini
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
if ERRORLEVEL 1 (
	echo %EM% setting environment for demo environment 1 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

set TEMPJARFILE=%TEMPDIR%\%PROC%_ClassPath.jar
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat" /p "%TEMPJARFILE%" >NUL
if ERRORLEVEL 1 (
	echo %EM% creating class path JAR file for demo target system environment
	goto ExitFail
)

rem
rem Start the demo target system database.
rem Note that we use a "file:" based copy of the demo database instead of a "mem:" type so we get to show the tear down of the existing structure.
rem
start "Demo Target System" "%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" -classpath "%TEMPJARFILE%" org.hsqldb.Server -database.0 file:"%DEMO_HSQL_ROOT%\hsql\demo_trg" -port 20002
if ERRORLEVEL 1 (
	echo %EM% starting demo target system database 1>&2
	goto ExitFail
)

rem
rem Pause, for a while, for the asynchronous database start up processes to complete.
rem
echo %IM% pausing for demo target system database start up asynchronous process
sleep 15

rem
rem Set the environment for demo environment 1 in this shell level.
rem
set ODI_SCM_INI=%DEMO_ENV1_INI%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
if ERRORLEVEL 1 (
	echo %EM% setting environment for demo environment 1 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

rem
rem Add the source and target system DDL to demo environment 1 working copy.
rem
md "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\DatabaseDDL"
if ERRORLEVEL 1 (
	echo %EM% creating working copy DDL directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\DatabaseDDL^> 1>&2
	goto ExitFail
)

copy "%DEMO_HSQL_ROOT%\hsql\CREATE_SRC_ISOSQL.sql" "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\DatabaseDDL\ddl-schema-HSQL_DEMO_SRC-t1-createtables.sql" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying source system DDL script to working copy directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\DatabaseDDL^> 1>&2
	goto ExitFail
)

copy "%DEMO_HSQL_ROOT%\hsql\CREATE_TRG_ISOSQL.sql" "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\DatabaseDDL\ddl-schema-HSQL_DEMO_TARG-t1-createtables.sql" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying target system DDL script to working copy directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\DatabaseDDL^> 1>&2
	goto ExitFail
)

rem
rem Add the demo unit tests to the working copy.
rem
set MSG=adding ODI unit tests to demo environment 1 SVN repository working copy
xcopy /e /i /h /q "%ODI_SCM_HOME%\Configuration\Demo\Demo4\FitNesseRoot\OdiScmDemo" "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\FitNesseRoot\OdiScmDemo" >NUL
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=adding source and target system DDL scripts to demo environment 1 SVN repository working copy
echo %IM% %MSG%
svn add %ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\* --force %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Commit the exported demo files to the SCM repository.
rem
set MSG=committing changes in demo environment 1 SVN repository working copy to SVN repository
echo %IM% %MSG%
svn commit -m "Demo auto check in source and target system DDK scripts" "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT%\." %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Set the environment for demo environment 2 in this shell level.
rem
set ODI_SCM_INI=%DEMO_ENV2_INI%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
if ERRORLEVEL 1 (
	echo %EM% setting environment for demo environment 1 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

set MSG=updating demo environment 2 SVN repository working copy from SVN repository and generating ODI code import scripts
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=executing generated ODI code import scripts to update demo environment 2 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmBuild_DemoEnvironment2.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=executing generated DDL import scripts to update demo source and target database environments
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmDdlImport_DemoEnvironment2.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=executing SPL import scripts to update demo source and target database environments
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmSplImport_DemoEnvironment2.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=executing DML execution scripts to update demo source and target database environments
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmDmlExecution_DemoEnvironment2.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=executing SSAS import scripts to update demo source and target environments
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmSsasImport_DemoEnvironment2.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Run a FitNesse acceptance test to unpack FitNesse resources.
rem
echo %IM% executing FitNesse acceptance test to unpack resources
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecFitNesseCmd.bat" /p "FitNesse.SuiteAcceptanceTests.SuiteFitDecoratorTests.MaxTimeDivision" "test"
set EXITSTATUS=%ERRORLEVEL%
if not "%EXITSTATUS%" == "0" (
	echo %WM% FitNesse acceptance test execution return non zero exit status ^<%EXITSTATUS%^> 1>&2
)

rem
rem Execute the unit tests from demo environment 2.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmExecUnitTests_DemoEnvironment2.bat" /p
if ERRORLEVEL 1 (
	echo %EM% executing demo environment 2 unit tests 1>&2
	goto ExitFail
)

rem
rem Stop the demo source system database.
rem
echo %IM% stopping demo source system database

set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\Demo4\OdiScmStandardOdiDemoSourceSystem.ini
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
if ERRORLEVEL 1 (
	echo %EM% setting environment for demo source system database 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" /p "%ODI_SCM_HOME%\Configuration\Demo\OdiScmShutDownHSQLServer.sql"
if ERRORLEVEL 1 (
	echo %EM% shutting down demo source system database 1>&2
	goto ExitFail
)

rem
rem Stop the demo target system database.
rem
echo %IM% stopping demo target system database

set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\Demo4\OdiScmStandardOdiDemoTargetSystem.ini
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
if ERRORLEVEL 1 (
	echo %EM% setting environment for demo target system database 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" /p "%ODI_SCM_HOME%\Configuration\Demo\OdiScmShutDownHSQLServer.sql"
if ERRORLEVEL 1 (
	echo %EM% shutting down demo target system database 1>&2
	goto ExitFail
)

echo %IM% demo creation completed successfully
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% demo creation failed 1>&2
echo %EM% ends 1>&2
exit %IsBatchExit% 1