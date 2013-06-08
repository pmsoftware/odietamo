@echo off
set FN=OdiScmGet
set IM=%FN%: INFO:
set EM=%FN%: ERROR:

if /i "%1" == "/b" (
	set IsBatchExit=/b
	shift
) else (
	set IsBatchExit=
)

PowerShell -Command "& { %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGet.ps1 ; exit $LASTEXITCODE }"
exit %IsBatchExit% %ERRORLEVEL%