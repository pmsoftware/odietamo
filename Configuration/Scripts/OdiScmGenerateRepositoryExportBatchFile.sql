SELECT 'call startcmd.bat OdiExportObject -I_OBJECT=' || i_object || ' "-FILE_NAME=C:\Temp\' || file_name || '" -CLASS_NAME=' || class_name || ' -FORCE_OVERWRITE=yes -RECURSIVE_EXPORT=yes'
  FROM (
       --
       -- Master repository objects.
       --
       SELECT i_connect
                  AS i_object
            , 'CON_' || REPLACE(REPLACE(REPLACE(con_name, '/', '_'), '.', '_'), ' ', '_') || '.xml'
                  AS file_name
            , 'SnpConnect'
                  AS class_name
         FROM snp_connect
        UNION
       SELECT i_pschema
            , 'PS_' || REPLACE(REPLACE(REPLACE(ext_name, '/', '_'), '.', '_'), ' ', '_') || '.xml'
            , 'SnpPschema'
         FROM snp_pschema
        UNION
       SELECT i_context
            , 'CTX_' || context_code || '.xml'
            , 'SnpContext'
         FROM snp_context
        UNION
       SELECT i_lschema
            , 'LS_' || lschema_name || '.xml'
            , 'SnpLschema'
         FROM snp_lschema
        UNION
       SELECT i_techno
            , 'TECH_' || tech_int_name || '.xml'
            , 'SnpTechno'
         FROM snp_techno
       )
