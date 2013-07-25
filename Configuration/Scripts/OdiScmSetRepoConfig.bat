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

if "%ODI_SCM_INI%" == "" (
	echo %EM% no configuration INI file specified in environment variable ODI_SCM_INI
	goto ExitFail
) else (
	echo %IM% using configuration INI file ^<%ODI_SCM_INI%^> 
)

rem
rem Source the temporary working directory.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory
	goto ExitFail
)

rem
rem Define a temporary empty file.
rem
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetEmptyFile.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary empty file
	goto ExitFail
)

rem
rem Configure the ODI-SCM repository infrastructure - SCM actions metadata.
rem
set TEMPFILE=%TEMPDIR%\%RANDOM%_OdiScmImportOdiScm_Configure.sql

cat "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmConfigureRepositoryMetadataTemplate.sql" | sed s/"<OdiScmOdiUserName>"/%ODI_USER%/ > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% substituting ODI user name
	goto ExitFail
)

cat "%TEMPFILE%" | sed s/"<SCMSystemTypeName>"/%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_TYPE_NAME%/ > "%TEMPFILE%2"
if ERRORLEVEL 1 (
	echo %EM% substituting SCM system type name
	goto ExitFail
)

if "%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_TYPE_NAME%" == "" (
	set SCM_ADD_FILE_COMMAND=
	set SCM_BASIC_COMMAND=
	set SCM_CHECK_FILE_IN_SOURCE_CONTROL_COMMAND=
	set SCM_CHECK_OUT_COMMAND=
	set SCM_REQUIRES_CHECK_OUT=
	set SCM_WC_CONFIG_DELETE_FILE_COMMAND=
) else (
	if "%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_TYPE_NAME%" == "TFS" (
		set SCM_ADD_FILE_COMMAND=tf.exe add %%s \/lock:none
		set SCM_BASIC_COMMAND=tf.exe \/?
		set SCM_CHECK_FILE_IN_SOURCE_CONTROL_COMMAND=tf.exe dir %%s
		set SCM_CHECK_OUT_COMMAND=tf.exe checkout \/lock:none %%s
		set SCM_REQUIRES_CHECK_OUT=Yes
		set SCM_WC_CONFIG_DELETE_FILE_COMMAND=tf delete %%s
	) else (
		if "%ODI_SCM_SCM_SYSTEM_SCM_SYSTEM_TYPE_NAME%" == "SVN" (
			set SCM_ADD_FILE_COMMAND=svn add %%s
			set SCM_BASIC_COMMAND=svn help
			set SCM_CHECK_FILE_IN_SOURCE_CONTROL_COMMAND=svn info %%s
			set SCM_CHECK_OUT_COMMAND=
			set SCM_REQUIRES_CHECK_OUT=No
			set SCM_WC_CONFIG_DELETE_FILE_COMMAND=svn delete %%s
		)
	)
)

cat "%TEMPFILE%2" | sed s/"<SCMAddFileCommand>"/"%SCM_ADD_FILE_COMMAND%"/g > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% substituting SCM add file command
	goto ExitFail
)

cat "%TEMPFILE%" | sed s/"<SCMBasicCommand>"/"%SCM_BASIC_COMMAND%"/g > "%TEMPFILE%2"
if ERRORLEVEL 1 (
	echo %EM% substituting SCM basic command
	goto ExitFail
)

cat "%TEMPFILE%2" | sed s/"<SCMCheckFileInSourceControlCommand>"/"%SCM_CHECK_FILE_IN_SOURCE_CONTROL_COMMAND%"/g > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% substituting SCM check file under source control command
	goto ExitFail
)

cat "%TEMPFILE%" | sed s/"<SCMCheckOutCommand>"/"%SCM_CHECK_OUT_COMMAND%"/g > "%TEMPFILE%2"
if ERRORLEVEL 1 (
	echo %EM% substituting SCM check out command
	goto ExitFail
)

cat "%TEMPFILE%2" | sed s/"<SCMRequiresCheckOut>"/"%SCM_REQUIRES_CHECK_OUT%"/g > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% substituting SCM system requires file check out indicator
	goto ExitFail
)

cat "%TEMPFILE%" | sed s/"<SCMWorkingCopyDeleteFileCommand>"/"%SCM_WC_CONFIG_DELETE_FILE_COMMAND%"/g > "%TEMPFILE%2"
if ERRORLEVEL 1 (
	echo %EM% substituting SCM working copy file deletion command
	goto ExitFail
)

cat "%TEMPFILE%2" | sed s/"<ExportRefPhysArchOnly>"/"%ODI_SCM_GENERATE_EXPORT_REF_PHYS_ARCH_ONLY%"/g > "%TEMPFILE%"
if ERRORLEVEL 1 (
	echo %EM% substituting OdiScm export only reference physical architecture indicator
	goto ExitFail
)

rem
rem Define files used to capture standard output and standard error channels.
rem
set TEMPFILESTR=%RANDOM%
set STDOUTFILE=%TEMPDIR%\%TEMPFILESTR%_OdiScmSetRepoConfig_StdOut.log
set STDERRFILE=%TEMPDIR%\%TEMPFILESTR%_OdiScmSetRepoConfig_StdErr.log

rem
rem Run the generated ODI-SCM repository infrastructure configuration script.
rem
echo %IM% configuring ODI-SCM metadata
call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmJisqlRepo.bat^" %TEMPFILE% %STDOUTFILE% %STDERRFILE%
if ERRORLEVEL 1 (
	echo %EM% batch file OdiScmJisqlRepo.bat returned non-zero ERRORLEVEL
	echo %IM% StdErr content:
	type %STDERRFILE%
	goto ExitFail
)

rem
rem The called batch file has returned a 0 errorlevel but check for anything in the stderr file.
rem
echo %IM% Batch file OdiScmJisqlRepo.bat returned zero ERRORLEVEL
echo fc %EMPTYFILE% %STDERRFILE%
fc %EMPTYFILE% %STDERRFILE% >NUL 2>NUL
if ERRORLEVEL 1 (
	echo %IM% Batch file OdiScmJisqlRepo.bat returned StdErr content:
	type %STDERRFILE%
	goto ExitFail
)

:ExitOk
exit %IsBatchExit% 0

:ExitFail
exit %IsBatchExit% 1