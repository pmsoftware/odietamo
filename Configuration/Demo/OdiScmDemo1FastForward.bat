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
rem Validate arguments.
rem
if "%ARGC%" neq "2" (
	echo %EM% invalid number of arguments 1>&2
	echo %EM% usage: ^<%PROC%^> ^<path/to/demo/env1/INI/file^> ^<path/to/demo/env2/INI/file^> 1>&2
	goto ExitFail
)

if not EXIST "%ARGV1%" (
	echo %EM% specified demo environment 1 configuration INI file ^<%ARGV1%^> does not exist 1>&2
	goto ExitFail
)

set DEMO_ENV1_INI=%ARGV1%

if not EXIST "%ARGV2%" (
	echo %EM% specified demo environment 2 configuration INI file ^<%ARGV2%^> does not exist 1>&2
	goto ExitFail
)

set DEMO_ENV2_INI=%ARGV2%

rem
rem Create the demo base directory.
rem
set ODI_SCM_DEMO_BASE=C:\OdiScmWalkThrough

if not EXIST "%ODI_SCM_DEMO_BASE%" (
	echo %IM% creating demo base directory ^<%ODI_SCM_DEMO_BASE%^>
	md "%ODI_SCM_DEMO_BASE%"
	if ERRORLEVEL 1 (
		echo %EM% creating demo base directory ^<%ODI_SCM_DEMO_BASE%^> 1>&2
		goto ExitFail
	)
)

rem
rem Create the SCM repository.
rem
set ODI_SCM_SCM_REPO_ROOT=%ODI_SCM_DEMO_BASE%\SvnRepoRoot

if EXIST "%ODI_SCM_SCM_REPO_ROOT%" (
	echo %IM% deleting existing SVN repository directory tree ^<%ODI_SCM_SCM_REPO_ROOT%^>
	chmod -R a+w "%ODI_SCM_SCM_REPO_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing SVN repository directory tree ^<%ODI_SCM_SCM_REPO_ROOT%^> writable 1>&2
		goto ExitFail
	)
	rm -fr "%ODI_SCM_SCM_REPO_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing SVN repository directory tree ^<%ODI_SCM_SCM_REPO_ROOT%^> 1>&2
		goto ExitFail
	)
)

set MSG=creating demo SVN repository base directory ^^^<%ODI_SCM_SCM_REPO_ROOT%^^^>
echo %IM% %MSG%
md "%ODI_SCM_SCM_REPO_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=creating demo SVN repository
echo %IM% %MSG%
svnadmin create "%ODI_SCM_SCM_REPO_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem *************************************************************
rem Demo environment 1.
rem *************************************************************
set ODI_SCM_INI=%DEMO_ENV1_INI%
set MSG=setting OdiScm environment for demo 1 environment from ^^^<%ODI_SCM_INI%^^^>
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

set MSG=dropping existing demo environment 1 ODI repository database user ^^^<%ODI_SCM_ORACLEDI_SECU_USER%^^^>
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=creating demo environment 1 ODI repository database user ^^^<%ODI_SCM_ORACLEDI_SECU_USER%^^^>
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Working copy directories.
rem
set MSG=creating demo environment 1 SVN repository working copy
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Working directory.
rem
setlocal enabledelayedexpansion

if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	set MSG=deleting existing demo environment 1 working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
	echo %IM% !MSG!
	chmod -R a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing demo environment 1 working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable 1>&2
		goto ExitFail
	)
	rm -fr "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% !MSG! 1>&2
		goto ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	set MSG=importing demo environment 1 ODI repository
	echo %IM% !MSG!
	"%ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe" %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SCM_ORACLEDI_SECU_USER%_repid_%ODI_SCM_ORACLEDI_REPOSITORY_ID%_empty_master_work_%ODI_SCM_ORACLEDI_VERSION%.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		echo %EM% !MSG! 1>&2
		goto ExitFail
	)
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		set MSG=creating demo environment 1 ODI repository
		echo %IM% !MSG!
		rem
		rem Use a repository ID that doesn't conflict with with the standard ODI demo.
		rem
		call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat^" /p %ODI_SCM_ORACLEDI_REPOSITORY_ID% %DiscardStdOut% %DiscardStdErr%
		if ERRORLEVEL 1 (
			echo %EM% !MSG! 1>&2
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_SCM_ORACLEDI_VERSION%^> 1>&2
		goto ExitFail
	)
)

set MSG=importing OdiScm into demo environment 1 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat^" /p ExportPrimeLast %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Import the standard ODI demo after OdiScm so that we can flush it out to the working copy later on.
rem
set MSG=importing standard ODI demo into demo environment 1 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportOracleDIDemo.bat^" /p %ODI_SCM_HOME%\Configuration\Demo\Odi10gStandardDemo %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Add custom OdiScm object markers to ensure objects get scenarios generated in subsequent builds.
rem
set MSG=adding custom OdiScm object markers to standard ODI demo in demo environment 1 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat^" /p %ODI_SCM_HOME%\Configuration\Demo\Demo1\OdiScmObjectMarkers %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Re-align the internal ID tracking metadata as we're importing objects into this repository that were originally created in a repository
rem with this same internal ID - in this script we're recreating what the user would have done.
rem
set MSG=re-aligning demo environment 1 ODI repository object internal ID tracking metadata
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo^" /p %ODI_SCM_HOME%\Configuration\Scripts\OdiScmRestoreRepositoryIntegrity.sql %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Export the demo, using OdiScm, to the working copy from demo repository 1.
rem
set MSG=flushing demo environment 1 ODI repository to demo environment 1 SVN repository working copy
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFlushRepository.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Add the exported demo files to the SCM system working copy.
rem
set MSG=adding standard ODI demo files flushed from demo environment 1 ODI repository to demo environment 1 SVN repository working copy
echo %IM% %MSG%
svn add %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.* --force %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Commit the exported demo files to the SCM repository.
rem
set MSG=committing changes in demo environment 1 SVN repository working copy to SVN repository
echo %IM% %MSG%
svn commit -m "Demo auto check in of initial demo export" %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.* %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem *************************************************************
rem Demo environment 2.
rem *************************************************************
set ODI_SCM_INI=%DEMO_ENV2_INI%
set MSG=setting OdiScm environment for demo 2 environment from ^^^<%ODI_SCM_INI%^^^>
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% %MSG% 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

set MSG=dropping existing demo environment 2 ODI repository database user ^^^<%ODI_SCM_ORACLEDI_SECU_USER%^^^>
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=creating demo environment 2 ODI repository database user ^^^<%ODI_SCM_ORACLEDI_SECU_USER%^^^>
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Working copy directories.
rem
set MSG=creating demo environment 2 SVN repository working copy
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Working directory.
rem
if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	set MSG=deleting existing demo environment 2 working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
	echo %IM% !MSG!
	chmod -R a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing demo environment 2 working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable 1>&2
		goto ExitFail
	)
	rm -fr "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% !MSG! 1>&2
		goto ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	set MSG=importing demo environment 2 ODI repository
	echo %IM% !MSG!
	"%ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe" %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SCM_ORACLEDI_SECU_USER%_repid_%ODI_SCM_ORACLEDI_REPOSITORY_ID%_empty_master_work_%ODI_SCM_ORACLEDI_VERSION%.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		echo %IM% !MSG! 1>&2
		goto ExitFail
	)
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		set MSG=creating demo environment 2 ODI repository
		echo %IM% !MSG!
		rem
		rem Use a repository ID that doesn't conflict with with the standard ODI demo.
		rem
		call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat^" /p %ODI_SCM_ORACLEDI_REPOSITORY_ID% %DiscardStdOut% %DiscardStdErr%
		if ERRORLEVEL 1 (
			echo %EM% !MSG! 1>&2
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_SCM_ORACLEDI_VERSION%^> 1>&2
		goto ExitFail
	)
)

set MSG=importing OdiScm into demo environment 2 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat^" /p ExportPrimeLast %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=updating demo environment 2 SVN repository working copy from SVN repository and generating ODI code import scripts
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=executing generated ODI code import scripts to update demo environment 2 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment2\OdiScmBuild_DemoEnvironment2.bat^" %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Create a new project and package in demo environment 2 ODI repository.
rem
set MSG=creating new project and package in demo environment 2 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat^" /p %ODI_SCM_HOME%\Configuration\Demo\Demo1\NewProject %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Re-align the internal ID tracking metadata as we're importing objects into this repository that were originally created in a repository
rem with this same internal ID - in this script we're recreating what the user would have done.
rem
set MSG=re-aligning demo environment 2 ODI repository object internal ID tracking metadata
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo^" /p %ODI_SCM_HOME%\Configuration\Scripts\OdiScmRestoreRepositoryIntegrity.sql %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Export the new project and package and updated procedure, using OdiScm, to the working copy from demo repository 2.
rem
set MSG=flushing demo environment 2 ODI repository to demo environment 2 SVN repository working copy
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFlushRepository.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Add the new and updated ODI object files to the SCM system working copy.
rem
set MSG=adding new and updated ODI object files flushed from demo environment 2 ODI repository to demo environment 2 SVN repository working copy
echo %IM% %MSG%
svn add %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.* --force %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem
rem Commit the new and updated ODI object files to the SCM repository.
rem
set MSG=committing changes in demo environment 2 SVN repository working copy to SVN repository
echo %IM% %MSG%
svn commit -m "Demo auto check in of initial demo export" %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.* %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

rem *************************************************************
rem Demo environment 1.
rem *************************************************************
set ODI_SCM_INI=%DEMO_ENV1_INI%
set MSG=setting OdiScm environment for demo 1 environment from ^^^<%ODI_SCM_INI%^^^>
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% %MSG% 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

set MSG=updating demo environment 1 SVN repository working copy from SVN repository and generating ODI code import scripts
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

set MSG=executing generated ODI code import scripts to update demo environment 1 ODI repository
echo %IM% %MSG%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment1\OdiScmBuild_DemoEnvironment1.bat^" %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% %MSG% 1>&2
	goto ExitFail
)

echo %IM% demo creation completed successfully 
exit %IsBatchExit% 0

:ExitFail
echo %EM% demo creation failed 1>&2
exit %IsBatchExit% 1