@echo off

echo MoiEXecOdiScen: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:MoiExecOdiScen.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEMoiExecOdiScen=%CD%
popd
echo MoiExecOdiScen: Absolute directory path of this command is: %ABSPATHNAMEMoiExecOdiScen%

pushd %ABSPATHNAMEMoiExecOdiScen%

pushd ..
call MoiFitNesseEnv.bat
popd

echo MoiExecOdiScen.bat: ODI_HOME: %ODI_HOME%
echo MoiExecOdiScen.bat: CWD is now:
cd

pushd %ODI_HOME%\bin
echo MoiExecOdiScen.bat: CWD is now:
cd

REM
REM params are name [, context]
REM we execute the latest version
REM
if "%2" == "" (
	set ODI_SCEN_CONTEXT=%ODI_CONTEXT%
) else (
	set ODI_SCEN_CONTEXT=%2
	shift /2
)

rem .\startcmd.bat OdiStartScen -SCEN_NAME=%1 -SCEN_VERSION=-1 -CONTEXT=%ODI_SCEN_CONTEXT% -AGENT_CODE=moi_agt
.\startcmd.bat OdiStartScen -SCEN_NAME=%1 -SCEN_VERSION=-1 -CONTEXT=%ODI_SCEN_CONTEXT% %2 %3 %4 %5 %6 %7 %8 %9
set EXITSTATUS=%ERRORLEVEL%

popd

if %EXITSTATUS% == 0 (
	echo MoiExecOdiScen.bat: Scenario execution completed successfully
) else (
	echo MoiExecOdiScen.bat: Scenario execution failed
}

echo MoiEXecOdiScen: Ends
exit /b %EXITSTATUS%
