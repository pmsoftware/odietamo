SELECT DISTINCT
       'call <OdiScmOdiStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=YES -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3200
   AND marker_group_code = 'ODISCM'
 UNION
SELECT DISTINCT
       'call <OdiScmOdiStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=YES -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3100
   AND marker_group_code = 'ODISCM'
 UNION
SELECT DISTINCT
       'call <OdiScmOdiStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3600
   AND marker_group_code = 'ODISCM'  
 UNION
SELECT DISTINCT
       'call <OdiScmOdiStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=YES'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3500
   AND marker_group_code = 'ODISCM'
/