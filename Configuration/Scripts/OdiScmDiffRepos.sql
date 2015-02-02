--
-- Detect the differences between two repositories of the same structure.
-- 
-- Known differences between empty repositories generated with different IDs as of
-- repository version 4.2.02.01 (checked with ODI 10.1.3.5.6_02).
--
-- SNP_USER
--	"PASS" - encoded user password. The encoding used does not always produce the same encoded string.
--
-- SNP_CONNECT
--	Rows created for the work repositories have I_CONNECT based on master repository ID.
--	Different repository DB user name and encoded password.
--	Different FK of an SNP_MTXT / SNP_MTXT_PART that specifies the work reposiory URL.
--
-- SNP_HOST (PCs having logged in to the master repository).
--	"I_HOST" based on master repository ID.
--
-- SNP_HOST_MOD (ODI modules used by PCs having logged in to the master repository).
--	Reference to SNP_HOST (see above), plus "LAST_CHECK_DATE" (date/time) differs.
--
-- SNP_LOC_REP
--	Master repository ID.
--
-- SNP_LOC_REPW
--	Work rrepository ID and encoded repository password (REP_PASSW).
--
-- SNP_MODULE
--	"CHECKSUM" differs (ODI bug?)
--
-- SNP_REM_REP
--	Work repository ID and reference to data server (I_CONNECT).

--
-- Run in repository schema A.
--
SELECT 'GRANT SELECT ON ' || table_name || ' TO <other_schema>;'
  FROM user_tables
 WHERE table_name LIKE 'SNP_%'  
 ORDER
    BY table_name
<OdiScmGenerateSqlStatementDelimiter>

--
-- Run in repository schema B.
--
DECLARE
	l_txt			VARCHAR2(32767);
	l_col_txt		VARCHAR2(32767);
	l_tab_no		PLS_INTEGER := 0;
BEGIN
	FOR c_tab
	 IN (
	    SELECT usta.table_name
	      FROM user_tables usta
	     WHERE table_name LIKE 'SNP_%'  
	     ORDER
	        BY usta.table_name
	    )
	LOOP
	    l_col_txt := NULL;
	    l_tab_no := l_tab_no + 1;
	    
	    FOR c_tab_col
	     IN (
	        SELECT ustc.column_name
	          FROM user_tab_columns ustc
	         WHERE ustc.table_name = c_tab.table_name
	           AND ustc.column_name
	           NOT -- These will always differ. Ignore them.
	            IN ('FIRST_DATE','LAST_DATE','FIRST_USER','LAST_USER')
	           AND ustc.data_type
	           NOT
	            IN ('LONG RAW')
	         ORDER
	            BY ustc.column_id
	        )
	    LOOP
	        IF l_col_txt IS NOT NULL
	        THEN
	            l_col_txt := l_col_txt || ',' || c_tab_col.column_name;
	        ELSE
	            l_col_txt := c_tab_col.column_name;
	        END IF;
	    END LOOP;
	    
	    IF l_tab_no > 1
	    THEN
	        l_txt := ' UNION ';
	    ELSE
	        l_txt := NULL;
	    END IF;
	    
	    l_txt := NVL(l_txt, '') || 'SELECT ''' || c_tab.table_name || ''', COUNT(*) FROM (';
	    l_txt := l_txt || 'SELECT ' || l_col_txt || ' FROM ' || c_tab.table_name;
	    l_txt := l_txt || ' MINUS SELECT ' || l_col_txt || ' FROM <other_schema>.' || c_tab.table_name;
	    l_txt := l_txt || ')';
	    dbms_output.put_line(l_txt);
	END LOOP;
END;
<OdiScmGenerateSqlStatementDelimiter>
