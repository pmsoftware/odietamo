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
END;
/