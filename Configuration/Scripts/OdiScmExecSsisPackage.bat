@echo off

rem
rem Check basic environment requirements.
rem
if "%ODI_SCM_HOME%" == "" (
	echo OdiScm: ERROR: no OdiScm home directory specified in environment variable ODI_SCM_HOME
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0
echo %IM% starts

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*
if ERRORLEVEL 1 (
	echo %EM% processing script arguments 1>&2
	goto ExitFail
)

if "%ARGV1%" == "" (
	echo %EM% missing package path/name argument 1>&2
	call :ShowUsage
	goto ExitFail
)

set LASTARG=1
set OTHERARGS=%ARGVALL%

set INHERITCONTEXT=Y

if not "%ARGV2%" == "" (
	if not "%ARGV2%" == "OdiScmInherit" (
		set INHERITCONTEXT=N
		echo %IM% execution context ^<%ARGV2%^> specified to override environment context ^<%ODI_SCM_SSIS_EXECUTION_ENVIROMENT%^>
		set EXECONTEXT=%ARGV2%
		set LASTARG=2
	)
)

if "%INHERITCONTEXT%" == "Y" (
	echo %IM% using execution context ^<%ODI_SCM_SSIS_EXECUTION_ENVIROMENT%^> from environment
	set EXECONTEXT=%ODI_SCM_SSIS_EXECUTION_ENVIROMENT%
)

if "%ODI_SCM_SSIS_SERVER_NAME%" == ""
	echo %EM% integration services server name not specified in environment variable ^<ODI_SCM_SSIS_SERVER_NAME^> 1>&2
	goto ExitFail
)

call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetTempDir.bat"
if ERRORLEVEL 1 (
	echo %EM% creating temporary working directory 1>&2
	goto ExitFail
)

set /a SSISFIRSTVAR=%LASTARG% + 1
set OUTPARAMS=

setlocal enabledelayedexpansion
set VARORVAL=VAR

for /l %%n in (%SSISFIRSTVAR%, 1, %ARGC%) do (
	set PARAM=ARGV%%n
	call :GetArgStringDynamic !PARAM!
	for /f "tokens=1,2 delims=;" %%g in ("!OUTSTRING!") do (
		set VARNAME=%%g
		set VARVAL=%%h
	)
	if "!OUTPARAMS!" == "" (
		set OUTPARAMS=/Parameter 
	) else (
		set OUTPARAMS=!OUTPARAMS! /Parameter 
	)
	set OUTPARAMS=!OUTPARAMS!"!VARNAME!";"!VARVAL!"
)

set SSISVARVALS=%OUTPARAMS%
set DTEXECCMD=dtexec /ISServer "\SSISDB\%EXECONTEXT%\%ARGV1%" /Server "%ARGV2%" /Parameter "$ServerOption::SYNCHRONIZED(Boolean)";True

if not "%SSISVARVALS%" == "" (
	set DTEXECCMD=%DTEXECCMD% %SSISVARVALS%
)

echo %IM% executing dtexec command ^<%DTEXECCMD%^>
%DTEXECCMD%
set EL=%ERRORLEVEL%

if %EL% == 6 (
	echo %EM% The utility encountered an internal error of syntactic or semantic errors in the command line
	goto ExitFail
) else (
	if %EL% == 5 (
		echo %EM% The utility was unable to load the requested package. The Package could not be loaded
		goto ExitFail
	) else (
		if %EL% == 4 (
			echo %EM% The utility was unable to locate the requested package. The Package could not be found
			goto ExitFail
		) else (
			if %EL% == 3 (
				echo %EM% The Package was cancelled by user
				goto ExitFail
			) else (
				if %EL% == 1 (
					echo %EM% The Package failed
					goto ExitFail
				) else (
					if %EL% GTR 0 (
						echo %EM% Unrecognised exit status ^<%EL%^>
						goto ExitFail
					)
				)
			)
		)
	)
)

:ExitOk
echo %IM% ends
exit %IsBatchExit% 0

:ExitFail
echo %EM% ends 1>&2
exit %IsBatchExit% 1

rem ===============================================
rem ==           S U B R O U T I N E S           ==
rem ===============================================

rem -----------------------------------------------
:ShowUsage
rem -----------------------------------------------
echo %EM% usage: %PROC% ^<SSIS Package Path and Name^> [^<Execution Environment Name^>] [[^<SSIS Property Assignment 1^>]...[^<SSIS Property Assignment N>]] 1>&2
echo %EM%      : default SSIS Execution Environment Name is value of environment variable ODI_SCM_SSIS_EXECUTION_ENVIROMENT 1>&2
echo %EM%      : NOTE: variable assignments are specified as VAR=VAL and must be enclosed in double quotes 1>&2
goto :eof

rem -----------------------------------------------
:GetArgStringDynamic
rem -----------------------------------------------
set VARNAME=%1
set VARVAL=%%%VARNAME%%%
call set OUTSTRING=%VARVAL%
goto :eof