DECLARE 
	l_count					PLS_INTEGER := 0;
BEGIN
	SELECT COUNT(*)
	  INTO l_count
	  FROM all_users
	 WHERE username = UPPER('<OdiSecuUser>')
	;
	
	IF l_count = 1
	THEN
		BEGIN
			EXECUTE IMMEDIATE 'DROP USER <OdiSecuUser> CASCADE';
		EXCEPTION
			WHEN OTHERS
			THEN
				raise_application_error(-20000, 'ERROR: Cannot drop user <OdiSecuUser>');
		END;
	END IF;
END;
<OdiScmGenerateSqlStatementDelimiter>