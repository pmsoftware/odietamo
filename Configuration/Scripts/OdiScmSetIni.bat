@echo off
setlocal
REM
REM Set a configuration INI file entry.
REM
set FN=OdiScmSetIni
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

echo %IM% starts

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
echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> ^<Key Value^>
goto ExitFail

:Arg1Ok
if not "%2" == "" goto Arg2Ok
echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> ^<Key Value^>
goto ExitFail

:Arg2Ok
if not "%3" == "" goto Arg3Ok
echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> ^<Key Value^>
goto ExitFail

:Arg3Ok
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
REM Create an AWK script to set the key.
REM
set TEMPSTR=%RANDOM%
set TEMPSCRIPT=%TEMPDIR%\%TEMPSTR%_OdiScmSetIni.awk
echo %IM% using generated AWK script ^<%TEMPSCRIPT%^>
set TEMPSTDOUT=%TEMPDIR%\%TEMPSTR%_OdiScmSetIni.stdout

cat "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetIniTemplate.awk" | sed "s/<SectionName>/%1/g" | sed "s/<KeyName>/%2/g" | sed "s/<KeyValue>/%3/g" > %TEMPSCRIPT%
if ERRORLEVEL 1 (
	echo %EM% creating AWK script
	goto ExitFail
)

cat %ODI_SCM_INI% | gawk -f "%TEMPSCRIPT%" > %TEMPSTDOUT%
if ERRORLEVEL 1 (
	echo %EM% executing AWK script or configuration INI file ^<%ODI_SCM_INI%^> does not contain the requested section or key
	goto ExitFail
)

cat %TEMPSTDOUT% > %ODI_SCM_INI%
if ERRORLEVEL 1 (
	echo %EM% copying temporary file ^<%TEMPSTDOUT%^> to configuration INI file ^<%ODI_SCM_INI%^>
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1
