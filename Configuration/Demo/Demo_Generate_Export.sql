SELECT '-CLASS_NAME=SnpModel -I_OBJECT=' || i_mod || ' -FILE_NAME=MOD_' || REPLACE(mod_name, ' ', '_') || '.xml'
  FROM snp_model
 UNION
   ALL
SELECT '-CLASS_NAME=SnpProject -I_OBJECT=' || i_project || ' -FILE_NAME=PROJ_' || REPLACE(project_name, ' ', '_') || '.xml'
  FROM snp_project
 UNION
   ALL
SELECT '-CLASS_NAME=SnpConnect -I_OBJECT=' || i_connect || ' -FILE_NAME=CON_' || REPLACE(con_name, ' ', '_') || '.xml'
  FROM snp_connect
 UNION
   ALL
SELECT '-CLASS_NAME=SnpConnect -I_OBJECT=' || i_context || ' -FILE_NAME=CTX_' || REPLACE(context_name, ' ', '_') || '.xml'
  FROM snp_context


  select * from snp_context

