function ExecSqlServerSqlScript ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSchemaName, $strSqlScript) {
	
	$FN = "ExecSqlServerSqlScript"
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
	
	$strJdbcDriver = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
	
	#
	# Specify the database in the JDBC URL.
	#
	if (($strJdbcUrl.ToLower().contains("database=")) -or ($strJdbcUrl.ToLower().contains("databasename="))) {
		$strFullUrl = $strJdbcUrl
	}
	else {
		$strFullUrl = $strJdbcUrl + ";database=" + $strDatabaseName
	}
	
	#
	# Replace the "go" statement separators in the script.
	#
	$arrStrSetUpScriptContent = get-content -path $strSqlScript
	$arrStrOut = @()
	
	foreach ($strLine in $arrStrSetUpScriptContent) {
		if ($_ -match "^go$") {
			$arrStrOut += "/"
		}
		else {
			$arrStrOut += $strLine
		}
	}
	
	$strNoGoSqlScript = "$env:TEMPDIR\ExecSqlServerSqlScript_${strDatabaseName}_${strSchemaName}.sql"
	set-content -path $strNoGoSqlScript -value $arrStrOut
	
	$strNoGoSqlScriptFileName = split-path $strNoGoSqlScript -leaf
	$strStdOutLogFile = "$env:TEMPDIR\ExecSqlServerSqlScript_${strDatabaseName}_${strSchemaName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\ExecSqlServerSqlScript_${strDatabaseName}_${strSchemaName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strNoGoSqlScript $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strNoGoSqlScript>"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecTeradataSqlScript ($strUserName, $strUserPassword, $strJdbcUrl, $strDatabaseName, $strSqlScript) {
	
	$FN = "ExecTeradataSqlScript"
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
	
	$strJdbcDriver = "com.teradata.jdbc.TeraDriver"
	
	#
	# Specify the database in the JDBC URL.
	#
	if ($strJdbcUrl.ToLower().contains("database=")) {
		$strFullUrl = $strJdbcUrl
	}
	else {
		$strFullUrl = $strJdbcUrl + "/database=" + $strDatabaseName
	}
	
	#
	# Replace the "go" statement separators in the script.
	#
	$arrStrSetUpScriptContent = get-content -path $strSqlScript
	$arrStrOut = @()
	
	write-host "$IM changing end of statement markers"
	$intLines = $arrStrSetUpScriptContent.length
	write-host "$IM source script contains <$intLines> lines"
	
	foreach ($strLine in $arrStrSetUpScriptContent) {
		if ($strLine.Contains(";")) {
			$arrStrOut += ($strLine.Replace(";","/"))
		}
		else {
			$arrStrOut += $strLine
		}
		#write-host "$IM done <$($arrStrOut.length)> lines"
	}
	write-host "$IM completed changing end of statement markers"
	
	$strNoGoSqlScript = "$env:TEMPDIR\ExecTeradataSqlScript_${strDatabaseName}.sql"
	set-content -path $strNoGoSqlScript -value $arrStrOut
	
	$strNoGoSqlScriptFileName = split-path $strNoGoSqlScript -leaf
	$strStdOutLogFile = "$env:TEMPDIR\ExecTeradataSqlScript_${strDatabaseName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\ExecTeradataSqlScript_${strDatabaseName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strNoGoSqlScript $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strNoGoSqlScript>"
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
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmTearDownSqlServerSchema_${strSchemaName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\TearDownSqlServerSchema_${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\TearDownSqlServerSchema_${strSqlScriptFileName}_StdErr.log"
	
	#
	# Specify the database in the JDBC URL.
	#
	if (($strJdbcUrl.ToLower().contains("database=")) -or ($strJdbcUrl.ToLower().contains("databasename="))) {
		$strFullUrl = $strJdbcUrl
	}
	else {
		$strFullUrl = $strJdbcUrl + ";database=" + $strDatabaseName
	}
	
	#
	# Run the script to generate the DROP statements.
	#
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strFullUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strSqlScriptFile>"
		return $False
	}
	
	#
	# Define the other objects drop script name.
	#
	$strDropScriptFile = "$env:TEMPDIR\OdiScmTearDownSqlServerSchema_${strUserName}.sql"
	$arrQueryLine = get-content -path $strStdOutLogFile
	
	$arrTearDownOthersScriptContent = @()
	foreach ($strLine in $arrQueryLine) {
		$arrTearDownOthersScriptContent += ($strLine + [Environment]::NewLine + "/" + [Environment]::NewLine)
	}
	
	set-content -path $strDropScriptFile -value $arrTearDownOthersScriptContent
	
	#
	# Run the DROP statements script.
	#
	$strDropScriptFileName = split-path $strDropScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\TearDownSqlServerSchemaSchema_${strDropScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\TearDownSqlServerSchemaSchema_${strDropScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strDropScriptFile $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strDropScriptFile>"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function TearDownOracleSchema ($strUserName, $strUserPassword, $strJdbcUrl, $strSchemaName) {
	
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
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmTearDownOracleSchema.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaName>", $strSchemaName
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmTearDownOracleSchema_${strSchemaName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\TearDownOracleSchema_${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\TearDownOracleSchema_${strSqlScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strSqlScriptFile>"
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
	
	#
	# Process unnamed FK constraints.
	#
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateTearDownTeradataDatabaseUnnamedFkConstraints.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaName>", $strDatabaseName
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmGenTearDownTdUnnamedFkCons_${strUserName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\GenTearDownTeradataDatabaseUnamedFkCons_${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\GenTearDownTeradataDatabaseUnamedFkCons_${strSqlScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strSqlScriptFile>"
		return $False
	}
	
	#
	# Define the unnamed FK constraints drop script name.
	#
	$strDropUnnamedFkConsScriptFile = "$env:TEMPDIR\OdiScmTearDownTdUnnamedFkCons_${strUserName}.sql"
	
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
				$strAlter += [Environment]::NewLine + "/" + [Environment]::NewLine
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
	
	set-content -path $strDropUnnamedFkConsScriptFile -value $arrOutQueryLines
	
	#
	# Run the script to drop the unnamed FK constraints.
	#
	$strSqlScriptFileName = split-path $strDropUnnamedFkConsScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\TearDownTeradataDatabaseUnamedFkCons_${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\TearDownTeradataDatabaseUnamedFkCons_${strSqlScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strDropUnnamedFkConsScriptFile $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strDropUnnamedFkConsScriptFile>"
		return $False
	}
	
	#
	# Process all other objects.
	#
	$strTearDownTemplateContent = get-content -path "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateTearDownTeradataDatabase.sql" | out-string
	$strTearDownTemplateContent = $strTearDownTemplateContent -replace "<OdiScmPhysicalSchemaName>", $strDatabaseName
	
	$strSqlScriptFile = "$env:TEMPDIR\OdiScmGenerateTearDownTeradataDatabase_${strUserName}.sql"
	set-content -path $strSqlScriptFile -value $strTearDownTemplateContent
	
	$strSqlScriptFileName = split-path $strSqlScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\TearDownTeradataDatabase_${strSqlScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\TearDownTeradataDatabase_${strSqlScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strSqlScriptFile $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strSqlScriptFile>"
		return $False
	}
	
	#
	# Define the other objects drop script name.
	#
	$strDropScriptFile = "$env:TEMPDIR\OdiScmTearDownTd_${strUserName}.sql"
	$arrQueryLine = get-content -path $strStdOutLogFile
	
	$arrTearDownOthersScriptContent = @()
	foreach ($strLine in $arrQueryLine) {
		if (($strLine -eq "") -or ($strLine -eq $Null)) {
			continue
		}
		$arrTearDownOthersScriptContent += ($strLine + [Environment]::NewLine + "/" + [Environment]::NewLine)
	}
	
	set-content -path $strDropScriptFile -value $arrTearDownOthersScriptContent
	
	#
	# Run the script to drop the other objects.
	#
	$strDropScriptFileName = split-path $strDropScriptFile -leaf
	$strStdOutLogFile = "$env:TEMPDIR\TearDownTeradataDatabase_${strDropScriptFileName}_StdOut.log"
	$strStdErrLogFile = "$env:TEMPDIR\TearDownTeradataDatabase_${strDropScriptFileName}_StdErr.log"
	
	$blnResult = ExecSqlScript $strUserName $strUserPassword $strJdbcDriver $strJdbcUrl $strDropScriptFile $strStdOutLogFile $strStdErrLogFile
	if (!($blnResult)) {
		write-host "$EM executing SQL script file <$strDropScriptFile>"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function ExecSqlScript ($strUserName, $strUserPassword, $strJdbcDriver, $strJdbcUrl, $strSqlScriptFile, $strStdOutLogFile, $strStdErrLogFile) {
	
	$FN = "ExecSqlScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (("$env:TEMPDIR" -eq "") -or ("$env:TEMPDIR" -eq $Null)) {
		write-host "$EM environment variable TEMPDIR is not set"
		return $False
	}
	
	write-host "$IM User Name     <$strUserName>"
	write-host "$IM User Password <$strUserPassword>"
	write-host "$IM JDBC Driver   <$strJdbcDriver>"
	write-host "$IM JDBC URL      <$strJdbcUrl>"
	write-host "$IM Script File   <$strSqlScriptFile>"
	write-host "$IM StdOut File   <$strStdOutLogFile>"
	write-host "$IM StdErr File   <$strStdErrLogFile>"
	
	$strClassPathJarFile = "$env:TEMPDIR\OdiScmExecSqlScript.jar"
	
	$strCmdLineCmd  = "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmCreateOdiClassPathJar.bat"
	$strCmdLineArgs = '"' + $strClassPathJarFile + '"'
	
	write-host "$IM executing Jisql command line <$strCmdLineCmd $strCmdLineArgs>"
	
	#
	# Execute the batch file process.
	#
	$strCmdStdOut = & $strCmdLineCmd /p $strCmdLineArgs 2>&1
	if (($?) -and ($LastExitCode -eq 0)) {
		write-host "$IM completed creation of JAR file <$strClassPathJarFile>"
	}
	else {
		write-host "$EM executing command line <$strCmdLineCmd>"
		write-host "$EM start of command output <"
		write-host $strCmdStdOut
		write-host "$EM > end of command output <"
		return $False
	}
	
	$strCmdLineCmd  = "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmJisql.bat"
	$strCmdLineArgs = '"' + $strUserName + '" "' + $strUserPassword + '" '
	$strCmdLineArgs += '"' + $strJdbcDriver + '" "' + $strJdbcUrl + '" "' + $strSqlScriptFile + '" "' + $strClassPathJarFile + '" "' + $strStdOutLogFile + '" '
	$strCmdLineArgs += '"' + $strStdErrLogFile + '"'
	
	write-host "$IM executing command line <$strCmdLineCmd $strCmdLineArgs>"
	
	#
	# Execute the batch file process.
	#
	$strCmdStdOut = & $strCmdLineCmd /p $strCmdLineArgs 2>&1
	if (($?) -and ($LastExitCode -eq 0)) {
		if (test-path $strStdErrLogFile) {
			$strStdErrLogFileContent = get-content -path $strStdErrLogFile
			if ($strStdErrLogFileContent.length -gt 0) {
				write-host "$IM command created StdErr output"
				write-host "$IM start of StdErr file content <"
				write-host "$strStdErrLogFileContent"
				write-host "$IM > end of StdErr file content <"
			}
		}
	}
	else {
		write-host "$EM executing SQL script <$strSqlScriptFile>"
		write-host "$EM start of command output <"
		write-host $strCmdStdOut
		write-host "$EM > end of command output <"
		if (test-path $strStdErrLogFile) {
			write-host "$IM command created StdErr file"
			write-host "$IM start of StdErr file content <"
			write-host (get-content $strStdErrLogFile)
			write-host "$IM > end of StdErr file content <"
		}
		return $False
	}
	
	$arrStdErrContent = get-content -path $strStdErrLogFile
	if ($arrStdErrContent.length -gt 0) {
		write-host "$EM command line returned stderr text <"
		write-host $arrStdErrContent
		write-host "> end of stderr text <"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}