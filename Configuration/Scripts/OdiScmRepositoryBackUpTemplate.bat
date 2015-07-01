@echo off
setlocal
set FN=OdiScmRepositoryBackUp
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

set BU_ORACLE_HOME=%ORACLE_HOME%
set BU_PATH=%PATH%

set ORACLE_HOME=%ODI_SCM_TOOLS_ORACLE_HOME%
set PATH=%ORACLE_HOME%\bin

echo %IM% backing up user ^<<OdiWorkRepoUserName>^> in database ^<<OdiWorkRepoServer>:<OdiWorkRepoPort>/<OdiWorkRepoSID>^>
rem
rem Note: imp.exe and exp.exe write all messages to stderr for some reason.
rem We reroute them so we can check for any stderr in larger, surrounding OdiScm processes.
rem This does of course mean that we lose the ability to pinpoint stderr from exp.exe.
rem
"%ORACLE_HOME%\bin\exp.exe" <OdiWorkRepoUserName>/<OdiWorkRepoPassWord>@<OdiWorkRepoServer>:<OdiWorkRepoPort>/<OdiWorkRepoSID> file=<ExportBackUpFile> statistics=none tables=<TableList> 2>&1
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
exit 0

:ExitError
set ORACLE_HOME=%BU_ORACLE_HOME%
set PATH=%BU_PATH%
exit 1