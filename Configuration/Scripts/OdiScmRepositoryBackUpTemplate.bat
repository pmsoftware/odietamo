@echo off
setlocal
set FN=OdiScmRepositoryBackUp
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

set BU_ODI_SCM_TOOLS_ORACLE_HOME=%ODI_SCM_TOOLS_ORACLE_HOME%
set BU_PATH=%PATH%

set PATH=%ODI_SCM_TOOLS_ORACLE_HOME%\bin

echo %IM% backing up user ^<<OdiWorkRepoUserName>^> in database ^<<OdiWorkRepoServer>:<OdiWorkRepoPort>/<OdiWorkRepoSID>^>
"%ODI_SCM_TOOLS_ORACLE_HOME%\bin\exp.exe" <OdiWorkRepoUserName>/<OdiWorkRepoPassWord>@<OdiWorkRepoServer>:<OdiWorkRepoPort>/<OdiWorkRepoSID> owner=<OdiWorkRepoUserName> file=<ExportBackUpFile> statistics=none
if ERRORLEVEL 1 goto ExportFail
goto ExportOk

:ExportFail
echo %EM% exporting ODI repository schema
goto ExitError

:ExportOk
zip -9 <ExportBackUpFile>.zip <ExportBackUpFile>
if ERRORLEVEL 1 goto CompressFail
goto CompressOk

:CompressFail
echo %EM% compressing ODI repository export file
goto ExitError

:CompressOk
del <ExportBackUpFile>
if ERRORLEVEL 1 goto DeleteFail
goto DeleteOk

:DeleteFail
echo %EM% deleting uncompressed ODI repository export file
goto ExitError

:DeleteOk
goto ExitOk

:ExitOk
set ODI_SCM_TOOLS_ORACLE_HOME=%BU_ODI_SCM_TOOLS_ORACLE_HOME%
set PATH=%BU_PATH%
exit 0

:ExitError
set ODI_SCM_TOOLS_ORACLE_HOME=%BU_ODI_SCM_TOOLS_ORACLE_HOME%
set PATH=%BU_PATH%
exit 1