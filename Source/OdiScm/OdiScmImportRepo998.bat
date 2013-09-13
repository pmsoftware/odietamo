@echo off

set PROC=OdiScmImportRepo998
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:

if not "%TEMP%" == "" (
	set TEMPDIR=%TEMP%
) else (
	if not "%TMP%" == "" (
		set TEMPDIR=%TMP%
	) else (
		set TEMPDIR=%CD%
	)
)
	
copy OdiScm_Master_Work_Repo_ID_998.zip "%TEMPDIR%\OdiScm_Master_Work_Repo_ID_998.zip" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying file repository archive file to temporary directory ^<%TEMPDIR%^> 1>&2
	goto ExitFail
)

unzip "%TEMPDIR%\OdiScm_Master_Work_Repo_ID_998.zip"
if ERRORLEVEL 1 (
	echo %EM% unziping file ^<%TEMPDIR%\OdiScm_Master_Work_Repo_ID_998.zip^> 1>&2
	goto ExitFail
)

imp odirepo998/odirepo998@localhost:1521/xe file=OdiScm_Master_Work_Repo_ID_998.dmp full=y
if ERRORLEVEL 1 (
	echo %EM% importing repository objects 1>&2
	goto ExitFail
)

del "%TEMPDIR%\OdiScm_Master_Work_Repo_ID_998.zip" >NUL
if ERRORLEVEL 1 (
	echo %EM% deleting temporary repository export file ^<%TEMPDIR%\OdiScm_Master_Work_Repo_ID_998.dmp^> 1>&2
	goto ExitFail
)

echo %IM% import process completed sucessfully
exit /b 0

:ExitFail
exit /b 1
