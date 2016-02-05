function ExecHSqlSqlScript ($strUserName, $strUserPassword, $strJdbcUrl, $strSchemaName, $strSqlScript, $blnReplaceEosMarker) {
	
	$FN = "ExecHSqlSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (!(test-path $strSqlScript)) {
		write-host "$EM SQL script file <$strSqlScript> is not accessible"
	}
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "org.hsqldb.jdbcDriver"
	
	#
	# Replace the ";" statement separators in the script.
	#
	$arrStrSetUpScriptContent = get-content -path $strSqlScript
	if ($arrStrSetUpScriptContent -eq $Null) {
		#
		# Get-Content returns $Null for an empy file.
		#
		$arrStrSetUpScriptContent = @()
	}
	
	$arrStrOut = @()
	
	if (($strSchemaName -ne "") -and ($strSchemaName -ne $Null)) {
		$arrStrOut += "SET SCHEMA $strSchemaName"
		$arrStrOut += "<OdiScmGenerateSqlStatementDelimiter>"
		$arrStrOut += ""
	}
	
	#
	# Replace end of statement markers to standard value.
	#
	if ($blnReplaceEosMarker) {
		$arrStrOut += $arrStrSetUpScriptContent -replace ";$", "<OdiScmGenerateSqlStatementDelimiter>"
	}
	else {
		$arrStrOut = $arrStrSetUpScriptContent
	}
	
	$strSqlScriptName = split-path $strSqlScript -leaf
	$strNoGoSqlScript = "$env:TEMPDIR\${strSqlScriptName}_${strSchemaName}.sql"
	set-content -path $strNoGoSqlScript -value $arrStrOut
	
	$strNoGoSqlScriptFileName = split-path $strNoGoSqlScript -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_${strSchemaName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_${strSchemaName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strNoGoSqlScript $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecSqlServerSqlScript ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSqlScript, $blnReplaceEosMarker) {
	
	$FN = "ExecSqlServerSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (!(test-path $strSqlScript)) {
		write-host "$EM SQL script file <$strSqlScript> is not accessible"
		return $False
	}
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
	
	#
	# Specify the database in the JDBC URL.
	# Note that we don't use "USE <database>" as this statement causes a warning message to be written to stderr.
	#
	if (($strJdbcUrl.ToLower().contains("database=")) -or ($strJdbcUrl.ToLower().contains("databasename="))) {
		$strFullUrl = $strJdbcUrl
	}
	else {
		$strFullUrl = $strJdbcUrl + ";databaseName=" + $strDatabaseName
	}
	
	write-host "$IM using full JDBC URL <$strFullUrl>"
	
	#
	# Replace the "go" statement separators in the script.
	#
	$arrStrSetUpScriptContent = get-content -path $strSqlScript
	if ($arrStrSetUpScriptContent -eq $Null) {
		#
		# Get-Content returns $Null for an empty file.
		#
		write-host "$WM input SQL script file <$strSqlScript> is empty"
		$arrStrSetUpScriptContent = @()
	}
	
	$arrStrOut = @()
	
	if ($blnReplaceEosMarker) {
		write-host "$DEBUG replacing statement delimiters with standard ODI-SCM delimiter"
		$arrStrOut += $arrStrSetUpScriptContent -replace "^go$", "<OdiScmGenerateSqlStatementDelimiter>"
	}
	else {
		$arrStrOut = $arrStrSetUpScriptContent
	}
	
	$strSqlScriptName = split-path $strSqlScript -leaf
	$strNoGoSqlScript = "$env:TEMPDIR\${strSqlScriptName}_${strDatabaseName}.sql"
	set-content -path $strNoGoSqlScript -value $arrStrOut
	
	$strNoGoSqlScriptFileName = split-path $strNoGoSqlScript -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdErr.log"
	
	#
	# For SQL Server we request that OdiScmJisql does not return a failure if stderr text is generated.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strNoGoSqlScript $strStdOutLogFile $strStdErrLogFile $False
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecMySqlSqlScript ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSqlScript, $blnReplaceEosMarker) {
	
	$FN = "ExecMySqlSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	write-host "$IM User Name     <$strUserName>"
	write-host "$IM User Password <$strUserPassword>"
	write-host "$IM JDBC URL      <$strJdbcUrl>"
	write-host "$IM Schema        <$strDatabaseName>"
	write-host "$IM Script File   <$strSqlScript>"
	
	if (!(test-path $strSqlScript)) {
		write-host "$EM SQL script file <$strSqlScript> is not accessible"
		return $False
	}
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "com.mysql.jdbc.Driver"
	
	#
	# Specify the database in the JDBC URL.
	#
	if ($strJdbcUrl.ToLower() -match "[^:]/") {
		$strFullUrl = $strJdbcUrl
	}
	else {
		if ($strFullUrl.Contains("?")) {
			$intPropertiesPos = $strFullUrl.IndexOf("?")
			$strUrlBegin = $strFullUrl.Substring(0, $intPropertiesPos)
			$strUrlEnd = $strFullUrl.Substring($intPropertiesPos)
			$strFullUrl = $strUrlBegin + "/" + $strDatabaseName
		}
		else {
			$strFullUrl = $strJdbcUrl + "/" + $strDatabaseName
		}
	}
	
	write-host "$IM using full JDBC URL <$strFullUrl>"
	
	#
	# Replace the end of statement separators in the script.
	#
	$arrStrSetUpScriptContent = get-content -path $strSqlScript
	if ($arrStrSetUpScriptContent -eq $Null) {
		#
		# Get-Content returns $Null for an empy file.
		#
		$arrStrSetUpScriptContent = @()
	}
	
	$arrStrOut = @()
	
	if (($strDatabaseName -ne "") -and ($strDatabaseName -ne $Null)) {
		$arrStrOut += "USE $strDatabaseName"
		$arrStrOut += "<OdiScmGenerateSqlStatementDelimiter>"
		$arrStrOut += ""
	}
	
	write-host "$IM changing end of statement markers"
	$intLines = $arrStrSetUpScriptContent.length
	write-host "$IM source script contains <$intLines> lines"
	
	if ($blnReplaceEosMarker) {
		write-host "$DEBUG replacing statement delimiters with standard ODI-SCM delimiter"
		$arrStrOut += $arrStrSetUpScriptContent -replace "^;$", "<OdiScmGenerateSqlStatementDelimiter>"
	}
	else {
		$arrStrOut = $arrStrSetUpScriptContent
	}
	
	write-host "$IM completed changing end of statement markers"
	
	$strSqlScriptName = split-path $strSqlScript -leaf
	$strNoGoSqlScript = "$env:TEMPDIR\${strSqlScriptName}_${strDatabaseName}.sql"
	set-content -path $strNoGoSqlScript -value $arrStrOut
	
	$strNoGoSqlScriptFileName = split-path $strNoGoSqlScript -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdErr.log"
	
	#
	# For MySQL we request that OdiScmJisql does not return a failure if stderr text is generated.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strNoGoSqlScript $strStdOutLogFile $strStdErrLogFile $False
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecOracleSqlScript ($strUserName, $strUserPassword, $strJdbcUrl, $strSchemaName, $strSqlScript, $blnReplaceEosMarker) {
	
	$FN = "ExecOracleSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (!(test-path $strSqlScript)) {
		write-host "$EM SQL script file <$strSqlScript> is not accessible"
	}
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "oracle.jdbc.driver.OracleDriver"
	
	#
	# Replace the ";" statement separators in the script.
	#
	$arrStrSetUpScriptContent = get-content -path $strSqlScript
	if ($arrStrSetUpScriptContent -eq $Null) {
		#
		# Get-Content returns $Null for an empy file.
		#
		$arrStrSetUpScriptContent = @()
	}
	
	$arrStrOut = @()
	
	if (($strSchemaName -ne "") -and ($strSchemaName -ne $Null)) {
		$arrStrOut += "ALTER SESSION SET CURRENT_SCHEMA = $strSchemaName"
		$arrStrOut += "<OdiScmGenerateSqlStatementDelimiter>"
		$arrStrOut += ""
	}
	
	if ($blnReplaceEosMarker) {
		$arrStrOut += $arrStrSetUpScriptContent -replace ";$", "<OdiScmGenerateSqlStatementDelimiter>"
	}
	else {
		$arrStrOut = $arrStrSetUpScriptContent
	}
	
	$strSqlScriptName = split-path $strSqlScript -leaf
	$strNoGoSqlScript = "$env:TEMPDIR\${strSqlScriptName}_${strSchemaName}.sql"
	set-content -path $strNoGoSqlScript -value $arrStrOut
	
	$strNoGoSqlScriptFileName = split-path $strNoGoSqlScript -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdErr.log"
	
	#
	# For Oracle we request that OdiScmJisql does not return a failure if stderr text is generated.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strNoGoSqlScript $strStdOutLogFile $strStdErrLogFile $False
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecTeradataSqlScript ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSqlScript, $blnReplaceEosMarker) {
	
	$FN = "ExecTeradataSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	write-host "$IM User Name     <$strUserName>"
	write-host "$IM User Password <$strUserPassword>"
	write-host "$IM JDBC URL      <$strJdbcUrl>"
	write-host "$IM Schema        <$strDatabaseName>"
	write-host "$IM Script File   <$strSqlScript>"
	
	if (!(test-path $strSqlScript)) {
		write-host "$EM SQL script file <$strSqlScript> is not accessible"
	}
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "com.teradata.jdbc.TeraDriver"
	
	#
	# Specify the database in the JDBC URL.
	#
	if ($strJdbcUrl.ToLower().contains("database=")) {
		$strFullUrl = $strJdbcUrl
	}
	else {
		if (($strDatabaseName -ne "") -and ($strDatabaseName -ne $Null)) {
			$strFullUrl = $strJdbcUrl + "/database=" + $strDatabaseName
		}
	}
	
	write-host "$IM using full JDBC URL <$strFullUrl>"
	
	#
	# Replace the end of statement separators in the script.
	#
	$arrStrSetUpScriptContent = get-content -path $strSqlScript
	if ($arrStrSetUpScriptContent -eq $Null) {
		#
		# Get-Content returns $Null for an empy file.
		#
		$arrStrSetUpScriptContent = @()
	}
	
	$arrStrOut = @()
	
	if (($strDatabaseName -ne "") -and ($strDatabaseName -ne $Null)) {
		$arrStrOut += "DATABASE $strDatabaseName"
		$arrStrOut += "<OdiScmGenerateSqlStatementDelimiter>"
		$arrStrOut += ""
	}
	
	write-host "$IM changing end of statement markers"
	$intLines = $arrStrSetUpScriptContent.length
	write-host "$IM source script contains <$intLines> lines"
	
	if ($blnReplaceEosMarker) {
		write-host "$DEBUG replacing statement delimiters with standard ODI-SCM delimiter"
		$arrStrOut += $arrStrSetUpScriptContent -replace ";$", "<OdiScmGenerateSqlStatementDelimiter>"
	}
	else {
		$arrStrOut = $arrStrSetUpScriptContent
	}
	
	write-host "$IM completed changing end of statement markers"
	
	$strSqlScriptName = split-path $strSqlScript -leaf
	$strNoGoSqlScript = "$env:TEMPDIR\${strSqlScriptName}_${strDatabaseName}.sql"
	set-content -path $strNoGoSqlScript -value $arrStrOut
	
	$strNoGoSqlScriptFileName = split-path $strNoGoSqlScript -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strNoGoSqlScriptFileName}_StdErr.log"
	
	#
	# For Teradata we request that OdiScmJisql does not return a failure if stderr text is generated.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strNoGoSqlScript $strStdOutLogFile $strStdErrLogFile $False
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecDatabaseSqlScript ($strDbTypeName, $strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSchemaName, $strSqlScript, $strReplaceEosMarkerInd) {
	
	$FN = "ExecDatabaseSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	write-host "$DEBUG script file is <$strSqlScript>"
	write-host "$DEBUG replace end of statement delimiters flag is <$strReplaceEosMarkerInd>"
	
	switch ($strReplaceEosMarkerInd.ToUpper()) {
		"Y" {
			$blnReplaceEosMarker = $True
		}
		
		"YES" {
			$blnReplaceEosMarker = $True
		}
		
		"T" {
			$blnReplaceEosMarker = $True
		}
		
		"TRUE" {
			$blnReplaceEosMarker = $True
		}
		
		"N" {
			$blnReplaceEosMarker = $False
		}
		
		"NO" {
			$blnReplaceEosMarker = $False
		}
		
		"F" {
			$blnReplaceEosMarker = $False
		}
		
		"FALSE" {
			$blnReplaceEosMarker = $False
		}
		
		default {
			write-host "$EM invalid value specified for parameter <strReplaceEosMarkerInd>"
			return $False
		}
	}
	
	write-host "$DEBUG blnReplaceEosMarker <$blnReplaceEosMarker>"
	
	switch ($strDbTypeName.ToLower()) {
		
		"oracle" {
			$RetVal = ExecOracleSqlScript $strUserName $strUserPassword $strJdbcUrl $strSchemaName $strSqlScript $blnReplaceEosMarker
		}
		
		"sqlserver" {
			# We cannot set a default schema in a SQL Server script so we don't pass it.
			$RetVal = ExecSqlServerSqlScript $strUserName $strUserPassword $strJdbcUrl $strDatabaseName $strSqlScript $blnReplaceEosMarker
		}
		
		"teradata" {
			$RetVal = ExecTeradataSqlScript $strUserName $strUserPassword $strJdbcUrl $strSchemaName $strSqlScript $blnReplaceEosMarker
		}
		
		"hsql" {
			$RetVal = ExecHSqlSqlScript $strUserName $strUserPassword $strJdbcUrl $strSchemaName $strSqlScript $blnReplaceEosMarker
		}
		"mysql" {
			$RetVal = ExecMySqlSqlScript $strUserName $strUserPassword $strJdbcUrl $strDatabaseName $strSqlScript $blnReplaceEosMarker
		}
		default {
			write-host "$EM unrecognised database type <$strDbTypeName> specified"
			return $False
		}
	}
	
	if (!($RetVal)) {
		write-host "$EM executing SQL script <$strSqlScript>" 
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function TearDownHsqlSchema ($strUserName, $strUserPassword, $strJdbcUrl, $strSchemaName) {
	
	$FN = "TearDownHSQLSchema"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "org.hsqldb.jdbcDriver"
	
	#
	# Set the target database name and schema name in the script.
	#
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateTearDownHSqlSchema.sql" | out-string
	
	if (($strSchemaName -ne $Null) -and ($strSchemaName -ne "")) {
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaFilter>", " WHERE table_schema = '$strSchemaName'"
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmSchemaSelect>", "|| table_schema"
	}
	else {
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmSchemaSelect>", ""
	}
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmGenerateTearDownHSqlServerSchema_${strSchemaName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdErr.log"
	
	#
	# Run the script to generate the DROP statements.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	#
	# Create the DROP statements script.
	#
	$strDropScriptFile = "$env:TEMPDIR\OdiScmTearDownHSqlSchema_${strSchemaName}.sql"
	$arrQueryLine = get-content -path $strStdOutLogFile
	
	$arrTearDownScriptContent = @()
	foreach ($strLine in $arrQueryLine) {
		if (($strLine -eq "") -or ($strLine -eq $Null)) {
			continue
		}
		$arrTearDownScriptContent += ($strLine + [Environment]::NewLine + "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine)
	}
	
	set-content -path $strDropScriptFile -value $arrTearDownScriptContent
	
	#
	# Run the DROP statements script.
	#
	$strDropScriptFileName = split-path $strDropScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strDropScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function TearDownSqlServerSchema ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSchemaName) {
	
	$FN = "TearDownSqlServerSchema"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
	
	#
	# Set the target database name and schema name in the script.
	#
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmTearDownSqlServerSchema.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaName>", $strSchemaName
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmDatabaseName>", $strDatabaseName
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmTearDownSqlServerSchema_${strDatabaseName}.${strSchemaName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdErr.log"
	
	#
	# Specify the database in the JDBC URL.
	#
	$strConnStart = ""
	$strRest = ""
	
	if (($strJdbcUrl.ToLower().contains("database=")) -or ($strJdbcUrl.ToLower().contains("databasename="))) {
		if ($strJdbcUrl.ToLower().contains("database=")) {
			$strDatabaseNameAttr = "database="
		}
		else {
			$strDatabaseNameAttr = "databasename="
		}
		$intDatabaseNameAttrStart = $strJdbcUrl.ToLower().IndexOf("${strDatabaseNameAttr}")
		$strRest = $strJdbcUrl.Substring($intDatabaseNameAttrStart)
		$intNextAttrStart = $strRest.IndexOf(";")
		if ($intNextAttrStart > 0)  {
			$strRest = $strRest.Substring($intNextAttrStart)
		}
		else {
			$strRest = ""
		}
		$strFullUrl = $strJdbcUrl.Substring(0, $intDatabaseNameAttrStart) + "databaseName=" + $strDatabaseName + $strRest
	}
	else {
		$strFullUrl = $strJdbcUrl + ";databaseName=" + $strDatabaseName
	}
	write-host "$IM using full JDBC URL <$strFullUrl>"
	
	#
	# Run the script to generate the DROP statements.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	#
	# Create the DROP statements script.
	#
	$strDropScriptFile = "$env:TEMPDIR\OdiScmTearDownSqlServerSchema_${strDatabaseName}.${strSchemaName}.sql"
	$arrQueryLine = get-content -path $strStdOutLogFile
	if ($arrQueryLine -eq $Null) {
		#
		# Get-Content returns $Null for an empy file.
		#
		$arrQueryLine = @()
	}
	
	$arrTearDownScriptContent = @()
	foreach ($strLine in $arrQueryLine) {
		if ($strLine.Trim() -ne "") {
			$arrTearDownScriptContent += ($strLine + [Environment]::NewLine + "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine)
		}
	}
	
	set-content -path $strDropScriptFile -value $arrTearDownScriptContent
	
	#
	# Run the DROP statements script.
	#
	$strDropScriptFileName = split-path $strDropScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strDropScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function TearDownMySqlSchema ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName) {
	
	$FN = "TearDownMySqlSchema"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "com.mysql.jdbc.Driver"
	
	#
	# Set the target database name in the script.
	#
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateTearDownMySqlSchema.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmDatabaseName>", $strDatabaseName
	
	if (($strDatabaseName -ne $Null) -and ($strDatabaseName -ne "")) {
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaFilter>", " WHERE table_schema = '$strDatabaseName'"
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmConstraintPhysicalSchemaFilter>", " WHERE constraint_schema = '$strDatabaseName'"
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmSchemaSelect>", ($strDatabaseName + ".")
	}
	else {
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaFilter>", ""
		$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmSchemaSelect>", ""
	}
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmTearDownMySqlSchema_${strDatabaseName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdErr.log"
	
	#
	# Specify the database in the JDBC URL.
	#
	if ($strJdbcUrl.ToLower() -match "[^:]/") {
		$strFullUrl = $strJdbcUrl
	}
	else {
		if ($strFullUrl.Contains("?")) {
			$intPropertiesPos = $strFullUrl.IndexOf("?")
			$strUrlBegin = $strFullUrl.Substring(0, $intPropertiesPos)
			$strUrlEnd = $strFullUrl.Substring($intPropertiesPos)
			$strFullUrl = $strUrlBegin + "/" + $strDatabaseName
		}
		else {
			$strFullUrl = $strJdbcUrl + "/" + $strDatabaseName
		}
	}
	write-host "$IM using full JDBC URL <$strFullUrl>"
	
	#
	# Run the script to generate the DROP statements.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strSqlScriptFile $strStdErrLogFile)) {
		return $False
	}
	
	#
	# Create the DROP statements script.
	#
	$strDropScriptFile = "$env:TEMPDIR\OdiScmTearDownMySqlSchema_${strDatabaseName}.sql"
	$arrQueryLine = get-content -path $strStdOutLogFile
	if ($arrQueryLine -eq $Null) {
		#
		# Get-Content returns $Null for an empy file.
		#
		$arrQueryLine = @()
	}
	
	$arrTearDownScriptContent = @()
	foreach ($strLine in $arrQueryLine) {
		if ($strLine.Trim() -ne "") {
			$arrTearDownScriptContent += ($strLine + [Environment]::NewLine + "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine)
		}
	}
	
	set-content -path $strDropScriptFile -value $arrTearDownScriptContent
	
	#
	# Run the DROP statements script.
	#
	$strDropScriptFileName = split-path $strDropScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strDropScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strDropScriptFile $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function TearDownOracleSchema ($strUserName, $strUserPassword, $strJdbcUrl, $strSchemaName, $strDropWithPurgeInd) {
	
	$FN = "TearDownOracleSchema"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "oracle.jdbc.driver.OracleDriver"
	
	#
	# Set the target schema name in the script.
	#
	$strDropWithPurgeInd = $strDropWithPurgeInd.ToUpper()

	if ($strDropWithPurgeInd -eq "YES") {
		$strPurge = "PURGE"
	}
	else {
		$strPurge = ""
	}

	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmTearDownOracleSchema.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaName>", $strSchemaName
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPurge>", $strPurge
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmTearDownOracleSchema_${strSchemaName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function TearDownTeradataDatabase ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName) {
	
	$FN = "TearDownTeradataDatabase"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	$strJdbcDriver = "com.teradata.jdbc.TeraDriver"
	
	if ($strDatabaseName -eq "" -or $strDatabaseName -eq $Null) {
		write-host "$EM no Teradata database name specified"
		return $False
	}
	
	#
	# Process unnamed FK constraints.
	#
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateTearDownTeradataDatabaseUnnamedFkConstraints.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaName>", $strDatabaseName
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmGenTearDownTdUnnamedFkCons_${strDatabaseName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	#
	# Define the unnamed FK constraints drop script name.
	#
	$strDropUnnamedFkConsScriptFile = "$env:TEMPDIR\OdiScmTearDownTdUnnamedFkCons_${strDatabaseName}.sql"
	
	#
	# Process the query results to consolidate the constraint columns.
	#
	$arrQueryLine = get-content -path $strStdOutLogFile
	
	$arrOutQueryLines = @()
	$strCurrChildTable = ""
	$strCurrChildKeyCols = ""
	$strCurrParentTable = ""
	$strCurrParentKeyCols = ""
	
	foreach ($strQueryLine in $arrQueryLine) {
		
		if (($strQueryLine -eq "") -or ($strQueryLine -eq $Null)) {
			continue
		}
		
		$strQueryLine = $strQueryLine.Trim()
		
		$arrLineParts = @([regex]::split($strQueryLine, ","))
		$strChildDbTable = $arrLineParts[0]
		$strChildKeyCol = $arrLineParts[1]
		$strParentDbTable = $arrLineParts[2]
		$strParentKeyCol = $arrLineParts[3]
		
		if (($strChildDbTable -ne $strCurrChildTable) -or ($strParentDbTable -ne $strCurrParentTable)) {
			#
			# Start of a new relationship.
			#
			if ($strCurrChildTable -ne "") {
				#
				# Output a statement, if this is not the first row.
				#
				$strAlter  = "ALTER TABLE " + $strCurrChildTable + " DROP FOREIGN KEY (" + $strCurrChildKeyCols + ") "
				$strAlter += "REFERENCES " + $strCurrParentTable + " (" + $strCurrParentKeyCols + ")"
				$strAlter += [Environment]::NewLine + "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine
				$arrOutQueryLines += $strAlter
				
				#
				# Reset current relationship column lists.
				#
				$strCurrChildKeyCols = ""
				$strCurrParentKeyCols = ""
			}
			
			if ($strCurrChildKeyCols -eq "") {
				$strCurrChildKeyCols += $strChildKeyCol
			}
			else {
				$strCurrChildKeyCols += "," + $strChildKeyCol
			}
			
			if ($strCurrParentKeyCols -eq "") {
				$strCurrParentKeyCols += $strParentKeyCol
			}
			else {
				$strCurrParentKeyCols += "," + $strParentKeyCol
			}
			
			$strCurrChildTable = $strChildDbTable
			$strCurrParentTable = $strParentDbTable
		}
	}
	
	#
	# Process all other objects.
	#
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateTearDownTeradataDatabase.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaName>", $strDatabaseName
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmGenerateTearDownTeradataDatabase_${strDatabaseName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strSqlScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	#
	# Define the *all* objects drop script name.
	#
	$strDropScriptFile = "$env:TEMPDIR\OdiScmTearDownTd_${strDatabaseName}.sql"
	$arrQueryLine = get-content -path $strStdOutLogFile
	
	$arrTearDownOthersScriptContent = @()
	foreach ($strLine in $arrQueryLine) {
		if (($strLine -eq "") -or ($strLine -eq $Null)) {
			continue
		}
		$arrTearDownOthersScriptContent += ($strLine + [Environment]::NewLine + "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine)
	}
	
	$arrStrDropAllObjsScriptContent  = $arrOutQueryLines
	$arrStrDropAllObjsScriptContent += $arrTearDownOthersScriptContent
	set-content -path $strDropScriptFile -value $arrStrDropAllObjsScriptContent
	
	#
	# Run the script to drop the other objects.
	#
	$strDropScriptFileName = split-path $strDropScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\${strDropScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strDropScriptFile $strStdOutLogFile $strStdErrLogFile $True
	if (!(TestSqlExecStatus $IM $EM $blnResult $strNoGoSqlScript $strStdErrLogFile)) {
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function TearDownDatabaseSchema ($strDbTypeName, $strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSchemaName, $strDropWithPurgeInd) {
	
	$FN = "TearDownDatabaseSchema"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	switch ($strDbTypeName.ToLower()) {
		
		"oracle" {
			$RetVal = TearDownOracleSchema $strUserName $strUserPassword $strJdbcUrl $strSchemaName $strDropWithPurgeInd
		}
		
		"sqlserver" {
			$RetVal = TearDownSqlServerSchema $strUserName $strUserPassword $strJdbcUrl $strDatabaseName $strSchemaName
		}
		
		"teradata" {
			$RetVal = TearDownTeradataDatabase $strUserName $strUserPassword $strJdbcUrl $strSchemaName
		}
		
		"hsql" {
			$RetVal = TearDownHSqlSchema $strUserName $strUserPassword $strJdbcUrl $strSchemaName
		}
		"mysql" {
			$RetVal = TearDownMySqlSchema $strUserName $strUserPassword $strJdbcUrl $strDatabaseName
		}
		default {
			write-host "$EM unrecognised database type <$strDbTypeName> specified"
			return $False
		}
	}
	
	if (!($RetVal)) {
		write-host "$EM tearing down database schema"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecSqlScript ($strUserName, $strUserPassword, $strJdbcDriver, $strJdbcUrl, $strSqlScriptFile, $strStdOutLogFile, $strStdErrLogFile, $blnFailIfStdErrOutput) {
	
	$FN = "ExecSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	# write-host "$IM User Name          <$strUserName>"
	# write-host "$IM User Password      <$strUserPassword>"
	# write-host "$IM JDBC Driver        <$strJdbcDriver>"
	# write-host "$IM JDBC URL           <$strJdbcUrl>"
	write-host "$IM Script File          <$strSqlScriptFile>"
	# write-host "$IM StdOut File        <$strStdOutLogFile>"
	# write-host "$IM StdErr File        <$strStdErrLogFile>"
	# write-host "$IM FailIfStdErrOutput <$blnFailIfStdErrOutput>"
	
	$strClassPathJarFile = "$env:TEMPDIR\OdiScmExecSqlScript.jar"
	
	$strCmdLineCmd  = "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat"
	$strCmdLineArgs = '"' + $strClassPathJarFile + '"'
	
	#write-host "$IM executing command line <$strCmdLineCmd $strCmdLineArgs>"
	
	#
	# Execute the batch file process.
	#
	$strCmdStdOut = & $strCmdLineCmd /p $strCmdLineArgs 2>&1
	if ((!($?)) -or ($LastExitCode -ne 0)) {
		write-host "$EM executing command line <$strCmdLineCmd /p $strCmdLineArgs 2>&1>"
		write-host "$EM start of command output <"
		write-host $strCmdStdOut
		write-host "$EM > end of command output"
		return $False
	}
	
	$strCmdLineCmd  = "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmJisql.bat"
	$strCmdLineArgs = '"' + $strUserName + '" "' + $strUserPassword + '" '
	$strCmdLineArgs += '"' + $strJdbcDriver + '" "' + $strJdbcUrl + '" "' + $strSqlScriptFile + '" "' + $strClassPathJarFile + '" "' + $strStdOutLogFile + '" '
	$strCmdLineArgs += '"' + $strStdErrLogFile + '" "' + $blnFailIfStdErrOutput + '"'
	
	#write-host "$IM executing command line <$strCmdLineCmd $strCmdLineArgs>"
	
	#
	# Execute the batch file process.
	#
	$strCmdStdOut = & $strCmdLineCmd /p $strCmdLineArgs 2>&1
	if ((!($?)) -or ($LastExitCode -ne 0)) {
		write-host "$EM executing command line <$strCmdLineCmd /p $strCmdLineArgs 2>&1"
		write-host "$EM start of command output <"
		write-host $strCmdStdOut
		write-host "$EM > end of command output"
		return $False
	}
	
	#
	# Note: The caller of this function is responsible for checking the presence and content of the stderr file.
	#       This is to allow for handling of different behaviours of different drivers reporting warnings and/or errors to stderr.
	#
	write-host "$IM ends"
	return $True
}

function TestSqlExecStatus ($IM, $EM, $blnResult, $strSqlScriptFile, $strStdErrLogFile) {
	
	#
	# Note that $IM and $EM are inherited from the caller.
	#
	
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strSqlScriptFile>"
		if (test-path $strStdErrLogFile) {
			$strStdErrLogFileContent = get-content -path $strStdErrLogFile
			if ($strStdErrLogFileContent.length -gt 0) {
				write-host "$IM command created StdErr output"
				write-host "$IM start of StdErr file content <"
				write-host "$strStdErrLogFileContent"
				write-host "$IM > end of StdErr file content"
			}
		}
		return $False
	}
	
	#
	# Check for any standard error output even if the command returned a successful exit status.
	#
	if (test-path $strStdErrLogFile) {
		$strStdErrLogFileContent = get-content -path $strStdErrLogFile
		
		if ($strStdErrLogFileContent.length -gt 0) {
			write-host "$IM command created StdErr output"
			write-host "$IM start of StdErr file content <"
			write-host "$strStdErrLogFileContent"
			write-host "$IM > end of StdErr file content"
			
			#
			# Check the stderr text to see if it contains only JDBC warning messages.
			#
			$blnStdErrFileContainsOnlyWarnings = $True
			
			foreach ($strStdErrLine in $strStdErrLogFileContent) {
				#
				# Ignore warning messages.
				#
				if ($strStdErrLine -ne $Null) {
					if (($strStdErrLine.Trim() -ne "") -and (!($strStdErrLine -match "^SQLException : SQL state: .* java.sql.SQLWarning: "))) {
						write-host "$EM command StdErr output line <$strStdErrLine> contains non warning message"
						$blnStdErrFileContainsOnlyWarnings = $False
					}
				}
			}
			
			if ($blnStdErrFileContainsOnlyWarnings) {
				write-host "$IM command StdErr output contains only warning messages"
			}
			else {
				write-host "$EM command StdErr output contains non warning messages"
				return $False
			}
		}
	}
	
	return $True
}
