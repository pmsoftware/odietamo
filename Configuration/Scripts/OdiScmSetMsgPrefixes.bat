rem echo DEBUG: entering OdiScmSetMsgPrefixes
rem *************************************************************
rem SetMsgPrexixes
rem *************************************************************
for %%F in ("%1") do set PROC=%%~nxF

set PROC=%PROC:.bat=%
set IM=%PROC%: INFO:
set EM=%PROC%: ERROR:
set WM=%PROC%: WARNING:
set DM=%PROC%: DEBUG:
