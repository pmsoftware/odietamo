@echo off
setlocal
set FN=OdiScmRepositoryBackUp
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

REM set BU_ORACLE_HOME=%ORACLE_HOME%
set BU_PATH=%PATH%

REM set ORACLE_HOME=C:\MOI\Configuration\Tools\Oracle10gClient
REM set PATH=C:\MOI\Configuration\Tools\Oracle10gClient\BIN
set PATH=%ORACLE_HOME%\bin

echo %IM% backing up user ^<<OdiWorkRepoUserName>^> in database ^<<OdiWorkRepoServer>:<OdiWorkRepoPort>/<OdiWorkRepoSID>^>
"%ORACLE_HOME%\bin\exp.exe" <OdiWorkRepoUserName>/<OdiWorkRepoPassWord>@<OdiWorkRepoServer>:<OdiWorkRepoPort>/<OdiWorkRepoSID> owner=<OdiWorkRepoUserName> file=<ExportBackUpFile> statistics=none
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