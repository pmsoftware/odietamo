@echo off

set IM=OdiScmJisqlRepo: INFO:
set EM=OdiScmJisqlRepo: ERROR:

set ISBATCHEXIT=

if "%1" == "/b" goto IsBatchExit
if "%1" == "/B" goto IsBatchExit

goto IsNotBatchExit

:IsBatchExit
set ISBATCHEXIT=/b
shift

:IsNotBatchExit

echo %IM% Script=%1
echo %IM% StdOutFile=%2
echo %IM% StdErrFile=%3

rem
rem Edit the details of your ODI repository here.
rem Arguments are RepoDbUser RepoDbPassWord RepoJdbcDriver RepoJdbcUrl
rem
call <ScriptsRootDir>\OdiScmJisql.bat /b <SECURITY_USER> <SECURITY_UNENC_PWD> <SECURITY_DRIVER> <SECURITY_URL> %1 %2 %3
if ERRORLEVEL 1 goto ExitFail

:ExitOk
exit %ISBATCHEXIT% 0

:ExitFail
exit %ISBATCHEXIT% 1