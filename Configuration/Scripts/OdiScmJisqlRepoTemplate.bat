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

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^>
	goto ExitFail
)

set TEMPJARFILE=%TEMPDIR%\%PROC%.jar

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat^" /p %TEMPJARFILE%
if ERRORLEVEL 1 (
	echo %EM% creating ODI class path helper JAR file
	goto ExitFail
)

echo %IM% Script=%1
echo %IM% StdOutFile=%2
echo %IM% StdErrFile=%3

rem
rem Edit the details of your ODI repository here.
rem Arguments are RepoDbUser RepoDbPassWord RepoJdbcDriver RepoJdbcUrl
rem
call "<OdiScmHomeDir>\Configuration\Scripts\OdiScmFork.bat" ^"<ScriptsRootDir>\OdiScmJisql.bat^" <SECURITY_USER> <SECURITY_UNENC_PWD> <SECURITY_DRIVER> <SECURITY_URL> %1 %TEMPJARFILE% %2 %3
if ERRORLEVEL 1 goto ExitFail

:ExitOk
exit %ISBATCHEXIT% 0

:ExitFail
exit %ISBATCHEXIT% 1