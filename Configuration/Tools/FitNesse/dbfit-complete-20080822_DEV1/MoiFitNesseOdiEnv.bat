@echo off

echo MoiFitNesseOdiEnv: Starts

rem
rem This batch file sets the environment for this instance of Fitnesse+DbFit+ODI.
rem

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:MoiFitNesseOdiEnv.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMEMoiFitNesseOdiEnv=%CD%
popd
echo MoiFitNesseOdiEnv: Absolute directory path of this command is: %ABSPATHNAMEMoiFitNesseOdiEnv%

pushd %ABSPATHNAMEMoiFitNesseOdiEnv%
rem
rem Set the global environment settings.
rem
pushd ..
call MoiFitNesseEnv.bat
popd

set MOI_FITNESSE_PORT=8085
set MOI_DEVELOPMENT_ROOT=C:/MOI/P_Unstable
REM set MOI_DEVELOPMENT_ROOT=../../../../Development
rem
rem The GLOBAL context is used for executing ODI scenarios.
rem
set ODI_CONTEXT=GLOBAL

set ODI_HOME=%MOI_FITNESSE_ROOT%\..\odi

popd

echo MoiFitNesseOdiEnv: Ends