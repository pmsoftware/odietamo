DECLARE 
	l_count					PLS_INTEGER := 0;
	l_create_table			BOOLEAN := FALSE;
	l_crt_main_ddl			VARCHAR(1000) := 'CREATE TABLE odisvn_controls'
						  || '('
						  || '  odi_user_name                  VARCHAR2(35) PRIMARY KEY'
						  || ', import_start_datetime          DATE'
						  || ', code_branch_name               VARCHAR(1000)'
						  || ', code_branch_last_import_rev    VARCHAR(1000)'
--------------------------|| ', import_in_progress_ind         CHAR(1) NOT NULL'
						  || ')';
	l_crt_scen_ddl			VARCHAR(1000) := 'CREATE TABLE odisvn_genscen_sources'
						  || '('
						  || '  source_object_id               INTEGER NOT NULL'
						  || ', source_type_id                 INTEGER NOT NULL'
						  || ', folder_id                      INTEGER NOT NULL'
						  || ', project_id                     INTEGER NOT NULL'
						  || ', marker_group_code              VARCHAR2(100)'
						  || ', CONSTRAINT osgs_pk PRIMARY KEY (source_object_id, source_type_id, marker_group_code)'
						  || ')';
	l_crt_master_flush_ddl	VARCHAR(1000) := 'CREATE TABLE odisvn_master_flush_controls'
						  || '('
						  || '  odi_user_name                  VARCHAR2(35) PRIMARY KEY'
						  || ', flush_from_datetime            DATE'
						  || ', flush_to_datetime              DATE'
						  || ', last_updated_by_command_name   VARCHAR2(500)'
						  || ')';
	l_crt_work_flush_ddl	VARCHAR(1000) := 'CREATE TABLE odisvn_work_flush_controls'
						  || '('
						  || '  odi_user_name                  VARCHAR2(35) PRIMARY KEY'
						  || ', flush_from_datetime            DATE'
						  || ', flush_to_datetime              DATE'
						  || ', last_updated_by_command_name   VARCHAR2(500)'
						  || ')';
	l_crt_work_link_ddl		VARCHAR(1000) := 'CREATE DATABASE LINK odiworkrep_data CONNECT TO <OdiWorkRepoUserName>'
						  || '  IDENTIFIED BY <OdiWorkRepoPassWord> USING ''<OdiWorkRepoConnectionString>''';
BEGIN
	SELECT COUNT(*)
	  INTO l_count
	  FROM user_tables
	 WHERE table_name = 'ODISVN_CONTROLS'
	;
	
	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE l_crt_main_ddl;
			EXECUTE IMMEDIATE 'ANALYZE TABLE odisvn_controls ESTIMATE STATISTICS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot create or analyse table ODISVN_CONTROLS');
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
			EXECUTE IMMEDIATE l_crt_scen_ddl;
			EXECUTE IMMEDIATE 'ANALYZE TABLE odisvn_genscen_sources ESTIMATE STATISTICS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot create or analyse table ODISVN_GENSCEN_SOURCES');
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
			EXECUTE IMMEDIATE l_crt_master_flush_ddl;
			EXECUTE IMMEDIATE 'ANALYZE TABLE odisvn_master_flush_controls ESTIMATE STATISTICS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot create or analyse table ODISVN_MASTER_FLUSH_CONTROLS');
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
			EXECUTE IMMEDIATE l_crt_work_flush_ddl;
			EXECUTE IMMEDIATE 'ANALYZE TABLE odisvn_work_flush_controls ESTIMATE STATISTICS';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot create or analyse table ODISVN_WORK_FLUSH_CONTROLS');
		END;
	END IF;

	SELECT COUNT(*)
	  INTO l_count
	  FROM user_db_links
	 WHERE db_link = 'ODIWORKREP_DATA'
	;
	
	IF l_count = 0
	THEN
		BEGIN
			EXECUTE IMMEDIATE l_crt_work_link_ddl;
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'Cannot create database link ODIWORKREP_DATA');
		END;
	END IF;

END;
/