@echo off
REM
REM Set repository connection environment variables extracted from the odiparams script.
REM
REM TODO: change from using repository connection details extracted from the odiparams script
REM       to those from configuration INI file specified in the environment variable ODI_SCM_INI.
REM
set FN=OdiScmSetRepoEnvFromOdiParams
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

if "%ODI_HOME%" == "" goto NoOdiHomeError
echo %IM% using ODI_HOME directory ^<%ODI_HOME%^>
goto OdiHomeOk

:NoOdiHomeError
echo %EM% environment variable ODI_HOME is not set
goto ExitFail

:OdiHomeOk
set PARAMFILE=%ODI_HOME%\bin\odiparams.bat
if not EXIST "%PARAMFILE%" (
	echo %EM% parameter file ^<%PARAMFILE%^> does not exist
	goto ExitFail
)

which cat.exe >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% checking for presence of cat command
	goto ExitFail
)

which gawk.exe >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% checking for presence of gawk command
	goto ExitFail
)

which tail.exe >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %EM% checking for presence of tail command
	goto ExitFail
)

if "%TEMP%" == "" goto NoTempDir
set TEMPDIR=%TEMP%
goto TempDirSet

:NoTempDir
if "%TMP%" == "" goto NoTmpDir
set TEMPDIR=%TMP%
goto TempDirSet

:NoTmpDir
set TEMPDIR=%CD%

:TempDirSet
set TEMPSTR=%RANDOM%

rem
rem Extract the repository connection details from odiparams.bat.
rem
set TEMPFILE=%TEMPDIR%\%TEMPSTR%_OdiScmSetRepoEnvFromOdiParams.txt

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
set MSG=extracting ODI_SECU_DRIVER
cat "%PARAMFILE%" | gawk "/^set ODI_SECU_DRIVER/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_DRIVER=<"%TEMPFILE%"

set MSG=extracting ODI_SECU_URL
cat "%PARAMFILE%" | gawk "/^set ODI_SECU_URL/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_URL=<"%TEMPFILE%"

set MSG=extracting ODI_SECU_USER
cat "%PARAMFILE%" | gawk "/^set ODI_SECU_USER/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_USER=<"%TEMPFILE%"

set MSG=extracting ODI_SECU_PASS
cat "%PARAMFILE%" | gawk "/^set ODI_SECU_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_PASS=<"%TEMPFILE%"

set MSG=extracting ODI_SECU_ENCODED_PASS
cat "%PARAMFILE%" | gawk "/^set ODI_SECU_ENCODED_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_ENCODED_PASS=<"%TEMPFILE%"

set MSG=extracting ODI_SECU_WORK_REP
cat "%PARAMFILE%" | gawk "/^set ODI_SECU_WORK_REP/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SECU_WORK_REP=<"%TEMPFILE%"

set MSG=extracting ODI_USER
cat "%PARAMFILE%" | gawk "/^set ODI_USER/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_USER=<"%TEMPFILE%"

set MSG=extracting ODI_ENCODED_PASS
cat "%PARAMFILE%" | gawk "/^set ODI_ENCODED_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_ENCODED_PASS=<"%TEMPFILE%"

echo %IM% completed parsing of odiparams.bat
echo %IM% extracted ODI_SECU_DRIVER ^<%ODI_SECU_DRIVER%^>
echo %IM% extracted ODI_SECU_URL ^<%ODI_SECU_URL%^>
echo %IM% extracted ODI_SECU_USER ^<%ODI_SECU_USER%^>
echo %IM% extracted ODI_SECU_PASS ^<%ODI_SECU_PASS%^>
echo %IM% extracted ODI_SECU_ENCODED_PASS ^<%ODI_SECU_ENCODED_PASS%^>
echo %IM% extracted ODI_SECU_WORK_REP ^<%ODI_SECU_WORK_REP%^>
echo %IM% extracted ODI_USER ^<%ODI_USER%^>
echo %IM% extracted ODI_ENCODED_PASS ^<%ODI_ENCODED_PASS%^>

goto OdiParamsParsedOk

:GetOdiParamsParseFail
echo %EM% %MSG%
goto ExitFail

:OdiParamsParsedOk
echo %ODI_SECU_URL%|cut -f4 -d:|sed s/@// > "%TEMPFILE%"
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SECU_URL_HOST=<"%TEMPFILE%"

echo %ODI_SECU_URL%|cut -f5 -d: > "%TEMPFILE%"
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SECU_URL_PORT=<"%TEMPFILE%"

echo %ODI_SECU_URL%|cut -f6 -d: > "%TEMPFILE%"
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SECU_URL_SID=<"%TEMPFILE%"

echo %IM% extracted ODI_SECU_URL_HOST ^<%ODI_SECU_URL_HOST%^>
echo %IM% extracted ODI_SECU_URL_PORT ^<%ODI_SECU_URL_PORT%^>
echo %IM% extracted ODI_SECU_URL_SID ^<%ODI_SECU_URL_SID%^>

goto ConnStringGenOk

:ConnStringGenFail
echo %EM% extracting host/port/SID from connection URL
goto ExitFail

:ConnStringGenOk

:ExitOk
exit /b 0

:ExitFail
exit /b 1
