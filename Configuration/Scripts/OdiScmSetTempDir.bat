rem if not "%TEMPDIR%" == "" (
rem 	exit /b 0
rem )

if "%ODI_SCM_MISC_TEMP_ROOT%" == "" (
	if "%TEMP%" == "" (
		if "%TMP%" == "" (
			set TEMPDIR=%CD%
		) else (
			set TEMPDIR=%TMP%
		)
	) else (
		set TEMPDIR=%TEMP%
	)
) else (
	set TEMPDIR=%ODI_SCM_MISC_TEMP_ROOT%
)

set TEMPDIR=%TEMPDIR%\OdiScm

if /i "%1" == "/t" (
	rem
	rem We were requested to just report the parent temp directory in TEMPDIR.
	rem
	goto ExitOk
)

set PYYYYMMDD=%YYYYMMDD%
set PHHMMSSFF=%HHMMSSFF%

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetDateTimeStrings.bat"
if ERRORLEVEL 1 (
	echo %EM% setting date and time strings 1>&2
	goto ExitFail
)

set TEMPDIR=%TEMPDIR%\%YYYYMMDD%_%HHMMSSFF%

for /f "tokens=1" %%g in ('set ^| md5sum') do (
	set MD5HASH=%%g
)

set TEMPDIR=%TEMPDIR%_%MD5HASH%

:CheckDirExists
if EXIST "%TEMPDIR%" (
	echo %WM% temporary directory ^<%TEMPDIR%^> already exists
	set TEMPDIR=%TEMPDIR%_
	rem rd /s /q "%TEMPDIR%" >NUL 2>NUL
	rem if ERRORLEVEL 1 (
	rem	echo %EM% deleting existing temporary directory ^<%TEMPDIR%^> 1>&2
	rem	exit /b 1
	rem )
	set CHECKTEMPDIR=YES
) else (
	set CHECKTEMPDIR=NO
)

if "%CHECKTEMPDIR%" == "YES" (
	echo %IM% using alternate path ^<%TEMPDIR%^>
	goto CheckDirExists
)

md "%TEMPDIR%"
if ERRORLEVEL 1 (
	echo %EM% creating temporary directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

if not EXIST "%TEMPDIR%" (
	echo %EM% verifying creation of temporary directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

set YYYYMMDD=%PYYYYMMDD%
set HHMMSSFF=%PHHMMSSFF%

:ExitOk
exit /b 0

:ExitFail
exit /b 1