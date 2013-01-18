@echo off

rem
rem This batch file is used to wrap around MoiStartFitNesseReal.bat and capture all stdout and stderr
rem output to a log file when running FitNesse as a Windows service.

echo MoiStartFitNesse: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:MoiStartFitNesse.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEMoiStartFitNesse=%CD%
popd
echo MoiStartFitNesse: Absolute directory path of this command is: %ABSPATHNAMEMoiStartFitNesse%

cd /d %ABSPATHNAMEMoiStartFitNesse%
MoiStartFitNesseReal.bat >MoiStartFitNesseReal.log 2>&1

echo MoiStartFitNesse: Ends