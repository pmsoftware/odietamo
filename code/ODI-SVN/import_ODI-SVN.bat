ECHO OFF

REM Manual file to just import ODI SVN into a 
REM assumes it is run in the location of a bin dir, with ODI params pointing at the deired tgt



SET SRCDIR=C:\$WELLKNOWNINSURER_CODE\TFS_SOURCE\MOIInternalReleases\SourceCode\source_for_release\ODI-SVN_install
SET LOGDIR=c:\temp
SET ODIBIN=C:\$WELLKNOWNINSURER_DEPLOY\oracledi_10.1.3.5.2_hypersonicdemo\bin
SET WORKREPNAME=WORKREP

cd /d %ODIBIN%

REM import CONNECTS (pops?)




call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\6110.SnpConnect -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\6110.log 2>&1
call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\10110.SnpConnect -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\10110.log 2>&1
call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\11110.SnpConnect -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\11110.log 2>&1


call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\1110.SnpLschema -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\1110.log 2>&1
call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\2110.SnpLschema -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\2110.log 2>&1
call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\3110.SnpLschema -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\3110.log 2>&1

call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\2999.SnpContext -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\2999.log 2>&1



REM - Import whole project
call startcmd.bat OdiImportObject  -FILE_NAME=%SRCDIR%\PROJ_ODI-SVN.xml -WORK_REP_NAME=%WORKREPNAME%  -IMPORT_MODE=SYNONYM_INSERT_UPDATE > %LOGDIR%\proj.log 2>&1

