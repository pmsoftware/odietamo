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

if /i not "%ARGV1%" == "all" (
	if /i not "%ARGV1%" == "odi" (
		if /i not "%ARGV1%" == "ddl" (
			if /i not "%ARGV1%" == "ddl-patch" (
				if /i not "%ARGV1%" == "spl" (
					if /i not "%ARGV1%" == "dml" (
						echo %EM% invalid generation type ^<%ARGV1%^> specified 1>&2
						echo %IM% valid options: all ^| odi ^| ddl ^| ddl-patch ^| spl ^| dml
						goto ExitFail
					)
				)
			)
		)
	)
)

PowerShell -Command "& { %ODI_SCM_HOME%\Configuration\Scripts\OdiScmGenImport.ps1 %ARGV1%; exit $LASTEXITCODE }"
exit %IsBatchExit% %ERRORLEVEL%

:ExitFail
exit %IsBatchExit% 1
