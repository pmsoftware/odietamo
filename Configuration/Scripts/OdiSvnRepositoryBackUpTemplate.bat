@echo off

set IM=OdiSvnRepositoryBackUp: INFO:
set EM=OdiSvnRepositoryBackUp: ERROR:

set BU_ORACLE_HOME=%ORACLE_HOME%
set BU_PATH=%PATH%

set ORACLE_HOME=C:\MOI\Configuration\Tools\Oracle10gClient
set PATH=C:\MOI\Configuration\Tools\Oracle10gClient\BIN

exp <OdiWorkRepoUserName>/<OdiWorkRepoPassWord>@<OdiWorkRepoServer>:<OdiWorkRepoPort>/<OdiWorkRepoSID> owner=<OdiWorkRepoUserName> file=<ExportBackUpFile> statistics=none
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
set ORACLE_HOME=%BU_ORACLE_HOME%
set PATH=%BU_PATH%
exit /b 0

:ExitError
set ORACLE_HOME=%BU_ORACLE_HOME%
set PATH=%BU_PATH%
exit /b 1