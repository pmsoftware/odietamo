@echo off

echo StartFitNesseServices: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:StartFitNesseServices.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEStartFitNesseServices=%CD%
popd
echo StartFitNesseServices: Absolute directory path of this command is: %ABSPATHNAMEStartFitNesseServices%

pushd %ABSPATHNAMEStartFitNesseServices%

net start FitNesseDEV1
rem net start FitNesseSIT1
rem net start FitNesseUAT1

popd

echo StartFitNesseServices: Ends