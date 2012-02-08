ECHO OFF

set ODI_ROOT=C:\$WELLKNOWNINSURER_DEPLOY\oracledi_10.1.3.5.2_hypersonicdemo
xcopy /Y /E /I  %ODI_ROOT%\demo\hsql %ODI_ROOT%\demo\hsql_clean

cd %ODI_ROOT%\bin
call startdemo.bat
PAUSE

ECHO ON
ECHO Testing your setup.  A file should appear in c:\testfile.xml.  if it does, click ok.
cd %ODI_ROOT%\bin
call startcmd.bat OdiExportObject -CLASS_NAME=SnpPop -I_OBJECT=3002 -FILE_NAME="c:\testfile.xml" -FORCE_OVERWRITE=yes -RECURSIVE_EXPORT=No
ECHO Have run the test, if you want to install ODI-SVN into the demo servers, click ok
pause

SET SRCDIR=C:\$WELLKNOWNINSURER_CODE\TFS_SOURCE\MOIInternalReleases\SourceCode\source_for_release\ODI-SVN_install
cd %SRCDIR%
call import_ODI-SVN.bat
