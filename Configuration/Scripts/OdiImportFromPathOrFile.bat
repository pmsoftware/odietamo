@echo off
rem
rem Enable variables to be expanded as, not before, commands are executed.
rem
setlocal enabledelayedexpansion

if "%1" == "" goto ParamCodeMissing
if "%2" == "" goto ParamOdiBinMissing
goto ParamOk

:ParamCodeMissing
echo ERROR: no argument for code directory root parameter supplied
goto ShowUsage

:ParamOdiBinMissing
echo ERROR: no argument for ODI bin directory parameter supplied
goto ShowUsage

:ShowUsage
echo ERROR: usage: OdiImportFromPathOrFile.bat ^<ODI source code root directory^> ^<ODI bin directory^> [ODI source code object list file]
goto ExitFail

:ParamOk
set IMPORT_DIR=%1
set ODI_BIN_DIR=%2

if "%3" == "" goto NoObjFilePassed

rem
rem We've been passed a file of objects to import.
rem This can be used to manually restart the import operation.
rem
echo INFO: object override list file passed. Using file "%3"
if EXIST "%3" goto PassedObjFileExists

echo ERROR: object list file "%3" does not exist
goto ExitFail

set OBJLISTFILE=%3%
goto StartImport

:NoObjFilePassed
rem
rem Generate the list of files to import.
rem
echo INFO: no object override list file passed. Looking for files at "%1"
set OBJLISTDIR=C:\MOI\Logs
mkdir %OBJLISTDIR% >NUL 2>&1
call :SetDateTimeStrings
set OBJLISTFILE=%OBJLISTDIR%\OdiImportFromPathOrFile_FilesToImport_%YYYYMMDD%_%HHMMSS%.txt

rem
rem Master Repository objects first.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpTechno >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpConnect >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpPschema >>%OBJLISTFILE% 2>NUL
rem
rem SnpContext before SnpLschema because the SnpLschema files, not the
rem SnpConext files contain the SnpContext/SnpLschema/SnpPschema mappings
rem in our solution.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpContext >>%OBJLISTFILE% 2>NUL
rem
rem SnpContext before SnpLschema because the SnpLschema files, not the
rem SnpConext files contain the SnpContext/SnpLschema/SnpPschema mappings
rem in our solution.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpLschema >>%OBJLISTFILE% 2>NUL
rem
rem Work Repository objects last.
rem
rem
rem Marker Groups can be global (used by model objects) or project specific
rem (used by project objects) so we need to do SnpProject objects (Projects)
rem first then the Marker Groups.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpProject >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpGrpState >>%OBJLISTFILE% 2>NUL
rem
rem We import all SnpTrt objects (Procedure/Knowledge Modules) here because
rem Models can rem use Knowledge Modules. As we're importing all of the SnpTrt
rem objects so we need to import the SnpProject (for Procedures and Knowledge Modules)
rem and SnpFolder objects (for Procedures) first. We also import the SnpVar (Variables)
rem at this point as they could be used in Knowledge Modules (even though they're loosely
rem coupled. I.e. there's not foreign key relationship in the repository data model).
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpFolder >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpVar >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.Ufunc >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpTrt >>%OBJLISTFILE% 2>NUL
rem
rem Now the models.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpModFolder >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpModel >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpSubModel >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpTable >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpJoin >>%OBJLISTFILE% 2>NUL
rem
rem The the rest of the project contents.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpSequence >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpPop >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpPackage >>%OBJLISTFILE% 2>NUL
rem
rem Finally Object/Marker relationships.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpObjState >>%OBJLISTFILE% 2>NUL

:StartImport
set ERROROCCURED=N

echo gonna process the files

for /f %%A in (%OBJLISTFILE%) do (
	
	for %%B in (%%A) do (
		set IMPORTFILENOPATH=%%~nxB
		set IMPORTFILEPATH=%%~dpB
	)
	
	set IMPORTFILENAME=
	set IMPORTFILEEXT=
	set IMPORTFILENAME2=
	set IMPORTFILEEXT2=
	
	for /f "tokens=1,2,3,4 delims=." %%C in ('echo !IMPORTFILENOPATH!') do (
		set IMPORTFILENAME=%%C
		set IMPORTFILEEXT=%%D
		set IMPORTFILENAME2=%%E
		set IMPORTFILEEXT2=%%F
	)
	REM echo IMPORTFILENAME=!IMPORTFILENAME!
	REM echo IMPORTFILEEXT=!IMPORTFILEEXT!
	REM echo IMPORTFILENAME2=!IMPORTFILENAME2!
	REM echo IMPORTFILEEXT2=!IMPORTFILEEXT2!
	
	REM if "!IMPORTFILEEXT2!"=="" (
	REM		echo IMPORTFILEEXT2 is empty string
	REM ) else (
	REM		echo IMPORTFILEEXT2 is NOT empty string
	REM )
	
	if "!IMPORTFILEEXT2!"=="" (
		echo INFO: importing file "!IMPORTFILENAME!.!IMPORTFILEEXT!" from path "!IMPORTFILEPATH!"
	) else (
		echo INFO: importing file "!IMPORTFILENAME!.!IMPORTFILEEXT!.!IMPORTFILENAME2!.!IMPORTFILEEXT2!" from path "!IMPORTFILEPATH!"
	)
	
	set CONTAINEROBJTYPE=FALSE
	for %%G in (SnpConnect SnpModFolder SnpModel SnpSubModel SnpProject SnpFolder) do (
		if "!IMPORTFILEEXT2!"=="" (
			if !IMPORTFILEEXT!==%%G set CONTAINEROBJTYPE=TRUE
		) else (
			if !IMPORTFILEEXT2!==%%G set CONTAINEROBJTYPE=TRUE
		)
	)
	
	if !CONTAINEROBJTYPE!==TRUE (
		echo INFO: object type is a container
		if "!IMPORTFILEEXT2!"=="" (
			call :ImportContainerObject !IMPORTFILEPATH!!IMPORTFILENAME!.!IMPORTFILEEXT!
		) else (
			call :ImportContainerObject !IMPORTFILEPATH!!IMPORTFILENAME!.!IMPORTFILEEXT!.!IMPORTFILENAME2!.!IMPORTFILEEXT2!
		)
	) else (
		echo INFO: object type is not a container
		if "!IMPORTFILEEXT2!"=="" (
			call :ImportObject !IMPORTFILEPATH!!IMPORTFILENAME!.!IMPORTFILEEXT!
		) else (
			call :ImportObject !IMPORTFILEPATH!!IMPORTFILENAME!.!IMPORTFILEEXT!.!IMPORTFILENAME2!.!IMPORTFILEEXT2!
		)
	)
	if !ERROROCCURED!==Y (
		rem
		rem Abort the script immediately.
		rem
		exit /b 1
	)
)

echo INFO: successfully completed import of Work Repository objects
echo INFO: successfully completed import process
exit /b 0

:ExitFail
echo ERROR: import process failed
exit /b 1

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************

rem *************************************************************
:SetDateTimeStrings
rem *************************************************************
rem
rem Define unique file name suffixes.
rem
for /f "tokens=1,2,3 delims=/ " %%A in ('date /t') do ( 
	set Day=%%A
	set Month=%%B
	set Year=%%C
	set YYYYMMDD=%%C%%B%%A
)

for /f "tokens=1,2,3 delims=:" %%A in ('echo %TIME%') do ( 
	set Hour=%%A
	set Minute=%%B
	set Second=%%C
)

for /f "tokens=1,2 delims=." %%A in ('echo %Second%') do ( 
	set Second=%%A
	set SubSecond=%%B
)
set HHMM=%Hour%%Minute%
set HHMMSS=%Hour%%Minute%%Second%
exit /b 0
rem *************************************************************
:ImportObject
rem *************************************************************
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
rem *************************************************************
:ImportContainerObject
rem *************************************************************
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