if "%~1" == "" goto ErrParamNoCmd
if "%~2" == "" goto ErrParamNoOutFile
goto ParamOk

:ErrParamNoCmd
echo ERROR: no command specified
goto ShowUsage

:ErrParamNoOutFile
echo ERROR: no output file stub specified
goto ShowUsage

:ShowUsage
echo ERROR: usage: OdiSvnRedirCmd.bat {command} {file-name-stub-to-redirect-stdout-and-stderr} {command-arguments}
goto ExitFail

:ParamOk
if "%~3" == "" echo INFO: no command parameters supplied
echo INFO: command to execute: "%~1"
echo INFO: file to redirect standard output to: "%~2.stdout"
echo INFO: file to redirect standard error to: "%~2.stderr"
echo INFO: command arguments: "%~3"
echo INFO: full command line to be executed: %1 %~3 ^> "%~2.stdout" 2^>"%~2.stderr" >c:\temp\debutredir.log
echo INFO: full command line to be executed: %1 %~3 ^> "%~2.stdout" 2^>"%~2.stderr"
%1 %~3 >"%~2.stdout" 2>"%~2.stderr"
if ERRORLEVEL 1 goto ExitFail

:ExitOk
exit /b 0

:ExitFail
exit /b 1