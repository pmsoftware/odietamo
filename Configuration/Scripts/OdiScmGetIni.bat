@echo off
setlocal
REM
REM Get a configuration INI file entry.
REM
set FN=OdiScmGetIni
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

set ISBATCHEXIT=

if "%1" == "/b" goto IsBatchExit
if "%1" == "/B" goto IsBatchExit

goto IsNotBatchExit

:IsBatchExit
set ISBATCHEXIT=/b
shift

:IsNotBatchExit
if "%ODI_SCM_INI%" == "" (
	echo %EM% configuration INI file environment variable ODI_SCM_INI file is not set
	goto ExitFail
)

if "%ODI_SCM_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_HOME file is not set
	goto ExitFail
)

if not "%1" == "" goto Arg1Ok
echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^>
goto ExitFail

:Arg1Ok
if not "%2" == "" goto Arg2Ok
echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^>
goto ExitFail

:Arg2Ok
if "%TEMP%" == "" goto NoTempDir
set TEMPDIR=%TEMP%
goto GotTempDir

:NoTempDir
if "%TMP%" == "" goto NoTmpDir
set TEMPDIR=%TMP%
goto GotTempDir

:NoTmpDir
set TEMPDIR=%CD%

:GotTempDir
REM
REM Create an AWK script to extract the key.
REM
set TEMPSTR=%RANDOM%
set TEMPSCRIPT=%TEMPDIR%\%TEMPSTR%_OdiScmGetIni.awk
set TEMPSTDOUT=%TEMPDIR%\%TEMPSTR%_OdiScmGetIni.stdout

cat "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGetIniTemplate.awk" | sed "s/<SectionName>/%1/g" | sed "s/<KeyName>/%2/g" > %TEMPSCRIPT%
if ERRORLEVEL 1 (
	echo %EM% creating AWK script
	goto ExitFail
)

REM echo %IM% using generated script file ^<%TEMPSCRIPT%^>
cat %ODI_SCM_INI% | gawk -f "%TEMPSCRIPT%"
if ERRORLEVEL 1 (
	echo %EM% executing AWK script
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1
