@echo off

echo MoiRunTest: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:MoiRunTest.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEMoiRunTest=%CD%
popd
echo MoiRunTest: Absolute directory path of this command is: %ABSPATHNAMEMoiRunTest%

pushd %ABSPATHNAMEMoiRunTest%

pushd ..
call MoiFitNesseEnv.bat
popd

java -cp lib\fitnesse.jar fitnesse.runner.TestRunner -v localhost %MOI_FITNESSE_PORT% %1

popd

echo MoiRnTest: Ends