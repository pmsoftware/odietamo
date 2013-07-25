@echo off

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

if "%ARGV1%" == "" (
	echo %EM% output JAR file path/name not specified
	echo %IM% usage: %PROC% ^<output JAR file^>
	goto ExitFail
)

set OUTJARFILE=%ARGV1%

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^>
	goto ExitFail
)

rem
rem Create a manifest file with the paths and names of all the JARs we need.
rem
set TEMPFILE=%TEMPDIR%\%PROC%_Maniftest.txt
<nul set /p =Class-Path:> "%TEMPFILE%"

rem TODO: get jars from this var and add separately.
if not "%ODI_SCM_JISQL_ADDITIONAL_CLASSPATH%" == "" (
	echo %IM% using additional class path from environment variable ODI_SCM_JISQL_ADDITIONAL_CLASSPATH
	set JISQL_CLASS_PATH=%ODI_SCM_JISQL_ADDITIONAL_CLASSPATH%
) else (
	echo %IM% no additional class path specified in environment variable ODI_SCM_JISQL_ADDITIONAL_CLASSPATH
)

echo %IM% adding files from OracleDI drivers directory ^<%ODI_HOME%^> to class path
for /f %%f in ('dir /b /s %ODI_HOME%\drivers\*.jar 2^>NUL') do (
	rem <nul set /p =%%f >> "%TEMPFILE%"
	call :AddToManifest %%f
)

for /f %%f in ('dir /b /s %ODI_HOME%\drivers\*.zip 2^>NUL') do (
	rem <nul set /p =%%f >> "%TEMPFILE%"
	call :AddToManifest %%f
)

echo %IM% adding OracleDI common directory ^<%ODI_COMMON%^> to class path
call :AddToManifest %ODI_COMMON%\odi\

if not "%ODI_COMMON%" == "" (
	rem TODO: check if this dir actually exists.
	echo %IM% adding files from OracleDI common directory ^<%ODI_COMMON%^> to class path
	for /f %%f in ('dir /b /s %ODI_COMMON%\*.jar 2^>NUL') do (
		rem <nul set /p =%%f >> "%TEMPFILE%"
		call :AddToManifest %%f
	)
	
	for /f %%f in ('dir /b /s %ODI_COMMON%\*.zip 2^>NUL') do (
		rem <nul set /p =%%f >> "%TEMPFILE%"
		call :AddToManifest %%f
	)
)

if not "%ODI_SDK%" == "" (
	rem TODO: check if this dir actually exists.
	echo %IM% adding files from OracleDI SDK directory ^<%ODI_SDK%^> to class path
	for /f %%f in ('dir /b /s %ODI_SDK%\*.jar 2^>NUL') do (
		rem <nul set /p =%%f >> "%TEMPFILE%"
		call :AddToManifest %%f
	)
	
	for /f %%f in ('dir /b /s %ODI_SDK%\*.zip 2^>NUL') do (
		rem <nul set /p =%%f >> "%TEMPFILE%"
		call :AddToManifest %%f
	)
)

rem
rem Ensure the Class-Path entry ends with a new line character (LF or CR).
rem
echo.>>"%TEMPFILE%"

rem
rem Make the JAR file.
rem
"%ODI_JAVA_HOME%\bin\jar.exe" cfm "%OUTJARFILE%" "%TEMPFILE%" 
if ERRORLEVEL 1 (
	echo %EM% creating JAR file ^<%OUTJARFILE%^> from manifest file ^<%TEMPFILE%^>
	goto ExitFail
) else (
	echo %IM% successfully created JAR file ^<%OUTJARFILE%^> from manifest file ^<%TEMPFILE%^>
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1

REM ===============================================
REM S U B R O U T I N E S
REM ===============================================

REM ===============================================
:AddToManifest
REM ===============================================
echo %IM% adding file ^<%1^>
set FILESTRING= file:///%1
rem Note: the space after the file name is required in the manifest file.
echo %FILESTRING:\=/% >> "%TEMPFILE%"