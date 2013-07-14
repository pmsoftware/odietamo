rem *************************************************************
rem SetDateTimeStrings
rem *************************************************************
rem
rem Define unique file name suffixes.
rem
for /f "tokens=1,2,3 delims=/ " %%A in ('date /t') do ( 
	set SDTSDay=%%A
	set SDTSMonth=%%B
	set SDTSYear=%%C
	set SDTSYYYYMMDD=%%C%%B%%A
)
rem
rem Remove trailing spaces.
rem
for /f "tokens=1 delims= " %%X in ('echo %SDTSYYYYMMDD%') do set YYYYMMDD=%%X

for /f "tokens=1,2,3,4 delims=.:" %%A in ('echo %time%') do (
	set SDTSHour=%%A
	set SDTSMin=%%B
	set SDTSSec=%%C
	set SDTSSub=%%D
	set SDTSHHMMSSFF=%%A%%B%%C%%D
)
rem
rem Remove trailing spaces.
rem
for /f "tokens=1 delims= " %%X in ('echo %SDTSHHMMSSFF%') do set HHMMSSFF=%%X

exit /b 0
