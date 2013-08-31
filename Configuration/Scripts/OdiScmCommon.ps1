#
# Import modes used when importing ODI objects.
#
$ODIImportModeInsertUpdate = 'SYNONYM_INSERT_UPDATE'
$ODIImportModeInsert = 'SYNONYM_INSERT'
$ODIImportModeUpdate = 'SYNONYM_UPDATE'

#
# Strings used to correctly generate the ODI object imports for nestable object types.
#
$orderedExtensions = @("*.SnpTechno","*.SnpLang","*.SnpContext","*.SnpConnect","*.SnpPschema","*.SnpLschema","*.SnpProject","*.SnpGrpState","*.SnpFolder","*.SnpVar","*.SnpUfunc","*.SnpTrt","*.SnpModFolder","*.SnpModel","*.SnpSubModel","*.SnpTable","*.SnpJoin","*.SnpSequence","*.SnpPop","*.SnpPackage","*.SnpObjState")
$containerExtensions = @("*.SnpTechno","*.SnpConnect","*.SnpLschema","*.SnpModFolder","*.SnpModel","*.SnpSubModel","*.SnpProject","*.SnpFolder")
$nestableContainerExtensions = @("*.SnpModFolder","*.SnpSubModel","*.SnpFolder")
$nestableContainerExtensionParentFields = @("ParIModFolder","ISmodParent","ParIFolder")
$nestableContExtParBegin = '<Field name="XXXXXXXXXXXXXXXXXXXX" type="com.sunopsis.sql.DbInt"><![CDATA['
$nestableContExtParEnd = ']]></Field>'

############################################################################################################################

function DebuggingPause {
	
	$IM = "DebuggingPause: INFO:"
	$EM = "DebuggingPause: ERROR:"
	
	write-host "$IM you're debugging. Press any key to continue"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
}

function LogDebug ($strSource, $strToPrint) {
	
	if ($DebuggingActive) {
		write-host "$strSource: DEBUG: $strToPrint"
	}
	###DebuggingPause
}

function LogDebugArray ($strSource, $strArrName, [array] $strToPrint) {
	
	$intIdx = 0
	
	if ($DebuggingActive) {
		foreach ($x in $strToPrint) {
			write-host "$strSource: DEBUG: $strArrName[$intIdx]: $x"
			$intIdx += 1
		}
	}
}

#
# Read the contents of an INI file and return it in a nested hash table.
# Code adapted from Scripting Guy's blog post!
#
function GetIniContent ($FilePath)
{
	$FN = "GetIniContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	if (!(test-path "$FilePath")) {
		write-host "$EM cannot access configuration file <$FilePath>"
		return $False
	}
	
	$ini = @{}
	switch -regex -file $FilePath
	{
		"^\[(.+)\]" # Section
		{
			LogDebug "$FN" "got a section"
			$section = $matches[1]
			LogDebug "$FN" "section = $section"
			$ini[$section] = @{}
			$CommentCount = 0
		}
		"^(;.*)$" # Comment
		{
			LogDebug "$FN" "got a comment in section $section"
			if ($section -eq $Null) {
				LogDebug "$FN" "section is null"
				$section = "NoSection"
				$ini[$section] = @{}
				LogDebug "$FN" "in section $section"
			}
			else {
				LogDebug "$FN" "in section $section"
			}
			$value = $matches[1]
			LogDebug "$FN" "value = $value"
			$CommentCount = $CommentCount + 1
			$name = "Comment" + $CommentCount
			LogDebug "$FN" "gonna set using section/name/value: $section/$name/$value"
			$ini["$section"]["$name"] = "$value"
		}
		"(.+?)\s*=(.*)" # Key
		{
			$name,$value = $matches[1..2]
			#
			# Ensure we're not picking up a comment containing "=".
			#
			if (!($name -match "^(;.*)$")) {
				LogDebug "$FN" "got a key"
				LogDebug "$FN" "name = $name"
				LogDebug "$FN" "value = $value"
				$ini[$section][$name] = $value
			}
		}
	}
	return $ini
}

#
# Write the contents of the passed nested hash table to the specified INI file.
#
function SetIniContent ($InputObject, $FilePath)
{
	$outFile = new-item -itemtype file -path $FilePath -force
	foreach ($i in $InputObject.keys)
	{
		if (!($($InputObject[$i].GetType().Name) -eq "Hashtable"))
		{
			#
			# The top level hash table entry is not a section.
			#
			add-content -path $outFile -value "$i=$($InputObject[$i])"
		}
		else {
			#
			# The top level hash table entry is a section.
			#
			add-content -path $outFile -value "[$i]"
			
			foreach ($j in ($InputObject[$i].keys | sort-object))
			{
				if ($j -match "^Comment[\d]+") {
					add-content -path $outFile -value "$($InputObject[$i][$j])"
				}
				else {
					add-content -path $outFile -value "$j=$($InputObject[$i][$j])" 
				}
			}
			add-content -path $outFile -value ""
		}
    }
}

#
# Order the list of passed ODI object source files into import dependency order.
#
function OrderOdiImports ($lstInFiles, $refLstOutFiles) {
	
	$FN = "OrderOdiImports"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	#
	# Loop through each extension and find files for which to include import commands.
	#
	foreach ($Extention in $orderedExtensions) {
		#
		# Initialise the current file type's list.
		#
		$currFileTypeList = @()
		
		#
		# Remove the asterisk from the file type name pattern.
		#
		$FileObjType = $Extention.Replace("*","")
		$FileObjTypeExt = $FileObjType.replace(".","")
		write-host "$IM processing object type <$FileObjTypeExt>"
		
		$ExtensionFileCount = 0
		$FileToImportPathName = ""
		
		foreach ($TfGetOutputLine in $lstInFiles) {
			##write-host "$DEBUG doing file: $TfGetOutputLine"
			##write-host "$DEBUG TfGetOutputLine has type" $TfGetOutputLine.GetType()
			#DebuggingPause
			if ($TfGetOutputLine.EndsWith($FileObjType)) {
				#
				# This is an ODI source object file name.
				#
				$ExtensionFileCount += 1
				$currFileTypeList += $TfGetOutputLine
			}
		}
		
		#
		# Sort the current file type list for nestable types.
		#
		$FileTypeIdx = 0
		foreach ($nestableContainerExtension in $nestableContainerExtensions) {
			
			if ($nestableContainerExtension -eq $Extention) {
				#
				# The current file type is a nestable container type.
				#
				
				#
				# Initialise the sort input array. Elements are in the form <Object ID>.<Parent Object ID>.
				#
				[array] $sortFileList = @()
				#
				# Load the temporary array that we use to sort the files.
				#
				foreach ($sortFile in $currFileTypeList) {
					
					$strFileDotParent = split-path $sortFile -leaf
					$strFileDotParent = $strFileDotParent.replace($nestableContainerExtension.replace("*",""),"")
					$strFileParentContent = get-content $sortFile | where {$_ -match $nestableContainerExtensionParentFields[$FileTypeIdx]}
					
					if ($strFileParentContent.length -gt 0) {
						$strFileParExtParBegin = $nestableContExtParBegin.replace("XXXXXXXXXXXXXXXXXXXX",$nestableContainerExtensionParentFields[$FileTypeIdx])
						$strFileParent = $strFileParentContent.replace($strFileParExtParBegin,"")
						$strFileParent = $strFileParent.replace($nestableContExtParEnd,"")
						$strFileParent = $strFileParent.replace("null","")
						$strFileParent = $strFileParent.trim()		# Remove any white space.
						if ($strFileParent -ne "") {
							$strFileDotParent += "." + $strFileParent
						}
					}
					else {
						write-host "$EM cannot find parent ID field for sort input file <$sortFile>"
						return $False
					}
					$sortFileList += $strFileDotParent
				}
				
				#
				# Bubble sort the array.
				#
				do {
					$blnSwapped = $False
					for ($i = 0; $i -lt $sortFileList.length - 1; $i++) {
						
						[array] $intParentChild = @([regex]::split($sortFileList[$i],"\."))
						
						if ($intParentChild.length -eq 2) {
							#
							# There is a parent. Search for the parent's position in the working list.
							#
							$intChild = $intParentChild[0]
							$intParent = $intParentChild[1]
							
							$intParentPos = -1
							for ($j = 0; $j -lt $sortFileList.length - 1; $j++) {
								[array] $intSearchParentChild = @([regex]::split($sortFileList[$j],"\."))
								$intSearchChild = $intSearchParentChild[0]
								if ($intSearchChild -eq $intParent) {
									$intParentPos = $j
									break
								}
							}
							
							if ($intParentPos -gt $i) {
								# Swap the current item with the next item.
								$tempFileListEntry = $sortFileList[$i]
								$sortFileList[$i]  = $sortFileList[$i + 1]
								$sortFileList[$i + 1]  = $tempFileListEntry
								$blnSwapped = $True
							}
						}
					}
				}
				while ($blnSwapped -eq $True)
				
				#
				# Repopulate the current file type list.
				#
				$sortedCurrFileTypeList = @()
				foreach ($sortedFile in $sortFileList) {
					# Find the child entry.
					[array] $intParentChild = @([regex]::split($sortedFile,"\."))
					$intChild = $intParentChild[0]
					for ($k = 0; $k -lt $currFileTypeList.length; $k++) {
						$strFileName = split-path $currFileTypeList[$k] -leaf
						$intChildFile = $strFileName.replace($nestableContainerExtension.replace("*",""),"")
						if ($intChild -eq $intChildFile) {
							$sortedCurrFileTypeList += $currFileTypeList[$k]
							break
						}
					}
				}
				$currFileTypeList = @()
				foreach ($sortedCurrFile in $sortedCurrFileTypeList) {
					$currFileTypeList += $sortedCurrFile
				}
			}
			$FileTypeIdx += 1
		}
		
		#
		# Add the current file type's list to the main output list.
		#
		foreach ($currFileTypeFile in $currFileTypeList) {
			$refLstOutFiles.value += $currFileTypeFile		# We need to use the 'value' property for references to arrays.
		}
	}
	
	write-host "$IM completed ordering of <$(($refLstOutFiles.value).length)> files"
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateOdiImportScript ([array] $filesToImport) {
	
	$FN = "GenerateOdiImportScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG"
	
	write-host "$IM starts"
	
	$ExitStatus = $False
	
	write-host "$IM passed <$($filesToImport.length)> files to import"
	write-host "$IM writing output to <$OdiImportScriptFile>"
	
	$OutScriptHeader  = '@echo off' + [Environment]::NewLine
	$OutScriptHeader += "set PROC=$ImportScriptStubName" + [Environment]::NewLine
	$OutScriptHeader += "set IM=%PROC%" + ": INFO:" + [Environment]::NewLine
	$OutScriptHeader += "set EM=%PROC%" + ": ERROR:" + [Environment]::NewLine + [Environment]::NewLine
	
	$OutScriptHeader += 'if /i "%1" == "/b" (' + [Environment]::NewLine
	$OutScriptHeader += '	set IsBatchExit=/b' + [Environment]::NewLine
	$OutScriptHeader += '	shift' + [Environment]::NewLine
	$OutScriptHeader += ') else (' + [Environment]::NewLine
	$OutScriptHeader += '	set IsBatchExit=' + [Environment]::NewLine
	$OutScriptHeader += ')' + [Environment]::NewLine + [Environment]::NewLine
	
	$OutScriptHeader += 'call "' + $ScriptsRootDir + '\OdiScmSetTempDir.bat"' + [Environment]::NewLine
	$OutScriptHeader += 'if ERRORLEVEL 1 (' + [Environment]::NewLine
	$OutScriptHeader += '	echo %EM% creating temporary working directory ^<%TEMPDIR%^>' + [Environment]::NewLine
	$OutScriptHeader += '	goto ExitFail' + [Environment]::NewLine
	$OutScriptHeader += ')' + [Environment]::NewLine + [Environment]::NewLine
	$OutScriptHeader += "set OLDPWD=%CD%" + [Environment]::NewLine + [Environment]::NewLine
	
	$OutScriptHeader += "cd /d $GenScriptRootDir" + [Environment]::NewLine
	$OutScriptHeader | out-file $OdiImportScriptFile -encoding ASCII
	
	#
	# Loop through each extension and file files for which to include import commands.
	#
	foreach ($ext in $orderedExtensions) {
		
		$fileObjType = $ext.Replace("*.","")
		write-host "$IM processing object type <$fileObjType>"
		
		$extensionFileCount = 0
		
		foreach ($fileToImport in $filesToImport) {
			
			if ($fileToImport.EndsWith($fileObjType)) {
				
				$FileToImportName = split-path $fileToImport -leaf
				$FileToImportPathName = split-path $fileToImport -parent
				$SourceFile = $fileToImport
				$extensionFileCount += 1
				
				$ImportText = "echo %IM% date ^<%date%^> time ^<%time%^>" + [Environment]::NewLine
				$ImportText += "set MSG=importing file ^^^<" + $FileToImportName + "^^^> from directory ^^^<" + $FileToImportPathName + "^^^>" + [Environment]::NewLine
				$ImportText += "echo %IM% %MSG%" + [Environment]::NewLine
				
				#
				# Work around (yet another) bug in ODI (as of 11.1.1.6.4) where an SnpProject can't be imported
				# unless it has the file name prefix "PROJ_".
				#
				if ($fileObjType -eq "SnpProject") {
					$ImportText += "echo %IM% creating renamed SnpProject file for source file ^<$FileToImportName^>" + [Environment]::NewLine
					$FileToImportPathName = "%TEMPDIR%"
					$FileToImportName = "PROJ_" + $FileToImportName + ".xml"
					$SourceFile = $FileToImportPathName + "\" + $FileToImportName
					$ImportText += 'copy "' + $fileToImport + '" "' + $SourceFile + '" >NUL' + [Environment]::NewLine
				}
				
				if (!($containerExtensions -contains $ext)) {
					$ImportText += 'call "' + $ScriptsRootDir + '\OdiScmFork.bat" ^"' + $OdiScmOdiStartCmdBat + '^" OdiImportObject ' + '-FILE_NAME=' + $SourceFile + " -IMPORT_MODE=$ODIImportModeInsertUpdate -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
				}
				else {
					$ImportText += 'call "' + $ScriptsRootDir + '\OdiScmFork.bat" ^"' + $OdiScmOdiStartCmdBat + '^" OdiImportObject ' + '-FILE_NAME=' + $SourceFile + " -IMPORT_MODE=$ODIImportModeInsert -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
					$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
					$ImportText += 'call "' + $ScriptsRootDir + '\OdiScmFork.bat" ^"' + $OdiScmOdiStartCmdBat + '^" OdiImportObject ' + '-FILE_NAME=' + $SourceFile + " -IMPORT_MODE=$ODIImportModeUpdate -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
				}
				$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
				$ImportText += "echo %IM% import of file ^<" + $FileToImportName + "^> completed succesfully" + [Environment]::NewLine
				$ImportText | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
			}
		}
	}
	
	#
	# Import script termination commands - the common Exit labels.
	#
	$OutScriptTail  = [Environment]::NewLine
	$OutScriptTail  = ":ExitOk" + [Environment]::NewLine
	$OutScriptTail += "echo %IM% import process completed" + [Environment]::NewLine
	$OutScriptTail += "cd /d %OLDPWD%" + [Environment]::NewLine
	$OutScriptTail += "exit %IsBatchExit% 0" + [Environment]::NewLine + [Environment]::NewLine
	$OutScriptTail += ":ExitFail" + [Environment]::NewLine
	$OutScriptTail += "echo %EM% %MSG%" + [Environment]::NewLine
	$OutScriptTail += "cd /d %OLDPWD%" + [Environment]::NewLine
	$OutScriptTail += "exit %IsBatchExit% 1" + [Environment]::NewLine
	$OutScriptTail | out-file $OdiImportScriptFile -encoding ASCII -append
	
	write-host "$IM lines in generated script content <$(((get-content $OdiImportScriptFile).Count)-1)>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GetOdiScmConfiguration {
	
	$FN = "GetOdiScmConfiguration"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	#
	# Load the OdiScm configuration.
	#
	write-host "$IM using configuration file <$SCMConfigurationFile>"
	$script:OdiScmConfig = GetIniContent "$SCMConfigurationFile"
	if ($OdiScmConfig -eq $False) {
		write-host "$EM reading OdiScm configuration"
		return $False
	}
	
	if (!($OdiScmConfig.ContainsKey("SCM System"))) {
		write-host "$EM configuration INI file is missing section <SCM System>"
		return $False
	}
	
	#
	# Load the SCM system configuration.
	#
	$SCMSystemTypeName = $OdiScmConfig["SCM System"]["Type Name"]
	
	if (($SCMSystemTypeName -eq $Null) -or ($SCMSystemTypeName -eq "")) {
		write-host "$EM cannot retrieve SCM System Type Name from configuration INI file"
		return $False
	}
	
	if ((($SCMSystemTypeName) -ne "TFS") -and (($SCMSystemTypeName) -ne "SVN")) {
		write-host "$EM retrieved unrecognised SCM System Type Name <$SCMSystemTypeName> from configuration INI file"
		return $False
	}
	
	$SCMSystemUrl = $OdiScmConfig["SCM System"]["System Url"]
	
	if (($SCMSystemUrl -eq $Null) -or ($SCMSystemUrl -eq "")) {
		write-host "$EM cannot retrieve SCM System URL from configuration INI file"
		return $False
	}
	
	$SCMBranchUrl = $OdiScmConfig["SCM System"]["Branch Url"]
	
	if (($SCMBranchUrl -eq $Null) -or ($SCMBranchUrl -eq "")) {
		write-host "$EM cannot retrieve SCM Branch URL from configuration INI file"
		return $False
	}
	
	if ($OdiScmConfig["SCM System"].ContainsKey("Global User Name")) {
		$SCMUserName = $OdiScmConfig["SCM System"]["Global User Name"]
		write-host "$IM using SCM Global User Name <$SCMUserName>"
		
		if (!($OdiScmConfig["SCM System"].ContainsKey("Global User Password"))) {
			write-host "$EM no Global User Password entry in INI file for SCM user <$SCMUserName>"
			return $False
		}
		else {
			$SCMUserPassword = $OdiScmConfig["SCM System"]["Global User Password"]
			#if (($SCMUserPassword -eq $Null) -or ($SCMUserPassword -eq "")) {
			#	write-host "$EM no Global User Password entry in INI file for SCM user <$SCMUserName>"
			#	return $False
			#}
		}
	}
	
	if ($OdiScmConfig["SCM System"].ContainsKey("Working Copy Root")) {
		$script:WorkingCopyRootDir = $OdiScmConfig["SCM System"]["Working Copy Root"]
		if ($WorkingCopyRootDir -eq "" -or $WorkingCopyRootDir -eq $Null) {
			$WorkingCopyRootDir = get-location | out-string
		}
		else {
			$WorkingCopyRootDir = $OdiScmConfig["SCM System"]["Working Copy Root"]
		}
	}
	
	#
	# Determine the ODI home directory to use.
	#
	$script:OdiHomeDir = ""
	
	if ($OdiScmConfig.ContainsKey("OracleDI")) {
		if ($OdiScmConfig["OracleDI"].ContainsKey("Home")) {
			$script:OdiHomeDir = $OdiScmConfig["OracleDI"]["Home"]
			write-host "$IM found ODI home directory <$OdiHomeDir> from INI file"
		}
	}
	
	if ($OdiHomeDir -eq "") {
		write-host "$EM no Home entry in OracleDI section in INI file"
		return $False
	}
	else {
		write-host "$IM using OracleDI home directory <$OdiHomeDir>"
	}
	
	###$script:OdiBinDir = $OdiHomeDir + "\bin"
	
	#
	# Determine the Java home directory to use with ODI.
	#
	$script:OdiJavaHomeDir = ""
	
	if ($OdiScmConfig.ContainsKey("OracleDI")) {
		if ($OdiScmConfig["OracleDI"].ContainsKey("Java Home")) {
			$script:OdiJavaHomeDir = $OdiScmConfig["OracleDI"]["Java Home"]
			write-host "$IM found OracleDI Java Home directory <$OdiJavaHomeDir> from INI file"
		}
	}
	
	if ($OdiJavaHomeDir -eq "") {
		write-host "$EM no Java Home entry in OracleDU section in INI file"
		return $False
	}
	else {
		write-host "$IM using OracleDI Java Home directory <$OdiJavaHomeDir>"
	}
	
	#
	# Determine the Java home directory to use with Jisql.
	#
	$script:JisqlJavaHomeDir = ""
	
	if ($OdiScmConfig.ContainsKey("Tools")) {
		if ($OdiScmConfig["Tools"].ContainsKey("Jisql Java Home")) {
			$script:JisqlJavaHomeDir = $OdiScmConfig["Tools"]["Jisql Java Home"]
			write-host "$IM found Jisql Java Home directory <$JisqlJavaHomeDir> from INI file"
		}
	}
	
	if ($JisqlJavaHomeDir -eq "") {
		write-host "$EM no Jisql Java Home entry in Tools section in INI file"
		return $False
	}
	else {
		write-host "$IM using Jisql Java Home home directory <$JisqlJavaHomeDir>"
	}
	
	#
	# Determine the Jisql home directory to use.
	#
	$script:JisqlHomeDir = ""
	
	if ($OdiScmConfig.ContainsKey("Tools")) {
		if ($OdiScmConfig["Tools"].ContainsKey("Jisql Home")) {
			$script:JisqlHomeDir = $OdiScmConfig["Tools"]["Jisql Home"]
			write-host "$IM found Jisql Home <$JisqlHomeDir> from INI file"
		}
	}
	
	if ($JisqlHomeDir -eq "") {
		write-host "$EM no Jisql Home entry in Tools section in INI file"
		return $False
	}
	else {
		write-host "$IM using Jisql Home home directory <$JisqlHomeDir>"
	}
	
	#
	# Determine the Oracle home directory to use.
	#
	$script:OracleHomeDir = ""
	
	if ($OdiScmConfig.ContainsKey("Tools")) {
		if ($OdiScmConfig["Tools"].ContainsKey("Oracle Home")) {
			$script:OracleHomeDir = $OdiScmConfig["Tools"]["Oracle Home"]
			write-host "$IM found Oracle Home directory <$OracleHomeDir> from INI file"
		}
	}
	
	if ($OracleHomeDir -eq "") {
		write-host "$EM no Oracle Home entry in Tools section in INI file"
		return $False
	}
	else {
		write-host "$IM using Oracle Home home directory <$OracleHomeDir>"
	}
	
	write-host "$IM using SCM System Type Name <$SCMSystemTypeName>"
	write-host "$IM using SCM System URL       <$SCMSystemUrl>"
	write-host "$IM using SCM Branch URL       <$SCMBranchUrl>"
	
	#
	# Add the Import Controls section if not already in the INI file.
	#
	if (!($OdiScmConfig.ContainsKey("Import Controls"))) {
		$script:OdiScmConfig["Import Controls"] = @{}
	}
	else {
		write-host "$IM configuration INI file contains Import Controls section"
	}
	
	if (!($OdiScmConfig["Import Controls"].ContainsKey("Working Copy Revision"))) {
		if ($OdiScmConfig["SCM System"]["Type Name"] -eq "TFS") {
			$script:OdiScmConfig["Import Controls"]["Working Copy Revision"] = "1"
		}
		else { # I.e. SVN.
			$script:OdiScmConfig["Import Controls"]["Working Copy Revision"] = "0"
		}
	}
	else {
		write-host "$IM configuration INI file contains Working Copy Revision key entry in Import Controls section"
		$KeyEntry = $OdiScmConfig["Import Controls"]["Working Copy Revision"]
		write-host "$IM key entry is <$KeyEntry>"
	}
	
	if (!($OdiScmConfig["Import Controls"].ContainsKey("OracleDI Imported Revision"))) {
		if ($OdiScmConfig["SCM System"]["Type Name"] -eq "TFS") {
			$script:OdiScmConfig["Import Controls"]["OracleDI Imported Revision"] = "1"
		}
		else { # I.e. SVN.
			$script:OdiScmConfig["Import Controls"]["OracleDI Imported Revision"] = "0"
		}
	}
	else {
		write-host "$IM configuration INI file contains OracleDI Imported Revision key entry in Import Controls section"
		$KeyEntry = $OdiScmConfig["Import Controls"]["OracleDI Imported Revision"]
		write-host "$IM key entry is <$KeyEntry>"
	}
	
	#
	# Look for repository connection details in the INI file overriding those in odiparams.
	#
	if ($OdiScmConfig.ContainsKey("OracleDI")) {
	
		if ($OdiScmConfig["OracleDI"].ContainsKey("Secu Driver")) {
			$script:OdiRepoSECURITY_DRIVER = $OdiScmConfig["OracleDI"]["Secu Driver"]
			write-host "$IM found INI file OracleDI Secu Driver       <$OdiRepoSECURITY_DRIVER>"
		}
		
		if ($OdiScmConfig["OracleDI"].ContainsKey("Secu Url")) {
			$script:OdiRepoSECURITY_URL = $OdiScmConfig["OracleDI"]["Secu Url"]
			write-host "$IM found INI file OracleDI Secu Url          <$OdiRepoSECURITY_URL>"
		}
		
		if ($OdiScmConfig["OracleDI"].ContainsKey("Secu User")) {
			$script:OdiRepoSECURITY_USER = $OdiScmConfig["OracleDI"]["Secu User"]
			write-host "$IM found INI file OracleDI Secu User         <$OdiRepoSECURITY_USER>"
		}
		
		if ($OdiScmConfig["OracleDI"].ContainsKey("Secu Encoded Pass")) {
			$script:OdiRepoSECURITY_PWD = $OdiScmConfig["OracleDI"]["Secu Encoded Pass"]
			write-host "$IM found INI file OracleDI Secu Encoded Pass <$OdiRepoSECURITY_PWD>"
		}
		
		if ($OdiScmConfig["OracleDI"].ContainsKey("Secu Pass")) {
			$script:OdiRepoSECURITY_UNENC_PWD = $OdiScmConfig["OracleDI"]["Secu Pass"]
			write-host "$IM found INI file OracleDI Secu Pass         <$OdiRepoSECURITY_UNENC_PWD>"
		}
		
		if ($OdiScmConfig["OracleDI"].ContainsKey("Secu Work Rep")) {
			$script:OdiRepoWORK_REP_NAME = $OdiScmConfig["OracleDI"]["Secu Work Rep"]
			write-host "$IM found INI file OracleDI Secu Work Rep     <$OdiRepoWORK_REP_NAME>"
		}
		
		if ($OdiScmConfig["OracleDI"].ContainsKey("User")) {
			$script:OdiRepoUSER = $OdiScmConfig["OracleDI"]["User"]
			write-host "$IM found INI file OracleDI User              <$OdiRepoUSER>"
		}
		
		if ($OdiScmConfig["OracleDI"].ContainsKey("Encoded Pass")) {
			$script:OdiRepoPASSWORD = $OdiScmConfig["OracleDI"]["Encoded Pass"]
			write-host "$IM found INI file OracleDI Encoded Pass      <$OdiRepoPASSWORD>"
		}
	}
	
	if ($OdiRepoSECURITY_DRIVER.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI Secu Driver in INI file"
		return $False
	}
	
	if ($OdiRepoSECURITY_URL.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI Secu Url in INI file"
		return $False
	}
	
	if ($OdiRepoSECURITY_USER.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI Secu User in INI file"
		return $False
	}
	
	if ($OdiRepoSECURITY_PWD.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI Secu Encoded Pass in INI file"
		return $False
	}
	
	if ($OdiRepoSECURITY_UNENC_PWD.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI Secu Pass in INI file"
		return $False
	}
	
	if ($OdiRepoWORK_REP_NAME.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI Secu Work Rep in INI file"
		return $False
	}
	
	if ($OdiRepoUSER.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI User in INI file"
		return $False
	}
	
	if ($OdiRepoPASSWORD.length -eq 0) {
		write-host "$EM no value for connection parameter OracleDI Encoded Pass in INI file"
		return $False
	}
	
	[array] $OdiIniSecuUrlParts = @([regex]::split($OdiRepoSECURITY_URL,":"))
	
	$script:OdiRepoSECURITY_URL_SERVER = $OdiIniSecuUrlParts[3].Replace("@","")
	if ($OdiRepoSECURITY_URL_SERVER.length -eq 0) {
		write-host "$EM no value for server field of connection parameter OracleDI Secu Url in INI file"
		return $False
	}
	
	$script:OdiRepoSECURITY_URL_PORT = $OdiIniSecuUrlParts[4]
	if ($OdiRepoSECURITY_URL_PORT.length -eq 0) {
		write-host "$EM no value for port field of connection parameter OracleDI Secu Url in INI file"
		return $False
	}
	
	$script:OdiRepoSECURITY_URL_SID = $OdiIniSecuUrlParts[5]
	if ($OdiRepoSECURITY_URL_SID.length -eq 0) {
		write-host "$EM no value for SID field of connection parameter OracleDI Secu Url in INI file"
		return $False
	}
	
	write-host "$IM from OracleDI Secu Url extracted server   <$OdiRepoSECURITY_URL_SERVER>"
	write-host "$IM from OracleDI Secu Url extracted port     <$OdiRepoSECURITY_URL_PORT>"
	write-host "$IM from OracleDI Secu Url extracted SID      <$OdiRepoSECURITY_URL_SID>"
	
	#
	# Set process-level environment variables for those read from the INI file.
	# Note process (i.e. session) level environment variables can be set simply using "$env:<var> = <value>".
	#
	#[Environment]::SetEnvironmentVariable("ODI_HOME", "$OdiHomeDir", "Process")
	#[Environment]::SetEnvironmentVariable("ODI_JAVA_HOME", "$OdiJavaHomeDir", "Process")
	#[Environment]::SetEnvironmentVariable("JAVA_HOME", "$JavaHomeDir", "Process")
	#[Environment]::SetEnvironmentVariable("ODI_SCM_JISQL_HOME", "$JisqlHomeDir", "Process")
	
	#
	# [Test]
	#
	if ($OdiScmConfig.ContainsKey("Test")) {
		
		if ($OdiScmConfig["Test"].ContainsKey("ODI Standards Script")) {
			$ODIStandardsTestScript = $OdiScmConfig["Test"]["ODI Standards Script"]
			if ($ODIStandardsTestScript -ne "") {
				write-host "$IM using ODI standard test script <$ODIStandardsTestScript>"
			}
		}
		else {
			write-host "$EM missing key <ODI Standards Script> in section [Test] in INI file"
			return $False
		}
	}
	else {
		write-host "$EM missing [Test] section in INI file"
		return $False
	}
	
	#
	# [Generate]
	#
	if ($OdiScmConfig.ContainsKey("Generate")) {
		
		if ($OdiScmConfig["Generate"].ContainsKey("Output Tag")) {
			$GenScriptTag = $OdiScmConfig["Generate"]["Output Tag"]
			if ($GenScriptTag -ne "") {
				write-host "$IM using fixed output tag <$GenScriptTag>"
			}
		}
		else {
			write-host "$EM missing key <Output Tag> in section [Generate] in INI file"
			return $False
		}
		
		if ($OdiScmConfig["Generate"].ContainsKey("Import Resets Flush Control")) {
			$GenImportFlushReset = $OdiScmConfig["Generate"]["Import Resets Flush Control"]
			$GenImportFlushReset = $GenImportFlushReset.ToUpper()
			if (!($GenImportFlushReset -eq "YES" -or $GenImportFlushReset -eq "NO")) {
				write-host "$EM invalid value for key <Import Resets Flush Control> in section [Generate] INI file"
				return $False
			}
		}
		else {
			write-host "$EM missing key <Import Resets Flush Control> in section [Generate] in INI file"
			return $False
		}
		
		if ($OdiScmConfig["Generate"].ContainsKey("Export Ref Phys Arch Only")) {
			$ExpRefPhysArchOnly = $OdiScmConfig["Generate"]["Export Ref Phys Arch Only"]
			$ExpRefPhysArchOnly = $ExpRefPhysArchOnly.ToUpper()
			if (!($ExpRefPhysArchOnly -eq "YES" -or $ExpRefPhysArchOnly -eq "NO")) {
				write-host "$EM invalid value for key <Export Ref Phys Arch Only> in section [Generate] INI file"
				return $False
			}
		}
		else {
			write-host "$EM missing key <Import Resets Flush Control> in section [Generate] in INI file"
			return $False
		}
		
		if ($OdiScmConfig["Generate"].ContainsKey("Import Object Batch Size Max")) {
			$ImpObjBatchSizeMax = $OdiScmConfig["Generate"]["Import Object Batch Size Max"]
			if (($ImpObjBatchSizeMax -ne "") -and ($ImpObjBatchSizeMax -ne $Null)) {
				[boolean] $IsNumber = $False
				[int]::TryParse($ImpObjBatchSizeMax,[ref]$IsNumber)
				if (! $IsNumber) {
					write-error "$EM invalid integer specified for key <Import Object Batch Size Max> in section [Generate] INI file"
					return $False
				}
			}
			else {
				write-host "$IM no value specified for key <Import Object Batch Size Max> in section [Generate] INI file"
				write-host "$IM object source files will not be batched for importing"
			}
		}
		else {
			write-host "$EM missing key <Import Object Batch Size Max> in section [Generate] in INI file"
			return $False
		}
	}
	else {
		write-host "$EM missing [Generate] section in INI file"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

#
# Set output file and directory name contants.
#
function SetOutputNames {
	
	$FN = "SetOutputNames"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	$script:OutputTag = $env:ODI_SCM_GENERATE_OUTPUT_TAG
	
	if (($OutputTag -eq $Null) -or ($OutputTag -eq "")) {
		$OutputTag = ${VersionString}
		write-host "$IM using variable output tag <$OutputTag>"
	}
	else {
		write-host "$IM using fixed output tag <$OutputTag>"
	}
	
	#
	# Generated script locations and names.
	#
	$script:GenScriptRootDir = $LogRootDir + "\${OutputTag}"
	$script:GenScriptConsObjSrcDir = $GenScriptRootDir + "\" + "ConsolidatedObjSources"
	
	$script:OdiScmOdiStartCmdBat = $GenScriptRootDir + "\OdiScmStartCmd_${OutputTag}.bat"
	$script:OdiScmJisqlRepoBat = $GenScriptRootDir + "\OdiScmJisqlRepo_${OutputTag}.bat"
	$script:OdiScmRepositoryBackUpBat = $GenScriptRootDir + "\OdiScmRepositoryBackUp_${OutputTag}.bat"
	$script:OdiScmBuildBat = $GenScriptRootDir + "\OdiScmBuild_${OutputTag}.bat"
	$script:OdiScmGenScenPreImportBat = $GenScriptRootDir + "\OdiScmGenScenPreImport_${OutputTag}.bat"
	$script:OdiScmGenScenPostImportBat = $GenScriptRootDir + "\OdiScmGenScenPostImport_${OutputTag}.bat"
	$script:OdiScmGenScenDeleteOldSql = $GenScriptRootDir + "\OdiScmGenScen20DeleteOldScen_${OutputTag}.sql"
	$script:OdiScmGenScenNewSql = $GenScriptRootDir + "\OdiScmGenScen40NewScen_${OutputTag}.sql"
	$script:OdiScmRepoInfrastructureSetupSql = $GenScriptRootDir + "\OdiScmCreateInfrastructure_${OutputTag}.sql"
	$script:OdiScmRepoSetNextImport = $GenScriptRootDir + "\OdiScmSetNextImport_${OutputTag}.sql"
	$script:OdiScmBuildNote = $GenScriptRootDir + "\OdiScmBuildNote_${OutputTag}.txt"
	$script:OdiScmUnitTestExecBat = $GenScriptRootDir + "\OdiScmExecUnitTests_${OutputTag}.bat"
	
	$script:ImportScriptStubName = "OdiScmImport_" + ${OutputTag}
	$script:OdiImportScriptName = $ImportScriptStubName + ".bat"
	$script:OdiImportScriptFile = $GenScriptRootDir + "\$OdiImportScriptName"
	
	if (Test-Path $GenScriptRootDir) { 
		write-host "$IM generated scripts root directory <$GenScriptRootDir> already exists"
	}
	else {  
		write-host "$IM creating generated scripts root directory <$GenScriptRootDir>"
		New-Item -itemtype directory $GenScriptRootDir 
	}
	
	if (Test-Path $GenScriptConsObjSrcDir) { 
		write-host "$IM generated consolidated ODI object source files directory <$GenScriptConsObjSrcDir> already exists"
	}
	else {  
		write-host "$IM generated consolidated ODI object source files directory <$GenScriptConsObjSrcDir> already exists"
		New-Item -itemtype directory $GenScriptConsObjSrcDir 
	}
	
	$script:GetLatestVersionOutputFile = $GenScriptRootDir + "\GetFromSCM_" + ${OutputTag} + ".txt"
	write-host "$IM GetIncremental output will be written to <$GetLatestVersionOutputFile>"
	$script:GetLatestVersionConflictsOutputFile = $GenScriptRootDir + "\GetLatestVersionConflicts_Results_" + ${OutputTag} + ".txt"
	
	if (Test-Path $OdiImportScriptFile) {
		write-host "$IM generated ODI import batch file <$OdiImportScriptFile> already exists"
	}
	else {
		write-host "$IM creating empty generated ODI import batch file <$OdiImportScriptFile>"
		New-Item -itemtype file $OdiImportScriptFile 
	}
	
	write-host "$IM ends"
	return $True
}

#
# Generate a version of startcmd.bat that uses the derived repository connection details.
# I.e. extracted from odiparams.bat and optionally overridden in the INI file.
#
function SetStartCmdContent {
	
	$FN = "SetStartCmdContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	$CmdLine = "cmd.exe /c " + '"' + "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenStartCmd.bat" + '" "' + "$OdiScmOdiStartCmdBat" + '"'
	write-host "$IM running command line <$CmdLine>"
	
	invoke-expression $CmdLine
	if ($LastExitCode -ne 0) {
		write-host "$EM generating StartCmd batch script <$OdiScmOdiStartCmdBat>"
		return $False
	}
	
	write-host "$IM ends"
	
	return $True
}

#
# Generate the batch file OdiScmJisqlRepo.bat.
# This batch file is used to execute SQL statements directly against the ODI repository
# whose details are specified in "odiparams.bat" and optionally overridden in the INI file.
#
function SetOdiScmJisqlRepoBatContent {
	
	$FN = "SetOdiScmJisqlRepoBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"

	write-host "$IM starts"
	$fileContent = get-content $OdiScmJisqlRepoBatTemplate | out-string 
	
	$fileContent = $fileContent.Replace("<OdiScmHomeDir>",$OdiScmHomeDir)
	$fileContent = $fileContent.Replace("<ScriptsRootDir>",$ScriptsRootDir)
	$fileContent = $fileContent.Replace("<SECURITY_DRIVER>",$OdiRepoSECURITY_DRIVER)
	$fileContent = $fileContent.Replace("<SECURITY_URL>",$OdiRepoSECURITY_URL)
	$fileContent = $fileContent.Replace("<SECURITY_USER>",$OdiRepoSECURITY_USER)  
	$fileContent = $fileContent.Replace("<SECURITY_UNENC_PWD>",$OdiRepoSECURITY_UNENC_PWD)
	
	set-content $OdiScmJisqlRepoBat -value $fileContent
	
	write-host "$IM completed modifying content of <$OdiScmJisqlRepoBat>"
	write-host "$IM ends"
	
	return $True
}

#
# Generate the script to back up the ODI repository.
#
function SetOdiScmRepositoryBackUpBatContent {
	
	$FN = "SetOdiScmRepositoryBackUpBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	#
	# Set up the OdiScm ODI repository back-up script.
	#
	$ScriptFileContent = get-content $OdiScmRepositoryBackUpBatTemplate | out-string
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoUserName>",$OdiRepoSECURITY_USER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPassWord>",$OdiRepoSECURITY_UNENC_PWD)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoServer>",$OdiRepoSECURITY_URL_SERVER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPort>",$OdiRepoSECURITY_URL_PORT)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoSID>",$OdiRepoSECURITY_URL_SID)
	
	$ExportFileName = "$GenScriptRootDir" + "\OdiScmExportBackUp_${OdiRepoSECURITY_USER}_${OdiRepoSECURITY_URL_SERVER}_${OdiRepoSECURITY_URL_SID}_${VersionString}.dmp"
	$ScriptFileContent = $ScriptFileContent.Replace("<ExportBackUpFile>",$ExportFileName)
	
	set-content -path $OdiScmRepositoryBackUpBat -value $ScriptFileContent
	
	write-host "$IM ends"
	
	return $True
}

#
# Generate the script to set up the OdiScm ODI repository metadata infrastructure.
#
function SetOdiScmRepoCreateInfractureSqlContent {
	
	$FN = "SetOdiScmRepoCreateIntractureBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	#
	# Set up the OdiScm metadata infrastructure creation script.
	#
	$ScriptFileContent = get-content $OdiScmRepoInfrastructureSetupSqlTemplate | out-string
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoUserName>",$OdiRepoSECURITY_USER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPassWord>",$OdiRepoSECURITY_UNENC_PWD)
	
	###$OraConn = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$OdiRepoSECURITY_URL_SERVER)(PORT=$OdiRepoSECURITY_URL_PORT))(CONNECT_DATA=(SID=$OdiRepoSECURITY_URL_SID))))"
	$OraConn = "$OdiRepoSECURITY_URL_SERVER:$OdiRepoSECURITY_URL_PORT/$OdiRepoSECURITY_URL_SID"
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoConnectionString>",$OraConn)
	set-content -path $OdiScmRepoInfrastructureSetupSql -value $ScriptFileContent
	
	write-host "$IM ends"
	
	return $True
}

#
# Generate the script to set up the OdiScm ODI repository metata infrastructure.
#
function SetOdiScmRepoSetNextImportSqlContent ($NextImportChangeSetRange) {
	
	$FN = "SetOdiScmRepoSetNextImportSqlContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	#
	# Set up the OdiScm metadata update script.
	#
	$SCMBranchUrl = $OdiScmConfig["SCM System"]["Branch Url"]
	
	$ScriptFileContent = get-content $OdiScmRepoSetNextImportTemplate | out-string
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmBranchUrl>",$SCMBranchUrl)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmNextImportRevison>",$NextImportChangeSetRange)
	
	set-content -path $OdiScmRepoSetNextImport -value $ScriptFileContent
	
	write-host "$IM ends"
	return $True
}

#
# Generate the build note content.
#
function SetOdiScmBuildNoteContent ($VersionRange) {
	
	$FN = "SetOdiScmBuildNoteContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	$NoteText = get-content $OdiScmBuildNoteTemplate | out-string
	if (!($?)) {
		write-host "$EM getting build note tempate text from template file <$OdiScmBuildNoteTemplate>"
		return $False
	}
	
	$NoteText = $NoteText.Replace("<ScmSystemTypeName>" , $OdiScmConfig["SCM System"]["Type Name"])
	$NoteText = $NoteText.Replace("<ScmSystemUrl>"      , $OdiScmConfig["SCM System"]["System Url"])
	$NoteText = $NoteText.Replace("<ScmBranchUrl>"      , $OdiScmConfig["SCM System"]["Branch Url"])
	$NoteText = $NoteText.Replace("<VersionRange>"      , $VersionRange)
	$NoteText = $NoteText.Replace("<WorkingCopyRootDir>", $WorkingCopyRootDir)
	
	set-content $OdiScmBuildNote $NoteText
	if (!($?)) {
		write-host "$EM setting build note tempate text in file <$OdiScmBuildNote>"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

#
# Generate the pre-ODI import script.
#
function SetOdiScmPreImportBatContent {
	
	$FN = "SetOdiScmPreImportBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using script template file <$OdiScmGenScenPreImportBatTemplate>"
	write-host "$IM setting content of pre ODI import script file <$OdiScmGenScenPreImportBat>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiScmGenScenPreImportBatTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<GenScriptRootDir>",$GenScriptRootDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmJisqlRepoBat>",$OdiScmJisqlRepoBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmHomeDir>",$OdiScmHomeDir)
	set-content -path $OdiScmGenScenPreImportBat -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate the Scenario deletion script generation script.
#
function SetOdiScmGenScenDeleteOldSqlContent {
	
	$FN = "SetOdiScmGenScenDeleteOldSqlContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using script template file <$OdiScmGenScenDeleteOldSqlTemplate>"
	write-host "$IM setting content of pre ODI import script file <$OdiScmGenScenDeleteOldSql>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiScmGenScenDeleteOldSqlTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmOdiStartCmdBat>",$OdiScmOdiStartCmdBat)
	set-content -path $OdiScmGenScenDeleteOldSql -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate the Scenario generation script generation script.
#
function SetOdiScmGenScenNewSqlContent {
	
	$FN = "SetOdiScmGenScenNewSqlContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using script template file <$OdiScmGenScenNewSqlTemplate>"
	write-host "$IM setting content of pre ODI import script file <$OdiScmGenScenNewSql>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiScmGenScenNewSqlTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmOdiStartCmdBat>",$OdiScmOdiStartCmdBat)
	set-content -path $OdiScmGenScenNewSql -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate the pre-ODI import script.
#
function SetOdiScmPostImportBatContent {
	
	$FN = "SetOdiScmPostImportBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using script template file <$OdiScmGenScenPostImportBatTemplate>"
	write-host "$IM setting content of script file <$OdiScmGenScenPostImportBat>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiScmGenScenPostImportBatTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiHomeDir>",$OdiHomeDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<GenScriptRootDir>",$GenScriptRootDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenScenDeleteOldSql>",$OdiScmGenScenDeleteOldSql)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenScenNewSql>",$OdiScmGenScenNewSql)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmJisqlRepoBat>",$OdiScmJisqlRepoBat)
	
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmHomeDir>",$OdiScmHomeDir)
	set-content -path $OdiScmGenScenPostImportBat -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate a batch file to execute the ODI object unit tests.
#
function GenerateUnitTestExecScript($strOutputFile) {
	
	$FN = "GenerateUnitTestExecScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	write-host "$IM output will be written to file <$strOutputFile>"
	
	#
	# Generate the list of FitNesse command line calls.
	#
	$CmdOutput = ExecOdiRepositorySql "$ScriptsRootDir\OdiScmGenerateUnitTestExecs.sql" "$env:TEMPDIR" "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmJisqlRepo.bat"
	if (! $CmdOutput) {
		write-host "$EM error generating ODI unit test execution calls list"
		return $ExitStatus
	}
	
	#
	# Write the output batch file.
	#
	$arrOutFileLines = @()
	$arrOutFileLines += '@echo off'
	
	$strOutPutFileName = (split-path $strOutputFile -leaf) -replace ".bat", ""
	
	$arrOutFileLines += ('set PROC=' + $strOutPutFileName)
	$arrOutFileLines += 'set IM=%PROC%: INFO:'
	$arrOutFileLines += 'set EM=%PROC%: ERROR:'
	$arrOutFileLines += 'echo %IM% starts'
	$arrOutFileLines += ''
	$arrOutFileLines += 'if "%ODI_SCM_HOME%" == "" ('
	$arrOutFileLines += '	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME 1>&2'
	$arrOutFileLines += '	goto ExitFail'
	$arrOutFileLines += ')'
	$arrOutFileLines += ''
	$arrOutFileLines += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0'
	$arrOutFileLines += ''
	$arrOutFileLines += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*'
	$arrOutFileLines += 'if ERRORLEVEL 1 ('
	$arrOutFileLines += '	echo %EM% processing script arguments 1>&2'
	$arrOutFileLines += '	goto ExitFail'
	$arrOutFileLines += ')'
	$arrOutFileLines += ''
	$arrOutFileLines += 'set OLDPWD=%CD%'
	$arrOutFileLines += ('cd /d "' + $env:ODI_SCM_TOOLS_FITNESSE_HOME + '"')
	$arrOutFileLines += 'if ERRORLEVEL 1 ('
	$arrOutFileLines += ('	echo %EM% changing working directory to FitNesse home directory ^<' + $env:ODI_SCM_TOOLS_FITNESSE_HOME + '^> 1>&2')
	$arrOutFileLines += '	goto ExitFail'
	$arrOutFileLines += ')'
	$arrOutFileLines += ''
	$arrOutFileLines += 'set TOTALTESTPAGES=0'
	$arrOutFileLines += 'set TOTALTESTFAILURES=0'
	$arrOutFileLines += 'set TOTALTESTPAGEPASSES=0'
	$arrOutFileLines += 'set TOTALTESTPAGEFAILURES=0'
	$arrOutFileLines += 'set TOTALTESTPAGESMISSING=0'
	$arrOutFileLines += 'setlocal enabledelayedexpansion'
	$arrOutFileLines += ''
	
	$arrCmdOutput = ($CmdOutput -replace "ExecOdiRepositorySql:", "").split("`n")
	
	foreach ($CmdOutputLine in $arrCmdOutput) {
		
		###write-host "$IM processing query result row <$CmdOutputLine>"
		$strNoCR = $CmdOutputLine -replace "`r", ""
		$strNoCR = $strNoCR -replace "`n", ""
		$strNoCR = $strNoCR.Trim()
		$arrOutputLineParts = $strNoCR.split("/")
		$strOdiObj = "Type:" + $arrOutputLineParts[1] + '/ID:' + $arrOutputLineParts[2] + '/Name:' + $arrOutputLineParts[3]
		$arrOutFileLines += ('echo %IM% executing unit tests for ODI object ^<' + $strOdiObj + '^>')
		$arrOutFileLines += 'set /a TOTALTESTPAGES=%TOTALTESTPAGES% + 1'
		
		$strFitNesseCmd  = ('"' + $env:ODI_SCM_TOOLS_FITNESSE_JAVA_HOME + '\bin\java.exe" -jar lib/fitnesse-standalone.jar ')
		$strFitNesseCmd += ('-d "' + $env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT +'" -r "' + $env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME + '" ')
		$strFitNesseCmd += ('-p ' + $env:ODI_SCM_TEST_FITNESSE_PORT + ' ')
		$strFitNesseCmd += '-c "'
		
		$strTestPagePath = ""
		
		if ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME -ne "") {
			$strTestPagePath += ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME + '.')
		}
		
		if (($arrOutputLineParts[0] -ne "") -and ($arrOutputLineParts[0] -ne $Null)) {
			$strTestPagePath += ('OdiProject' + $arrOutputLineParts[0] + '.')
		}
		
		$strTestPagePath += ('Odi' + $arrOutputLineParts[1] + $arrOutputLineParts[2])
		$strFitNesseCmd += $strTestPagePath
		$strFitNesseCmd += ('?test&format=' + $env:ODI_SCM_TEST_FITNESSE_OUTPUT_FORMAT + '"')
		
		$strTestPageFilePath = ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT).Replace("/","\") + "\" + ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME).Replace(".","\") + "\" + $strTestPagePath.Replace(".","\")

		$arrOutFileLines += 'if not EXIST "' + $strTestPageFilePath + '\content.txt" ('
		$arrOutFileLines += ('	echo %EM% cannot find FitNesse test content file ^<' + $strTestPageFilePath + '^>')
		$arrOutFileLines += '	set TESTFAILURES=0'
		$arrOutFileLines += '	set /a TOTALTESTPAGESMISSING=!TOTALTESTPAGESMISSING! + 1'
		$arrOutFileLines += ') else ('
		$arrOutFileLines += ('	' + $strFitNesseCmd)
		$arrOutFileLines += '	set TESTFAILURES=!ERRORLEVEL!'
		$arrOutFileLines += '	if not "!TESTFAILURES!" == "0" ('
		$arrOutFileLines += '		echo %EM% tests failed 1>&2'
		$arrOutFileLines += '		set /a TOTALTESTFAILURES=!TOTALTESTFAILURES! + !TESTFAILURES!'
		$arrOutFileLines += '		set /a TOTALTESTPAGEFAILURES=!TOTALTESTPAGEFAILURES! + 1'
		$arrOutFileLines += '	) else ('
		$arrOutFileLines += '		echo %IM% tests passed'
		$arrOutFileLines += '		set /a TOTALTESTPAGEPASSES=!TOTALTESTPAGEPASSES! + 1'
		$arrOutFileLines += '	)'
		$arrOutFileLines += ')'
		$arrOutFileLines += 'set /a TOTALTESTFAILURES=!TOTALTESTFAILURES! + !TESTFAILURES!'
		$arrOutFileLines += ''
	}
	
	$arrOutFileLines += 'echo %IM% total test pages attempted ^<%TOTALTESTPAGES%^>'
	$arrOutFileLines += 'echo %IM% total test page failures ^<%TOTALTESTPAGEFAILURES%^>'
	$arrOutFileLines += 'echo %IM% total test page passes ^<%TOTALTESTPAGEPASSES%^>'
	$arrOutFileLines += 'echo %IM% total test pages missing ^<%TOTALTESTPAGESMISSING%^>'
	$arrOutFileLines += 'echo %IM% total test failures ^<%TOTALTESTFAILURES%^>'
	$arrOutFileLines += ''
	$arrOutFileLines += 'set /a TOTALFAILURES=%TOTALTESTFAILURES% + %TOTALTESTPAGESMISSING%'
	$arrOutFileLines += ''
	$arrOutFileLines += 'echo %IM% total failures ^<%TOTALFAILURES%^>'
	$arrOutFileLines += ''
	$arrOutFileLines += 'if not "%TOTALFAILURES%" == "0" ('
	$arrOutFileLines += '	echo %EM% unit tests have failed 1>&2'
	$arrOutFileLines += '	goto ExitFail'
	$arrOutFileLines += ')'
	$arrOutFileLines += ''
	$arrOutFileLines += ':ExitOk'
	$arrOutFileLines += 'exit %IsBatchExit% 0'
	$arrOutFileLines += ''
	$arrOutFileLines += ':ExitFail'
	$arrOutFileLines += 'exit %IsBatchExit% 1'
	
	$arrOutFileLines | set-content $strOutputFile
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate the top level script that performs the entire import/build process.
#
function SetTopLevelScriptContent ($NextImportChangeSetRange) {
	
	$FN = "SetTopLevelScriptContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using top level build script template file <$OdiScmBuildBatTemplate>"
	write-host "$IM setting content of top level build script file <$OdiScmBuildBat>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiScmBuildBatTemplate | out-string
	
	#
	# Set the script path/names, etc.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiHomeDir>", $OdiHomeDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiJavaHomeDir>", $OdiJavaHomeDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmHomeDir>", $OdiScmHomeDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmIniFile>", $SCMConfigurationFile)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmJisqlHomeDir>", $JisqlHomeDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmJisqlJavaHomeDir>", $JisqlJavaHomeDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OracleHomeDir>", $OracleHomeDir)
	
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmRepositoryBackUpBat>",$OdiScmRepositoryBackUpBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenScenPreImportBat>",  $OdiScmGenScenPreImportBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiImportScriptFile>", $OdiImportScriptFile)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmJisqlRepoBat>", $OdiScmJisqlRepoBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmValidateRepositoryIntegritySql>", $OdiScmValidateRepositoryIntegritySql)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmRestoreRepositoryIntegritySql>", $OdiScmRestoreRepositoryIntegritySql)    
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenScenPostImportBat>", $OdiScmGenScenPostImportBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<SCMConfigurationFile>", $SCMConfigurationFile)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmLatestChangeSet>", $NextImportChangeSetRange)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmSetNextImportSql>", $OdiScmRepoSetNextImport)
	$ScriptFileContent = $ScriptFileContent.Replace("<GenScriptRootDir>", $GenScriptRootDir)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmUnitTestExecBat>", $OdiScmUnitTestExecBat)
	
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmUpdateIniAwk>", $OdiScmUpdateIniAwk)
	
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiStandardsCheckScript>", $OdiScmConfig["Test"]["ODI Standards Script"])
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenerateImportResetsFlushControl>", $OdiScmConfig["Generate"]["Import Resets Flush Control"])
	
	set-content -path $OdiScmBuildBat -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function ExecOdiRepositorySql($SqlScriptFile, $strWorkDir, $strJiqlRepoBat) {
	
	$FN = "ExecOdiRepositorySql"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	$ExitStatus = $True
	
	write-host "$IM SQL script file is <$SqlScriptFile>"
	
	#
	# Capture the command output and display it so that it does not get returned
	# by this function.
	#
	$SqlScriptFileName = split-path $SqlScriptFile -leaf
	$StdOutLogFile = "$strWorkDir\ExecOdiRepositorySql_${SqlScriptFileName}_StdOut_${VersionString}.log"
	$StdErrLogFile = "$strWorkDir\ExecOdiRepositorySql_${SqlScriptFileName}_StdErr_${VersionString}.log"
	write-host "$IM StdOut will be captured in file <$StdOutLogFile>"
	write-host "$IM StdErr will be captured in file <$StdErrLogFile>"
	
	write-host "$IM executing command <$strJiqlRepoBat $SqlScriptFile $StdOutLogFile $StdErrLogFile>"
	$CmdOutput = invoke-expression "$strJiqlRepoBat $SqlScriptFile $StdOutLogFile $StdErrLogFile"
	$BatchExitCode = $LastExitCode
	
	write-host "$IM command returned exit status <$BatchExitCode>"
	
	if ($BatchExitCode -eq 0) {
		write-host "$IM execution of command completed successfully"
		
		if (test-path $StdErrLogFile) {
			$StdErrText = get-content $StdErrLogFile | out-string
			if (($StdErrText.Trim()).length -ne 0) {
				write-host "$EM executed script produced StdErr output"
				write-host "$EM command captured StdErr >>>"
				write-host (get-content $StdErrLogFile)
				write-host "$EM <<< end of command captured StdErr"
				
				$ExitStatus = $False
				return $ExitStatus
			}
		}
	}
	else {
		write-host "$EM execution of command failed with exit status <$BatchExitCode>"
		
		write-host "$EM command output >>>"
		write-host $CmdOutput
		write-host "$EM <<< end of command output"
		
		if (test-path $StdOutLogFile) {
			write-host "$EM command captured StdOut >>>"
			write-host (get-content $StdOutLogFile)
			write-host "$EM <<< end of command captured StdOut"
		}
		
		if (test-path $StdErrLogFile) {
			write-host "$EM command captured StdErr >>>"
			write-host (get-content $StdErrLogFile)
			write-host "$EM <<< end of command captured StdErr"
		}
		$ExitStatus = $False
		return $ExitStatus
	}
	
	$StdOutText = get-content $StdOutLogFile | out-string
	write-host "$IM ends"
	
	return ($FN + ":" + $StdOutText.Trim())
}

function GetNewChangeSetNumber {
	
	$SCMSystemTypeName = $OdiScmConfig["SCM System"]["Type Name"]
	
	switch ($SCMSystemTypeName) {
		"TFS" { GetNewTFSChangeSetNumber }
		"SVN" { GetNewSVNRevisionNumber }
	}
}

#
# Get the latest revision number from the SVN repository.
#
function GetNewSVNRevisionNumber {
	
	$FN = "GetNewSVNRevisionNumber"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	write-host "$IM Getting the latest revision number from the SVN repository"
	
	#
	# Generate a unique file name (with path included).
	#
	$SCMSystemUrl = $OdiScmConfig["SCM System"]["System Url"]
	$SCMBranchUrl = $OdiScmConfig["SCM System"]["Branch Url"]
	
	$CmdLine = "svn.exe info ${SCMSystemUrl}/${SCMBranchUrl}"
	$CmdOutput = invoke-expression $CmdLine
	if ($LastExitCode -ne 0) {
		write-host "$EM executing command <$CmdLine>"
		return $False
	}
	
	$NewRevNo = ""
	
	foreach ($CmdOutputLine in $CmdOutput) {
		if ($CmdOutputLine.StartsWith("Last Changed Rev:")) {
			$NewRevNo = $CmdOutputLine.Replace("Last Changed Rev:","").Trim()
		}
	}
	
	write-host "$IM new Revision number is <$NewRevNo>"
	
	write-host "$IM ends"
	return $NewRevNo
}

#
# Get the latest ChangeSet number from the TFS server.
#
function GetNewTFSChangeSetNumber {
	
	$FN = "GetNewTFSChangeSetNumber"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	write-host "$IM Getting the latest ChangeSet number from the TFS server"
	
	$SCMSystemUrl = $OdiScmConfig["SCM System"]["System Url"]
	$SCMBranchUrl = $OdiScmConfig["SCM System"]["Branch Url"]
	
	$SCMGlobalUserName = $OdiScmConfig["SCM System"]["Global User Name"]
	$SCMGlobalUserPassword = $OdiScmConfig["SCM System"]["Global User Password"]
	
	#
	# Generate a unique file name (with path included).
	#
	$CmdLine = "tf.exe changeset /latest /noprompt /collection:$SCMSystemUrl 2>&1"
	if ($SCMGlobalUserName -ne "" -and $SCMGlobalUserName -ne $Null) {
		# Note: the single quotes are required to prevent Invoke-Expression interpreting the comma as a list/array.
		$CmdLine += " '/login:$SCMGlobalUserName,$SCMGlobalUserPassword'"
	}
	LogDebug "$FN" "executing command line <$CmdLine>"
	$CmdStdOutStdErr = invoke-expression $CmdLine | foreach { $_.ToString() } | out-string
	$changesetText = $CmdStdOutStdErr -replace "\r", " "
	$changesetText = $changesetText -replace "\n", " "
	LogDebug "$FN" "cleaned commnand output <$changesetText>"
	
	$TfDeniedAccessTextHead = "needs Read permission(s) for at least one item in changeset"
	$TfDeniedAccessTextTail = "."
	if ($changesetText.IndexOf($TfDeniedAccessTextHead) -gt 1) {
		write-host "$IM extracting latest ChangeSet number from denied access error message"
		$newChangeset = $changesetText.Substring($changesetText.IndexOf($TfDeniedAccessTextHead) + $TfDeniedAccessTextHead.length)
		$newChangeset = $newChangeset.substring(0, $newChangeset.indexof($TfDeniedAccessTextTail))
	}
	else {
		write-host "$IM extracting latest ChangeSet number from ChangeSet text"
		$TfChangeSetText = "Changeset:"
		$TfUserText = "User: "
		$TfChangeSetTextLen = $TfChangeSetText.length
		$ChangeSetTextChangeSetPos = $changesetText.IndexOf($TfChangeSetText)
		$ChangeSetTextUserPos = $changesetText.IndexOf($TfUserText)
		$newChangeset = $changesetText.Substring($ChangeSetTextChangeSetPos + $TfChangeSetTextLen, $ChangeSetTextUserPos - $ChangeSetTextChangeSetPos - $TfChangeSetTextLen - 1)
	}
	
	$ChangeSetLog = $newChangeset.Trim()
	write-host "$IM new ChangeSet number is <$ChangeSetLog>"
	
	write-host "$IM ends"
	return $ChangeSetLog
}

#
# Validate a ChangeSet range string.
#
function ChangeSetRangeIsValid ([string] $ChangeSetRange) {
	
	if (! $ChangeSetRange.contains("~")) {
		return $False
	}
	
	if ($ChangeSetRange.substring(0,1) -eq "~") {
		return $False
	}
	
	$intTildeCount = 0
	$arrCharRange = $ChangeSetRange.ToCharArray()
	
	$arrCharRange | foreach-object -process {
		if ($_ -eq "~") {
			$intTildeCount += 1
		}
	}
	
	if ($intTildeCount -gt 1) {
		return $False
	}
	
	[array] $ChangeSetParts = @([regex]::split($ChangeSetRange,"~"))
	
	[boolean] $IsNumber = $False
	
	[int]::TryParse($ChangeSetRange[0],[ref]$IsNumber)
	if (! $IsNumber) {
		return $False
	}
	
	[int] $intFromChangeSet = $ChangeSetRange[0]
	
	[int]::TryParse($ChangeSetRange[0],[ref]$IsNumber)
	
	if ($ChangeSetRange[1] -eq "") {
		return $True
	}
	
	[int]::TryParse($ChangeSetRange[1],[ref]$IsNumber)
	if (! $IsNumber) {
		return $False
	}
	
	[int] $intToChangeSet = $ChangeSetRange[1]
	
	if ($intFromChangeSet -gt $intToChangeSet) {
		return $False
	}
	
	if ($intFromChangeSet -lt 1 -or $intFromChangeSet -gt 2147483647) {
		return $False
	}
	
	if ($intFromChangeTo -lt 1 -or $intFromChangeTo -gt 2147483647) {
		return $False
	}
	
	return $True
}

#
# Write consolidated ODI source object files to $GenScriptConsObjSrcDir and return
# the list of new files in the array referenced by $OutFileList.
#
function CreateConsolidatedFiles ($FileList, [ref] $OutFileList) {
	
	$FN = "CreateConsolidatedFiles"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	$ExitStatus = $False
	
	write-host "$IM passed <$($FileList.length)> files to consolidate"
	
	$intBatchCount = 0
	$intBatchNumber = 0
	$arrStrFileBatch = @()
	
	$ImpObjBatchSizeMax = $OdiScmConfig["Generate"]["Import Object Batch Size Max"]
	
	#
	# Loop through each extension and find files for which to include import commands.
	#
	foreach ($ext in $orderedExtensions) {
		
		$fileObjType = $ext.Replace("*.","")
		write-host "$IM processing object type <$fileObjType>"
		
		foreach ($FileToImport in $FileList) {
			
			if ($FileToImport.EndsWith($fileObjType)) {
				$arrStrFileBatch += $FileToImport
				$intBatchCount += 1
				
				if ($intBatchCount -eq $ImpObjBatchSizeMax) {
					#
					# It's time to write out a batch.
					#
					$intBatchNumber += 1
					$strBatchOutFile = "$GenScriptConsObjSrcDir\Consolidated_$intBatchNumber.$fileObjType"
					$OutFileList.value += $strBatchOutFile
					if (!(CreateConsolidatedOdiSourceFile $arrStrFileBatch $strBatchOutFile)) {
						write-host "$EM creating consolidated object source file number <$intBatchNumber> for object type <$fileObjType>"
						return $False
					}
					
					# Reinitialise the batch.
					$arrStrFileBatch = @()
					$intBatchCount = 0
				}
			}
		}
		
		if ($intBatchCount -gt 0) {
			#
			# There are unconsolidated files for the current object type.
			#
			$intBatchNumber += 1
			$strBatchOutFile = "$GenScriptConsObjSrcDir\Consolidated_$intBatchNumber.$fileObjType"
			$OutFileList.value += $strBatchOutFile
			
			if (!(CreateConsolidatedOdiSourceFile $arrStrFileBatch $strBatchOutFile)) {
				write-host "$EM creating consolidated object source file number <$intBatchNumber> for object type <$fileObjType>"
				return $False
			}
			
			# Reinitialise the batch.
			$arrStrFileBatch = @()
			$intBatchCount = 0
		}
	}
	
	write-host "$IM created <$intBatchNumber> consolidated ODI object source files"
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Concatenate ODI object source files for much faster imports.
#
function CreateConsolidatedOdiSourceFile ($fileList, $outFile) {
	
	$FN = "CreateConsolidatedOdiSourceFile"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM creating consolidated ODI object source file <$strBatchOutFile>"
	#write-host "otuput file is " $outfile
	$outRecordList = @()
	
	$outRecordList += '<?xml version="1.0" encoding="ISO-8859-1"?>'
	$outRecordList += '<SunopsisExport>'
	
	foreach ($File in $FileList) {
		
		write-host "$IM processing object source file <$file>"
		$RecordList = get-content $File
		
		$blnFoundXmlDocHeader           = $False
		#$blnFoundXmlDocTrailer         = $False
		$blnFoundExportHeader           = $False
		#$blnFoundExportTrailer         = $False
		$blnFoundAdminRepositoryVersion = $False
		$blnFoundSummaryHeader          = $False
		#$blnFoundSummaryTrailer        = $False
		
		if ($RecordList.length -lt 3) {
			write-error "$EM object source file contains less records that the minimum necessary for an ODI object"
			return $False
		}
		
		if ($RecordList[0] -ne '<?xml version="1.0" encoding="ISO-8859-1"?>') {
			write-error "$EM first record does not contain the XML document header"
			return $False
		}
		
		if ($RecordList[1] -ne '<SunopsisExport>') {
			write-error "$EM second record does not contain the <SunopsisExport> tag"
			return $False
		}
		
		for ($intRecIdx = 2; $intRecIdx -lt $RecordList.length; $intRecIdx++) {
			
			$Record = $RecordList[$intRecIdx]
			
			###write-host "$IM processing record <$Record>"
			$blnSuppressRecord = $False
			
			if (!($blnFoundAdminRepositoryVersion)) {
				if ($Record.StartsWith('<Admin RepositoryVersion="')) {
					continue
				}
			}
			
			#
			# Check every non XML / export header record for the summary header.
			#
			if ($Record -eq '<Object class="com.sunopsis.dwg.DwgExportSummary">') {
				break
			}
			
			$outRecordList += $Record
		}
	}
	
	$outRecordList += '</SunopsisExport>'
	write-host "$IM starting to write file <$outFile>"
	$outRecordList | set-content $outFile
	write-host "$IM finished writing file <$outFile>"
	return $True
}

#
# Expand ODI variables, and complete SET statements, in batch file script text.
#
function OdiExpandedBatchScriptText ($arrInText) {
	
	$FN = "OdiExpandedBatchScriptText"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	write-host "$IM starts"
	
	#
	# Expand variable values.
	#
	$ScriptFileContent = $arrInText

	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_HOME%"         , $env:ODI_SCM_ORACLEDI_HOME }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_JAVA_HOME%"    , $env:ODI_SCM_ORACLEDI_JAVA_HOME }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%JAVA_HOME%"        , $env:ODI_SCM_ORACLEDI_JAVA_HOME }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_SECU_WORK_REP%", $env:ODI_SCM_ORACLEDI_SECU_WORK_REP }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_USER%"         , $env:ODI_SCM_ORACLEDI_USER }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_ENCODED_PASS%" , $env:ODI_SCM_ORACLEDI_ENCODED_PASS }
	#
	# ODI 10g variables.
	#
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_SECU_DRIVER%"      , $env:ODI_SCM_ORACLEDI_SECU_DRIVER }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_SECU_URL%"         , $env:ODI_SCM_ORACLEDI_SECU_URL }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_SECU_USER%"        , $env:ODI_SCM_ORACLEDI_SECU_USER }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_SECU_ENCODED_PASS%", $env:ODI_SCM_ORACLEDI_SECU_ENCODED_PASS }
	#
	# ODI 11g variables.
	#
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_MASTER_DRIVER%"      , $env:ODI_SCM_ORACLEDI_SECU_DRIVER }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_MASTER_URL%"         , $env:ODI_SCM_ORACLEDI_SECU_URL }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_MASTER_USER%"        , $env:ODI_SCM_ORACLEDI_SECU_USER }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "%ODI_MASTER_ENCODED_PASS%", $env:ODI_SCM_ORACLEDI_SECU_ENCODED_PASS }
	
	#
	# Modify variable SET statements.
	#
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_HOME=.*$"         , "set ODI_HOME=$env:ODI_SCM_ORACLEDI_HOME" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_JAVA_HOME=.*$"    , "set ODI_JAVA_HOME=$env:ODI_SCM_ORACLEDI_JAVA_HOME" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set JAVA_HOME=.*$"        , "set JAVA_HOME=$env:ODI_SCM_ORACLEDI_JAVA_HOME" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_SECU_WORK_REP=.*$", "set ODI_SECU_WORK_REP=$env:ODI_SCM_ORACLEDI_SECU_WORK_REP" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_USER=.*$"         , "set ODI_USER=$env:ODI_SCM_ORACLEDI_USER" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_ENCODED_PASS=.*$" , "set ODI_ENCODED_PASS=$env:ODI_SCM_ORACLEDI_ENCODED_PASS" }
	#
	# ODI 10g variables.
	#
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_SECU_DRIVER=.*$"      , "set ODI_SECU_DRIVER=$env:ODI_SCM_ORACLEDI_SECU_DRIVER" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_SECU_URL=.*$"         , "set ODI_SECU_URL=$env:ODI_SCM_ORACLEDI_SECU_URL" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_SECU_USER=.*$"        , "set ODI_SECU_USER=$env:ODI_SCM_ORACLEDI_SECU_USER" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_SECU_ENCODED_PASS=.*$", "set ODI_SECU_ENCODED_PASS=$env:ODI_SCM_ORACLEDI_SECU_ENCODED_PASS" }
	#
	# ODI 11g variables.
	#
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_MASTER_DRIVER=.*$"      , "set ODI_MASTER_DRIVER=$env:ODI_SCM_ORACLEDI_SECU_DRIVER" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_MASTER_URL=.*$"         , "set ODI_MASTER_URL=$env:ODI_SCM_ORACLEDI_SECU_URL" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_MASTER_USER=.*$"        , "set ODI_MASTER_USER=$env:ODI_SCM_ORACLEDI_SECU_USER" }
	$ScriptFileContent = $ScriptFileContent | foreach { $_ -replace "^set ODI_MASTER_ENCODED_PASS=.*$", "set ODI_MASTER_ENCODED_PASS=$env:ODI_SCM_ORACLEDI_SECU_ENCODED_PASS" }
	
	write-host "$IM ends"
	
	return $ScriptFileContent
}

#
# Create an odiparams.bat script with ODI variables expanded, and completed SET statements.
#
function CreateOdiParamsExpandedBatchScript ($strOutFile) {
	
	$FN = "CreateOdiParamsExpandedBatchScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	write-host "$IM starts"
	
	$OdiParamsBat = $env:ODI_SCM_ORACLEDI_HOME + "\bin\odiparams.bat"
	if (!(test-path $OdiParamsBat)) {
		write-output "$EM odiparams.bat batch script not found in ODI bin directory <$env:ODI_SCM_ORACLEDI_HOME\bin>"
		return $False
	}
	
	#
	# Load odiparams.bat into an array.
	#
	[array] $arrOdiParamsContent = get-content $OdiParamsBat
	
	#
	# Expand variable values and complete SET statements.
	#
	$ExpandedOdiParamsContent = OdiExpandedBatchScriptText $arrOdiParamsContent
	
	#
	# Create the output file.
	#
	set-content -path $strOutFile -value $ExpandedOdiParamsContent
	if (!($?)) {
		write-output "$EM writing output file <$strOutFile> "
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function PrimeWriteHost {
	
	$FN = "PrimeWriteHost"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	$OdiScmBannerText = get-content "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmBanner.txt" | out-string
	write-host $OdiScmBannerText
}

#===================================================================
# Set fixed configuration and script level constants.
#===================================================================

#
# A string used to create unique generated script and log file names.
#
$VersionString = get-date -format "yyyyMMdd_HHmmss"

$WorkingCopyRootDir = ""

$ConfigurationFolder = $env:ODI_SCM_HOME + "\Configuration"

#
# OdiScm configuration read from/written to INI file.
#
$OdiScmConfig = $Null

#
# Local environment definition.
#
$SCMConfigurationFile = $env:ODI_SCM_INI
$SCMConfigurationFileName = split-path -leaf -path "$SCMConfigurationFile"
$ScriptsRootDir = $ConfigurationFolder + "\Scripts"

#
# Fixed utility script and file locations and names.
#
$MoiTempEmptyFile = $ConfigurationFolder + "\EmptyFileDoNotDelete.txt"
$OdiScmValidateRepositoryIntegritySql = $ScriptsRootDir + "\OdiScmValidateRepositoryIntegrity.sql"
$OdiScmRestoreRepositoryIntegritySql = $ScriptsRootDir + "\OdiScmRestoreRepositoryIntegrity.sql"
$OdiScmUpdateIniAwk = $ScriptsRootDir + "\OdiScmUpdateIni.awk"

#
# Script Template locations and names.
#
$OdiScmRepositoryBackUpBatTemplate = $ScriptsRootDir + "\OdiScmRepositoryBackUpTemplate.bat"
$OdiScmJisqlRepoBatTemplate = $ScriptsRootDir + "\OdiScmJisqlRepoTemplate.bat"
$OdiScmBuildBatTemplate = $ScriptsRootDir + "\OdiScmBuildTemplate.bat"
$OdiScmGenScenPreImportBatTemplate = $ScriptsRootDir + "\OdiScmGenScenPreImportTemplate.bat"
$OdiScmGenScenPostImportBatTemplate = $ScriptsRootDir + "\OdiScmGenScenPostImportTemplate.bat"
$OdiScmGenScenDeleteOldSqlTemplate = $ScriptsRootDir + "\OdiScmGenScen20DeleteOldScenTemplate.sql"
$OdiScmGenScenNewSqlTemplate = $ScriptsRootDir + "\OdiScmGenScen40NewScenTemplate.sql"
$OdiScmRepoInfrastructureSetupSqlTemplate = $ScriptsRootDir + "\OdiScmCreateInfrastructureTemplate.sql"
$OdiScmRepoSetNextImportTemplate = $ScriptsRootDir + "\OdiScmSetNextImportTemplate.sql"
$OdiScmBuildNoteTemplate = $ScriptsRootDir + "\OdiScmBuildNoteTemplate.txt"

#
# Logging and generated scripts directory structure.
#
$LogRootDir = $OdiScmHomeDir + "\Logs"

#
# ODI configuration.
#
$OdiHomeDir = ""
$OdiJavaHomeDir = ""
$OdiParamFile = ""
$OdiJavaHomeDir = ""

#
# General Java configuration.
#
$JavaHomeDir = ""

#
# Jisql configuration.
#
$JisqlHomeDir = ""
$JisqlJavaHomeDir = ""

#
# Oracle client configuration.
#
$OracleHomeDir = ""

#
# The fixed or variable (derived) output tag.
#
$OutputTag = ""