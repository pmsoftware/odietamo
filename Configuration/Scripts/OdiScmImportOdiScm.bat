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

if not EXIST "%ODI_SCM_HOME%\Source\OdiScm" (
	echo %EM% OdiScm repository components not found in directory ^<%ODI_SCM_HOME%\Source\ODI^>
	goto ExitFail
)

if not EXIST "%ODI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_HOME directory ^<%ODI_HOME%\bin^>
	goto ExitFail
)

REM
REM Define a temporary work directory.
REM
if not "%TEMP%" == "" (
	set TEMPDIR=%TEMP%
) else (
	if not "%TMP%" == "" (
		set TEMPDIR=%TMP%
	) else (
		set TEMPDIR=%CD%
	)
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" %TEMPFILE%3 %STDOUTFILE% %STDERRFILE%
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
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto CreateInfrastructureOk

echo %IM% Batch file OdiScmJisqlRepo.bat returned StdErr content:
type %STDERRFILE%

goto ExitFail

:CreateInfrastructureOk
echo %IM% completed creation of ODI-SCM repository objects

if %PRIMEMETADATA% == FALSE goto StartImport

if %PRIMEMETADATA% == LAST goto StartImport

call :PrimeExport
if ERRORLEVEL 1 goto PrimeExportFirstFail
goto StartImport

:PrimeExportFirstFail
echo %EM% priming ODI-SCM export metadata before ODI-SCM import
goto ExitFail

:StartImport
echo %IM% starting import of ODI-SCM repository objects
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat" %ODI_SCM_HOME%\Source\OdiScm
if ERRORLEVEL 1 goto ImportFail

echo %IM% completed import of ODI-SCM repository objects
goto ImportOk

:ImportFail
echo %EM% importing ODI-SCM repository objects
goto ExitFail

:ImportOk

if %PRIMEMETADATA% == FALSE goto PrimeExportLastOk

if %PRIMEMETADATA% == FIRST goto PrimeExportLastOk

call :PrimeExport
if ERRORLEVEL 1 goto PrimeExportLastFail
goto PrimeExportLastOk

:PrimeExportLastFail
echo %EM% priming ODI-SCM export metadata after ODI-SCM import
goto ExitFail

:PrimeExportLastOk
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
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" /b %ODI_SCM_HOME%\Configuration\Scripts\OdiScmPrimeExportNow.sql
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
goto :eof