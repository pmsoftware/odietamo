@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0

echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if /i not "%ARGV1%" == "EMPTY" (
	if /i not "%ARGV1%" == "LATEST" (
		echo %EM% invalid initial state specified. Specify EMPTY or LATEST 1>&2
		echo %EM% usage: %PROC% ^<EMPTY ^| LATEST^> ^[^<TFS Workspace Name^>^] 1>&2
		goto ExitFail
	)
)

if /i "%ARGV1%" == "EMPTY" (
	if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "TFS" (
		set INITREV=/version:C1
	) else (
		if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "SVN" (
			set INITREV=--revision 0
		) else (
			echo %EM% unsupported SCM system type ^<%ODI_SCM_SCM_SYSTEM_TYPE_NAME%^> 1>&2
			goto ExitFail
		)
	)
) else (
	if /i "%ARGV1%" == "LATEST" (
		if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "TFS" (
			set INITREV=/version:T
		) else (
			if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "SVN" (
				set INITREV=--revision HEAD
			) else (
				echo %EM% unsupported SCM system type ^<%ODI_SCM_SCM_SYSTEM_TYPE_NAME%^> 1>&2
				goto ExitFail
			)
		)
	)
)

if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "TFS" (
	if not %ARGC% == 2 (
		echo %EM% workspace name must be specified for TFS working copies 1>&2
		echo %EM% usage: %PROC% ^<EMPTY ^| LATEST^> ^[^<TFS Workspace Name^>^] 1>&2
		goto ExitFail
	)
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

rem
rem Ensure the CWD is not the working copy tree to be destroyed.
rem
set WCROOT=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT:/=\%
set WCROOTFS=%WCROOT:/=\%
set CDFS=%CD:/=\%
set TEMPGREPOUT=%TEMPDIR%\%PROC%_grep.txt
echo %WCROOTFS% | grep -i "^%CDFS%" >"%TEMPGREPOUT%"
set TEMPEMPTYFILE=%TEMPDIR%\%PROC%_Empty.txt

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmCreateEmptyFile.bat^" /p "%TEMPEMPTYFILE%"
if ERRORLEVEL 1 (
	echo %EM% creating empty file ^<%TEMPEMPTYFILE%^> 1>&2
	goto ExitFail
)

fc "%TEMPGREPOUT%" "%TEMPEMPTYFILE%" >NUL
if ERRORLEVEL 1 (
	echo %EM% current working directory is in the working copy root directory that will be destroyed 1>&2
	goto ExitFail
)

rem
rem Destroy any existing working copy directory tree.
rem
if EXIST "%WCROOT%" (
	echo %IM% making all files writable in existing working copy root directory ^<%WCROOT%^>
	chmod -R a+w "%WCROOT%"
	if ERRORLEVEL 1 (
		echo %EM% making existing working copy directory tree ^<%WCROOT%^> writable 1>&2
		goto ExitFail
	)
	echo %IM% deleting existing working copy directory tree ^<%WCROOT%^>
	rem Note that RD/RMDIR does not return a non zero exit status on failure, in all cases.
	rem We use || (error action) to resolve the issue ().
	rem See for details: http://stackoverflow.com/questions/11137702/batch-exit-code-for-rd-is-0-on-error-as-well
	rd /q /s "%WCROOT%"
	if ERRORLEVEL 1 (
		echo %EM% deleting existing working copy directory tree ^<%WCROOT%^> 1>&2
		goto ExitFail
	)
	if EXIST "%WCROOT%" (
		echo %EM% verifying deletion of working copy directory tree ^<%WCROOT%^> 1>&2
		goto ExitFail
	)
)

rem
rem Create the working copy root directory.
rem
echo %IM% creating working copy root directory ^<%WCROOT%^>
md "%WCROOT%"
if ERRORLEVEL 1 (
	echo %EM% creating working copy root directory ^<%WCROOT%^> 1>&2
	goto ExitFail
)

cd /d "%WCROOT%"
if ERRORLEVEL 1 (
	echo %EM% cannot change working directory to working copy root directory ^<%WCROOT%^> 1>&2
	goto ExitFail
)

if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "SVN" (
	goto GetCode
)

rem
rem Delete the existing workspace if present.
rem
set TEMPGREPOUT=%TEMPDIR%\%PROC%_grep.txt
rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
call tf workspaces >%TEMPGREPOUT%
grep "%ARGV2%" %TEMPGREPOUT% >%TEMPGREPOUT%2
fc "%TEMPGREPOUT%2" "%TEMPEMPTYFILE%" >NUL
if ERRORLEVEL 1 (
	rem
	rem An existing workspace has been detected so destroy it.
	rem
	echo %IM% deleting existing TFS workspace ^<%ARGV2%^>
	call tf workspace /delete /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% %ARGV2% /noprompt
	if ERRORLEVEL 1 (
		echo %EM% creating TFS workspace ^<%ARGV2%^> 1>&2
		goto ExitFail
	)
)

rem
rem Ensure the workspace does not exist.
rem
rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
call tf workspaces >%TEMPGREPOUT%
grep "%ARGV2%" %TEMPGREPOUT% >%TEMPGREPOUT%
fc "%TEMPGREPOUT%" "%TEMPEMPTYFILE%" >NUL
if ERRORLEVEL 1 (
	echo %EM% existing TFS workspace ^<%ARGV2%^> detected 1>&2
	goto ExitFail
)

rem
rem Create a TFS workspace.
rem
echo %IM% creating TFS workspace ^<%ARGV2%^>
rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
call tf workspace /new /noprompt %ARGV2% /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%
if ERRORLEVEL 1 (
	echo %EM% creating TFS workspace ^<%ARGV2%^> 1>&2
	goto ExitFail
)

rem Check for the existence of a default folder mapping for "$/" (created by tf.exe but not tf.cmd).
set TEMPFILE=%TEMPDIR%\OdiScmCreateWorkingCopyTfsFolderMappingCheck.txt
echo %IM% checking for existence of default folder mapping in workspace ^<%ARGV2%^>
rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
call tf workfold /workspace:%ARGV2% /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% verifying mapping for TFS workspace ^<%ARGV2%^> to directory ^<%WCROOT%^> 1>&2
	goto ExitFail
)

grep \$\/ "%TEMPFILE%" >NUL 2>&1
set EL=%ERRORLEVEL%
if "%EL%" == "1" (
	echo %IM% no default folder mapping detected for TFS workspace ^<%ARGV2%^>
) else (
	echo %IM% deleting default folder mapping for TFS workspace ^<%ARGV2%^>
	rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
	call tf workfold /noprompt /unmap /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% /workspace:%ARGV2% $/
	if ERRORLEVEL 1 (
		echo %EM% deleting default folder mapping for TFS workspace ^<%ARGV2%^> 1>&2
		goto ExitFail
	)
)

echo %IM% creating mapping for TFS workspace ^<%ARGV2%^> to branch URL ^<%ODI_SCM_SCM_SYSTEM_BRANCH_URL%^>
rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
call tf workfold /map "%ODI_SCM_SCM_SYSTEM_BRANCH_URL%" "%WCROOT%" /workspace:%ARGV2% /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%
if ERRORLEVEL 1 (
	echo %EM% creating mapping for TFS workspace ^<%ARGV2%^> to branch URL ^<%ODI_SCM_SCM_SYSTEM_BRANCH_URL%^> 1>&2
	goto ExitFail
)

set TEMPFILE=%TEMPDIR%\OdiScmCreateWorkingCopyTfsWorkspaceCheck.txt
echo %IM% verifying mapping for TFS workspace ^<%ARGV2%^> to directory ^<%WCROOT%^>
rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
call tf workfold /workspace:%ARGV2% /collection:%ODI_SCM_SCM_SYSTEM_SYSTEM_URL% > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% verifying mapping for TFS workspace ^<%ARGV2%^> to directory ^<%WCROOT%^> 1>&2
	goto ExitFail
)

rem
rem Note the "\" to escape the "$" in TFS URLs.
rem
cat "%TEMPFILE%" | grep "\%ODI_SCM_SCM_SYSTEM_BRANCH_URL%" | cut -f3 -d" " >"%TEMPFILE%"2
set /p TFSWORKMAPPEDDIR=<"%TEMPFILE%"2

if /i not "%TFSWORKMAPPEDDIR%" == "%WCROOT%" (
	echo %EM% mismatched directory names whilst verifying mapping for TFS workspace ^<%ARGV2%^> 1>&2
	echo %EM% expected directory name ^<%WCROOT%^> actual directory name ^<%TFSWORKMAPPEDDIR%^> 1>&2
	goto ExitFail
)

:GetCode
if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "SVN" (
	echo %IM% creating SVN working copy
	svn checkout %ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL% %INITREV%
	if ERRORLEVEL 1 (
		echo %EM% checking out from SCM system from URL ^<%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%/%ODI_SCM_SCM_SYSTEM_BRANCH_URL%^> 1>&2
		goto ExitFail
	)
) else (
	echo %IM% getting contents from SCM repository for TFS workspace ^<%ARGV2%^>
	rem Note that we use "call" to invoke "tf" as is this is "tf.cmd" (TEE) then any EXIT in "tf.cmd" needs to be correctly handled.
	call tf get %ODI_SCM_SCM_SYSTEM_BRANCH_URL% %INITREV% /recursive /force /noprompt
	if ERRORLEVEL 1 (
		echo %EM% getting contents from SCM repository for TFS workspace ^<%ARGV2%^> 1>&2
		echo %EM% current working directory is ^<%CD%^> 1>&2
		goto ExitFail
	)
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1