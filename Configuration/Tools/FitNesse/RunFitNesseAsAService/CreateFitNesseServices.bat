@echo off

echo CreateFitNesseServices: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:CreateFitNesseServices.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMECreateFitNesseServices=%CD%
popd
echo CreateFitNesseServices: Absolute directory path of this command is: %ABSPATHNAMECreateFitNesseServices%

pushd %ABSPATHNAMECreateFitNesseServices%

call CreateFitNesseService.bat DEV1
rem call CreateFitNesseService.bat SIT1
rem call CreateFitNesseService.bat UAT1

popd

echo CreateFitNesseServices: Ends