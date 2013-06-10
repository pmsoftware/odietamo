@echo off
setlocal
REM
REM Execute a SQL script against the ODI repository.
REM TODO: change from using repository connection details extracted from the odiparams script
REM       to those from configuration INI file specified in the environment variable ODI_SCM_INI.
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
if "%ODI_SCM_HOME%" == "" goto NoOdiScmHomeError
echo %IM% using ODI_SCM_HOME directory ^<%ODI_SCM_HOME%^>
goto OdiScmHomeOk

:NoOdiScmHomeError
echo %EM% environment variable ODI_SCM_HOME is not set
goto ExitFail

:OdiScmHomeOk
REM if "%ODI_SCM_JISQL_HOME%" == "" goto NoOdiScmJisqlScmHomeError
REM echo %IM% using ODI_SCM_JISQL_HOME directory ^<%ODI_SCM_JISQL_HOME%^>
REM goto OdiScmJisqlHomeOk

REM :NoOdiScmJisqlScmHomeError
REM echo %EM% environment variable ODI_SCM_JISQL_HOME is not set
REM goto ExitFail

REM :OdiScmJisqlHomeOk
if EXIST "%1" goto ScriptExists
echo %EM% cannot access script file ^<%1^>
goto ExitFail

:ScriptExists
set SCRIPTFILE=%1

if "%TEMP%" == "" goto NoTempDir
set TEMPDIR=%TEMP%
goto TempDirDone

:NoTempDir
if "%TMP%" == "" goto NoTmpDir
set TEMPDIR=%TMP%
goto TempDirDone

:NoTmpDir
set TEMPDIR=%CD%

:TempDirDone
set TEMPSTR=%RANDOM%

rem
rem Extract the repository connection details from odiparams.bat.
rem
set TEMPFILE=%TEMPDIR%\%TEMPSTR%_OdiScmImportOdiScm.txt

rem
rem Ensure the working file can be written to.
rem
if not EXIST "%TEMPFILE%" goto TempFileAbsent

del /f /q "%TEMPFILE%" >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% deleting working file ^<%TEMPFILE%^>
	goto ExitFail
)

:TempFileAbsent
rem
rem Extract the repository connection details into the environment (i.e. variables).
rem Note that we don't execute this via OdiScmFork.bat as we want the current environment
rem to be set. Using OdiScmFork.bat would cause the forked child environment to be set and
rem this would be lost when the child process terminated.
rem
rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetRepoEnvFromOdiParams.bat"
rem if ERRORLEVEL 1 (
rem 	echo %EM% setting repository connection environment variables
rem 	goto ExitFail
rem )

REM set MSG=extracting ODI_SECU_DRIVER
REM cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_DRIVER/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
REM if ERRORLEVEL 1 goto GetOdiParamsParseFail
REM set /p ODI_SECU_DRIVER=<%TEMPFILE%

REM set MSG=extracting ODI_SECU_URL
REM cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_URL/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
REM if ERRORLEVEL 1 goto GetOdiParamsParseFail
REM set /p ODI_SECU_URL=<%TEMPFILE%

REM set MSG=extracting ODI_SECU_USER
REM cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_USER/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
REM if ERRORLEVEL 1 goto GetOdiParamsParseFail
REM set /p ODI_SECU_USER=<%TEMPFILE%

REM set MSG=extracting ODI_SECU_PASS
REM cat %ODI_HOME%\bin\odiparams.bat | gawk "/^set ODI_SECU_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > %TEMPFILE%
REM if ERRORLEVEL 1 goto GetOdiParamsParseFail
REM set /p ODI_SECU_PASS=<%TEMPFILE%

REM echo %IM% completed parsing of odiparams.bat
REM echo %IM% extracted ODI_SECU_DRIVER ^<%ODI_SECU_DRIVER%^>
REM echo %IM% extracted ODI_SECU_URL ^<%ODI_SECU_URL%^>
REM echo %IM% extracted ODI_SECU_USER ^<%ODI_SECU_USER%^>
REM echo %IM% extracted ODI_SECU_PASS ^<%ODI_SECU_PASS%^>

REM goto OdiParamsParsedOk

REM :GetOdiParamsParseFail
REM echo %EM% %MSG%
REM goto ExitFail

REM :OdiParamsParsedOk
REM echo %ODI_SECU_URL%|cut -f4 -d:|sed s/@// > %TEMPFILE%
REM if ERRORLEVEL 1 goto ConnStringGenFail
REM set /p ODI_SECU_URL_HOST=<%TEMPFILE%

REM echo %ODI_SECU_URL%|cut -f5 -d: > %TEMPFILE%
REM if ERRORLEVEL 1 goto ConnStringGenFail
REM set /p ODI_SECU_URL_PORT=<%TEMPFILE%

REM echo %ODI_SECU_URL%|cut -f6 -d: > %TEMPFILE%
REM if ERRORLEVEL 1 goto ConnStringGenFail
REM set /p ODI_SECU_URL_SID=<%TEMPFILE%

REM echo %IM% extracted ODI_SECU_URL_HOST ^<%ODI_SECU_URL_HOST%^>
REM echo %IM% extracted ODI_SECU_URL_PORT ^<%ODI_SECU_URL_PORT%^>
REM echo %IM% extracted ODI_SECU_URL_SID ^<%ODI_SECU_URL_SID%^>

REM goto ConnStringGenOk

REM :ConnStringGenFail
REM echo %EM% extracting host/port/SID from connection URL
REM goto ExitFail

REM :ConnStringGenOk
rem
rem Run the script file. Pass through any StdOut and StdErr capture file paths/names.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisql.bat" %ODI_SECU_USER% %ODI_SECU_PASS% %ODI_SECU_DRIVER% %ODI_SECU_URL% %SCRIPTFILE% %2 %3
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
