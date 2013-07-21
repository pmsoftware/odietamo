@echo off

call :SetMsgPrefixes

echo %IM% starts

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

set PRIMEMETADATA=FALSE

if "%1" == "" goto ArgsOk

if "%1" == "NoExportPrime" (
	set PRIMEMETADATA=FALSE
	goto ArgsOk
)

if "%1" == "ExportPrimeFirst" (
	set PRIMEMETADATA=FIRST
	goto ArgsOk
)

if "%1" == "ExportPrimeLast" (
	set PRIMEMETADATA=LAST
	goto ArgsOk
)

echo %EM% invalid argument ^<%1%^>
echo %IM% usage %PROC% ^[NoExportPrime ^| ExportPrimeFirst ^| ExportPrimeLast^]
goto ExitFail

:ArgsOk

REM
REM Check basic environment requirements.
REM
if "%ODI_SCM_HOME%" == "" (
	echo %EM% no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI
	goto ExitFail
) else (
	echo %IM% using source configuration INI file ^<%ODI_SCM_INI%^> 
)

REM
REM Set the environment from the configuration INI file.
REM
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEnv.bat" /b
set EXITSTATUS=%ERRORLEVEL%
call :SetMsgPrefixes
if not "%EXITSTATUS%" == "0" (
	echo %EM% setting environment from configuration INI file
	goto ExitFail
)

set ODI_SCM_ODI_VERSION_MAJOR=%ODI_VERSION:~0,3%
if not "%ODI_SCM_ODI_VERSION_MAJOR%" == "10." (
	if not "%ODI_SCM_ODI_VERSION_MAJOR%" == "11." (
		echo %EM% invalid ODI version ^<%ODI_VERSION%^> specified in environment variable ODI_VERSION 1>&2
		goto ExitFail
	)
)

if not EXIST "%ODI_SCM_HOME%\Source\OdiScm" (
	echo %EM% OdiScm repository components not found in directory ^<%ODI_SCM_HOME%\Source\ODI^>
	goto ExitFail
)

if not EXIST "%ODI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_HOME directory ^<%ODI_HOME%\bin^>
	goto ExitFail
)

rem
rem Define a temporary work directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^>
	goto ExitFail
)

rem
rem Define a temporary empty file.
rem
set EMPTYFILE=%TEMPDIR%\%RANDOM%_EmptyFile.txt
type NUL >%EMPTYFILE% 2>NUL
if ERRORLEVEL 1 (
	echo %EM% cannot create empty file ^<%EMPTYFILE%^>
	goto ExitFail
)

rem
rem Create a StartCmd.bat script for the current environment.
rem
set TEMPSTARTCMD=%TEMPDIR%\%RANDOM%_OdiScmImportOdiScm_StartCmd.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat^" %TEMPSTARTCMD%
if ERRORLEVEL 1 (
	echo %EM% creating StartCmd wrapper script
	goto ExitFail
)

rem
rem Create a version of the ODI-SCM infrastructure setup script for this repository.
rem
set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmImportOdiScm_CreateInfrastructure.sql
cat "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateInfrastructureTemplate.sql" | sed s/"<OdiWorkRepoUserName>"/%ODI_SECU_USER%/ > "%TEMPFILE%"
if ERRORLEVEL 1 goto ScriptGenFail

cat "%TEMPFILE%" | sed s/"<OdiWorkRepoPassWord>"/%ODI_SECU_PASS%/ > "%TEMPFILE%2"
if ERRORLEVEL 1 goto ScriptGenFail

set CONNSTR=%ODI_SECU_URL_HOST%:%ODI_SECU_URL_PORT%\/%ODI_SECU_URL_SID%
cat "%TEMPFILE%2" | sed s/"<OdiWorkRepoConnectionString>"/%CONNSTR%/ > "%TEMPFILE%3"
if ERRORLEVEL 1 goto ScriptGenFail

goto ScriptGenOk

:ScriptGenFail
echo %EM% creating ODI-SCM repository infrastructure set up script
goto ExitFail

:ScriptGenOk
rem
rem Define files used to capture standard output and standard error channels.
rem
set TEMPFILESTR=%RANDOM%
set STDOUTFILE=%TEMPDIR%\%TEMPFILESTR%_OdiScmImportOdiScm_StdOut.log
set STDERRFILE=%TEMPDIR%\%TEMPFILESTR%_OdiScmImportOdiScm_StdErr.log

rem
rem Run the generated ODI-SCM repository infrastructure set up script.
rem
echo %IM% creating ODI-SCM repository objects
echo
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat^" %TEMPFILE%3 %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto CreateInfrastructureFail

goto CreateInfrastructureChkStdErr

:CreateInfrastructureFail
echo %EM% Batch file OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto ExitFail

:CreateInfrastructureChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
echo fc %EMPTYFILE% %STDERRFILE%
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto CreateInfrastructureOk

echo %IM% Batch file OdiScmJisqlRepo.bat returned StdErr content:
type %STDERRFILE%

goto ExitFail

:CreateInfrastructureOk

echo %IM% completed creation of ODI-SCM infrastructure repository objects

rem
rem Configure the ODI-SCM repository metadata.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetRepoConfig.bat^"
if ERRORLEVEL 1 (
	echo %EM% configurating ODI-SCM repository metadata
	goto ExitFail
)

if %PRIMEMETADATA% == FIRST (
	call :PrimeExport
	if ERRORLEVEL 1 (
		echo %EM% priming ODI-SCM export metadata before ODI-SCM import
		goto ExitFail
	)
)

rem
rem Copy the ODI-SCM repository components import files and modify the connection details in the copy before we import them.
rem
set TEMPOBJSDIR=%TEMPDIR%\%RANDOM%_OdiScmImportOdiScm
md "%TEMPOBJSDIR%"
if ERRORLEVEL 1 (
	echo %EM% creating temporary work directory ^<%TEMPOBJSDIR%^>
	goto ExitFail
)

xcopy /e "%ODI_SCM_HOME%\Source\OdiScm\master" "%TEMPOBJSDIR%\master\" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying ODI-SCM master repository component import files
	goto ExitFail
)

xcopy /e "%ODI_SCM_HOME%\Source\OdiScm\project.1998" "%TEMPOBJSDIR%\project.1998\" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying ODI-SCM work repository component import files
	goto ExitFail
)

rem
rem Modify the contents of the SnpConnect files.
rem
setlocal enabledelayedexpansion
for /f %%g in ('dir /s /b "%TEMPOBJSDIR%\*.SnpConnect"') do (
	echo %IM% preparing data server file ^<%%g^>
	rem echo %DEBUG% setting driver class
	cat "%%g" | sed s/"<OdiScmJavaDriverClass>"/"%ODI_SECU_DRIVER%"/g > %%g.1
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting pass word
	cat "%%g.1" | sed s/"<OdiScmPassWord>"/"%ODI_SECU_ENCODED_PASS%"/g > %%g.2
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting user name
	cat "%%g.2" | sed s/"<OdiScmUserName>"/"%ODI_SECU_USER%"/g > %%g.3
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting URL
	cat "%%g.3" | sed s/"<OdiScmUrl>"/"%ODI_SECU_URL%"/g > %%g.4
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting working copy dir root
	set WCROOT=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT:\=\\%
	set WCROOT=!WCROOT:/=\/!
	cat "%%g.4" | sed s/"<OdiScmWorkingCopyDir>"/"!WCROOT!"/g > %%g.5
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting work dir
	set WDIR=%ODI_SCM_SCM_SYSTEM_WORKING_ROOT:\=\\%
	set WDIR=!WDIR:/=\/!
	cat "%%g.5" | sed s/"<OdiScmTempDir>"/"!WDIR!"/g > %%g.6
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	copy "%%g.6" "%%g" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
)

echo %IM% starting import of ODI-SCM master repository objects
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat^" %TEMPOBJSDIR%\master
if ERRORLEVEL 1 (
	echo %EM% importing ODI-SCM ODI repository objects
	goto ExitFail
)

echo %IM% completed import of ODI-SCM master repository objects

REM echo %IM% starting import of ODI-SCM work repository objects
REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat^" %TEMPOBJSDIR%\project.1998
REM if ERRORLEVEL 1 (
	REM echo %EM% importing ODI-SCM ODI repository objects
	REM goto ExitFail
REM )

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiImportObject -FILE_NAME=%ODI_SCM_HOME%\Source\OdiScm\PROJ_ODI-SCM.xml -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% importing ODI-SCM ODI project
	goto ExitFail
)

echo %IM% completed import of ODI-SCM work repository objects

echo %IM% regenerating ODI-SCM ODI project scenarios
if "%ODI_SCM_ODI_VERSION_MAJOR%" == "10." (
	set ODI_SCM_PROJECT=1998
) else (
	set ODI_SCM_PROJECT=OS
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiGenerateAllScen -PROJECT=%ODI_SCM_PROJECT% -MODE=REPLACE -GENERATE_PACK=YES -GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO
if ERRORLEVEL 1 (
	echo %EM% regenerating ODI-SCM ODI project scenarios
	goto ExitFail
)

if %PRIMEMETADATA% == LAST (
	call :PrimeExport
	if ERRORLEVEL 1 (
		echo %EM% priming ODI-SCM export metadata after ODI-SCM import
		goto ExitFail
	)
)

rem
rem Configure the ODI-SCM ODI constants (variables).
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiStartScen -SCEN_NAME=OSCONFIGURE -SCEN_VERSION=-1 -CONTEXT=GLOBAL
if ERRORLEVEL 1 (
	echo %EM% setting ODI-SCM ODI repository SCM actions constants
	goto ExitFail
)

echo %IM% import of ODI-SCM ODI components completed successfully
goto ExitOk

:ExitFail
exit %IsBatchExit% 1

:ExitOk
exit %IsBatchExit% 0

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

rem *************************************************************
:PrimeExport
rem *************************************************************
rem
rem Prime the export control metadata.
rem
echo %IM% priming ODI-SCM export control metadata
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat^" %ODI_SCM_HOME%\Configuration\Scripts\OdiScmPrimeExportNow.sql
if ERRORLEVEL 1 goto PrimeExportControlFail

echo %IM% completed priming of ODI-SCM export control metadata
goto :eof

:PrimeExportControlFail
echo %EM% priming ODI-SCM export metadata
exit /b 1

:SetMsgPrefixes
set PROC=OdiScmImportOdiScm
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:
set DEBUG=%PROC%: DEBUG:
goto :eof