DECLARE
BEGIN   
    FOR c_repo_obj IN (
                      SELECT owner
                           , object_name
                           , subobject_name
                           , object_type
                           , CASE WHEN object_type = 'TABLE'
                                  THEN ' CASCADE CONSTRAINTS'
                                  ELSE ''
                              END
                                 AS command_tail
                        FROM (
                             SELECT log_owner
                                        AS owner
                                  , master
                                        AS object_name
                                  , NULL
                                        AS subobject_name
                                  , 'MATERIALIZED VIEW LOG ON'
                                        AS object_type
                               FROM all_mview_logs
                              UNION
                             SELECT owner
                                  , object_name
                                  , subobject_name
                                  , object_type
                               FROM all_objects
                              WHERE
                                NOT (
                                    -- Ignore Materialised View log tables.
                                    -- These have a table name of LIKE 'MLOG$_'.
                                    object_type = 'TABLE'
                                AND (
                                    owner
                                  , object_name
                                    )
                                 IN (
                                    SELECT log_owner
                                         , log_table
                                      FROM all_mview_logs
                                     WHERE UPPER(log_owner) = UPPER('<OdiScmPhysicalSchemaName>')
                                    )
                                    )
                                AND
                                NOT (
                                    -- Ignore Materialised View tables.
                                    object_type = 'TABLE'
                                AND (
                                    owner
                                  , object_name
                                    )
                                 IN (
                                    SELECT owner
                                         , mview_name
                                      FROM all_mviews
                                     WHERE UPPER(owner) = UPPER('<OdiScmPhysicalSchemaName>')
                                    )
                                    )
                                AND
                                NOT (
                                    -- Ignore Updatable Materialised View tables.
                                    object_type = 'TABLE'
                                AND object_name LIKE 'RUPD$_'
                                    )
                                AND
                                NOT (
                                    -- We drop these types of object when we drop their parent object.
                                    object_type
                                 IN (
                                    'LOB'
                                  , 'INDEX'
                                    )
                                    )
                              UNION
                             SELECT owner
                                  , db_link
                                        AS object_name
                                  , NULL
                                        AS subobject_name
                                  , 'DATABASE LINK'
                                        AS object_type
                               FROM all_db_links
                             )
                       WHERE UPPER(owner) = UPPER('<OdiScmPhysicalSchemaName>')
                       ORDER
                          BY CASE WHEN object_type = 'TRIGGER'
                                  THEN 100
                                  WHEN object_type = 'PROCEDURE'	-- Stand alone procedures.
                                   AND subobject_name IS NULL
                                  THEN 200
                                  WHEN object_type = 'FUNCTION'		-- Stand alone functions.
                                   AND subobject_name IS NULL
                                  THEN 300
                                  WHEN object_type = 'PROCEDURE'	-- Package procedures.
                                   AND subobject_name IS NOT NULL
                                  THEN 400
                                  WHEN object_type = 'FUNCTION'		-- Package functions.
                                   AND subobject_name IS NOT NULL
                                  THEN 500
                                  WHEN object_type = 'PACKAGE'
                                  THEN 600
                                  WHEN object_type = 'PACKAGE BODY'
                                  THEN 700
                                  WHEN object_type = 'VIEW'
                                  THEN 800
                                  WHEN object_type = 'TABLE'
                                  THEN 900
                                  WHEN object_type = 'DATABASE LINK'
                                  THEN 1000
                                  ELSE 9999
                              END
                      )
    LOOP
        BEGIN
            IF (c_repo_obj.object_type != 'DATABASE LINK')
            THEN
                dbms_output.put_line('Dropping object ' || c_repo_obj.owner || '.' || c_repo_obj.object_name || ' of type ' || c_repo_obj.object_type);
                EXECUTE IMMEDIATE('DROP ' || c_repo_obj.object_type || ' ' || c_repo_obj.owner || '.' || c_repo_obj.object_name || c_repo_obj.command_tail);
            ELSE
                IF (USER = c_repo_obj.owner)
                THEN
                    dbms_output.put_line('Dropping database link ' || c_repo_obj.object_name || ' owned by ' || c_repo_obj.owner);
                    EXECUTE IMMEDIATE('DROP DATABASE LINK ' || c_repo_obj.object_name);
                ELSE
                    raise_application_error(-20000, 'Cannot drop database link ' || c_repo_obj.owner || '.' || c_repo_obj.object_name || ' as it is owned by a different user to the logged in user (' || user || ')');
                END IF;
            END IF;
        EXCEPTION
            WHEN OTHERS
                THEN raise_application_error(-20000, 'Cannot drop ' || c_repo_obj.object_type || ' ' || c_repo_obj.owner || '.' || c_repo_obj.object_name);
        END;
    END LOOP;
END;
/
