@echo off
setlocal enabledelayedexpansion

set PROG=MoiMergeMoiProductionToAllChildrenPreview.bat
set IM=%PROG%: INFO:
set EM=%PROG%: ERROR:

set LocalWorkSpaceRoot=C:\TFS_MERGE_ADMIN
set TfCheckInNoFiles=/nThere are no pending changes matching the specified items./nNo files checked in.

echo %IM% starts

rem
rem Update local workspace files.
rem
set SourceBranch=MOI_Production
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=Integration
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=HotFix
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=NP_Stable
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=P_Stable
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=NP_BICC_Stable
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=NP_Unstable
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=P_Unstable
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

set SourceBranch=NP_BICC_Unstable
call :ProcessGet %SourceBranch%
if ERRORLEVEL 1 goto MainProcessGetFail

rem
rem Perform merges as far as possible without conflicts occurring.
rem
set SourceBranch=MOI_Production
set TargetBranch=Integration
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

set SourceBranch=MOI_Production
set TargetBranch=HotFix
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

set SourceBranch=Integration
set TargetBranch=NP_Stable
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

set SourceBranch=Integration
set TargetBranch=P_Stable
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

set SourceBranch=Integration
set TargetBranch=NP_BICC_Unstable
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

set SourceBranch=NP_Stable
set TargetBranch=NP_Unstable
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

set SourceBranch=P_Stable
set TargetBranch=P_Unstable
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

set SourceBranch=NP_BICC_Stable
set TargetBranch=NP_BICC_Unstable
call :ProcessMerge %SourceBranch% %TargetBranch%
if ERRORLEVEL 1 goto MainProcessMergeFail

echo %IM% successfully completed merging of all branches
goto MainExitOk

:MainExitOk
exit /b 0

:MainProcessGetFail
echo %EM% failure in processing get for branch %SourceBranch%
goto MainExitFail

:MainProcessMergeFail
echo %EM% failure in processing merge from branch %SourceBranch% to branch %TargetBranch%
goto MainExitFail

:MainExitFail
exit /b 1

rem ======================================================================================================
:ProcessGet
rem ======================================================================================================
setlocal

set PROG=ProcessGet
set IM=%PROG%: INFO:
set EM=%PROG%: ERROR:

call :GetPreview %1 %2 Preview
if ERRORLEVEL 1 goto ProcessGetPreviewFail
goto ProcessGetPreviewOk

:ProcessGetPreviewFail
echo %EM% failure performing Get Latest Version (preview)
goto ProcessGetExitFail

:ProcessGetPreviewOk
call :GetPreview %1 %2 Actual
if ERRORLEVEL 1 goto ProcessGetActualFail
goto ProcessGetActualOk

:ProcessGetActualFail
echo %EM% failure performing Get Latest Version (actual)
goto ProcessGetExitFail

:ProcessGetActualOk
:ProcessGetExitOk
exit /b 0

:ProcessGetExitFail
exit /b 1

rem ======================================================================================================
:ProcessMerge
rem ======================================================================================================
setlocal

set PROG=ProcessMerge
set IM=%PROG%: INFO:
set EM=%PROG%: ERROR:

call :MergePreview %1 %2 Preview
if ERRORLEVEL 1 goto ProcessMergePreviewFail
goto ProcessMergePreviewOk

:ProcessMergePreviewFail
echo %EM% failure performing Get Latest Version (preview)
goto ProcessMergeExitFail

:ProcessMergePreviewOk
call :MergePreview %1 %2 Actual
if ERRORLEVEL 1 goto ProcessMergeActualFail
goto ProcessMergeActualOk

:ProcessMergeActualFail
echo %EM% failure performing Get Latest Version (actual)
goto ProcessMergeExitFail

:ProcessMergeActualOk
call :CheckinValidate %2 Validate
if ERRORLEVEL 1 goto ProcessMergeCheckInValidateFail
goto ProcessMergeCheckInValidateOk

:ProcessMergeCheckInValidateFail
echo %EM% failure performing Check In (validate)
goto ProcessMergeExitFail

:ProcessMergeCheckInValidateOk
call :CheckinValidate %2 Actual
if ERRORLEVEL 1 goto ProcessMergeCheckInActualFail
goto ProcessMergeCheckInActualOk

:ProcessMergeCheckInActualFail
echo %EM% failure performing Check In (actual)
goto ProcessMergeExitFail

:ProcessMergeCheckInActualOk
:ProcessMergeExitOk
exit /b 1

:ProcessMergeExitFail
exit /b 1

rem ======================================================================================================
:GetPreview
rem ======================================================================================================
setlocal

set PROG=GetPreview
set IM=%PROG%: INFO:
set EM=%PROG%: ERROR:

if "%2" == "Preview" (
	echo %IM% get will be preview only
	set PreviewString=/preview
	set PreviewDescr=preview
) else (
	echo %IM% get will be actual
	set PreviewString=
	set PreviewDescr=actaul
)

echo %IM% executing Get Latest Version (%PreviewDescr%) of branch %1
tf get $/MOIInternalReleases/%1 /recursive %PreviewString%
if ERRORLEVEL 2 goto GetPreviewFail
if ERRORLEVEL 1 goto GetPreviewPartFail
goto GetPreviewExitOk

:GetPreviewFail
echo %EM% failure during Get Latest Version (%PreviewDescr%) of branch %1
goto ExitFail

:GetPreviewPartFail
echo %EM% partial failure during Get Latest Version (%PreviewDescr%) of branch %1
goto ExitFail

:GetPreviewExitOk
exit /b 0

:GetPreviewExitFail
exit /b 1

rem ======================================================================================================
:MergePreview
rem ======================================================================================================
setlocal

set PROG=MergePreview
set IM=%PROG%: INFO:
set EM=%PROG%: ERROR:

if "%3" == "Preview" (
	echo %IM% merge will be preview only
	set PreviewString=/preview
	set PreviewDescr=preview
) else (
	echo %IM% merge will be actual
	set PreviewString=
	set PreviewDescr=actaul
)

echo %IM% executing Merge (%PreviewDescr%) of branch %1 to branch %2

tf merge /recursive %PreviewString% $/MOIInternalReleases/%1 $/MOIInternalReleases/%2
if ERRORLEVEL 2 goto MergePreviewFail
if ERRORLEVEL 1 goto MergePreviewPartFail
goto MergePreviewOk

:MergePreviewFail
echo %EM% failure during Merge (%PreviewDescr%) of branch %1 to branch %2
goto MergePreviewExitFail

:MergePreviewPartFail
echo %EM% partial failure during Merge (%PreviewDescr%) of branch %1 to branch %2
goto MergePreviewExitFail

:MergePreviewOk
:MergePreviewExitOk
endlocal
exit /b 0

:MergePreviewExitFail
endlocal
exit /b 1

rem ======================================================================================================
:CheckInValidate
rem ======================================================================================================
setlocal

set PROG=CheckInValidate
set IM=%PROG%: INFO:
set EM=%PROG%: ERROR:

if "%2" == "Validate" (
	echo %IM% check-in will be validate only
	set PreviewString=/validate
	set PreviewDescr=validate
) else (
	echo %IM% check-in will be actual
	set PreviewString=
	set PreviewDescr=actaul
)

echo %IM% executing Check-In (%PreviewDescr%) of branch %1

set StdErrFile=C:\Temp\tf_checkin_validate_StdErr_%RANDOM%.txt

echo would run: tf checkin %LocalWorkspaceRoot%\%1 /recursive /noprompt /saved %PreviewString% /comment:"Check in of merge from parent branch" 2^>%StdErrFile%
rem tf checkin %LocalWorkspaceRoot%\%1 /recursive /noprompt /saved %PreviewString% /comment:"Check in of merge from parent branch" 2>%StdErrFile%
set ExitStatus=%ERRORLEVEL%
if %ExitStatus% == 100 goto CheckInValidateChkStdErr
if %ExitStatus% == 0   goto CheckInValidateExitOk
if %ExitStatus% == 1   goto CheckInValidatePartFail
if %ExitStatus% == 2   goto CheckInValidateFail
goto CheckInValidateFail

:CheckInValidateFail
echo %EM% failure during Check In (%PreviewDescr%) of branch %1
goto CheckInValidateExitFail

:CheckInValidatePartFail
echo %EM% partial failure Check In (%PreviewDescr%) of branch %1
goto CheckInValidateExitFail

:CheckInValidateChkStdErr
call :ReadFileIntoVariable %StdErrFile%
if ERRORLEVEL 1 goto CheckInValidateChkStdErrFail
goto CheckInValidateChkStdErrOk

:CheckInValidateChkStdErrFail
echo %EM% failure reading Tf.exe /checkin StdErr output
goto CheckInValidateExitFail

:CheckInValidateChkStdErrOk
if "%TfCheckInNoFiles%" == "%FileContent%" goto CheckInValidateChkStdErrNoFiles

echo %EM% StdErr output contains errors
echo %EM% StdErr output [[[
echo %EM% %FileContent%
echo %EM% ]]] and of StdErr output
goto CheckInValidateExitFail

:CheckInValidateChkStdErrNoFiles
echo %IM% no files to check into branch %2
goto CheckInValidateExitOk

:CheckInValidateExitOk
exit /b 0

:CheckInValidateExitFail
exit /b 1

rem ============================================================================================================
:ReadFileIntoVariable
rem ============================================================================================================
echo ReadFileIntoVariable: starts
echo ReadFileIntoVariable: processing file "%1"
set FileContent=

for /f "tokens=* delims=!!!" %%a in ('type %1') do (
	set FileContent=!FileContent!/n%%a
)
echo ReadFileIntoVariable: ends
exit /b 0