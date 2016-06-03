@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% missing solution path argument 1>&2
	call :ShowUsage
	goto ExitFail
)

if "%ARGV2%" == "" (
	echo %EM% missing target database logical schema name 1>&2
	call :ShowUsage
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

rem
rem Get the Analysis Services deployment database name (e.g. MOI_A_UKM_DNTL_SSAS) and
rem the target deployment server.
rem
set KEYNAME=ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_%ARGV2%
call :GetStringDynamic %KEYNAME%
set KEYVAL=%OUTSTRING%

for /f "tokens=2,4 delims=+" %%g in ("%KEYVAL%") do (
	set TARGETDATASERVERKEYNAME=%%g
	set TARGETASDBNAME=%%h
)

if "%TARGETDATASERVERKEYNAME%" == "" (
	echo %EM% missing target data server key name in configuration key ^<%KEYNAME%^>
	goto ExitFail
)

if "%TARGETASDBNAME%" == "" (
	echo %EM% missing target AS database name in configuration key ^<%KEYNAME%^>
	goto ExitFail
)

set KEYNAME=ODI_SCM_DATA_SERVERS_%TARGETDATASERVERKEYNAME%
call :GetStringDynamic %KEYNAME%
set KEYVAL=%OUTSTRING%

for /f "tokens=2,4 delims=+" %%g in ("%KEYVAL%") do (
	set TARGETASSERVERTYPE=%%g
	set TARGETASSERVERNAME=%%h
)

if not "%TARGETASSERVERTYPE%" == "sqlserverAS" (
	echo %EM% invalid data server type ^<%TARGETASSERVERTYPE%^> in configuration key ^<%KEYNAME%^> 1>&2
	echo %EM% expected data server type ^<sqlserverAS^> 1>&2
	goto ExitFail
)

if "%TARGETASSERVERNAME%" == "" (
	echo %EM% missing server name in configuration key ^<%KEYNAME%^> 1>&2
	goto ExitFail
)

echo %IM% using target deployment server name ^<%TARGETASSERVERNAME%^>
echo %IM% using target deployment database name ^<%TARGETASDBNAME%^>

rem
rem Copy the solution and modify the target deployment server and database names.
rem
xcopy /i /s "%ARGV1%" "%TEMPDIR%\solution" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% copying solution files to temporary working directory 1>&2
	goto ExitFail
)

set PROJDEPLOYFILES=%TEMPDIR%\OdiScmSSasProjectFiles.txt
dir /b "%TEMPDIR%\solution\*.dwproj.user" /s >"%PROJDEPLOYFILES%"
if ERRORLEVEL 1 (
	echo %EM% searching for SSAS project deployment option files ^(*.dwproj.user^) in temporary working directory 1>&2
	goto ExitFail
)

set TEMPWITHSERVER=%TEMPDIR%\OdiScmSSasProjectFileWithServer.xml
set TEMPWITHDATABASE=%TEMPDIR%\OdiScmSSasProjectFileWithDatabase.xml

for /f "tokens=1" %%g in (%PROJDEPLOYFILES%) do (
	echo %IM% processing project deployment option file ^<%%g^>
	cat "%%g" | sed s/OdiScmTargetServer/%TARGETASSERVERNAME%/g > "%TEMPWITHSERVER%"
	if ERRORLEVEL 1 (
		echo %EM% substituting AS deployment server name in project file ^<%%g^> 1>&2
		goto ExitFail
	)
	cat "%TEMPWITHSERVER%" | sed s/OdiScmTargetDatabase/%TARGETASDBNAME%/g > "%TEMPWITHDATABASE%"
	if ERRORLEVEL 1 (
		echo %EM% substituting AS deployment database name in project file ^<%%g^> 1>&2
		goto ExitFail
	)
	copy "%TEMPWITHDATABASE%" "%%g" >NUL 2>&1
	if ERRORLEVEL 1 (
		echo %EM% creating updated AS project file ^<%%g^> 1>&2
		goto ExitFail
	)
)

rem
rem Modify the data source server and database names.
rem
set PROJDATASOURCEFILES=%TEMPDIR%\OdiScmSSasDataSourceFiles.txt
dir /b "%TEMPDIR%\solution\*.ds" /s >"%PROJDATASOURCEFILES%"
if ERRORLEVEL 1 (
	echo %EM% searching for SSAS data source files ^(*.ds^) in temporary working directory 1>&2
	goto ExitFail
)

setlocal enabledelayedexpansion

set DATASOURCENAMEFILE=%TEMPDIR%\OdiScmSSasDataSourceName.txt
set TEMPDATASOURCEFILE=%TEMPDIR%\OdiScmSSasDataSource.txt
set TEMPSOURCEDBURL=%TEMPDIR%\OdiScmTempDbUrl.txt
set TEMPSOURCESERVERNAME=%TEMPDIR%\OdiScmTempServer.txt
set TEMPSTRINGNOTAGS=%TEMPDIR%\OdiScmStringNoTags.txt
set TEMPTOKENS=%TEMPDIR%\OdiScmTokens.txt

set TEMPAWKNODQ=%TEMPDIR%\OdiScmRemoveDoubleQuotes.awk
echo { >%TEMPAWKNODQ%
echo sub("\"^<","^<^",$0) >>%TEMPAWKNODQ%
echo sub(">\"","^>^",$0) >>%TEMPAWKNODQ%
echo print $0 >>%TEMPAWKNODQ%
echo } >>%TEMPAWKNODQ%

for /f "tokens=*" %%g in (%PROJDATASOURCEFILES%) do (
	set PROJDATASOURCEFILE=%%g
	tr -cd '\11\12\15\40-\176' < "%%g" > "!PROJDATASOURCEFILE!.ascii"
	if ERRORLEVEL 1 (
		echo %EM% translating data source file ^<!PROJDATASOURCEFILE!^> to ASCII 1>&2
		goto ExitFail
	)
	copy "!PROJDATASOURCEFILE!.ascii" "!PROJDATASOURCEFILE!" >NUL 2>&1
	if ERRORLEVEL 1 (
		echo %EM% overwriting data source file ^<!PROJDATASOURCEFILE!^> from ASCII temporary file 1>&2
		goto ExitFail
	)
	echo %IM% examining data source file ^<!PROJDATASOURCEFILE!^> for data source entries
	grep ^<Name^>.*^</Name^> "!PROJDATASOURCEFILE!" | sed s/^<Name^>// | sed s/^<\/Name^>// | sed "s/ //g" >"%DATASOURCENAMEFILE%"
	if ERRORLEVEL 1 (
		echo %EM% cannot find data source name in data source file ^<%%h>^ 1>&2
		goto ExitFail
	)
	
	set /p DATASOURCENAME=<"%DATASOURCENAMEFILE%"
	if ERRORLEVEL 1 (
		echo %EM% cannot get data source name from temporary file ^<%DATASOURCENAMEFILE%>^ 1>&2
		goto ExitFail
	)
	
	echo %IM% extracted Data Source name ^<!DATASOURCENAME!^>
	
	set KEYNAME=ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_!DATASOURCENAME!
	call :GetStringDynamic !KEYNAME!
	set KEYVAL=!OUTSTRING!
	
	for /f "tokens=2,4 delims=+" %%h in ("!KEYVAL!") do (
		set SOURCEDATASERVER=%%h
		set SOURCEDBNAME=%%i
	)
	
	echo %IM% using data server configuration key name ^<!SOURCEDATASERVER!^>
	echo %IM% using data source database name ^<!SOURCEDBNAME!^>
	
	set KEYNAME=ODI_SCM_DATA_SERVERS_!SOURCEDATASERVER!
	call :GetStringDynamic !KEYNAME!
	set KEYVAL=!OUTSTRING!
	
	for /f "tokens=2,4,6,8 delims=+" %%h in ("!KEYVAL!") do (
		set SOURCEDBTYPE=%%h
		set SOURCEDBURL=%%i
		set SOURCEDBUSER=%%j
		set SOURCEDBPASS=%%k
	)
	
	echo %IM% using source data server type ^<!SOURCEDBTYPE!^>
	echo %IM% extracting server name from JDBC URL ^<!SOURCEDBURL!^>
	
	if "!SOURCEDBTYPE!" == "sqlserver" (
		echo !SOURCEDBURL! | sed s/jdbc:sqlserver:\/\///g >"%TEMPSOURCEDBURL%"
		cat "%TEMPSOURCEDBURL%" | sed s/jdbc:datadirect:sqlserver:\/\///g >"%TEMPSOURCEDBURL%.2"
	) else (
		echo %EM% unsupported DBMS Type ^<!SOURCEDBTYPE!^> in configuration key ^<!KEYNAME!^> 1>&2
		goto ExitFail
	)
	
	for /f "tokens=*" %%h in ('cat "%TEMPSOURCEDBURL%" ^| sed s/:.*//g') do (
		set TEMPSOURCESERVERNAME=%%h
	)
	
	if "!TEMPSOURCESERVERNAME!" == "" (
		echo %EM% cannot determine server name from JDBC URL ^<!SOURCEDBURL!^> 1>&2
		goto ExitFail
	) else (
		echo %IM% extracted server name ^<!TEMPSOURCESERVERNAME!^> from JDBC URL ^<!SOURCEDBURL!^>
	)
	rem
	rem Create a copy of the data source file with substituted server and database names.
	rem
	del "%TEMPDATASOURCEFILE%" >NUL 2>&1
	for /f "tokens=*" %%h in (!PROJDATASOURCEFILE!) do (
		
		echo "%%h" | gawk -f "%TEMPAWKNODQ%" | grep ^<ConnectionString^> 1>NUL 2>&1
		set EL=!ERRORLEVEL!
		if "!EL!" GEQ "2" (
			echo %EM% searching data source file ^<!PROJDATASOURCEFILE!^> for ^<ConnectionString^> tag 1>&2
			goto ExitFail
		)
		if "!EL!" == "1" (
			echo "%%h" | gawk -f "%TEMPAWKNODQ%" >> "%TEMPDATASOURCEFILE%"
		) else (
			echo "%%h" | sed s/^<ConnectionString^>// | sed s/^<\/ConnectionString^>// | sed s/\^"//g >"%TEMPSTRINGNOTAGS%"
			set /p ELEMENTSTRING=<"%TEMPSTRINGNOTAGS%"
			set OUTSTRING=
			del "%TEMPTOKENS%" >NUL 2>&1
			for /f "tokens=1-18 delims=;" %%i in ("!ELEMENTSTRING!") do (
				if not "%%i" == "" (
					echo %%i>> "%TEMPTOKENS%"
				)
				if not "%%j" == "" (
					echo %%j>> "%TEMPTOKENS%"
				)
				if not "%%k" == "" (
					echo %%k>> "%TEMPTOKENS%"
				)
				if not "%%l" == "" (
					echo %%l>> "%TEMPTOKENS%"
				)
				if not "%%m" == "" (
					echo %%m>> "%TEMPTOKENS%"
				)
				if not "%%n" == "" (
					echo %%n>> "%TEMPTOKENS%"
				)
				if not "%%o" == "" ( 
					echo %%o>> "%TEMPTOKENS%"
				)
				if not "%%p" == "" (
					echo %%p>> "%TEMPTOKENS%"
				)
				if not "%%q" == "" (
					echo %%q>> "%TEMPTOKENS%"
				)
				if not "%%r" == "" (
					echo %%r>> "%TEMPTOKENS%"
				)
				if not "%%r" == "" (
					echo %%r>> "%TEMPTOKENS%"
				)
				if not "%%s" == "" (
					echo %%s>> "%TEMPTOKENS%"
				)
				if not "%%t" == "" (
					echo %%t>> "%TEMPTOKENS%"
				)
				if not "%%u" == "" (
					echo %%u>> "%TEMPTOKENS%"
				)
				if not "%%v" == "" (
					echo %%v>> "%TEMPTOKENS%"
				)
				if not "%%w" == "" (
					echo %%w>> "%TEMPTOKENS%"
				)
				if not "%%x" == "" (
					echo %%x>> "%TEMPTOKENS%"
				)
				if not "%%y" == "" (
					echo %%y>> "%TEMPTOKENS%"
				)
				if not "%%z" == "" (
					echo %%z>> "%TEMPTOKENS%"
				)
			)
			for /f "tokens=*" %%i in (%TEMPTOKENS%) do (
				set FOUNDDATASOURCE=N
				set FOUNDINITIALCATALOG=N
				echo %%i | grep "Data Source=" >NUL 2>&1
				set EL=!ERRORLEVEL!
				if "!EL!" GEQ 2 (
					echo %EM% searching ^<ConnectionString^> node for ^<Data Source^> key 1>&2
					goto ExitFail
				) else (
					if "!EL!" == "0" (
						set FOUNDDATASOURCE=Y
					)
				)
				
				echo %%i | grep "Initial Catalog=" >NUL 2>&1
				set EL=!ERRORLEVEL!
				if "!EL!" GEQ 2 (
					echo %EM% searching ^<ConnectionString^> node for ^<Initial Catalog^> key 1>&2
					goto ExitFail
				) else (
					if "!EL!" == "0" (
						set FOUNDINITIALCATALOG=Y
					)
				)
				
				if "!FOUNDDATASOURCE!" == "N" (
					if "!FOUNDINITIALCATALOG!" == "N" (
						if "!OUTSTRING!" == "" (
							set OUTSTRING=%%i
						) else (
							set OUTSTRING=!OUTSTRING!;%%i
						)
					) else (
						if "!OUTSTRING!" == "" (
							set OUTSTRING=Initial Catalog=!SOURCEDBNAME!
						) else (
							set OUTSTRING=!OUTSTRING!;Initial Catalog=!SOURCEDBNAME!
						)
					)
				) else (
					if "!OUTSTRING!" == "" (
						set OUTSTRING=Data Source=!TEMPSOURCESERVERNAME!
					) else (
						set OUTSTRING=!OUTSTRING!;Data Source=!TEMPSOURCESERVERNAME!
					)
				)
			)
			set OUTSTRING=!OUTSTRING!
			echo ^<ConnectionString^>!OUTSTRING!^</ConnectionString^> >> "%TEMPDATASOURCEFILE%"
		)
	)
	copy "%TEMPDATASOURCEFILE%" "!PROJDATASOURCEFILE!" >NUL 2>&1
	if ERRORLEVEL 1 (
		echo %EM% copying server and database name substituted file 1>&2
		goto ExitFail
	)
)

rem
rem Create the build project file.
rem
set BUILDFILE=%TEMPDIR%\build.xml
copy "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSsasBuildTemplate.proj" "%BUILDFILE%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to copy SSAS build template file ^<%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSsasBuildTemplate.proj^> 2>&1
	goto ExitFail
)

set BUILDLOG=%TEMPDIR%\OdiScmASDatabaseBuild.log
echo %IM% executing command ^<msbuild "%BUILDFILE%" /target:buildCube /property:solutionPath="%TEMPDIR%\solution" /property:env="OdiScm"^>
msbuild "%BUILDFILE%" /target:buildCube /property:solutionPath="%TEMPDIR%\solution" /property:env="OdiScm" >%BUILDLOG% 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to build Analysis Services project 2>&1
	echo %EM% check log file ^<%BUILDLOG%^> for details 2>&1
	goto ExitFail
)

grep "0 Error(s)" "%BUILDLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to build Analysis Services project 2>&1
	goto ExitFail
)

grep "0 Warning(s)" "%BUILDLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %WM% warning messages detected in cube build output 2>&1
	goto ExitFail
)

rem
rem Now we need to modify the connection strings in the deployment configuration settings file generated by the build phase.
rem
set ASCONFIGSETTINGSFILE=%TEMPDIR%\OdiScmSSasConfigSettingsFiles.txt
dir /b "%TEMPDIR%\solution\*.configsettings" /s >"%ASCONFIGSETTINGSFILE%.2"
if ERRORLEVEL 1 (
	echo %EM% searching for SSAS deployment configuration files ^(*.configsettings^) in temporary working directory 1>&2
	goto ExitFail
)

grep \\OdiScmBuildPath\\ "%ASCONFIGSETTINGSFILE%.2" > "%ASCONFIGSETTINGSFILE%"
if ERRORLEVEL 1 (
	echo %EM% searching for OdiScmBuildPath solution configuration SSAS deployment configuration ^(*.configsettings^) files  1>&2
	goto ExitFail
)

for /f %%g in ('wc -l "%ASCONFIGSETTINGSFILE%"') do (
	if not "%%g" == "1" (
		echo %EM% found multiple SSAS deployment configuration ^(*.configsettings^) files 1>&2
	)
)

for /f %%g in (%ASCONFIGSETTINGSFILE%) do (
	set CONFIGSETTINGFILE=%%g
)

rem
rem Create a copy of the deployment configuration settings file with the appropriate connection string.
rem
set TEMPCONFIGSETTINGSFILE=%TEMPDIR%\OdiScmTempAsConfigSettings.xml
set TEMPCONFIGSETTINGSASCIIFILE=%TEMPDIR%\OdiScmTempAsConfigSettingsAscii.xml
set TEMPRECORDNOTAGSFILE=%TEMPDIR%\OdiScmRecordNoTags.txt
set TEMPSPLITSTRINGFILE=%TEMPDIR%\OdiScmSplitStringToFile.txt

set DATASOURCETAG=^<DataSource^>
set DATASOURCETAGESC=^^^<DataSource^^^>
set FOUNDDATASOURCETAG=NO

set IDTAG=^<ID^>
set IDTAGESC=^^^<ID^^^>
set FOUNDIDTAG=NO
set IDVAL=

set CONNECTIONSTRINGTAG=^<ConnectionString^>
set CONNECTIONSTRINGTAGESC=^^^<ConnectionString^^^>
set FOUNDCONNECTIONSTRINGTAG=NO

set LOOKFORTAG="%DATASOURCETAG%"

tr -cd '\11\12\15\40-\176' < "%CONFIGSETTINGFILE%" > "%TEMPCONFIGSETTINGSASCIIFILE%"
if ERRORLEVEL 1 (
	echo %EM% translating configuration settings file ^<%TEMPCONFIGSETTINGSFILE%^> to ASCII 1>&2
	goto ExitFail
)

copy "%TEMPCONFIGSETTINGSASCIIFILE%" "%CONFIGSETTINGFILE%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% overwriting data source file ^<%CONFIGSETTINGFILE%^> from ASCII temporary file 1>&2
	goto ExitFail
)

for /f "tokens=*" %%h in (%CONFIGSETTINGFILE%) do (
	set REC=%%h
	call :StringContainsTag "!REC!" !LOOKFORTAG!
	if ERRORLEVEL 1 (
		echo %EM% searching configuration settings file record ^<!REC!^> for ^<!LOOKFORTAG!^> tag 1>&2
		goto ExitFail
	)
	
	set FORWARDINPUT=YES
	
	if "!OUTIND!" == "YES" (
		rem We did find whatever tag we were looking for.
		if !LOOKFORTAG! == "%DATASOURCETAG%" (
			set FOUNDDATASOURCETAG=YES
			set FOUNDIDTAG=NO
			set FOUNDCONNECTIONSTRINGTAG=NO
			set LOOKFORTAG="%IDTAG%"
		) else (
			if !LOOKFORTAG! == "%IDTAG%" (
				set FOUNDIDTAG=YES
				set FOUNDCONNECTIONSTRINGTAG=NO
				set LOOKFORTAG="%CONNECTIONSTRINGTAG%"
				call :RemoveTagsFromString "!REC!" ID "%TEMPRECORDNOTAGSFILE%"
				if ERRORLEVEL 1 (
					echo %EM% splitting string to temporary file ^<%TEMPRECORDNOTAGSFILE%^> 1>&2
					goto ExitFail
				)
				set /p IDVAL=<"%TEMPRECORDNOTAGSFILE%"
				call :RemoveQuotes !IDVAL!
				set IDVAL=!OUTSTRING!
				echo %IM% found data source with ID of ^<!IDVAL!^>
				
				rem
				rem Extract the physical schema and server details from the configuration.
				rem
				set SCHEMAKEYNAME=ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_!IDVAL!
				call :GetStringDynamic !SCHEMAKEYNAME!
				set SCHEMAKEYVAL=!OUTSTRING!
				
				for /f "tokens=2,4 delims=+" %%k in ("!SCHEMAKEYVAL!") do (
					set SOURCEDATASERVER=%%k
					set SOURCEDBNAME=%%l
				)
				
				echo %IM% using data server configuration key name ^<!SOURCEDATASERVER!^>
				echo %IM% using data source database name ^<!SOURCEDBNAME!^>
				
				set SERVERKEYNAME=ODI_SCM_DATA_SERVERS_!SOURCEDATASERVER!
				call :GetStringDynamic !SERVERKEYNAME!
				set SERVERKEYVAL=!OUTSTRING!
				
				for /f "tokens=2,4,6,8 delims=+" %%k in ("!SERVERKEYVAL!") do (
					set SOURCEDBTYPE=%%k
					set SOURCEDBURL=%%l
					set SOURCEDBUSER=%%m
					set SOURCEDBPASS=%%n
				)
				
				echo %IM% using source data server type ^<!SOURCEDBTYPE!^>
				echo %IM% extracting server name from JDBC URL ^<!SOURCEDBURL!^>
				
				if "!SOURCEDBTYPE!" == "sqlserver" (
					echo !SOURCEDBURL! | sed s/jdbc:sqlserver:\/\///g >"%TEMPSOURCEDBURL%"
					cat "%TEMPSOURCEDBURL%" | sed s/jdbc:datadirect:sqlserver:\/\///g >"%TEMPSOURCEDBURL%.2"
				) else (
					echo %EM% unsupported DBMS Type ^<!SOURCEDBTYPE!^> in configuration key ^<!KEYNAME!^> 1>&2
					goto ExitFail
				)
				
				for /f "tokens=*" %%h in ('cat "%TEMPSOURCEDBURL%" ^| sed s/:.*//g') do (
					set TEMPSOURCESERVERNAME=%%h
				)
				
				if "!TEMPSOURCESERVERNAME!" == "" (
					echo %EM% cannot determine server name from JDBC URL ^<!SOURCEDBURL!^> 1>&2
					goto ExitFail
				) else (
					echo %IM% extracted server name ^<!TEMPSOURCESERVERNAME!^> from JDBC URL ^<!SOURCEDBURL!^>
				)
			) else (
				set FOUNDCONNECTIONSTRINGTAG=YES
				set FORWARDINPUT=NO
				call :RemoveTagsFromString "!REC!" ConnectionString "%TEMPRECORDNOTAGSFILE%"
				if ERRORLEVEL 1 (
					echo %EM% splitting string to temporary file ^<%OUTFILE%^> 1>&2
					goto ExitFail
				)
				set /p STRINGNOTAGS=<"%TEMPRECORDNOTAGSFILE%"
				
				rem call :RemoveQuotes !STRINGNOTAGS!
				rem if ERRORLEVEL 1 (
					rem echo %EM% removing quotes from string ^<%STRINGNOTAGS%^> 1>&2
					rem goto ExitFail
				rem )
				rem set STRINGNOTAGS=!OUTSTRING!
				
				call :SplitStringToFile !STRINGNOTAGS! ";" "%TEMPSPLITSTRINGFILE%"
				if ERRORLEVEL 1 (
					echo %EM% splitting string to temporary file ^<%TEMPSPLITSTRINGFILE%^> 1>&2
					goto ExitFail
				)
				
				rem
				rem Process each token in the connection string.
				rem
				set OUTCONNSTR=
				for /f "tokens=*" %%i in (%TEMPSPLITSTRINGFILE%) do (
					for /f "tokens=1,2 delims==" %%j in ("%%i") do (
						set KEYNAME=%%j
						set KEYVAL=%%k
						set OUTCONNSTR=!OUTCONNSTR!!KEYNAME!=
						if "!KEYVAL!" == "OdiScmSourceServer" (
							set OUTCONNSTR=!OUTCONNSTR!!TEMPSOURCESERVERNAME!
						) else (
							if "!KEYVAL!" == "OdiScmSourceUserName" (
								set OUTCONNSTR=!OUTCONNSTR!!SOURCEDBUSER!
							) else (
								if "!KEYVAL!" == "OdiScmSourcePassword" (
									set OUTCONNSTR=!OUTCONNSTR!!SOURCEDBPASS!
								) else (
									if "!KEYVAL!" == "OdiScmSourceDatabase" (
										set OUTCONNSTR=!OUTCONNSTR!!SOURCEDBNAME!
									) else (
										set OUTCONNSTR=!OUTCONNSTR!!KEYVAL!
									)
								)
							)
						)
					)
					set OUTCONNSTR=!OUTCONNSTR!;
				)
				echo ^<ConnectionString^>!OUTCONNSTR!^</ConnectionString^>>> "%TEMPCONFIGSETTINGSFILE%"
				set FOUNDCONNECTIONSTRINGTAG=NO
				set FOUNDIDTAG=NO
				set FOUNDDATASOURCETAG=NO
			)
		)
	)
	
	if "!FORWARDINPUT!" == "YES" (
		echo "!REC!" | gawk -f "%TEMPAWKNODQ%" >> "%TEMPCONFIGSETTINGSFILE%"
		if ERRORLEVEL 1 (
			echo %EM% forwarding input record to output configuration settings file ^<%TEMPCONFIGSETTINGSFILE%^> 1>&2
			goto ExitFail
		)
	)
)

copy "%TEMPCONFIGSETTINGSFILE%" "%CONFIGSETTINGFILE%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% copying modified configuration settings file ^<%TEMPCONFIGSETTINGSFILE%%^> 1>&2
	goto ExitFail
)

set DEPLOYLOG=%TEMPDIR%\OdiScmASDatabaseDeploy.log
echo %IM% executing command ^<msbuild "%BUILDFILE%" /target:deployCube /property:buildPath="%TEMPDIR%\solution" /property:env="OdiScm"^>
msbuild "%BUILDFILE%" /target:deployCube /property:buildPath="%TEMPDIR%\solution" /property:env="OdiScm" >%DEPLOYLOG% 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to deploy Analysis Services project 2>&1
	echo %EM% check log file ^<%DEPLOYLOG%^> for details 2>&1
	goto ExitFail
)

grep "Errors in the OLAP storage engine" "%DEPLOYLOG%" >NUL 2>&1
set EL=%ERRORLEVEL%

if "%EL%" == "0" (
	echo %EM% failed to deploy Analysis Services project - error messages detected in stdout 2>&1
	goto ExitFail
)

if not "%EL%" == "1" (
	echo %EM% checking for error messages detected in stdout 2>&1
	goto ExitFail
)

grep "0 Error(s)" "%DEPLOYLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %EM% failed to deploy Analysis Services project - msbuild errors detected 2>&1
	goto ExitFail
)

grep "0 Warning(s)" "%DEPLOYLOG%" >NUL 2>&1
if ERRORLEVEL 1 (
	echo %WM% failed to deploy Analysis Services project - msbuild warnings detected 2>&1
	goto ExitFail
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1

rem ===============================================
rem ==           S U B R O U T I N E S           ==
rem ===============================================

rem -----------------------------------------------
:ShowUsage
rem -----------------------------------------------
echo %EM% usage: %PROC% ^<SSAS Solution Path^> ^<SSAS Database Logical Schema Name^> 1>&2
echo %EM%      : NOTE: ^<SSAS Solution Path^> is the directory containing the solution ^(*.sln^) file 1>&2
goto :eof

rem -----------------------------------------------
:GetStringDynamic
rem -----------------------------------------------
set VARNAME=%1
set VARVAL=%%%VARNAME%%%
call set OUTSTRING=%VARVAL%
goto :eof

rem -----------------------------------------------
:StringContainsTag
rem -----------------------------------------------
set INTEXT=%1
set INSTR=%2
set OUTIND=NO

echo %INTEXT% | gawk -f "%TEMPAWKNODQ%" | grep %INSTR% 1>NUL 2>&1
set EL=!ERRORLEVEL!

if "!EL!" GEQ "2" (
	echo %EM% searching source string ^<%INTEXT%^> for text ^<%INSTR%^> 1>&2
	set OUTIND=ERROR
	exit /b 1
) else (
	if not "!EL!" == "1" (
		set OUTIND=YES
	) else (
		set OUTIND=NO
	)
)

exit /b 0

rem -----------------------------------------------
:StringEscapeDedir
rem -----------------------------------------------
set INTEXT=%1
set INSTR=%2
set OUTVAR=%INTEXT:<=^<%
set OUTVAR=%OUTVAR:>=^>%
goto :eof

rem -----------------------------------------------
:RemoveTagsFromString
rem -----------------------------------------------
set INTEXT=%1
set TAG=%2
set OUTFILE=%3

echo %INTEXT% | sed "s/<%TAG%>//g" | sed "s/<\/%TAG%>//g" > %OUTFILE%
if ERRORLEVEL 1 (
	echo %EM% splitting string to temporary file ^<%OUTFILE%^> 1>&2
	exit /b 1
)

exit /b 0

rem -----------------------------------------------
:RemoveQuotes
rem -----------------------------------------------
set REMOVEQUOTESTEMPFILE=%TEMPDIR%\OdiScmRemoveQuotes.txt

echo %1| sed s/\^"//g > "%REMOVEQUOTESTEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% splitting string to temporary file ^<%REMOVEQUOTESTEMPFILE%^> 1>&2
	exit /b 1
)

set /p OUTSTRING=<"%REMOVEQUOTESTEMPFILE%"
exit /b 0

rem -----------------------------------------------
:SplitStringToFile
rem -----------------------------------------------
set INTEXT=%1
set DELIM=%2
set OUTFILE=%3

call :RemoveQuotes %INTEXT%
if ERRORLEVEL 1 (
	echo %EM% removing quotes from string split input string ^<%INTEXT%^> 1>&2
	exit /b 1
)

set INTEXT=!OUTSTRING!

echo %INTEXT%| tr "%DELIM%" "\n" > "%OUTFILE%"
if ERRORLEVEL 1 (
	echo %EM% splitting string to temporary file ^<%OUTFILE%^> 1>&2
	exit /b 1
)

exit /b 0