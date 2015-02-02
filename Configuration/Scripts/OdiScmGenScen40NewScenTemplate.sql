SELECT DISTINCT
       'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmOdiStartCmdBat>" OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM_TEMPORARY -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=YES -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3200
 UNION
SELECT DISTINCT
       'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmOdiStartCmdBat>" OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM_TEMPORARY -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=YES -GENERATE_TRT=NO -GENERATE_VAR=NO'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3100
 UNION
SELECT DISTINCT
       'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmOdiStartCmdBat>" OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM_TEMPORARY -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=YES -GENERATE_VAR=NO'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3600
 UNION
SELECT DISTINCT
       'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "<OdiScmOdiStartCmdBat>" OdiGenerateAllScen -PROJECT='
    || project_id
    || ' -FOLDER='
    || folder_id
    || ' -MODE=CREATE -GRPMARKER=ODISCM_TEMPORARY -MARKER=GENERATE_SCENARIO'
    || ' -GENERATE_PACK=NO -GENERATE_POP=NO -GENERATE_TRT=NO -GENERATE_VAR=YES'
  FROM odiscm_genscen_sources
 WHERE source_type_id = 3500
<OdiScmGenerateSqlStatementDelimiter>
