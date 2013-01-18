@echo off

echo StopFitNesseService: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:StopFitNesseService.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEStopFitNesseService=%CD%
popd
echo StopFitNesseService: Absolute directory path of this command is: %ABSPATHNAMEStopFitNesseService%

pushd %ABSPATHNAMEStopFitNesseService%

pushd ..\dbfit-complete-20080822_%1
call MoiStopFitNesse.bat
popd

popd

net stop FitNesse%1

echo StopFitNesseService: Ends
