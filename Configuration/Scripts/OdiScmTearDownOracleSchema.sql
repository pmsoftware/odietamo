--SET SERVER OUTPUT ON SIZE 10000000;

DECLARE
BEGIN   
    FOR c_repo_obj IN (
                      SELECT object_name
                           , subobject_name
                           , object_type
                           , CASE WHEN object_type = 'TABLE'
                                  THEN ' CASCADE CONSTRAINTS'
                                  ELSE ''
                              END
                                 AS command_tail
                        FROM user_objects
                       WHERE object_type
                         NOT
                          IN (
                             'LOB'
                           , 'INDEX'
                             )
                       ORDER
                          BY CASE WHEN object_type = 'VIEW'
                                  THEN 1
                                  WHEN object_type = 'PROCEDURE'	-- Stand alone procedures.
                                   AND subobject_name IS NULL
                                  THEN 2
                                  WHEN object_type = 'FUNCTION'		-- Stand alone functions.
                                   AND subobject_name IS NULL
                                  THEN 3
                                  WHEN object_type = 'PROCEDURE'	-- Package procedures.
                                   AND subobject_name IS NOT NULL
                                  THEN 4
                                  WHEN object_type = 'FUNCTION'		-- Package functions.
                                   AND subobject_name IS NOT NULL
                                  THEN 5
                                  WHEN object_type = 'TABLE'
                                  THEN 6
                                  WHEN object_type = 'PACKAGE'
                                  THEN 7
                                  WHEN object_type = 'PACKAGE BODY'
                                  THEN 8
                                  WHEN object_type = 'DATABASE LINK'
                                  THEN 7
                                  ELSE 999
                              END
                      )
    LOOP
        BEGIN
            dbms_output.put_line('Dropping object ' || c_repo_obj.object_name || ' of type ' || c_repo_obj.object_type);
            EXECUTE IMMEDIATE('DROP ' || c_repo_obj.object_type || ' ' || c_repo_obj.object_name || c_repo_obj.command_tail);
        EXCEPTION
            WHEN OTHERS
                THEN raise_application_error(-20000, 'Cannot drop ' || c_repo_obj.object_type || ' ' || c_repo_obj.object_name);
        END;
    END LOOP;
END;
/