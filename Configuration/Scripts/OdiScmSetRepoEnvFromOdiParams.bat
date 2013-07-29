@echo off
REM
REM Set repository connection environment variables extracted from the odiparams script.
REM
REM TODO: change from using repository connection details extracted from the odiparams script
REM       to those from configuration INI file specified in the environment variable ODI_SCM_INI.
REM

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

set PARAMFILE=%ODI_SCM_ORACLEDI_HOME%\bin\odiparams.bat
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
set MSG=extracting ODI_SCM_ORACLEDI_SECU_DRIVER
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ORACLEDI_SECU_DRIVER/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ORACLEDI_SECU_DRIVER=<"%TEMPFILE%"

set MSG=extracting ODI_SCM_ORACLEDI_SECU_URL
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ORACLEDI_SECU_URL/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ORACLEDI_SECU_URL=<"%TEMPFILE%"

set MSG=extracting ODI_SCM_ORACLEDI_SECU_USER
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ORACLEDI_SECU_USER/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ORACLEDI_SECU_USER=<"%TEMPFILE%"

set MSG=extracting ODI_SCM_ORACLEDI_SECU_PASS
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ORACLEDI_SECU_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ORACLEDI_SECU_PASS=<"%TEMPFILE%"

set MSG=extracting ODI_SCM_ENCODED_PASS
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ENCODED_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ENCODED_PASS=<"%TEMPFILE%"

set MSG=extracting ODI_SCM_ORACLEDI_SECU_WORK_REP
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ORACLEDI_SECU_WORK_REP/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ORACLEDI_SECU_WORK_REP=<"%TEMPFILE%"

set MSG=extracting ODI_SCM_ORACLEDI_USER
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ORACLEDI_USER/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ORACLEDI_USER=<"%TEMPFILE%"

set MSG=extracting ODI_SCM_ORACLEDI_ENCODED_PASS
cat "%PARAMFILE%" | gawk "/^set ODI_SCM_ORACLEDI_ENCODED_PASS/ { print $0 }" | tail -1 | cut -f2 -d= > "%TEMPFILE%"
if ERRORLEVEL 1 goto GetOdiParamsParseFail
set /p ODI_SCM_ORACLEDI_ENCODED_PASS=<"%TEMPFILE%"

echo %IM% completed parsing of odiparams.bat
echo %IM% extracted ODI_SCM_ORACLEDI_SECU_DRIVER ^<%ODI_SCM_ORACLEDI_SECU_DRIVER%^>
echo %IM% extracted ODI_SCM_ORACLEDI_SECU_URL ^<%ODI_SCM_ORACLEDI_SECU_URL%^>
echo %IM% extracted ODI_SCM_ORACLEDI_SECU_USER ^<%ODI_SCM_ORACLEDI_SECU_USER%^>
echo %IM% extracted ODI_SCM_ORACLEDI_SECU_PASS ^<%ODI_SCM_ORACLEDI_SECU_PASS%^>
echo %IM% extracted ODI_SCM_ENCODED_PASS ^<%ODI_SCM_ENCODED_PASS%^>
echo %IM% extracted ODI_SCM_ORACLEDI_SECU_WORK_REP ^<%ODI_SCM_ORACLEDI_SECU_WORK_REP%^>
echo %IM% extracted ODI_SCM_ORACLEDI_USER ^<%ODI_SCM_ORACLEDI_USER%^>
echo %IM% extracted ODI_SCM_ORACLEDI_ENCODED_PASS ^<%ODI_SCM_ORACLEDI_ENCODED_PASS%^>

goto OdiParamsParsedOk

:GetOdiParamsParseFail
echo %EM% %MSG%
goto ExitFail

:OdiParamsParsedOk
echo %ODI_SCM_ORACLEDI_SECU_URL%|cut -f4 -d:|sed s/@// > "%TEMPFILE%"
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SCM_ORACLEDI_SECU_URL_HOST=<"%TEMPFILE%"

echo %ODI_SCM_ORACLEDI_SECU_URL%|cut -f5 -d: > "%TEMPFILE%"
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SCM_ORACLEDI_SECU_URL_PORT=<"%TEMPFILE%"

echo %ODI_SCM_ORACLEDI_SECU_URL%|cut -f6 -d: > "%TEMPFILE%"
if ERRORLEVEL 1 goto ConnStringGenFail
set /p ODI_SCM_ORACLEDI_SECU_URL_SID=<"%TEMPFILE%"

echo %IM% extracted ODI_SCM_ORACLEDI_SECU_URL_HOST ^<%ODI_SCM_ORACLEDI_SECU_URL_HOST%^>
echo %IM% extracted ODI_SCM_ORACLEDI_SECU_URL_PORT ^<%ODI_SCM_ORACLEDI_SECU_URL_PORT%^>
echo %IM% extracted ODI_SCM_ORACLEDI_SECU_URL_SID ^<%ODI_SCM_ORACLEDI_SECU_URL_SID%^>

goto ConnStringGenOk

:ConnStringGenFail
echo %EM% extracting host/port/SID from connection URL
goto ExitFail

:ConnStringGenOk

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1
