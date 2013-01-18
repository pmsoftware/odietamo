@echo off

echo DeleteFitNesseServices: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:DeleteFitNesseServices.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEDeleteFitNesseServices=%CD%
popd
echo DeleteFitNesseServices: Absolute directory path of this command is: %ABSPATHNAMEDeleteFitNesseServices%

pushd %ABSPATHNAMEDeleteFitNesseServices%

call DeleteFitNesseService.bat DEV1
rem call DeleteFitNessService.bat SIT1
rem call DeleteFitNesseService.bat UAT1

popd

echo DeleteFitNesseServices: Ends