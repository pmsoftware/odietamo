@echo off

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

echo %IM% Database Type Name ^<%ARGV1%^>
echo %IM% User Name is ^<%ARGV2%^>
echo %IM% User Password is ^<%ARGV3%^>
echo %IM% JDBC URL ^<%ARGV4%^>
echo %IM% Database Name ^<%ARGV5%^>
echo %IM% Schema Name ^<%ARGV6%^>

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating working directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEmptyFile.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary empty file ^<%EMPTYFILE%^> 1>&2
	goto ExitFail
)

set TEMPPSSCRIPT=%TEMPDIR%\%PROC%_psscript.ps1

echo . "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownDatabaseSchemas.ps1" >%TEMPPSSCRIPT%
echo $RetVal = TearDownDatabaseSchema "%ARGV1%" "%ARGV2%" "%ARGV3%" "%ARGV4%" "%ARGV5%" "%ARGV6%" >>%TEMPPSSCRIPT%
echo if (!($RetVal)) { >>%TEMPPSSCRIPT%
echo 	exit 5 >>%TEMPPSSCRIPT%
echo } >>%TEMPPSSCRIPT%
echo else { >>%TEMPPSSCRIPT%
echo 	exit 0 >>%TEMPPSSCRIPT%
echo } >>%TEMPPSSCRIPT%

echo %IM% execting temporary PowerShell script ^<%TEMPPSSCRIPT%^>
PowerShell -Command "& { %TEMPPSSCRIPT% ; exit $LASTEXITCODE }"
if ERRORLEVEL 1 (
	echo %EM% execting temporary PowerShell script ^<%TEMPPSSCRIPT%^> 1>&2 
	goto ExitFail
)

echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1