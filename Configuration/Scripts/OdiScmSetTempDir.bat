rem if not "%TEMPDIR%" == "" (
rem 	exit /b 0
rem )

if "%TEMP%" == "" (
	if "%TMP%" == "" (
		set TEMPDIR=%CD%
	) else (
		set TEMPDIR=%TMP%
	)
) else (
	set TEMPDIR=%TEMP%
)

set TEMPDIR=%TEMPDIR%\OdiScm

if /i "%1" == "/t" (
	rem
	rem We were requested to just report the parent temp directory in TEMPDIR.
	rem
	exit /b 0
)

set PYYYYMMDD=%YYYYMMDD%
set PHHMMSSFF=%HHMMSSFF%

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"
if ERRORLEVEL 1 (
	echo %EM% setting date and time strings
	exit /b 1
)

set TEMPDIR=%TEMPDIR%\OdiScm_%YYYYMMDD%_%HHMMSSFF%

if EXIST "%TEMPDIR%" (
	rd /s /q "%TEMPDIR%" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% deleting existing temporary directory ^<%TEMPDIR%^>
		exit /b 1
	)
)

md "%TEMPDIR%"
if ERRORLEVEL 1 (
	echo %EM% deleting existing temporary directory ^<%TEMPDIR%^>
	exit /b 1
)

set YYYYMMDD=%PYYYYMMDD%
set HHMMSSFF=%PHHMMSSFF%