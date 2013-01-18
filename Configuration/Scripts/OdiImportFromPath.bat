@echo off

if "%1" == "" goto ParamCodeMissing
if "%2" == "" goto ParamOdiBinMissing
goto ParamOk

:ParamCodeMissing
echo ERROR: no argument for code directory root parameter supplied
exit /b 1

:ParamOdiBinMissing
echo ERROR: no argument for ODI bin directory parameter supplied
exit /b 2

:ParamOk
rem TODO run multiple dir commands and output one file per object type
rem TODO and run the import from these files.
rem TODO introduce a restart flag parameter to allow the script to be
rem TODO restarted from the existing set of files instead of running
rem TODO the dir commands.
set OBJLISTFILENAMEPREFIX=C:\odi_import_files.
set OBJLISTFILENAMEEXT=.txt
set IMPORT_DIR=%1
set ODI_BIN_DIR=%2

set ERROROCCURED=N

rem
rem Master Repository objects first.
rem
echo INFO: importing Technology (*.SnpTechno) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpTechno') do (
	call :ImportObject %%g
)

if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Data Server (*.SnpConnect) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpConnect') do (
	call :ImportContainerObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Physical Schema (*.SnpPschema) objects
for /f %%g in ('dir /s /b /o:n  %IMPORT_DIR%\*.SnpPschema') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

rem
rem SnpContext before SnpLschema because the SnpLschema files, not the
rem SnpConext files contain the SnpContext/SnpLschema/SnpPschema mappings
rem in our solution.
rem
echo INFO: importing Context (*.SnpContext) objects
for /f %%g in ('dir /s /b /o:n  %IMPORT_DIR%\*.SnpContext') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

rem
rem SnpContext before SnpLschema because the SnpLschema files, not the
rem SnpConext files contain the SnpContext/SnpLschema/SnpPschema mappings
rem in our solution.
rem
echo INFO: importing Logical Schema (*.SnpLschema) objects
for /f %%g in ('dir /s /b /o:n  %IMPORT_DIR%\*.SnpLschema') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: successfully completed import of Master Repository objects
echo INFO: starting import of Work Repository objects

rem
rem Marker Groups can be global (used by model objects) or project specific
rem (used by project objects) so we need to do SnpProject objects (Projects)
rem first then the Marker Groups.
rem
echo INFO: importing Project (*.SnpProject) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpProject') do (
	call :ImportContainerObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Project (*.SnpGrpState) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpGrpState') do (
	call :ImportContainerObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

rem
rem We import all SnpTrt objects (Procedure/Knowledge Modules) here because
rem Models can rem use Knowledge Modules. As we're importing all of the SnpTrt
rem objects so we need to import the SnpProject (for Procedures and Knowledge Modules)
rem and SnpFolder objects (for Procedures) first. We also import the SnpVar (Variables)
rem at this point as they could be used in Knowledge Modules (even though they're loosely
rem coupled. I.e. there's not foreign key relationship in the repository data model).
rem
echo INFO: importing Folder (*.SnpFolder) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpFolder') do (
	call :ImportContainerObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Variable (*.SnpVar) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpVar') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Procedure/Knowledge Module (*.SnpTrt) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpTrt') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Model Folder (*.SnpModFolder) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpModFolder') do (
	call :ImportContainerObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Model (*.SnpModel) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpModel') do (
	call :ImportContainerObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Sub Model (*.SnpSubModel) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpSubModel') do (
	call :ImportContainerObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Data Store (*.SnpTable) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpTable') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Data Store Relationship (*.SnpJoin) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpJoin') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Sequence (*.SnpSequence) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpSequence') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing User Function (*.SnpUfunc) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.Ufunc') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Interface (*.SnpPop) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpPop') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing Package (*.SnpPackage) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpPackage') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: importing object/Marker relationship (*.SnpObjState) objects
for /f %%g in ('dir /s /b /o:n %IMPORT_DIR%\*.SnpObjState') do (
	call :ImportObject %%g
)
if "%ERROROCCURED%" == "Y" goto ExitFail

echo INFO: successfully completed import of Work Repository objects
echo INFO: successfully completed import process
exit /b 0

:ExitFail
echo ERROR: import process failed
exit /b 1

rem ===========================================================================================================
:ImportObject
rem ===========================================================================================================
echo INFO: importing non-container type object from file "%1"
echo INFO: datetime is %DATE% %TIME%
cd /d %ODI_BIN_DIR%
call startcmd.bat OdiImportObject -FILE_NAME=%1 -IMPORT_MODE=SYNONYM_INSERT_UPDATE -WORK_REP_NAME=WORKREP
if ERRORLEVEL 1 goto IOFail
goto :eof
:IOFail
echo ImportObject: ERROR: cannot import file "%1"
set ERROROCCURED=Y
exit /b 1
rem ===========================================================================================================
:ImportContainerObject
rem ===========================================================================================================
echo INFO: importing container type object from file "%1"
echo INFO: datetime is %DATE% %TIME%
cd /d %ODI_BIN_DIR%
rem
rem We try update first so that if there's nothing to update the operation is fairly quick.
rem
echo INFO: trying SYNONYNM_UPDATE import mode
call startcmd.bat OdiImportObject -FILE_NAME=%1 -IMPORT_MODE=SYNONYM_UPDATE
if ERRORLEVEL 1 goto ICOFail
rem
rem The insert should do nothing and return exit status of 0 if the object already exists.
rem
echo INFO: trying SYNONYM_INSERT import mode
call startcmd.bat OdiImportObject -FILE_NAME=%1 -IMPORT_MODE=SYNONYM_INSERT
if ERRORLEVEL 1 goto ICOFail
goto :eof
:ICOFail
echo ImportContainerObject: ERROR: cannot import file "%1"
set ERROROCCURED=Y
exit /b 1
rem ===========================================================================================================