@echo off

set PROC=OdiScmExportRepo998
set EM=%PROC%: INFO:
set EM=%PROC%: ERROR:

del OdiScm_Master_Work_Repo_ID_998.dmp >NUL 2>&1

exp odirepo998/odirepo998@localhost:1521/xe owner=odirepo998 file=OdiScm_Master_Work_Repo_ID_998.dmp statistics=none
echo %errorlevel%
if ERRORLEVEL 1 (
	echo %EM% exporting repository objects
	goto ExitFail
)

del OdiScm_Master_Work_Repo_ID_998.zip
if ERRORLEVEL 1 (
	echo %EM% deleting existing ZIP file
	goto ExitFail
)

zip OdiScm_Master_Work_Repo_ID_998.zip OdiScm_Master_Work_Repo_ID_998.dmp
if ERRORLEVEL 1 (
	echo %EM% creating new ZIP file
	goto ExitFail
)

del OdiScm_Master_Work_Repo_ID_998.dmp
if ERRORLEVEL 1 (
	echo %EM% deleting DMP file
	goto ExitFail
)

echo %IM% export process completed sucessfully
exit /b 0

:ExitFail
exit /b 1
