if "%TEMP%" == "" (
	if "%TMP%" == "" (
		set TEMPDIR=%CD%
	) else (
		set TEMPDIR=%TMP%
	)
) else (
	set TEMPDIR=%TEMP%
)

set TEMPDIR=%TEMPDIR%\%RANDOM%

if EXIST "%TEMPDIR" (
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