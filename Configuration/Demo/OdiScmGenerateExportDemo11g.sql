/* Generate a script to export the standard ODI Hypersonic SQL (HSQL) demo master and work repositories */
SELECT 'startcmd.bat OdiExportObject -CLASS_NAME=SnpModel -I_OBJECT=' || i_mod || ' -EXPORT_DIR=. -FILE_NAME=MOD_' || REPLACE(mod_name, ' ', '_') || '.xml'
  FROM snp_model
 UNION
   ALL
SELECT 'startcmd.bat OdiExportObject -CLASS_NAME=SnpProject -I_OBJECT=' || i_project || ' -EXPORT_DIR=. -FILE_NAME=PROJ_' || REPLACE(project_name, ' ', '_') || '.xml'
  FROM snp_project
 UNION
   ALL
SELECT 'startcmd.bat OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=' || i_connect || ' -EXPORT_DIR=. -FILE_NAME=CONN_' || REPLACE(con_name, ' ', '_') || '.xml'
  FROM snp_connect
 UNION
   ALL
SELECT 'startcmd.bat OdiExportObject -CLASS_NAME=SnpConnect -I_OBJECT=' || i_context || ' -EXPORT_DIR=. -FILE_NAME=CTX_' || REPLACE(context_name, ' ', '_') || '.xml'
  FROM snp_context
 UNION
   ALL
SELECT 'startcmd.bat OdiExportObject -CLASS_NAME=SnpLschema -I_OBJECT=' || i_lschema || ' -EXPORT_DIR=. -FILE_NAME=LSC_' || REPLACE(lschema_name, ' ', '_') || '.xml'
  FROM snp_lschema
 UNION
   ALL
SELECT 'startcmd.bat OdiExportObject -CLASS_NAME=SnpPschema -I_OBJECT=' || i_pschema || ' -EXPORT_DIR=. -FILE_NAME=PSC_' || REPLACE(REPLACE(REPLACE(ext_name, ' ', '_'),'/',''),'.','') || '.xml'
  FROM snp_pschema
<OdiScmGenerateSqlStatementDelimiter>
