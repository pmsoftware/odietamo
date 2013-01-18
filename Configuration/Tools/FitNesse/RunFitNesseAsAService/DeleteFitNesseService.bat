@echo off
echo DeleteFitNesseService: Starts

if "%1" == "" goto abort
goto continue

:abort
echo DeleteFitNesseService: environment name argument is missing
exit

:continue
echo DeleteFitNesseService: received environment name argument: %1

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:DeleteFitNesseService.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEDeleteFitNesseService=%CD%
popd
echo DeleteFitNesseService: Absolute directory path of this command is: %ABSPATHNAMEDeleteFitNesseService%

pushd %ABSPATHNAMEDeleteFitNesseService%

pushd ..
call MoiFitNesseEnv.bat
popd

pushd ..\dbfit-complete-20080822_%1
call MoiStopFitNesse.bat
popd
net stop FitNesse%1
instsrv FitNesse%1 remove

popd

echo DeleteFitNesseService: Ends