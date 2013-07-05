DECLARE
	l_count					PLS_INTEGER;
BEGIN
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISCM_CONTROLS'
	;
	
	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odiscm_controls CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISCM_CONTROLS');
		END;
	END IF;
	
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISCM_GENSCEN_SOURCES'
	;

	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odiscm_genscen_sources CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISCM_GENSCEN_SOURCES');
		END;
	END IF;

	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISCM_MASTER_FLUSH_CONTROLS'
	;

	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odiscm_master_flush_controls CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISCM_MASTER_FLUSH_CONTROLS');
		END;
	END IF;
	
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISCM_WORK_FLUSH_CONTROLS'
	;
	
	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odiscm_work_flush_controls CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISCM_WORK_FLUSH_CONTROLS');
		END;
	END IF;
	
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISCM_SCM_ACTIONS'
	;
	
	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE odiscm_scm_actions CASCADE CONSTRAINTS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot drop table ODISCM_SCM_ACTIONS');
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