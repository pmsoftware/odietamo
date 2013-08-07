@echo off
setlocal
REM
REM Set a configuration INI file entry.
REM

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

if "%ODI_SCM_INI%" == "" (
	echo %EM% configuration INI file environment variable ODI_SCM_INI file is not set 1>&2
	goto ExitFail
)

if "%ODI_SCM_HOME%" == "" (
	echo %EM% environment variable ODI_SCM_HOME file is not set
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> ^<Key Value^> 1>&2
	goto ExitFail
)

if "%ARGV2%" == "" (
	echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> ^<Key Value^> 1>&2
	goto ExitFail
)

if "%ARGV3%" == "" (
	echo %EM% usage: %FN% ^<Section Name^> ^<Key Name^> ^<Key Value^> 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

rem
rem Create an AWK script to set the key.
rem
set TEMPSCRIPT=%TEMPDIR%\OdiScmSetIni.awk
echo %IM% using generated AWK script ^<%TEMPSCRIPT%^>
set TEMPSTDOUT=%TEMPDIR%\OdiScmSetIni.stdout

set INISECTIONNAME=%ARGV1:$= %
set INIKEYNAME=%ARGV2:$= %

cat "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetIniTemplate.awk" | sed "s/<SectionName>/%INISECTIONNAME%/g" | sed "s/<KeyName>/%INIKEYNAME%/g" | sed "s/<KeyValue>/%ARGV3%/g" > %TEMPSCRIPT%
if ERRORLEVEL 1 (
	echo %EM% creating AWK script 1>&2
	goto ExitFail
)

cat %ODI_SCM_INI% | gawk -f "%TEMPSCRIPT%" > %TEMPSTDOUT%
if ERRORLEVEL 1 (
	echo %EM% executing AWK script or configuration INI file ^<%ODI_SCM_INI%^> does not contain the requested section or key 1>&2
	goto ExitFail
)

cat %TEMPSTDOUT% > %ODI_SCM_INI%
if ERRORLEVEL 1 (
	echo %EM% copying temporary file ^<%TEMPSTDOUT%^> to configuration INI file ^<%ODI_SCM_INI%^> 1>&2
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1