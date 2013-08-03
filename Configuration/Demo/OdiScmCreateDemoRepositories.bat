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

rem
rem Just to set the environment to create the SCM repository.
rem
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini
echo %IM% setting OdiScm environment for demo 1 environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% setting OdiScm environment for demo 1 environment from ^<%ODI_SCM_INI%^> 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

set ODI_SCM_DEMO_BASE=C:\OdiScmWalkThrough

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

md "%ODI_SCM_SCM_REPO_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo base directory ^<%ODI_SCM_SCM_DEMO_BASE%^> 1>&2
	goto ExitFail
)

svnadmin create "%ODI_SCM_SCM_REPO_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo SVN repository 1>&2
	goto ExitFail
)

rem *************************************************************
rem Demo environment 1.
rem *************************************************************
echo %IM% dropping existing demo environment 1 ODI repository database user ^<%ODI_SCM_ORACLEDI_SECU_USER%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% dropping existing demo environment 1 ODI repository database user 1>&2
	goto ExitFail
)

echo %IM% creating demo environment 1 ODI repository database user ^<%ODI_SCM_ORACLEDI_SECU_USER%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 ODI repository database user 1>&2
	goto ExitFail
)

rem
rem Working copy directories.
rem
echo %IM% creating demo environment 1 SVN repository working copy
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 SVN repository working copy 1>&2
	goto ExitFail
)

rem
rem Working directory.
rem
if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	echo %IM% deleting existing demo environment 1 working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> 1>&2
	chmod -R a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing demo environment 1 working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable 1>&2
		goto ExitFail
	)
	rm -fr "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing demo environment 1 working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> 1>&2
		goto ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	echo %IM% importing demo environment 1 ODI repository
	"%ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe" %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SCM_ORACLEDI_SECU_USER%_repid_100_empty_master_work_%ODI_SCM_ORACLEDI_VERSION%.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		echo %EM% importing demo environment 1 ODI repository 1>&2
		goto ExitFail
	)
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		echo %IM% creating demo environment 1 ODI repository
		rem
		rem Use a repository that doesn't conflict with with the standard ODI demo.
		rem
		call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat^" /p 100 %DiscardStdOut% %DiscardStdErr%
		if ERRORLEVEL 1 (
			echo %EM% creating demo environment 1 ODI repository 1>&2
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_SCM_ORACLEDI_VERSION%^> 1>&2
		goto ExitFail
	)
)

echo %IM% importing OdiScm into demo environment 1 ODI repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat^" /p ExportPrimeLast %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% importing OdiScm into demo environment 1 ODI repository 1>&2
	goto ExitFail
)

REM echo %IM% importing standard ODI demo into demo repository 1
REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportOracleDIDemo.bat" %ODI_SCM_HOME%\Configuration\Demo\Odi10gStandardDemo >NUL
REM if ERRORLEVEL 1 (
	REM goto ExitFail
REM )

rem *************************************************************
rem Demo environment 2.
rem *************************************************************
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo2.ini
echo %IM% setting OdiScm environment for demo 2 environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% setting OdiScm environment for demo 2 environment from ^<%ODI_SCM_INI%^> 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

echo %IM% dropping existing demo environment 2 ODI repository database user ^<%ODI_SCM_ORACLEDI_SECU_USER%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% dropping existing demo environment 2 ODI repository database user 1>&2
	goto ExitFail
)

echo %IM% creating demo environment 2 ODI repository database user ^<%ODI_SCM_ORACLEDI_SECU_USER%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 ODI repository database user 1>&2
	goto ExitFail
)

rem
rem Working copy directories.
rem
echo %IM% creating demo environment 2 SVN repository working copy
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 SVN repository working copy 1>&2
	goto ExitFail
)

rem
rem Working directory.
rem
if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	echo %IM% deleting existing demo environment 2 working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
	chmod -R a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing demo environment 2 working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable 1>&2
		goto ExitFail
	)
	rm -fr "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing demo environment 2 working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> 1>&2
		goto ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	echo %IM% importing demo environment 2 ODI repository
	"%ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe" %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SCM_ORACLEDI_SECU_USER%_repid_101_empty_master_work_%ODI_SCM_ORACLEDI_VERSION%.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		echo %IM% importing demo environment 2 ODI repository 1>&2
		goto ExitFail
	)
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		echo %IM% creating demo environment 2 ODI repository
		rem
		rem Use a repository that doesn't conflict with with the standard ODI demo.
		rem
		call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat^" /p 200 %DiscardStdOut% %DiscardStdErr%
		if ERRORLEVEL 1 (
			echo %EM% creating demo environment 2 ODI repository 1>&2
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_SCM_ORACLEDI_VERSION%^> 1>&2
		goto ExitFail
	)
)

echo %IM% importing OdiScm into demo environment 2 ODI repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat^" /p ExportPrimeLast %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% importing OdiScm into demo environment 2 ODI repository 1>&2
	goto ExitFail
)

rem
rem Import the standard ODI demo after OdiScm so that we can flush it out to the working copy later on.
rem
echo %IM% importing standard ODI demo into demo environment 2 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportOracleDIDemo.bat^" /p %ODI_SCM_HOME%\Configuration\Demo\Odi10gStandardDemo %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% importing standard ODI demo into demo environment 2 ODI repository 1>&2
	goto ExitFail
)

rem
rem Export the demo, using OdiScm, to the working copy from demo repository 2.
rem
echo %IM% flushing demo environment 2 ODI repository to demo environment 2 SVN repository working copy
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFlushRepository.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% flushing demo environment 2 ODI repository to demo environment 2 SVN repository working copy 1>&2
	goto ExitFail
)

rem
rem Add the exported demo files to the SCM system working copy.
rem
echo %IM% adding standard ODI demo files flushed from demo environment 2 ODI repository to demo environment 2 SVN repository working copy
svn add %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.* --force %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% adding standard ODI demo files flushed from demo environment 2 ODI repository to demo environment 2 SVN repository working copy 1>&2
	goto ExitFail
)

rem
rem Commit the exported demo files to the SCM repository.
rem
echo %IM% committing changes in demo environment 2 SVN repository working copy to SVN repository
svn commit -m "Demo auto check in of initial demo export" %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.* %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% committing changes in demo environment 2 SVN repository working copy to SVN repository 1>&2
	goto ExitFail
)

rem *************************************************************
rem Demo environment 1 - populate the repository from the code
rem checked in to SVN.
rem *************************************************************
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini
echo %IM% setting OdiScm environment for demo 1 environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSaveScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %IM% setting OdiScm environment for demo 1 environment from ^<%ODI_SCM_INI%^> 1>&2
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmLoadScriptSwitches.bat"
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

echo %IM% updating demo environment 1 SVN repository working copy from SVN repository and generating ODI code import scripts
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat^" /p %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% updating demo environment 1 SVN repository working copy from SVN repository and generating ODI code import scripts 1>&2
	goto ExitFail
)

echo %IM% executing generated ODI code import scripts to update demo environment 1 ODI repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment1\OdiScmBuild_DemoEnvironment1.bat^" %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	echo %EM% executing generated ODI code import scripts to update demo environment 1 ODI repository 1>&2
	goto ExitFail
)

echo %IM% demo creation completed successfully 
exit %IsBatchExit% 0

:ExitFail
echo %EM% demo creation failed 1>^2
exit %IsBatchExit% 1