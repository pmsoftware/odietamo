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

if "%ODI_VERSION%" == "" (
	echo %EM% environment variable ODI_VERSION is not set
	got ExitFail
)

rem
rem Source the working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	goto ExitFail
)

rem
rem Just to set up the Jisql tool and get the DBA user name and password.
rem Note that both demo repositories will be created in the database that's included in the URL in the Repo1 INI file.
rem
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini
echo %IM% setting OdiScm environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b %DiscardOutput%
if ERRORLEVEL 1 (
	goto ExitFail
)
call :SetMsgPrefixes

if "%ODI_ADMIN_USER%" == "" (
	echo %EM% environment variable ODI_ADMIN_USER is not set
	goto ExitFail
)

if "%ODI_ADMIN_PASS%" == "" (
	echo %EM% environment variable ODI_ADMIN_PASS is not set
	goto ExitFail
)

set PODI_SECU_USER=%ODI_SECU_USER%
set PODI_SECU_PASS=%ODI_SECU_PASS%

set ODI_SECU_USER=%ODI_ADMIN_USER%
set ODI_SECU_PASS=%ODI_ADMIN_PASS%

echo %IM% dropping existing demo environment repository database users
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" %ODI_SCM_HOME%\Configuration\Demo\OdiScmDropDemoRepoUsers.sql %DiscardOutput% %DiscardStdErr%
if ERRORLEVEL 1 (
	goto ExitFail
)

echo %IM% creating demo environment repository database users
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" %ODI_SCM_HOME%\Configuration\Demo\OdiScmCreateDemoRepoUsers.sql %DiscardStdOut% %DiscardStdErr%
if ERRORLEVEL 1 (
	goto ExitFail
)

set ODI_SECU_USER=%PODI_SECU_USER%
set ODI_SECU_PASS=%PODI_SECU_PASS%

REM set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini
REM echo %IM% setting OdiScm environment from ^<%ODI_SCM_INI%^>
REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b >NUL
REM if ERRORLEVEL 1 (
	REM goto ExitFail
REM )
REM call :SetMsgPrefixes

rem *************************************************************
rem Demo environment 1.
rem *************************************************************

rem
rem Working copy directories.
rem
if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%" (
	echo %IM% deleting existing working copy root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^>
	chmod a+w "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing working copy root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^> writable
		got ExitFail
	)
	rm -r "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working copy directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^>
		got ExitFail
	)
)

if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	echo %IM% deleting existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
	chmod a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable
		got ExitFail
	)
	rm -r "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
		got ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working copy root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^>
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

rem
rem Working copy directories.
rem
if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%" (
	echo %IM% deleting existing working copy root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^>
	chmod a+w "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing working copy root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^> writable
		got ExitFail
	)
	rm -r "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working copy directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^>
		got ExitFail
	)
)

if EXIST "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%" (
	echo %IM% deleting existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
	chmod a+w "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing working root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^> writable
		got ExitFail
	)
	rm -r "%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working directory tree ^<%ODI_SCM_SCM_SYSTEM_WORKING_ROOT%^>
		got ExitFail
	)
)

md "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating demo environment 2 working copy root directory ^<%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%^>
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

rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScm.bat^" 
echo %IM% deleting existing TFS workspace ^<DemoMaster^>
tf.exe workspace /delete /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% DemoMaster /noprompt %DiscardStdOut% %DiscardStdErr%

echo %IM% creating TFS workspace ^<DemoMaster^>
tf.exe workspace /new /noprompt DemoMaster /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL%
if ERRORLEVEL 1 (
	echo %EM% creating TFS workspace ^<DemoMaster^>
	goto ExitFail
)

echo %IM% deleting default folder mapping for TFS workspace ^<DemoMaster^>
tf.exe workfold /noprompt /unmap /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% /workspace:DemoMaster $/
if ERRORLEVEL 1 (
	echo %EM% deleting default folder mapping for TFS workspace ^<DemoMaster^>
	goto ExitFail
)

echo %IM% creating mapping for TFS workspace ^<DemoMaster^> to branch URL ^<%ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL%^>
tf.exe workfold /map "%ODI_SCM_SCM_SYSTEM_SCM_BRANCH_URL%" "%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT%" /workspace:DemoMaster /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL%
if ERRORLEVEL 1 (
	echo %EM% creating mapping for TFS workspace ^<DemoMaster^>
	goto ExitFail
)

rem
rem Export the demo, using OdiScm, to the working copy from demo repository 2.
rem
rem First, create a StartCmd.bat for the current environment.
rem
echo %IM% creating StartCmd script for demo environment 2
set TEMPSTARTCMD=%TEMPDIR%\%RANDOM%_%PROC%_StartCmd.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat^" %TEMPSTARTCMD% %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% creating StartCmd wrapper script
	goto ExitFail
)

echo %IM% exporting demo from demo environment 2 repository
call "%TEMPSTARTCMD%" OdiStartScen -SCEN_NAME=OSFLUSH_REPOSITORY -SCEN_VERSION=-1 -CONTEXT=GLOBAL %DiscardStdOut%
if ERRORLEVEL 1 (
	echo %EM% exporting demo from demo repository 2
	goto ExitFail
)

echo %IM% demo repository creation completed successfully 
exit /b 0

:ExitFail
echo %IM% demo repository creation failed
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