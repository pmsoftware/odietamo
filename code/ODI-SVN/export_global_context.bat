SET ODIBIN=C:\ODI\DEV4_oracledi_10.1.3.4.2\oracledi\bin
cd /d %ODIBIN%
startcmd.bat OdiExportObject -CLASS_NAME=SnpContext -I_OBJECT=2999 -FILE_NAME=C:\MOI\Development\ODI\ODI-SVN_install\2999.SNPContext1 -FORCE_OVERWRITE=yes -RECURSIVE_EXPORT=yes