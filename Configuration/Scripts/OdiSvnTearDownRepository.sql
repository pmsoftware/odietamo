DECLARE
BEGIN
    FOR c_repo_tab IN (
                      SELECT table_name
	                    FROM user_tables
	                   WHERE table_name
	                      IN (
		                     'ODISVN_TEARDWN_BKUP_SNP_ID'
		                   , 'ODISVN_TEARDWN_BKUP_SNP_ENT_ID'
                             )
                      )
    LOOP
	    BEGIN
		    EXECUTE IMMEDIATE('DROP TABLE ' || c_repo_tab.table_name || ' CASCADE CONSTRAINTS');
	    EXCEPTION
			WHEN OTHERS
				THEN
					raise_application_error(-20000, 'Cannot drop table ' || c_repo_tab.table_name);
		END;
	END LOOP;
END;
/

CREATE TABLE odisvn_teardwn_bkup_snp_id
AS 
SELECT *
  FROM snp_id
/

CREATE TABLE odisvn_teardwn_bkup_snp_ent_id
AS 
SELECT *
  FROM snp_ent_id
/

--SET SERVER OUTPUT ON SIZE 10000000;

DECLARE
BEGIN
    FOR c_repo_tab IN (
                      SELECT table_name
	                    FROM user_tables
	                   WHERE table_name
	                     NOT
	                      IN (
		                     'ODISVN_TEARDWN_BKUP_SNP_ID'
		                   , 'ODISVN_TEARDWN_BKUP_SNP_ENT_ID'
                             )
                      )
    LOOP
	    BEGIN
		    EXECUTE IMMEDIATE('DROP TABLE ' || c_repo_tab.table_name || ' CASCADE CONSTRAINTS');
	    EXCEPTION
			WHEN OTHERS
				THEN
					raise_application_error(-20000, 'Cannot drop table ' || c_repo_tab.table_name);
		END;
	END LOOP;
END;
/