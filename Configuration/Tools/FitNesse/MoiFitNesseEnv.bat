@echo off
echo MoiFitNesseEnv: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:MoiFitNesseEnv.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEMoiFitNesseEnv=%CD%
popd
echo MoiFitNesseEnv: Absolute directory path of this command is: %ABSPATHNAMEMoiFitNesseEnv%

echo pushd %ABSPATHNAMEMoiFitNesseEnv%
pushd %ABSPATHNAMEMoiFitNesseEnv%

set MOI_FITNESSE_ROOT=%CD%

set JAVA_HOME=%MOI_FITNESSE_ROOT%\..\java\jdk1.5.0_22

set ODI_JAVA_HOME=%JAVA_HOME%
set PATH=%JAVA_HOME%\bin;%PATH%

popd

echo MoiFitNesseEnv: Ends