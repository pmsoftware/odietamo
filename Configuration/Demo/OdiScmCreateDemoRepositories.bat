@echo off
call :SetMsgPrefixes
echo %IM% starts

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

if EXIST "C:\OdiScmWalkThrough" (
	echo %IM% deleting existing walk through directory tree ^<C:\OdiScmWalkThrough^>
	rem We don't use Windows RMDIR / RD here as the exit status does not reliably indicate success/failure.
	rem rd /s /q "C:\OdiScmWalkThrough"
	chmod -R a+w "C:\OdiScmWalkThrough"
	if ERRORLEVEL 1 (
		echo %EM% making writeable in directory tree ^<C:\OdiScmWalkThrough^>
		goto ExitFail
	)
	rm -fr "C:\OdiScmWalkThrough"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing walk through directory tree ^<C:\OdiScmWalkThrough^>
		goto ExitFail
	)
)

rem
rem Create Walk Through directories.
rem
echo %IM% creating walk through directory tree at ^<C:\OdiScmWalkThrough^>

md "C:\OdiScmWalkThrough"
if ERRORLEVEL 1 (
	echo %EM% creating walk through root directory ^<C:\OdiScmWalkThrough^>
)

md "C:\OdiScmWalkThrough\Repo1WorkingCopy"
if ERRORLEVEL 1 (
	echo %EM% creating walk through root directory ^<C:\OdiScmWalkThrough\Repo1WorkingCopy^>
)

md "C:\OdiScmWalkThrough\Temp1"
if ERRORLEVEL 1 (
	echo %EM% creating walk through root directory ^<C:\OdiScmWalkThrough\Temp1^>
)

md "C:\OdiScmWalkThrough\Repo2WorkingCopy"
if ERRORLEVEL 1 (
	echo %EM% creating walk through root directory ^<C:\OdiScmWalkThrough\Repo2WorkingCopy^>
)

md "C:\OdiScmWalkThrough\Temp2"
if ERRORLEVEL 1 (
	echo %EM% creating walk through root directory ^<C:\OdiScmWalkThrough\Temp2^>
)

rem
rem Source the working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	goto ExitFail
)
rem pause
REM xcopy C:\MOI\MOI_Production\ODI\Source\master "%TEMPDIR%\master\" >NUL
REM if ERRORLEVEL 1 (
	REM goto ExitFail
REM )
REM rem pause
REM xcopy C:\MOI\MOI_Production\ODI\Source\project.9007 "%TEMPDIR%\project.9007\" >NUL
REM if ERRORLEVEL 1 (
	REM goto ExitFail
REM )
rem pause

rem
rem Just to set up the Jisql tool and get the DBA user name and password.
rem Note that both demo repositories will be created in the database that's included in the URL in the Repo1 INI file.
rem
set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo1.ini
echo %IM% setting OdiScm environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b >NUL
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

echo %IM% dropping existing demo repository database users
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" %ODI_SCM_HOME%\Configuration\Demo\OdiScmDropDemoRepoUsers.sql >NUL 2>&1
if ERRORLEVEL 1 (
	goto ExitFail
)

echo %IM% creating demo repository database users
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" %ODI_SCM_HOME%\Configuration\Demo\OdiScmCreateDemoRepoUsers.sql >NUL 2>&1
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

echo %IM% importing demo repository 1
%ORACLE_HOME%\bin\imp.exe %ODI_SECU_USER%/%ODI_SECU_PASS%@%ODI_SECU_URL_HOST%:%ODI_SECU_URL_PORT%/%ODI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SECU_USER%_repid_100_empty_master_work.dmp full=y >NUL 2>&1
if ERRORLEVEL 1 (
	goto ExitFail
)

echo %IM% importing OdiScm into demo repository 1
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat" ExportPrimeLast >NUL
if ERRORLEVEL 1 (
	goto ExitFail
)

REM echo %IM% importing standard ODI demo into demo repository 1
REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportOracleDIDemo.bat" %ODI_SCM_HOME%\Configuration\Demo\Odi10gStandardDemo >NUL
REM if ERRORLEVEL 1 (
	REM goto ExitFail
REM )

set ODI_SCM_INI=%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportStandardOdiDemoRepo2.ini
echo %IM% setting OdiScm environment from ^<%ODI_SCM_INI%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b >NUL
if ERRORLEVEL 1 (
	goto ExitFail
)
call :SetMsgPrefixes

echo %IM% importing demo repository 2
%ORACLE_HOME%\bin\imp.exe %ODI_SECU_USER%/%ODI_SECU_PASS%@%ODI_SECU_URL_HOST%:%ODI_SECU_URL_PORT%/%ODI_SECU_URL_SID% file=%ODI_SCM_HOME%\Configuration\Demo\%ODI_SECU_USER%_repid_101_empty_master_work.dmp full=y >NUL 2>&1
if ERRORLEVEL 1 (
	goto ExitFail
)

echo %IM% importing OdiScm into demo repository 2
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportOdiScm.bat" ExportPrimeLast >NUL
if ERRORLEVEL 1 (
	goto ExitFail
)

rem
rem Import the standard ODI demo after OdiScm so that we can flush it out to the working copy later on.
rem
echo %IM% importing standard ODI demo into demo repository 2
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Demo\OdiScmImportOracleDIDemo.bat" %ODI_SCM_HOME%\Configuration\Demo\Odi10gStandardDemo >NUL
if ERRORLEVEL 1 (
	goto ExitFail
)

rem
rem Create a working copy of the SCM repository.
rem
rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScm.bat^" 
echo %IM% deleting existing TFS workspace ^<DemoMaster^>
tf.exe workspace /delete /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% DemoMaster >NUL 2>&1

echo %IM% creating TFS workspace ^<DemoMaster^>
tf.exe workspace /new /noprompt DemoMaster /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL%
if ERRORLEVEL 1 (
	echo %EM% creating TFS workspace ^<DemoMaster^>
	goto ExitFail
)

echo %IM% deleting default folder mapping for TFS workspace ^<DemoMaster^>
tf.exe workfold /unmap /collection:%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_URL% /workspace:DemoMaster $/
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
set TEMPSTARTCMD=%TEMPDIR%\%RANDOM%_%PROC%_StartCmd.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat^" %TEMPSTARTCMD%
if ERRORLEVEL 1 (
	echo %EM% creating StartCmd wrapper script
	goto ExitFail
)

echo %IM% exporting demo from demo repository 2
call "%TEMPSTARTCMD%" OdiStartScen -SCEN_NAME=OSFLUSH_REPOSITORY -SCEN_VERSION=-1 -CONTEXT=GLOBAL >NUL
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