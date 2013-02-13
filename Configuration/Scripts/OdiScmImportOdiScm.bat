@echo off
set FN=OdiScmImportOdiScm
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

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
set TEMPDIR=%CD%w

:StartImport
echo %IM% using temporary directory ^<%TEMPDIR%^>

echo %IM% starting import of ODI-SCM repository objects
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat %ODI_SCM_HOME%\Source\ODI
if ERRORLEVEL 1 goto ImportFail

goto CreateOdiScmInfrastructure

:ImportFail
echo %EM% importing ODI-SCM repository objects
goto ExitFail

:CreateOdiScmInfrastructure
set TEMPSTR=%RANDOM%

rem
rem Extract the repository connection details from odiparams.bat.
rem
set TEMPFILE=%TEMPDIR%\%TEMPSTR%_OdiScmImportOdiScm.txt

set MSG=extracting ODI_SECU_DRIVER
cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_DRIVER/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_DRIVER=<%TEMPFILE%

set MSG=extracting ODI_SECU_URL
cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_URL/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_URL=<%TEMPFILE%

set MSG=extracting ODI_SECU_USER
cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_USER/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_USER=<%TEMPFILE%

set MSG=extracting ODI_SECU_PASS
cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_PASS=<%TEMPFILE%

echo %IM% completed parsing of odiparams.bat
echo %IM% extracted ODI_SECU_DRIVER ^<%ODI_SECU_DRIVER%^>
echo %IM% extracted ODI_SECU_URL ^<%ODI_SECU_URL%^>
echo %IM% extracted ODI_SECU_USER ^<%ODI_SECU_USER%^>
echo %IM% extracted ODI_SECU_PASS ^<%ODI_SECU_PASS%^>

goto OdiParamsParsedOk

:GetOdiParamsParseFail
echo %EM% %MSG%
goto ExitFail

:OdiParamsParsedOk
echo %ODI_SECU_URL%|cut -f4 -d:|sed s/@// > %TEMPFILE%
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SECU_URL_HOST=<%TEMPFILE%

echo %ODI_SECU_URL%|cut -f5 -d: > %TEMPFILE%
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SECU_URL_PORT=<%TEMPFILE%

echo %ODI_SECU_URL%|cut -f6 -d: > %TEMPFILE%
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SECU_URL_SID=<%TEMPFILE%

echo %IM% extracted ODI_SECU_URL_HOST ^<%ODI_SECU_URL_HOST%^>
echo %IM% extracted ODI_SECU_URL_PORT ^<%ODI_SECU_URL_PORT%^>
echo %IM% extracted ODI_SECU_URL_SID ^<%ODI_SECU_URL_SID%^>

goto ConnStringGenOk

:ConnStringGenFail
echo %EM% extracting host/port/SID from connection URL
goto ExitFail

:ConnStringGenOk
rem
rem Create a version of the ODI-SCM infrastructure setup script for this repository.
rem
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
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat %ODI_SECU_USER% %ODI_SECU_PASS% %ODI_SECU_DRIVER% %ODI_SECU_URL% %TEMPFILE%3
if ERRORLEVEL 1 goto CreateInfrastructureFail
goto CreateInfrastructureOk

:CreateInfrastructureFail
echo %EM% creating ODI-SCM infrastructure
goto ExitFail

:CreateInfrastructureOk
rem
rem Prime the export control metadata.
rem
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat %ODI_SECU_USER% %ODI_SECU_PASS% %ODI_SECU_DRIVER% %ODI_SECU_URL% %ODI_SCM_HOME%\Configuration\Scripts\OdiScmPrimeExportNow.sql
if ERRORLEVEL 1 goto PrimeExportControlFail
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
