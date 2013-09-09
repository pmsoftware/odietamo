@echo off
set OLDPWD=

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

rem
rem Check parameter arguments.
rem
if "%ARGV1%" == "" (
	echo %EM% no target directory specified 1>&2
	call :ShowUsage
	goto ExitFail
)

if EXIST "%ARGV1%" (
	echo %EM% specified target directory ^<%ARGV1%^> exists. Specify a directory path to be created 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION%" == "" (
	echo %EM% no OracleDI version specified in environment variable ODI_SCM_ORACLEDI_VERSION 1>&2
	goto ExitFail
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%%" == "10." (
	set EXPDIR1=
	set EXPDIR2=%ARGV1%\
) else (
	if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
		set EXPDIR1=-EXPORT_DIR=%ARGV1%
		set EXPDIR2=
	) else (
		echo %EM% invalid OracleDI version specified. Specify either 10.w.x.y.z or 11.w.x.y.z 1>&2
		call :ShowUsage
		goto ExitFail
	)
)

if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "10." (
	rem
	rem Create the directory if not present.
	rem
	if not EXIST "%ARGV1%" (
		md "%ARGV1%"
		if ERRORLEVEL 1 (
			echo %EM% creating directory ^<%ARGV1%^>
			goto ExitFail
		)
	) else (
		echo %EM% target directory ^<%ARGV1%^> already exists. Specify a new target directory name
		goto ExitFail
	)
) else (
	rem
	rem Check that the directory does not already exist.
	rem
	if EXIST "%ARGV1%" (
		echo %EM% target directory ^<%ARGV1%^> already exists. Specify a new target directory name
		goto ExitFail
	)
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

rem
rem Generate a StartCmd script specific to this environment.
rem
set TEMPSTARTCMD=%TEMPDIR%\OdiScmExportOracleDIDemo_StartCmd.bat
echo %IM% creating startcmd script ^<%TEMPSTARTCMD%^>
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenStartCmd.bat" /p %TEMPSTARTCMD%
if ERRORLEVEL 1 (
	echo %EM% generating StartCmd script for current environment 1>&2
	goto ExitFail
)

rem
rem Copy the HSQL database files.
rem
md "%TEMPDIR%\hsql"
if ERRORLEVEL 1 (
	echo %EM% creating HSQL demo repository copy directory ^<%TEMPDIR%\hsql^> 1>&2
	goto ExitFail
)
echo on
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Demo\OdiScmCopyOdiDemoDbFiles.bat" "%TEMPDIR%\hsql"
if ERRORLEVEL 1 (
	echo %EM% copying HSQL demo files to directory ^<%TEMPDIR%\hsql^> 1>&2
	goto ExitFail
)

rem
rem Create a class path JAR for the current environment.
rem
set TEMPCLASSPATHJAR=%TEMPDIR%\%PROC%_ClassPathJar.jar
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat" /p "%TEMPCLASSPATHJAR%" >NUL
if ERRORLEVEL 1 (
	echo %EM% creating temporary class path Jar file ^<%TEMPCLASSPATHJAR%^> 1>&2
	goto ExitFail
)

rem
rem Clear up any HSQL server.properties file.
rem
if EXIST ".\server.properties" (
	del /f ".\server.properties"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing HSQL server properties file ^<.\server.properties^> 1>&2
		goto ExitFail
	)
)

rem
rem Start the demo repository as a background process.
rem We start up on a different port than when running from the standard ODI demo scripts.
rem
echo %IM% starting demo ODI repository in background
echo %IM% demo database file copies at ^<%TEMPDIR%\hsql^>
echo %IM% executing command ^<start "Demo HSQL Repository" "%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" -classpath "%TEMPCLASSPATHJAR%" org.hsqldb.Server -port %ODI_SCM_ORACLEDI_SECU_URL_PORT% -database.0 file:"%TEMPDIR%\hsql\demo_repository_en" -no_system_exit=false^>
start "Demo HSQL Repository" "%ODI_SCM_ORACLEDI_JAVA_HOME%\bin\java.exe" -classpath "%TEMPCLASSPATHJAR%" org.hsqldb.Server -port %ODI_SCM_ORACLEDI_SECU_URL_PORT% -database.0 file:"%TEMPDIR%\hsql\demo_repository_en" -no_system_exit=false
if ERRORLEVEL 1 (
	echo %EM% starting demo repository database 1>&2
	goto ExitFail
)

rem
rem Wait a, short, while after starting the datatabase (as we're starting an asynchronous process).
rem
echo %IM% pausing for demo database start up asynchronous process
sleep 10

rem
rem Alter the repository URLs stored in the database.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat^" /p %ODI_SCM_HOME%\Configuration\Demo\OdiScmModifyOracleDIDemoRepoURL.sql
if ERRORLEVEL 1 (
	echo %EM% modifying demo repository URLs 1>&2
	goto ExitFail
)

rem
rem Export the demo repository objects.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%^" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=2002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Orders_Application_-_HSQL.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=3002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Parameters_-_FILE.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpModel -I_OBJECT=4002 %EXPDIR1% -FILE_NAME=%EXPDIR2%MOD_Sales_Administration_-_HSQL.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpProject -I_OBJECT=2002 %EXPDIR1% -FILE_NAME=%EXPDIR2%PROJ_Demo.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=0 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_Security_Connection.xml -RECURSIVE_EXPORT=yes
rem if ERRORLEVEL 1 (
	rem echo %EM% exporting demo object
	rem goto ExitFail
rem )

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_HSQL_LOCALHOST_20001.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_HSQL_LOCALHOST_20002.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_FILE_GENERIC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_SUNOPSIS_MEMORY_ENGINE.xml -RECURSIVE_EXPORT=no
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=9999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_XML_GEO_DIM.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=15000 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_WORKREP.xml -RECURSIVE_EXPORT=no
rem if ERRORLEVEL 1 (
	rem echo %EM% exporting demo object
	rem goto ExitFail
rem )

rem if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
	rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpConnect -I_OBJECT=15999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CONN_MEMORY_ENGINE.xml
	rem if ERRORLEVEL 1 (
	rem echo %EM% exporting demo object
	rem goto ExitFail
rem )

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpContext -I_OBJECT=2999 %EXPDIR1% -FILE_NAME=%EXPDIR2%CTX_Global.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=4999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_HSQL_DEMO_SRC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_HSQL_DEMO_TARG.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_FILE_DEMO_SRC.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC__SUNOPSIS_MEMORY_ENGINE.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_XML_DEMO_GEO.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

rem if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
	rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=12999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC_File_Server_for_SAP_ABAP.xml -RECURSIVE_EXPORT=yes
	rem if ERRORLEVEL 1 (
	rem 	echo %EM% exporting demo object
	rem 	goto ExitFail
	rem )
rem )

rem if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
	rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpLschema -I_OBJECT=13999 %EXPDIR1% -FILE_NAME=%EXPDIR2%LSC__MEMORY_ENGINE.xml -RECURSIVE_EXPORT=yes
	rem if ERRORLEVEL 1 (
	rem 	echo %EM% exporting demo object
	rem 	goto ExitFail
	rem )
rem )

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=5999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_HSQL_LOCALHOST_20001_Default.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=6999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_HSQL_LOCALHOST_20002_Default.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=7999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_FILE_GENERICdemofile.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=8999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_SUNOPSIS_MEMORY_ENGINE_Default.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=9999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_XML_GEO_DIMGEO.xml -RECURSIVE_EXPORT=yes
if ERRORLEVEL 1 (
	echo %EM% exporting demo object
	goto ExitFail
)

rem if "%ODI_SCM_ORACLEDI_VERSION:~0,3%" == "11." (
	rem call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%TEMPSTARTCMD%" OdiExportObject -FORCE_OVERWRITE=yes -CLASS_NAME=SnpPschema -I_OBJECT=15999 %EXPDIR1% -FILE_NAME=%EXPDIR2%PSC_MEMORY_ENGINE_Default.xml -RECURSIVE_EXPORT=yes
	rem if ERRORLEVEL 1 (
	rem 	echo %EM% exporting demo object
	rem 	goto ExitFail
	rem )
rem )

rem
rem Stop the demo repository.
rem
echo %IM% stopping demo repository database processes
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat" /p "%ODI_SCM_HOME%\Configuration\Demo\OdiScmShutDownHSQLServer.sql"
if ERRORLEVEL 1 (
	echo %EM% executing database shut down script ^<%ODI_SCM_HOME%\Configuration\Demo\OdiScmShutDownHSQLServer.sql^> 1>&2
	goto ExitFail
)

rem
rem Clear up any HSQL server.properties file.
rem
if EXIST ".\server.properties" (
	del /f ".\server.properties"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing HSQL server properties file ^<.\server.properties^> 1>&2
		goto ExitFail
	)
)

:ExitOk
if DEFINED OLDPWD (
	cd %OLDPWD%
)

echo %IM% standard demo export completed successfully
exit %IsBatchExit% 0

:ExitFail
if DEFINED OLDPWD (
	cd %OLDPWD%
)
exit %IsBatchExit% 1

:ShowUsage
echo %EM% usage: %PROC% ^<export target directory^> 1>&2
exit /b