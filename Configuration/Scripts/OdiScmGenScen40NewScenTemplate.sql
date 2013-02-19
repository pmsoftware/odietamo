SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISVN_AUTOMATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=YES -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3200
   AND marker_group_code = 'ODISVN_AUTOMATION'
 UNION
SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISVN_AUTOMATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=YES -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3100
   AND marker_group_code = 'ODISVN_AUTOMATION'
 UNION
SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISVN_AUTOMATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3600
   AND marker_group_code = 'ODISVN_AUTOMATION'  
 UNION
SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISVN_AUTOMATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=YES'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3500
   AND marker_group_code = 'ODISVN_AUTOMATION'
 UNION
       --
       -- Repeat for the deprecated marker groups.
       --
SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=YES -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3200
   AND marker_group_code = 'MOI_CODE_RECONCILLIATION'
 UNION
SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=YES -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3100
   AND marker_group_code = 'MOI_CODE_RECONCILLIATION'
 UNION
SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3600
   AND marker_group_code = 'MOI_CODE_RECONCILLIATION'
 UNION
SELECT DISTINCT
       'call <OdiScmStartCmdBat> OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=MOI_CODE_RECONCILLIATION -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=YES'
  FROM odisvn_genscen_sources
 WHERE source_type_id = 3500
   AND marker_group_code = 'MOI_CODE_RECONCILLIATION'
/