@echo off

set IM=MoiJisqlRepo: INFO:
set EM=MoiJisqlRepo: ERROR:

echo %IM% Script=%1
echo %IM% StdOutFile=%2
echo %IM% StdErrFile=%3

rem
rem Edit the details of your ODI repository here.
rem Arguments are RepoDbUser RepoDbPassWord RepoJdbcDriver RepoJdbcUrl
rem
call C:\MOI\Configuration\Scripts\MoiJisql.bat <SECURITY_USER> <SECURITY_UNENC_PWD> <SECURITY_DRIVER> <SECURITY_URL> %1 %2 %3
if ERRORLEVEL 1 goto ExitFail

:ExitOk
exit /b 0

:ExitFail
exit /b 1