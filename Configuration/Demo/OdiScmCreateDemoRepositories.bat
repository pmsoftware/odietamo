@echo off
call :SetMsgPrefixes
echo %IM% starts

if /i "%1" == "/verbose" (
	set DiscardStdOut=
	set DiscardStdErr=
	shift
) else (
	set DiscardStdOut=1^>NUL
	set DiscardStdErr=2^>NUL
)

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b %DiscardOutput%
if ERRORLEVEL 1 (
	goto ExitFail
)
call :SetMsgPrefixes

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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% dropping existing demo environment 1 ODI repository database user
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 ODI repository database user
	goto ExitFail
)

rem
rem Working copy directories.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" EMPTY
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 working copy >&2
	goto ExitFail
)

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

if "%ODI_VERSION:~0,3%" == "10." (
	echo %IM% importing demo environment 1 repository
	%ORACLE_HOME%\bin\imp.exe %ODI_SECU_USER%/%ODI_SECU_PASS%@%ODI_SECU_URL_HOST%:%ODI_SECU_URL_PORT%/%ODI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SECU_USER%_repid_100_empty_master_work.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		goto ExitFail
	)
) else (
	if "%ODI_VERSION:~0,3%" == "11." (
		echo %IM% creating demo environment 2 repository
		call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat" 1
		if ERRORLEVEL 1 (
			echo %EM% creating demo environment 2 repository
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_VERSION%^>
		goto ExitFail
	)
)

echo %IM% importing OdiScm into demo environment 1 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat" ExportPrimeLast %DiscardStdOut%
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b %DiscardStdOut%
if ERRORLEVEL 1 (
	goto ExitFail
)
call :SetMsgPrefixes

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDropOdiRepositoryDbUser.bat^" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% dropping existing demo environment 2 ODI repository database user 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepositoryDbUser.bat^" %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 ODI repository database user 1>&2
	goto ExitFail
)

rem
rem Working copy directories.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" EMPTY
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working copy 1>&2
	goto ExitFail
)

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

if "%ODI_VERSION:~0,3%" == "10." (
	echo %IM% importing demo environment 2 repository
	%ORACLE_HOME%\bin\imp.exe %ODI_SECU_USER%/%ODI_SECU_PASS%@%ODI_SECU_URL_HOST%:%ODI_SECU_URL_PORT%/%ODI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SECU_USER%_repid_101_empty_master_work.dmp full=y %DiscardStdOut% %DiscardStdErr%
	if ERRORLEVEL 1 (
		goto ExitFail
	)
) else (
	if "%ODI_VERSION:~0,3%" == "11." (
		echo %IM% creating demo environment 2 repository
		call  "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiRepository.bat" 2
		if ERRORLEVEL 1 (
			echo %EM% creating demo environment 2 repository
			goto ExitFail
		)
	) else (
		echo %EM% unsupported ODI version number ^<%ODI_VERSION%^>
		goto ExitFail
	)
)

echo %IM% importing OdiScm into demo environment 2 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat" ExportPrimeLast %DiscardStdOut%
if ERRORLEVEL 1 (
	goto ExitFail
)

rem
rem Import the standard ODI demo after OdiScm so that we can flush it out to the working copy later on.
rem
echo %IM% importing standard ODI demo into demo environment 2 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportOracleDIDemo.bat" %ODI_SCM_HOME%\Configuration\Demo\Odi10gStandardDemo %DiscardStdOut%
if ERRORLEVEL 1 (
	goto ExitFail
)

rem *************************************************************
rem Create a working copy of the SCM repository.
rem *************************************************************

rem TODO: replace most OdiScmXXXX.bat commands with a central OdiScm.bat that takes the command as first arg and forks shells.
rem TODO: create SCM agnostic command to create/delete working copies.

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateWorkingCopy.bat^" EMPTY
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 1 working copy 1>&2
	got ExitFail
)



REM echo %IM% deleting existing TFS workspace ^<DemoMaster^>
REM tf.exe workspace /delete /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% DemoMaster /noprompt %DiscardStdOut% %DiscardStdErr%

REM echo %IM% creating TFS workspace ^<DemoMaster^>
REM tf.exe workspace /new /noprompt DemoMaster /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL%
REM if ERRORLEVEL 1 (
	REM echo %EM% creating TFS workspace ^<DemoMaster^>
	REM goto ExitFail
REM )

REM echo %IM% deleting default folder mapping for TFS workspace ^<DemoMaster^>
REM tf.exe workfold /noprompt /unmap /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% /workspace:DemoMaster $/
REM if ERRORLEVEL 1 (
	REM echo %EM% deleting default folder mapping for TFS workspace ^<DemoMaster^>
	REM goto ExitFail
REM )

REM echo %IM% creating mapping for TFS workspace ^<DemoMaster^> to branch URL ^<%ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL%^>
REM tf.exe workfold /map "%ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL%" "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%" /workspace:DemoMaster /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL%
REM if ERRORLEVEL 1 (
	REM echo %EM% creating mapping for TFS workspace ^<DemoMaster^>
	REM goto ExitFail
REM )

rem
rem Export the demo, using OdiScm, to the working copy from demo repository 2.
rem
rem First, create a StartCmd.bat for the current environment.
rem
echo %IM% creating StartCmd script for demo environment 2
set DEMOENV2STARTCMD=%TEMPDIR%\%RANDOM%_%PROC%_StartCmd.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat^" %DEMOENV2STARTCMD% %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating StartCmd wrapper script 1>&2
	goto ExitFail
)

echo %IM% exporting demo from demo environment 2 repository
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%DEMOENV2STARTCMD%^" OdiStartScen -SCEN_NAME=OSFLUSH_REPOSITORY -SCEN_VERSION=-1 -CONTEXT=GLOBAL %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% exporting demo from demo repository 2 1>&2
	goto ExitFail
)

rem
rem Add the exported demo files to the SCM system working copy.
rem
svn add %ODI_SCM_SCM_SYSTEM_WORKING_COPY% --force
if ERRORLEVEL 1 (
	echo %EM% adding exported demo files to source control 1>&2
	goto ExitFail
)

rem
rem Commit the exported demo files to the SCM repository.
rem
svn commit -m "Demo auto check in of initial demo export" %ODI_SCM_SCM_SYSTEM_WORKING_COPY%
if ERRORLEVEL 1 (
	echo %EM% checking in demo export to SCM repository 1>&2
	goto ExitFail
)

echo %IM% demo repository creation completed successfully 
exit /b 0

:ExitFail
echo %EM% demo repository creation failed
exit /b 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

:SetMsgPrefixes
set PROC=OdiScmCreateDemoRepositories
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:
goto :eof