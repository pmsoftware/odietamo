@echo off
rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

set PRIMEMETADATA=FALSE

if "%ARGV1%" == "" goto ArgsOk

if "%ARGV1%" == "NoExportPrime" (
	set PRIMEMETADATA=FALSE
	goto ArgsOk
)

if "%ARGV1%" == "ExportPrimeFirst" (
	set PRIMEMETADATA=FIRST
	goto ArgsOk
)

if "%ARGV1%" == "ExportPrimeLast" (
	set PRIMEMETADATA=LAST
	goto ArgsOk
)

echo %EM% invalid argument ^<%ARGV1%^>
echo %IM% usage %PROC% ^[NoExportPrime ^| ExportPrimeFirst ^| ExportPrimeLast^]
goto ExitFail

:ArgsOk

if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI
	goto ExitFail
) else (
	echo %IM% using source configuration INI file ^<%ODI_SCM_INI%^> 
)

REM
REM Set the environment from the configuration INI file.
REM
set PIsBatchExit=%IsBatchExit%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmEnvSet.bat"
set EXITSTATUS=%ERRORLEVEL%
set IsBatchExit=%PIsBatchExit%
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
if not "%EXITSTATUS%" == "0" (
	echo %EM% setting environment from configuration INI file
	goto ExitFail
)

set ODI_SCM_ODI_SCM_ORACLEDI_VERSION_MAJOR=%ODI_SCM_ORACLEDI_VERSION:~0,3%
if not "%ODI_SCM_ODI_SCM_ORACLEDI_VERSION_MAJOR%" == "10." (
	if not "%ODI_SCM_ODI_SCM_ORACLEDI_VERSION_MAJOR%" == "11." (
		echo %EM% invalid ODI version ^<%ODI_SCM_ORACLEDI_VERSION%^> specified in environment variable ODI_SCM_ORACLEDI_VERSION 1>&2
		goto ExitFail
	)
)

if not EXIST "%ODI_SCM_HOME%\Source\OdiScm" (
	echo %EM% OdiScm repository components not found in directory ^<%ODI_SCM_HOME%\Source\ODI^>
	goto ExitFail
)

if not EXIST "%ODI_SCM_ORACLEDI_HOME%\bin\startcmd.bat" (
	echo %EM% bin\startcmd.bat script not found in ODI_SCM_ORACLEDI_HOME directory ^<%ODI_SCM_ORACLEDI_HOME%\bin^>
	goto ExitFail
)

rem
rem Define a temporary work directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory ^<%TEMPDIR%^>
	goto ExitFail
)

rem
rem Define a temporary empty file.
rem
set EMPTYFILE=%TEMPDIR%\%RANDOM%_EmptyFile.txt
type NUL >%EMPTYFILE% 2>NUL
if ERRORLEVEL 1 (
	echo %EM% cannot create empty file ^<%EMPTYFILE%^>
	goto ExitFail
)

rem
rem Create a StartCmd.bat script for the current environment.
rem
set TEMPSTARTCMD=%TEMPDIR%\%RANDOM%_OdiScmImportOdiScm_StartCmd.bat
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat^" /p %TEMPSTARTCMD%
if ERRORLEVEL 1 (
	echo %EM% creating StartCmd wrapper script
	goto ExitFail
)

rem
rem Create a version of the ODI-SCM infrastructure setup script for this repository.
rem
set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmImportOdiScm_CreateInfrastructure.sql
cat "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateInfrastructureTemplate.sql" | sed s/"<OdiWorkRepoUserName>"/%ODI_SCM_ORACLEDI_SECU_USER%/ > "%TEMPFILE%"
if ERRORLEVEL 1 goto ScriptGenFail

cat "%TEMPFILE%" | sed s/"<OdiWorkRepoPassWord>"/%ODI_SCM_ORACLEDI_SECU_PASS%/ > "%TEMPFILE%2"
if ERRORLEVEL 1 goto ScriptGenFail

set CONNSTR=%ODI_SCM_ORACLEDI_SECU_URL_HOST%:%ODI_SCM_ORACLEDI_SECU_URL_PORT%\/%ODI_SCM_ORACLEDI_SECU_URL_SID%
cat "%TEMPFILE%2" | sed s/"<OdiWorkRepoConnectionString>"/%CONNSTR%/ > "%TEMPFILE%3"
if ERRORLEVEL 1 goto ScriptGenFail

goto ScriptGenOk

:ScriptGenFail
echo %EM% creating ODI-SCM repository infrastructure set up script
goto ExitFail

:ScriptGenOk
rem
rem Define files used to capture standard output and standard error channels.
rem
set TEMPFILESTR=%RANDOM%
set STDOUTFILE=%TEMPDIR%\%TEMPFILESTR%_OdiScmImportOdiScm_StdOut.log
set STDERRFILE=%TEMPDIR%\%TEMPFILESTR%_OdiScmImportOdiScm_StdErr.log

rem
rem Run the generated ODI-SCM repository infrastructure set up script.
rem
echo %IM% creating ODI-SCM repository objects
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat^" /p %TEMPFILE%3 %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 goto CreateInfrastructureFail

goto CreateInfrastructureChkStdErr

:CreateInfrastructureFail
echo %EM% Batch file OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL
echo %IM% StdErr content:
type %STDERRFILE%
goto ExitFail

:CreateInfrastructureChkStdErr
rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem 
echo %IM% Batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if not ERRORLEVEL 1 goto CreateInfrastructureOk

echo %IM% Batch file OdiScmJisqlRepo.bat returned StdErr content:
type %STDERRFILE%

goto ExitFail

:CreateInfrastructureOk

echo %IM% completed creation of ODI-SCM infrastructure repository objects

rem
rem Configure the ODI-SCM repository metadata.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetRepoConfig.bat^" /p
if ERRORLEVEL 1 (
	echo %EM% configurating ODI-SCM repository metadata
	goto ExitFail
)

if %PRIMEMETADATA% == FIRST (
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmPrimeRepoFlush.bat^" /p both
	if ERRORLEVEL 1 (
		echo %EM% priming ODI-SCM export metadata before ODI-SCM import
		goto ExitFail
	)
)

rem
rem Copy the ODI-SCM repository components import files and modify the connection details in the copy before we import them.
rem
set TEMPOBJSDIR=%TEMPDIR%\%RANDOM%_OdiScmImportOdiScm
md "%TEMPOBJSDIR%"
if ERRORLEVEL 1 (
	echo %EM% creating temporary work directory ^<%TEMPOBJSDIR%^>
	goto ExitFail
)

xcopy /e "%ODI_SCM_HOME%\Source\OdiScm\master" "%TEMPOBJSDIR%\master\" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying ODI-SCM master repository component import files
	goto ExitFail
)

xcopy /e "%ODI_SCM_HOME%\Source\OdiScm\project.1998" "%TEMPOBJSDIR%\project.1998\" >NUL
if ERRORLEVEL 1 (
	echo %EM% copying ODI-SCM work repository component import files
	goto ExitFail
)

rem
rem Modify the contents of the SnpConnect files.
rem

rem
rem Determine the actual working copy directory that files will be exported to.
rem
setlocal enabledelayedexpansion

if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "SVN" (
	rem
	rem For SVN we need to take the final part of the system URL and/or branch URL and append to the specified working copy path.
	rem This is because the last path component will have a working copy directory created for it when we check out of SVN.
	rem Note: beware of extra spaces at the end of the variable expansion.
	rem
	for /f "tokens=* delims=/" %%g in ('echo %ODI_SCM_SCM_SYSTEM_SYSTEM_URL%^| tr [/] [\n]') do (
		set SCMSYSTEMURLLASTPATH=%%g
	)
	rem echo set SCMSYSTEMURLLASTPATH to -!SCMSYSTEMURLLASTPATH!-
	if "!SCMSYSTEMURLLASTPATH!" == "" (
		echo %EM% last path component of SCM system URL ^<%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%^> is empty 1>&2
		goto ExitFail
	)
	for /f "tokens=* delims=/" %%g in ('echo %ODI_SCM_SCM_SYSTEM_BRANCH_URL%^| tr [/] [\n]') do (
		set SCMBRANCHURLLASTPATH=%%g
	)
	rem echo set SCMBRANCHURLLASTPATH to -!SCMBRANCHURLLASTPATH!-
	if "!SCMBRANCHURLLASTPATH!" == "" (
		echo %EM% last path component of SCM branch URL ^<%ODI_SCM_SCM_SYSTEM_BRANCH_URL%^> is empty 1>&2
		goto ExitFail
	)
	if "!SCMBRANCHURLLASTPATH!" == "." (
		set WCAPPEND=/!SCMSYSTEMURLLASTPATH!
		rem echo set WCAPPEND to -!WCAPPEND!- from SCMSYSTEMURLLASTPATH
		rem PAUSE
	) else (
		set WCAPPEND=/!SCMBRANCHURLLASTPATH!
		rem echo set WCAPPEND to -!WCAPPEND!- from SCMBRANCHURLLASTPATH
		rem PAUSE
	)
) else (
	rem
	rem For TFS or any unspecfied SCM system we don't need to append anything to the specified working copy root directory.
	rem
	set WCAPPEND=
)

for /f %%g in ('dir /s /b "%TEMPOBJSDIR%\*.SnpConnect"') do (
	echo %IM% preparing data server file ^<%%g^>
	rem echo %DEBUG% setting driver class
	cat "%%g" | sed s/"<OdiScmJavaDriverClass>"/"%ODI_SCM_ORACLEDI_SECU_DRIVER%"/g > %%g.1
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting pass word
	cat "%%g.1" | sed s/"<OdiScmPassWord>"/"%ODI_SCM_ORACLEDI_SECU_ENCODED_PASS%"/g > %%g.2
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting user name
	cat "%%g.2" | sed s/"<OdiScmUserName>"/"%ODI_SCM_ORACLEDI_SECU_USER%"/g > %%g.3
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting URL
	cat "%%g.3" | sed s/"<OdiScmUrl>"/"%ODI_SCM_ORACLEDI_SECU_URL%"/g > %%g.4
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting working copy dir root
	set WCROOT=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT:\=/%
	rem echo WCROOT now -!WCROOT!-
	set WCROOT=!WCROOT!%WCAPPEND%
	rem echo WCROOT now -!WCROOT!-
	set WCROOT=!WCROOT:/=\/!
	rem echo WCROOT now -!WCROOT!-
	rem echo cat "%%g.4" ^| sed s/"<OdiScmWorkingCopyDir>"/"!WCROOT!"/g
	rem PAUSE
	cat "%%g.4" | sed s/"<OdiScmWorkingCopyDir>"/"!WCROOT!"/g > %%g.5
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	rem echo %DEBUG% setting work dir
	set WDIR=%ODI_SCM_SCM_SYSTEM_WORKING_ROOT:\=\\%
	set WDIR=!WDIR:/=\/!
	cat "%%g.5" | sed s/"<OdiScmTempDir>"/"!WDIR!"/g > %%g.6
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
	copy "%%g.6" "%%g" >NUL 2>NUL
	if ERRORLEVEL 1 (
		echo %EM% preparing OdiScm repository components for import
		goto ExitFail
	)
)

echo %IM% starting import of ODI-SCM master repository objects
rem echo running: call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat^" /p %TEMPOBJSDIR%\master
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat^" /p %TEMPOBJSDIR%\master
if ERRORLEVEL 1 (
	echo %EM% importing ODI-SCM ODI repository objects
	goto ExitFail
)

echo %IM% completed import of ODI-SCM master repository objects

REM echo %IM% starting import of ODI-SCM work repository objects
REM call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmImportFromPathOrFile.bat^" /p %TEMPOBJSDIR%\project.1998
REM if ERRORLEVEL 1 (
	REM echo %EM% importing ODI-SCM ODI repository objects
	REM goto ExitFail
REM )

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiImportObject -FILE_NAME=%ODI_SCM_HOME%\Source\OdiScm\PROJ_ODI-SCM.xml -IMPORT_MODE=SYNONYM_INSERT_UPDATE
if ERRORLEVEL 1 (
	echo %EM% importing ODI-SCM ODI project
	goto ExitFail
)

echo %IM% completed import of ODI-SCM work repository objects

echo %IM% regenerating ODI-SCM ODI project scenarios
if "%ODI_SCM_ODI_SCM_ORACLEDI_VERSION_MAJOR%" == "10." (
	rem set ODI_SCM_PROJECT=1998
	set ODI_SCM_PROJECT=OS
) else (
	set ODI_SCM_PROJECT=OS
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiGenerateAllScen -PROJECT=%ODI_SCM_PROJECT% -MODE=REPLACE -GENERATE_PACK=YES -GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO
if ERRORLEVEL 1 (
	echo %EM% regenerating ODI-SCM ODI project scenarios
	goto ExitFail
)

if %PRIMEMETADATA% == LAST (
	call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmPrimeRepoFlush.bat^" /p both
	if ERRORLEVEL 1 (
		echo %EM% priming ODI-SCM export metadata after ODI-SCM import
		goto ExitFail
	)
)

rem
rem Configure the ODI-SCM ODI constants (variables).
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiStartScen -SCEN_NAME=OSCONFIGURE -SCEN_VERSION=-1 -CONTEXT=GLOBAL
if ERRORLEVEL 1 (
	echo %EM% setting ODI-SCM ODI repository SCM actions constants
	goto ExitFail
)

echo %IM% import of ODI-SCM ODI components completed successfully
goto ExitOk

:ExitFail
exit %IsBatchExit% 1

:ExitOk
exit %IsBatchExit% 0

rem *************************************************************
rem **                    S U B R O U T I N E S                **
rem *************************************************************