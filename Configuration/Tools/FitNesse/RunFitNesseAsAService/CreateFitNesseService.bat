@echo on

echo CreateFitNesseService: Starts

if "%1" == "" goto abort
goto continue

:abort
echo CreateFitNesseService: environment name argument is missing
exit

:continue
echo CreateFitNesseService: received environment name argument: %1

rem
rem Determine the absolute directory path where this batch file runs
rem Note that we really on this batch file being run with the .bat extension specified!
rem This is all required to allow us to run FitNesse as a service whilst not fixing an
rem installation directory name.
rem
set PATHANDCMD=%0
set PATHNAME=%PATHANDCMD:CreateFitNesseService.bat=%
if "%PATHNAME%" == "" set PATHNAME=.
pushd %PATHNAME%
set ABSPATHNAMECreateFitNesseService=%CD%
popd
echo CreateFitNesseService: Absolute directory path of this command is: %ABSPATHNAMECreateFitNesseService%

pushd %ABSPATHNAMECreateFitNesseService%

pushd ..
call MoiFitNesseEnv.bat
popd

echo %MOI_FITNESSE_ROOT% > moi_fitnesse_root.txt
.\fart -c -r -i moi_fitnesse_root.txt \ \\
set /p MOI_FITNESSE_ROOT_FMT=<moi_fitnesse_root.txt

for /l %%a in (1,1,31) do if "!MOI_FITNESSE_ROOT_FMT:~-1!"==" " set MOI_FITNESSE_ROOT_FMT=!MOI_FITNESSE_ROOT_FMTs:~0,-1!
set MOI_FITNESSE_ROOT_FMT=%MOI_FITNESSE_ROOT_FMT:~,-1%
echo CreateFitNesseService: using "%MOI_FITNESSE_ROOT_FMT%" as formatted MOI_FITNESSE_ROOT string
del moi_fitnesse_root.txt

copy FitNesseServiceTemplate.reg TempFitNesse%1Service.reg
.\fart -c -r -i TempFitNesseDEV1Service.reg ${MOI_FITNESSE_ROOT} %MOI_FITNESSE_ROOT_FMT%
.\fart -c -r -i TempFitNesseDEV1Service.reg ${MOI_FITNESSE_ENV} %1
rem Convert the ASCII file to Unicode
CMD /U /C TYPE TempFitNesse%1Service.reg > FitNesse%1Service.reg

instsrv FitNesse%1 %MOI_FITNESSE_ROOT%\RunFitNesseAsAService\srvany.exe

regedit /s FitNesse%1Service.reg

echo reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FitNesse%1\Parameters
echo reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FitNesse%1\Parameters /v Application /t REG_SZ /d %MOI_FITNESSE_ROOT_FMT%\\dbfit-complete-20080822_%1\\MoiStartFitnesse.bat
echo reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FitNesse%1\Parameters /v AppDirectory /t REG_SZ /d %MOI_FITNESSE_ROOT_FMT%\\dbfit-complete-20080822_%1

reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FitNesse%1\Parameters
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FitNesse%1\Parameters /v Application /t REG_SZ /d %MOI_FITNESSE_ROOT_FMT%\\dbfit-complete-20080822_%1\\MoiStartFitnesse.bat
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FitNesse%1\Parameters /v AppDirectory /t REG_SZ /d %MOI_FITNESSE_ROOT_FMT%\\dbfit-complete-20080822_%1

del FitNesse%1Service.reg

popd

echo CreateFitNesseService: Ends