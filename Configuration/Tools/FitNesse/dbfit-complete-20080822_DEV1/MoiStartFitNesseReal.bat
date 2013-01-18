@echo off

echo MoiStartFitNesseReal: Starts

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we rely on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:MoiStartFitNesseReal.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
echo pn = %PATHNAME%
pushd %PATHNAME%
set ABSPATHNAMEMoiStartFitNesseReal=%CD%
popd
echo MoiStartFitNesseReal: Absolute directory path of this command is: %ABSPATHNAMEMoiStartFitNesseReal%

pushd %ABSPATHNAMEMoiStartFitNesseReal%
call MoiFitNesseOdiEnv.bat

setlocal enableextensions
setlocal enabledelayedexpansion

set sysprops=
for /f %%g in ('type LOGICAL_PHYSICAL_SCHEMA_MAPPINGS.properties^|c:\windows\system32\find /v "#"') do set sysprops=!sysprops! -D%%g
rem
rem Also make the FitNesse page root available to pages in order access files relative to the pages root. E.g. for setting up ETL source data files.
rem
set sysprops=%sysprops% -DMOI_DEVELOPMENT_ROOT=%MOI_DEVELOPMENT_ROOT%

rem
rem Unset the _JAVA_OPTIONS environment variable so that no unwanted additional JVM options are used.
rem
set _JAVA_OPTIONS=

rem Xrs switch added to run as a service
rem Xms switch specifies the inital heap size allocation.
rem Xmx switch specifies the maximum heap size allocation.
java -Xms256m -Xmx1024m -Xrs -cp lib\fitnesse.jar %sysprops% fitnesse.FitNesse -p %MOI_FITNESSE_PORT% -e 0 -o -d %MOI_DEVELOPMENT_ROOT%  %1 %2 %3 %4 %5 
popd

echo MoiStartFitNesseReal: Ends