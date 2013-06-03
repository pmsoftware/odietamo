--SET SERVER OUTPUT ON SIZE 10000000;

DECLARE
BEGIN
    FOR c_repo_tab IN (
                      SELECT table_name
                        FROM user_tables
                      )
    LOOP
        BEGIN
            EXECUTE IMMEDIATE('DROP TABLE ' || c_repo_tab.table_name || ' CASCADE CONSTRAINTS');
        EXCEPTION
            WHEN OTHERS
            THEN raise_application_error(-20000, 'Cannot drop table ' || c_repo_tab.table_name);
        END;
    END LOOP;
    
    FOR c_repo_dbl IN (
                      SELECT db_link
                        FROM user_db_links
                      )
    LOOP
        BEGIN
            EXECUTE IMMEDIATE('DROP DATABASE LINK ' || c_repo_dbl.db_link);
        EXCEPTION
            WHEN OTHERS
                THEN raise_application_error(-20000, 'Cannot drop database link ' || c_repo_dbl.db_link);
        END;
    END LOOP;
    
    FOR c_repo_prc IN (
                      SELECT object_name
                           , object_type
                        FROM user_objects
                      )
    LOOP
        BEGIN
            EXECUTE IMMEDIATE('DROP ' || c_repo_prc.object_type || ' ' || c_repo_prc.object_name);
        EXCEPTION
            WHEN OTHERS
                THEN raise_application_error(-20000, 'Cannot drop ' || c_repo_prc.object_type || ' ' || c_repo_prc.object_name);
        END;
    END LOOP;
END;
/