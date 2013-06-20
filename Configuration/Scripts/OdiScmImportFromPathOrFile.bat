@echo off
set FN=OdiScmImportFromPathOrFile
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

rem
rem Enable variables to be expanded as, not before, commands are executed.
rem
setlocal enabledelayedexpansion

if "%1" == "" goto ParamCodeMissing
if "%ODI_HOME%" == "" goto OdiHomeMissing
goto ParamOk

:ParamCodeMissing
echo %EM% no argument for code directory root parameter supplied
goto ShowUsage

:OdiHomeMissing
echo %EM% environment variable ODI_HOME is not set
goto ShowUsage

:ShowUsage
echo %EM% usage: OdiScmImportFromPathOrFile.bat ^<ODI source code root directory^> [ODI source code object list file]
goto ExitFail

:ParamOk
set IMPORT_DIR=%1
rem set ODI_BIN_DIR=%ODI_HOME%\bin

if "%2" == "" goto NoObjFilePassed

rem
rem We've been passed a file of objects to import.
rem This can be used to manually restart the import operation.
rem
echo %IM% object override list file passed. Using file ^<%3^>
if EXIST "%2" goto PassedObjFileExists

echo %EM% object list file "%2" does not exist
goto ExitFail

set OBJLISTFILE=%2%
goto StartImport

:NoObjFilePassed

rem
rem Define a temporary working directory.
rem
if "%TEMP%" == "" goto NoTempDir
set TEMPDIR=%TEMP%
goto GotTempDir

:NoTempDir
if "%TMP%" == "" goto NoTmpDir
set TEMPDIR=%TMP%
goto GotTempDir

:NoTmpDir
set TEMPDIR=%CD%

:GotTempDir
call :SetDateTimeStrings

rem
rem Generate a startcmd.bat script file using the current environment settings.
rem
set STARTCMDFILE=%TEMPDIR%\OdiImportFromPathOrFile_StartCmd_%YYYYMMDD%_%HHMMSS%.bat
echo %IM% generating startcmd.bat file ^<%STARTCMDFILE%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat" %TEMPDIR%\OdiImportFromPathOrFile_StartCmd_%YYYYMMDD%_%HHMMSS%.bat
if ERRORLEVEL 1 (
	echo %EM% generating StartCmd batch script file ^<%STARTCMDFILE%^>
	goto ExitFail
)

rem
rem Generate the list of files to import.
rem
echo %IM% no object override list file passed. Looking for files at ^<%1^>
set OBJLISTFILE=%TEMPDIR%\OdiImportFromPathOrFile_FilesToImport_%YYYYMMDD%_%HHMMSS%.txt

rem
rem Master Repository objects first.
rem
dir /s /b /o:n %IMPORT_DIR%\*.SnpTechno >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpConnect >>%OBJLISTFILE% 2>NUL
dir /s /b /o:n %IMPORT_DIR%\*.SnpPschema >>%OBJLISTFILE% 2>NUL
rem
rem SnpContext before SnpLschema because the SnpLschema files, not the
rem SnpContext files contain the SnpContext/SnpLschema/SnpPschema mappings
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
		echo %IM% importing file ^<!IMPORTFILENAME!.!IMPORTFILEEXT!^> from path ^<!IMPORTFILEPATH!^>
	) else (
		echo %IM% importing file ^<!IMPORTFILENAME!.!IMPORTFILEEXT!.!IMPORTFILENAME2!.!IMPORTFILEEXT2!^> from path ^<!IMPORTFILEPATH!^>
	)
	
	set CONTAINEROBJTYPE=FALSE
	for %%G in (SnpConnect SnpLschema SnpModFolder SnpModel SnpSubModel SnpProject SnpFolder) do (
		if "!IMPORTFILEEXT2!"=="" (
			if !IMPORTFILEEXT!==%%G set CONTAINEROBJTYPE=TRUE
		) else (
			if !IMPORTFILEEXT2!==%%G set CONTAINEROBJTYPE=TRUE
		)
	)
	
	if !CONTAINEROBJTYPE!==TRUE (
		echo %IM% object type is a container
		if "!IMPORTFILEEXT2!"=="" (
			call :ImportContainerObject !IMPORTFILEPATH!!IMPORTFILENAME!.!IMPORTFILEEXT!
		) else (
			call :ImportContainerObject !IMPORTFILEPATH!!IMPORTFILENAME!.!IMPORTFILEEXT!.!IMPORTFILENAME2!.!IMPORTFILEEXT2!
		)
	) else (
		echo %IM% object type is not a container
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

echo %IM% successfully completed import of Work Repository objects
echo %IM% successfully completed import process
exit /b 0

:ExitFail
echo %EM% import process failed
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
echo %IM% importing non-container type object from file ^<%1^>
echo %IM% date ^<%DATE%^> time ^<%TIME%^>
rem cd /d %ODI_BIN_DIR%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%STARTCMDFILE%" OdiImportObject -FILE_NAME=%1 -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 goto IOFail
goto :eof
:IOFail
echo ImportObject: %EM% cannot import file ^<%1^>
set ERROROCCURED=Y
exit /b 1
rem *************************************************************
:ImportContainerObject
rem *************************************************************
echo %IM% importing container type object from file ^<%1^>
echo %IM% date ^<%DATE%^> time ^<%TIME%^>
rem cd /d %ODI_BIN_DIR%
rem
rem We try update first so that if there's nothing to update the operation is fairly quick.
rem
echo %IM% trying SYNONYNM_UPDATE import mode
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%STARTCMDFILE%" OdiImportObject -FILE_NAME=%1 -IMPORT_MODE=SYNONYM_UPDATE
if ERRORLEVEL 1 goto ICOFail
rem
rem The insert should do nothing and return exit status of 0 if the object already exists.
rem
echo %IM% trying SYNONYM_INSERT import mode
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%STARTCMDFILE%" OdiImportObject -FILE_NAME=%1 -IMPORT_MODE=SYNONYM_INSERT
if ERRORLEVEL 1 goto ICOFail
goto :eof
:ICOFail
echo ImportContainerObject: %EM% cannot import file ^<%1^>
set ERROROCCURED=Y
exit /b 1