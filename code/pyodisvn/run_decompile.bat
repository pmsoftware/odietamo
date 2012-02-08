REM decompile Scernarios and compare
ECHO OFF

set PYODISVN=C:\$WELLKNOWNINSURER_DEPLOY\pyodisvn
set DATADIR=D:\downloads\ODI\the_trough

cd /d %PYODISVN%
REM python decompile_diff_and_report.py logjob
python decompile_xml2sql.py
python decompile_diff_and_report.py mkdiff

cd /d %DATADIR%
call diffme_codework-exe.bat

cd /d %PYODISVN%
python decompile_diff_and_report.py mkreport

