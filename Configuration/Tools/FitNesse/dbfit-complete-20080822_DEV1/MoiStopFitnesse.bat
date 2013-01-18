@echo off

echo MoiStopFitNesse: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:MoiStopFitNesse.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEMoiStopFitNesse=%CD%
popd
echo MoiStopFitNesse: Absolute directory path of this command is: %ABSPATHNAMEMoiStopFitNesse%

pushd %ABSPATHNAMEMoiStopFitNesse%

call MoiFitNesseOdiEnv.bat

java -cp lib\fitnesse.jar fitnesse.Shutdown -p %MOI_FITNESSE_PORT%
popd

echo MoiStopFitNesse: Ends