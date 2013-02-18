@echo off
setlocal
REM
REM Execute a SQL script against the ODI repository using repository connection details extracted from odiparams.bat.
REM
set FN=OdiScmJisqlRepo
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

set ISBATCHEXIT=

if "%1" == "/b" goto IsBatchExit
if "%1" == "/B" goto IsBatchExit

goto IsNotBatchExit

:IsBatchExit
set ISBATCHEXIT=/b
shift

:IsNotBatchExit
if "%ODI_HOME%" == "" goto NoOdiHomeError
echo %IM% using ODI_HOME directory ^<%ODI_HOME%^>
goto OdiHomeOk

:NoOdiHomeError
echo %EM% environment variable ODI_HOME is not set
goto ExitFail

:OdiHomeOk
if "%ODI_SCM_HOME%" == "" goto NoOdiScmHomeError
echo %IM% using ODI_SCM_HOME directory ^<%ODI_SCM_HOME%^>
goto OdiScmHomeOk

:NoOdiScmHomeError
echo %EM% environment variable ODI_SCM_HOME is not set
goto ExitFail

:OdiScmHomeOk
if "%ODI_SCM_JISQL_HOME%" == "" goto NoOdiScmJisqlScmHomeError
echo %IM% using ODI_SCM_JISQL_HOME directory ^<%ODI_SCM_JISQL_HOME%^>
goto OdiScmJisqlHomeOk

:NoOdiScmJisqlScmHomeError
echo %EM% environment variable ODI_SCM_JISQL_HOME is not set
goto ExitFail

:OdiScmJisqlHomeOk
if EXIST "%1" goto ScriptExists
echo %EM% cannot access script file ^<%1^>
goto ExitFail

:ScriptExists
set SCRIPTFILE=%1

REM if "%TEMP%" == "" goto NoTempDir
REM set TEMPDIR=%TEMP%
REM goto StartImport

REM :NoTempDir
REM if "%TMP%" == "" goto NoTmpDir
REM set TEMPDIR=%TMP%
REM goto StartImport

REM :NoTmpDir
REM set TEMPDIR=%CD%

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
rem Run the script file. Pass through any StdOut and StdErr capture file paths/names.
rem
call %ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat /b %ODI_SECU_USER% %ODI_SECU_PASS% %ODI_SECU_DRIVER% %ODI_SECU_URL% %SCRIPTFILE% %2 %3
if ERRORLEVEL 1 goto RunScriptFail
goto RunScriptOk

:RunScriptFail
echo %EM% executing script file ^<%SCRIPTFILE%^>
goto ExitFail

:RunScriptOk

:ExitOk
exit %ISBATCHEXIT% 0

:ExitFail
exit %ISBATCHEXIT% 1
