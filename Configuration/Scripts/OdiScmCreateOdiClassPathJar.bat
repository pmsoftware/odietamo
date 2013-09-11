@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
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
	echo %EM% output JAR file path/name not specified 1>&2
	echo %EM% usage: %PROC% ^<output JAR file^> 1>&2
	goto ExitFail
)

set OUTJARFILE=%ARGV1%

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

rem
rem Create a manifest file with the paths and names of all the JARs we need.
rem
set TEMPFILE=%TEMPDIR%\%PROC%_Maniftest.txt
<nul set /p =Class-Path:> "%TEMPFILE%"

rem TODO: get jars from this var and add separately.
if not "%ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH%" == "" (
	echo %IM% using additional class path from environment variable ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH
	set JISQL_CLASS_PATH=%ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH%
) else (
	echo %IM% no additional class path specified in environment variable ODI_SCM_TOOLS_JISQL_ADDITIONAL_CLASSPATH
)

if EXIST "%ODI_SCM_ORACLEDI_HOME%\drivers" (
	echo %IM% adding files from OracleDI drivers directory ^<%ODI_SCM_ORACLEDI_HOME%\drivers^> to class path
	for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_HOME%\drivers\*.jar 2^>NUL') do (
		rem <nul set /p =%%f >> "%TEMPFILE%"
		call :AddToManifest %%f
	)
	for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_HOME%\drivers\*.zip 2^>NUL') do (
		rem <nul set /p =%%f >> "%TEMPFILE%"
		call :AddToManifest %%f
	)
) else (
	echo %EM% OracleDI drivers directory ^<%ODI_SCM_ORACLEDI_HOME%\drivers^> not found 1>&2
	goto ExitFail
)

if not "%ODI_SCM_ORACLEDI_COMMON%" == "" (
	if EXIST "%ODI_SCM_ORACLEDI_COMMON%" (
		echo %IM% adding OracleDI common directory ^<%ODI_SCM_ORACLEDI_COMMON%^> to class path
		call :AddToManifest %ODI_SCM_ORACLEDI_COMMON%\odi\
		echo %IM% adding files from OracleDI common directory ^<%ODI_SCM_ORACLEDI_COMMON%^> to class path
		for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_COMMON%\*.jar 2^>NUL') do (
			rem <nul set /p =%%f >> "%TEMPFILE%"
			call :AddToManifest %%f
		)
		for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_COMMON%\*.zip 2^>NUL') do (
			rem <nul set /p =%%f >> "%TEMPFILE%"
			call :AddToManifest %%f
		)
	) else (
		echo %EM% OracleDI common directory ^<%ODI_SCM_ORACLEDI_COMMON%^> not found 1>&2
		goto ExitFail
	)
)

if not "%ODI_SCM_ORACLEDI_SDK%" == "" (
	if EXIST "%ODI_SCM_ORACLEDI_SDK%" (
		echo %IM% adding OracleDI SDK directory ^<%ODI_SCM_ORACLEDI_SDK%^> to class path
		call :AddToManifest %ODI_SCM_ORACLEDI_SDK%\lib\
		echo %IM% adding files from OracleDI SDK directory ^<%ODI_SCM_ORACLEDI_SDK%^> to class path
		for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_SDK%\*.jar 2^>NUL') do (
			rem <nul set /p =%%f >> "%TEMPFILE%"
			call :AddToManifest %%f
		)		
		for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_SDK%\*.zip 2^>NUL') do (
			rem <nul set /p =%%f >> "%TEMPFILE%"
			call :AddToManifest %%f
		)
	) else (
		echo %EM% OracleDI SDK directory ^<%ODI_SCM_ORACLEDI_SDK%^> not found 1>&2
		goto ExitFail
	)
)

if not "%ODI_SCM_ORACLEDI_ORACLE_HOME%" == "" (
	if EXIST "%ODI_SCM_ORACLEDI_ORACLE_HOME%" (
		echo %IM% adding files from OracleDI Oracle Home directory ^<%ODI_SCM_ORACLEDI_ORACLE_HOME%^> to class path
		for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_ORACLE_HOME%\*.jar 2^>NUL') do (
			rem <nul set /p =%%f >> "%TEMPFILE%"
			call :AddToManifest %%f
		)
		for /f %%f in ('dir /b /s %ODI_SCM_ORACLEDI_ORACLE_HOME%\*.zip 2^>NUL') do (
			rem <nul set /p =%%f >> "%TEMPFILE%"
			call :AddToManifest %%f
		)
	) else (
		echo %EM% OracleDI Oracle Home directory ^<%ODI_SCM_ORACLEDI_ORACLE_HOME%^> not found 1>&2
		goto ExitFail
	)
)

rem
rem Ensure the Class-Path entry ends with a new line character (LF or CR).
rem
echo.>>"%TEMPFILE%"

rem
rem Ensure the JDK is available.
rem
if not EXIST "%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\jar.exe" (
	echo %EM% Java JDK ^<jar.exe^> command not found in JDK bin directory ^<%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\jar.exe^> 1>&2
	goto ExitFail
)

rem
rem Make the JAR file.
rem
"%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\jar.exe" cfm "%OUTJARFILE%" "%TEMPFILE%" 
if ERRORLEVEL 1 (
	echo %EM% creating JAR file ^<%OUTJARFILE%^> 1>&2
	echo %EM% from manifest file ^<%TEMPFILE%^> 1>&2
	goto ExitFail
) else (
	echo %IM% successfully created JAR file ^<%OUTJARFILE%^>
	echo %IM% from manifest file ^<%TEMPFILE%^>
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
echo %IM% adding entry ^<%1^>
set FILESTRING= file:///%1
rem Note: the space after the file name is required in the manifest file.
echo %FILESTRING:\=/% >> "%TEMPFILE%"