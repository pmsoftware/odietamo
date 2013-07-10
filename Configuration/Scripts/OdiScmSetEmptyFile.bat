rem
rem Define a temporary empty file.
rem
if "%TEMPDIR%" == "" (
	echo %EM% environment variable TEMPDIR is not set
	exit /b 1
)

set EMPTYFILE=%TEMPDIR%\%RANDOM%_EmptyFile.txt
type NUL >%EMPTYFILE% 2>NUL
if ERRORLEVEL 1 (
	echo %EM% cannot create empty file ^<%EMPTYFILE%^>
	exit /b 1
)
