/* Generate a script to export the standard ODI Hypersonic SQL (HSQL) demo master and work repositories */
SELECT 'startcmd.bat -CLASS_NAME=SnpModel -I_OBJECT=' || i_mod || ' -FILE_NAME=MOD_' || REPLACE(mod_name, ' ', '_') || '.xml -RECURSIVE_EXPORT=yes'
  FROM snp_model
 UNION
   ALL
SELECT 'startcmd.bat -CLASS_NAME=SnpProject -I_OBJECT=' || i_project || ' -FILE_NAME=PROJ_' || REPLACE(project_name, ' ', '_') || '.xml -RECURSIVE_EXPORT=yes'
  FROM snp_project
 UNION
   ALL
SELECT 'startcmd.bat -CLASS_NAME=SnpConnect -I_OBJECT=' || i_connect || ' -FILE_NAME=CON_' || REPLACE(con_name, ' ', '_') || '.xml -RECURSIVE_EXPORT=no'
  FROM snp_connect
 UNION
   ALL
SELECT 'startcmd.bat -CLASS_NAME=SnpContext -I_OBJECT=' || i_context || ' -FILE_NAME=CTX_' || REPLACE(context_name, ' ', '_') || '.xml -RECURSIVE_EXPORT=yes'
  FROM snp_context
 UNION
   ALL
SELECT 'startcmd.bat -CLASS_NAME=SnpLschema -I_OBJECT=' || i_lschema || ' -FILE_NAME=LS_' || REPLACE(lschema_name, ' ', '_') || '.xml -RECURSIVE_EXPORT=yes'
  FROM snp_lschema
 UNION
   ALL
SELECT 'startcmd.bat -CLASS_NAME=SnpPschema -I_OBJECT=' || i_pschema || ' -FILE_NAME=PS_' || REPLACE(REPLACE(REPLACE(ext_name, ' ', '_'),'/',''),'.','') || '.xml -RECURSIVE_EXPORT=yes'
  FROM snp_pschema
;