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

if not "%BeVerbose%%" == "" (
	set DiscardStdOut=
	set DiscardStdErr=
) else (
	set DiscardStdOut=1^>NUL
	set DiscardStdErr=2^>NUL
)

rem
rem Source the working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	goto ExitFail
)

rem
rem Just to set the environment to create the SCM repository.
rem
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini
echo %IM% setting OdiScm environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardOutput%
if ERRORLEVEL 1 (
	goto ExitFail
)

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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% dropping existing demo environment 1 ODI repository database user
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 ODI repository database user
	goto ExitFail
)

rem
rem Working copy directories.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 working copy >&2
	goto ExitFail
)

rem
rem Working directory.
rem
if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	echo %IM% deleting existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
	chmod -R a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable
		goto ExitFail
	)
	rm -fr "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
		goto ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working directory %ODI_SCM_SCM_SYSTEM_WORKING_ROOT%
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	echo %IM% importing demo environment 1 repository
	%ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SCM_ORACLEDI_SECU_USER%_repid_100_empty_master_work_%ODI_SCM_ORACLEDI_VERSION%.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		goto ExitFail
	)
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		echo %IM% creating demo environment 2 repository
		call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat" /p 1
		if ERRORLEVEL 1 (
			echo %EM% creating demo environment 1 repository
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_SCM_ORACLEDI_VERSION%^>
		goto ExitFail
	)
)

echo %IM% importing OdiScm into demo environment 1 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat^" /p ExportPrimeLast %DiscardStdOut%
if ERRORLEVEL 1 (
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
echo %IM% setting OdiScm environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% dropping existing demo environment 2 ODI repository database user 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 ODI repository database user 1>&2
	goto ExitFail
)

rem
rem Working copy directories.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" /p EMPTY
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working copy 1>&2
	goto ExitFail
)

rem
rem Working directory.
rem
if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	echo %IM% deleting existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
	chmod -R a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable
		goto ExitFail
	)
	rm -fr "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
		goto ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	echo %IM% importing demo environment 2 repository
	%ODI_SCM_TOOLS_ODI_SCM_TOOLS_ODI_SCM_TOOLS_ORACLE_HOME%\bin\imp.exe %ODI_SCM_ORACLEDI_SECU_USER%/%ODI_SCM_ORACLEDI_SECU_PASS%@%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%/%ODI_SCM_ORACLEDI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SCM_ORACLEDI_SECU_USER%_repid_101_empty_master_work_%ODI_SCM_ORACLEDI_VERSION%.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		goto ExitFail
	)
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		echo %IM% creating demo environment 2 repository
		call  "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat^" /p 2
		if ERRORLEVEL 1 (
			echo %EM% creating demo environment 2 repository
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_SCM_ORACLEDI_VERSION%^>
		goto ExitFail
	)
)

echo %IM% importing OdiScm into demo environment 2 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat^" /p ExportPrimeLast %DiscardStdOut%
if ERRORLEVEL 1 (
	goto ExitFail
)

rem
rem Import the standard ODI demo after OdiScm so that we can flush it out to the working copy later on.
rem
echo %IM% importing standard ODI demo into demo environment 2 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportOracleDIDemo.bat^" /p %ODI_SCM_HOME%\Configuration\Demo\Odi10gStandardDemo %DiscardStdOut%
if ERRORLEVEL 1 (
	goto ExitFail
)

rem
rem Export the demo, using OdiScm, to the working copy from demo repository 2.
rem
echo %IM% exporting standard ODI demo from demo environment 2 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFlushRepository.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% flushing repository to file system 1>&2
	goto ExitFail
)

rem
rem Add the exported demo files to the SCM system working copy.
rem
echo %IM% adding standard ODI demo files to demo environment 2 working copy
svn add %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.* --force
if ERRORLEVEL 1 (
	echo %EM% adding exported demo files to source control 1>&2
	goto ExitFail
)

rem
rem Commit the exported demo files to the SCM repository.
rem
echo %IM% committing standard ODI demo files to SCM repository from demo environment 2 working copy
svn commit -m "Demo auto check in of initial demo export" %ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%/SvnRepoRoot/*.*
if ERRORLEVEL 1 (
	echo %EM% checking in demo export to SCM repository 1>&2
	goto ExitFail
)

rem *************************************************************
rem Demo environment 1 - populate the repository from the code
rem checked in to SVN.
rem *************************************************************
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini
echo %IM% setting OdiScm environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat" %DiscardStdOut%
if ERRORLEVEL 1 (
	goto ExitFail
)
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.bat^" /p %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% getting code from SCM repository to demo environment 1 working copy
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Logs\DemoEnvironment1\OdiScmBuild_DemoEnvironment1.bat^" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% updating demo environment 1 repository from SCM system updates
	goto ExitFail
)

echo %IM% demo creation completed successfully 
exit /b 0

:ExitFail
echo %EM% demo creation failed
exit /b 1