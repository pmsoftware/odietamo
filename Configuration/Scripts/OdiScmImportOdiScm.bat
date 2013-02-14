@echo off
set FN=OdiScmImportOdiScm
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

set PRIMEMETADATA=TRUE

if "%1" == "" goto ArgsOk

if "%1" == "NoExportPrime" (
	set PRIMEMETADATA=FALSE
	goto ArgsOk
)

echo %EM% invalid argument ^<%1%^>
echo %IM% usage OdiScmImportOdiScm [NoExportPrime]
goto ExitFail

:ArgsOk
if "%ODI_HOME%" == "" goto NoOdiHomeError
goto OdiHomeOk

:NoOdiHomeError
echo %EM% environment variable ODI_HOME is not set
goto ExitFail

:OdiHomeOk
if "%ODI_SCM_HOME%" == "" goto NoOdiScmHomeError
goto OdiScmHomeOk

:NoOdiScmHomeError
echo %EM% environment variable ODI_SCM_HOME is not set
goto ExitFail

:OdiScmHomeOk
if "%ODI_SCM_JISQL_HOME%" == "" goto NoOdiScmJisqlScmHomeError
goto OdiScmJisqlHomeOk

:NoOdiScmJisqlScmHomeError
echo %EM% environment variable ODI_SCM_JISQL_HOME is not set
goto ExitFail

:OdiScmJisqlHomeOk
if "%TEMP%" == "" goto NoTempDir
set TEMPDIR=%TEMP%
goto StartImport

:NoTempDir
if "%TMP%" == "" goto NoTmpDir
set TEMPDIR=%TMP%
goto StartImport

:NoTmpDir
set TEMPDIR=%CD%

:StartImport
echo %IM% using temporary directory ^<%TEMPDIR%^>

echo %IM% starting import of ODI-SCM repository objects
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat %ODI_SCM_HOME%\Source\ODI
if ERRORLEVEL 1 goto ImportFail

echo %IM% completed import of ODI-SCM repository objects
goto CreateOdiScmInfrastructure

:ImportFail
echo %EM% importing ODI-SCM repository objects
goto ExitFail

:CreateOdiScmInfrastructure
set TEMPSTR=%RANDOM%

rem
rem Create a version of the ODI-SCM infrastructure setup script for this repository.
rem
set TEMPFILE=%TEMPDIR%\%TEMPSTR%_OdiScmImportOdiScm.txt
cat %ODI_SCM_HOME%\Configuration\Scripts\odisvn_create_infrastructure.sql | sed s/"<OdiWorkRepoUserName>"/%ODI_SECU_USER%/ > %TEMPFILE%
if ERRORLEVEL 1 goto ScriptGenFail

cat %TEMPFILE% | sed s/"<OdiWorkRepoPassWord>"/%ODI_SECU_PASS%/ > %TEMPFILE%2
if ERRORLEVEL 1 goto ScriptGenFail

set CONNSTR=%ODI_SECU_URL_HOST%:%ODI_SECU_URL_PORT%\/%ODI_SECU_URL_SID%
cat %TEMPFILE%2 | sed s/"<OdiWorkRepoConnectionString>"/%CONNSTR%/ > %TEMPFILE%3
if ERRORLEVEL 1 goto ScriptGenFail

goto ScriptGenOk

:ScriptGenFail
echo %EM% creating ODI-SCM repository infrastructure set up script
goto ExitFail

:ScriptGenOk
rem
rem Run the generated ODI-SCM repository infrastructure set up script.
rem
echo %IM% creating ODI-SCM repository objects
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat %TEMPFILE%
if ERRORLEVEL 1 goto CreateInfrastructureFail

echo %IM% completed creation of ODI-SCM repository objects
goto CreateInfrastructureOk

:CreateInfrastructureFail
echo %EM% creating ODI-SCM infrastructure
goto ExitFail

:CreateInfrastructureOk
if %PRIMEMETADATA% == FALSE goto ExitOk

rem
rem Prime the export control metadata.
rem
echo %IM% priming ODI-SCM export control metadata
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat %ODI_SCM_HOME%\Configuration\Scripts\OdiScmPrimeExportNow.sql
if ERRORLEVEL 1 goto PrimeExportControlFail

echo %IM% completed priming of ODI-SCM export control metadata
goto PrimeExportControlOk

:PrimeExportControlFail
echo %EM% priming ODI-SCM export metadata
goto ExitFail

:PrimeExportControlOk
echo %IM% import of ODI-SCM ODI components completed successfully

goto ExitOk

:ExitFail
exit /b 1

:ExitOk
exit /b 0
