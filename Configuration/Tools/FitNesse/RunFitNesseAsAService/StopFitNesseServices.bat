@echo off

echo StopFitNesseServices: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:StopFitNesseServices.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEStopFitNesseServices=%CD%
popd
echo StopFitNesseServices: Absolute directory path of this command is: %ABSPATHNAMEStopFitNesseServices%

pushd %ABSPATHNAMEStopFitNesseServices%

call StopFitNesseService.bat DEV1
rem call StopFitNesseService.bat SIT1
rem call StopFitNesseService.bat UAT1

popd


echo StopFitNesseServices: Ends