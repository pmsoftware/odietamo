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

if "%ODI_SCM_SSIS_SERVER_NAME%" == "" (
	echo %EM% variable ^<ODI_SCM_SSIS_SERVER_NAME^> not set 1>&2
	goto ExitFail
)

if "%ODI_SCM_SSIS_CATALOGUE_PATH%" == "" (
	echo %EM% variable ^<ODI_SCM_SSIS_CATALOGUE_PATH^> not set 1>&2
	goto ExitFail
)

rem
rem Deploy the MSBI-CI components to the SSIS catalogue folder.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmDeploySsisProject.bat" "%ODI_SCM_HOME%\Source\MsbiCi"
if ERRORLEVEL 1 (
	echo %EM% deploying ODI-SCM MSBI-CI SSIS components 2>&1
	goto ExitFail
)

echo %IM% import of ODI-SCM MSBI-CI SSIS components completed successfully
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 2>&1
exit %IsBatchExit% 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************
