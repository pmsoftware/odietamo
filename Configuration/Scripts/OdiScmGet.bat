@echo off
set FN=OdiScmGet
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

PowerShell -Command "& { %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.ps1 ; exit $LASTEXITCODE }"