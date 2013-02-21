DECLARE
	l_count					PLS_INTEGER;
BEGIN
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISVN_CONTROLS'
	;
	
	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odisvn_controls CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISVN_CONTROLS');
		END;
	END IF;
	
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISVN_GENSCEN_SOURCES'
	;

	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odisvn_genscen_sources CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISVN_GENSCEN_SOURCES');
		END;
	END IF;

	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISVN_MASTER_FLUSH_CONTROLS'
	;

	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odisvn_master_flush_controls CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISVN_MASTER_FLUSH_CONTROLS');
		END;
	END IF;
	
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISVN_WORK_FLUSH_CONTROLS'
	;
	
	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odisvn_work_flush_controls CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISVN_WORK_FLUSH_CONTROLS');
		END;
	END IF;
	
	FOR c_repo_dbl IN (
	                  SELECT db_link
	                    FROM user_db_links
	                   WHERE db_link LIKE 'ODIWORKREP_DATA%'
	                  )
	LOOP
		BEGIN
			EXECUTE IMMEDIATE('DROP DATABASE LINK ' || c_repo_dbl.db_link);
		EXCEPTION
			WHEN OTHERS
				THEN raise_application_error(-20000, 'Cannot drop database link ' || c_repo_dbl.db_link);
		END;
    END LOOP;
END;
/