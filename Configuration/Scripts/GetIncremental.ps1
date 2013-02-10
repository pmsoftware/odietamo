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
				LogDeug "$FN" "in section $section"
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
			LogDebug "$FN" "got a key"
			$name,$value = $matches[1..2]
			LogDebug "$FN" "name = $name"
			LogDebug "$FN" "value = $value"
			$ini[$section][$name] = $value
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
# Check that the required external commands are available.
#
function CheckDependencies {
	
	$FN = "CheckDependencies"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	if ($SCMSystemTypeName -eq "TFS") {
		$ToNull = tf.exe
		if ($LastExitCode -ne 0) {
			write-host "$EM command tf.exe is not available. Ensure PATH is correctly set"
			return $False
		}
		
		$ToNull = psexec.exe cmd /c dir
		if ($LastExitCode -ne 0) {
			write-host "$EM command psexec.exe is not available. Ensure PATH is correctly set"
			return $False
		}
	}
	elseif ($SCMSystemTypeName -eq "SVN") {
		$ToNull = svn.exe help
		if ($LastExitCode -ne 0) {
			write-host "$EM command svn.exe is not available. Ensure PATH is correctly set"
			return $False
		}
	}
	
	$ToNull = fgrep.exe --help
	if ($LastExitCode -ne 0) {
		write-host "$EM command fgrep.exe is not available. Ensure PATH is correctly set"
		return $False
	}
	
	write-host "$IM completed checking dependencies"
	return $True
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

function GetNewChangeSetNumber {
	
	$SCMSystemTypeName = $OdiScmConfig["SCMSystem"]["SCMSystemTypeName"]
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
	$SCMSystemUrl = $OdiScmConfig["SCMSystem"]["SCMSystemUrl"]
	$SCMBranchUrl = $OdiScmConfig["SCMSystem"]["SCMBranchUrl"]
	
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
	
	$SCMSystemUrl = $OdiScmConfig["SCMSystem"]["SCMSystemUrl"]
	$SCMBranchUrl = $OdiScmConfig["SCMSystem"]["SCMBranchUrl"]
	
	#
	# Generate a unique file name (with path included).
	#
	$TempFileNameStub = "$GenScriptRootDir\psexec_out_${VersionString}"
	
	$CmdArgs = '"' + "changeset /noprompt /latest /server:${SCMSystemUrl}" + '"'
	$CmdLine = "psexec.exe -u GBBUPAGROUP\moidevdeploy -p P1rsl3y cmd.exe /c " + '"' + "$ScriptsRootDir\OdiSvnRedirCmd.bat" + '" "' + "tf.exe" + '" "' + "$TempFileNameStub" + '"' + " $CmdArgs"
	###write-host "running: $CmdLine"
	invoke-expression $CmdLine
	
	$changesetText = get-content "$TempFileNameStub.stdout" | out-string
	
	if ($changesetText.IndexOf("needs Read permission(s) for at least one item in changeset") -gt 1) {
		$newChangeset = $changesetText.Substring($changesetText.IndexOf("at least one item in changeset") + "at least one item in changeset".length, 6)
	}
	else {
		$changeset = "Changeset:"
		$user = "User: "
		$changeset_len = $changeset.length 
		$newChangeset = $changesetText.Substring($changesetText.IndexOf($changeset) + $changeset_len, $changesetText.IndexOf($user) - $changesetText.IndexOf($changeset) - $changeset_len - 1)
	}
	
	$ChangeSetLog = $newChangeset.Trim()
	write-host "$IM new ChangeSet number is <$ChangeSetLog>"
	
	write-host "$IM ends"
	return $ChangeSetLog
}

#
# Get the list of changed files in the received ChangeSet range by parsing the details of each ChangeSet
# obtained from the TFS server.
#
# function GetTFSDifference ([string] $difference) {
	
	# $IM = "GetDifference: INFO:"
	# $EM = "GetDifference: ERROR:"
	# $DEBUG = "GetDifference: DEBUG:"
	
	# write-host "$IM starts"
	# write-host "$IM getting changed files list from TFS for Changesets <$difference>"
	
	# $difference = $difference.Replace(" ","")
	
	# write-host "$IM command to be executed <tf history $TFSBranchName /format:detailed /recursive /collection:${TFSServer} /version:${difference}>"
	
	# $CmdLine = "tf history " + '"' + $LocalBranchRoot + '"' + " /format:detailed /recursive /collection:${TFSServer} /version:${difference} | out-string"
	# $ChangeHistoryDiff = invoke-expression $CmdLine
	
	# #write-host "$DEBUG ChangeHistoryDiff: " $ChangeHistoryDiff
	# $IndexCheckinNotes = $ChangeHistoryDiff.IndexOf("Check-in Notes:")
	# #write-host "$DEBUG IndexOf `'Check-in Notes`':" $IndexCheckinNotes
	# $IndexItems = $ChangeHistoryDiff.IndexOf("Items:") 
	# #write-host "$DEBUG IndexOf Items: " $IndexItems
	
	# $CountOfItemInList = 0
	# [array] $outFileList = @()
		
	# if ($ChangeHistoryDiff.IndexOf("Check-in Notes:") -gt 0) {
		
		# $ChangeLogList = @([regex]::split($ChangeHistoryDiff,"Changeset: "))
		
		# foreach ($item in $ChangeLogList) { 
		
			# #
			# # Don't process the first/empty element.
			# #
			# if ($CountOfItemInList -ne 0) {
				
				# $IndexCheckinNotes = $item.IndexOf("Check-in Notes:")
				# $IndexItems = $item.IndexOf("Items:") 
				# #write-host "$DEBUG IndexCheckinNotes:" $IndexCheckinNotes
				# #write-host "$DEBUG IndexTtems: " $IndexItems
				
				# $item2 = $item.Substring($item.IndexOf("Items:") + 6, $item.IndexOf("Check-in Notes:") - $item.IndexOf("Items:") - 6)
				# $item2 = $item2.Trim()
				# #write-host "$DEBUG item2: " $item2
				
				# $item3 = @([regex]::split($item2,[Environment]::NewLine))
				# #write-host "$DEBUG item3: " $item3
				# foreach ($item4 in $item3) {
					# $item5 = $item4.Replace("add ", "").Replace("edit ", "").Trim()
					# $item5 = $item5.Replace(("$/" + $TFSMoiProjectName + "/"),"")
					# #write-host ("$IM final parsed item>>>" + $item5 + "<<<")
					# #
					# ################## Ensure we add a file system rather than a string object to the output array.
					# #
					# #$item6 = get-childitem $item5
					# $item6 = $item5
					# #write-host "$IM adding to list" $item6.Fullname
					# #$outFileList += @($item6)
					# #
					# # Ignore the creation of the actual branch root in TFS.
					# #
					# if ($item6 -ne $TFSMoiBranchName) {
						# #write-host "$IM adding to list" $item6
						# $outFileList += $item6
					# }
					# #DebuggingPause
				# }
			# }
			# $CountOfItemInList += 1
		# }
	# }
	# else {
		# write-host "$IM there are no changed files"
	# }
	
	# # 
	# # Exception trap for any exception raised in all code in this function up until this point.
	# #
	# &{trap	{
			# write-host "$EM exception trapped <$_.Exception>"
			# #
			# # Return an null array upon failure.
			# #
			# return
		# }
	# }
	
	# write-host "$IM ends"
	# return $outFileList
# }

function GenerateOdiImportScript ([array] $filesToImport) {
	
	$FN = "GenerateOdiImportScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG"
	
	write-host "$IM starts"
	
	$ExitStatus = $False
	
	write-host "$IM passed <$($filesToImport.length)> files to import"
	write-host "$IM writing output to <$OdiImportScriptFile>"
	
	#
	# Import script initialisation commands - CWD to the ODI bin directory.
	#
	"@echo off" | out-file $OdiImportScriptFile -encoding ASCII -append
	("set IM=$OdiImportScriptName" + ": INFO:") | out-file $OdiImportScriptFile -encoding ASCII -append
	("set EM=$OdiImportScriptName" + ": ERROR:") | out-file $OdiImportScriptFile -encoding ASCII -append
	"set OLDPWD=%CD%" | out-file 
	"cd /d ${OdiBinDir}" | out-file $OdiImportScriptFile -encoding ASCII -append
	
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
				$extensionFileCount += 1
				
				$ImportText = "echo %IM% date time ^<%date%^> ^<%time%^>" + [Environment]::NewLine
				$ImportText += "set MSG=importing file ^<" + $FileToImportName + "^> from directory ^<" + $FileToImportPathName + "^>" + [Environment]::NewLine
				
				if (!($containerExtensions -contains $ext)) {
					$ImportText += "call startcmd.bat OdiImportObject -FILE_NAME=" + '"' + $fileToImport + '"' + " -IMPORT_MODE=$ODIImportModeInsertUpdate -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
				}
				else {
					$ImportText += "call startcmd.bat OdiImportObject -FILE_NAME=" + '"' + $fileToImport + '"' + " -IMPORT_MODE=$ODIImportModeInsert -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
					$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
					$ImportText += "call startcmd.bat OdiImportObject -FILE_NAME=" + '"' + $fileToImport + '"' + " -IMPORT_MODE=$ODIImportModeUpdate -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
				}
				$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
				$ImportText += "echo " + $OdiImportScriptName + ": INFO: import of file ^<" + $FileToImportName + "^> completed succesfully" + [Environment]::NewLine
				$ImportText | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
			}
		}
	}
	
	#
	# Import script termination commands - the common Exit labels.
	#
	":ExitOk" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"echo INFO: import process completed" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"cd /d %OLDPWD%" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"exit /b 0" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	":ExitFail" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"echo %EM% %MSG%" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"cd /d %OLDPWD%" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"exit /b 1" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	
	write-host "$IM lines in generated script content <$(((get-content $OdiImportScriptFile).Count)-1)>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GetOdiScmConfiguration {
	
	$FN = "GetOdiScmConfiguration"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	#
	# Load the SCM configuration, ODI home location, etc.
	#
	write-host "$IM using configuration file <$SCMConfigurationFile>"
	$script:OdiScmConfig = GetIniContent "$SCMConfigurationFile"
	if ($OdiScmConfig -eq $False) {
		write-host "$EM reading OdiScm configuration"
		return $False
	}
	
	if ((!($OdiScmConfig.ContainsKey("SCMSystem"))) -or (!($OdiScmConfig.ContainsKey("OracleDI")))) {
		write-host "$EM configuration INI file structure is invalid"
	}
	
	$SCMSystemTypeName = $OdiScmConfig["SCMSystem"]["SCMSystemTypeName"]
	
	if (($OdiScmConfig["SCMSystem"]["SCMSystemTypeName"] -eq $Null) -or ($OdiScmConfig["SCMSystem"]["SCMSystemTypeName"] -eq "")) {
		write-host "$EM cannot retrieve SCM System Type Name from configuration INI file"
		return $False
	}
	
	if ((($SCMSystemTypeName) -ne "TFS") -and (($SCMSystemTypeName) -ne "SVN")) {
		write-host "$EM retrieved unrecognised SCM System Type Name <$SCMSystemTypeName> from configuration INI file"
		return $False
	}
	
	$SCMSystemUrl = $OdiScmConfig["SCMSystem"]["SCMSystemUrl"]
	
	if (($SCMSystemUrl -eq $Null) -or ($SCMSystemUrl -eq "")) {
		write-host "$EM cannot retrieve SCM System URL from configuration INI file"
		return $False
	}
	
	$SCMBranchUrl = $OdiScmConfig["SCMSystem"]["SCMBranchUrl"]
	
	if (($SCMBranchUrl -eq $Null) -or ($SCMBranchUrl -eq "")) {
		write-host "$EM cannot retrieve SCM Branch URL from configuration INI file"
		return $False
	}
	
	$OdiHomeDir = $OdiScmConfig["OracleDI"]["OdiHomeDir"]
	
	if (($OdiHomeDir -eq $Null) -or ($OdiHomeDir -eq "")) {
		write-host "$EM cannot retrieve ODI home directory path from configuration INI file"
		return $False
	}
	
	write-host "$IM using SCM System Type Name <$SCMSystemTypeName>"
	write-host "$IM using SCM System URL       <$SCMSystemUrl>"
	write-host "$IM using SCM Branch URL       <$SCMBranchUrl>"
	write-host "$IM using ODI home directory   <$OdiHomeDir>"
	
	if (!($OdiScmConfig.ContainsKey("ImportControls"))) {
		$script:OdiScmConfig["ImportControls"] = @{}
	}
	
	if (!($OdiScmConfig["ImportControls"].ContainsKey("WorkingCopyRevision"))) {
		if ($OdiScmConfig["SCMSystem"]["SCMSystemTypeName"] -eq "TFS") {
			$script:OdiScmConfig["ImportControls"]["WorkingCopyRevision"] = "1~"
		}
		else { # I.e. SVN.
			$script:OdiScmConfig["ImportControls"]["WorkingCopyRevision"] = "0~"
		}
	}
	
	if (!($OdiScmConfig["ImportControls"].ContainsKey("OracleDIImportedRevision"))) {
		if ($OdiScmConfig["SCMSystem"]["SCMSystemTypeName"] -eq "TFS") {
			$script:OdiScmConfig["ImportControls"]["OracleDIImportedRevision"] = "1~"
		}
		else { # I.e. SVN.
			$script:OdiScmConfig["ImportControls"]["OracleDIImportedRevision"] = "0~"
		}
	}
	###DebuggingPause
	
	$script:OdiBinDir = $OdiHomeDir + "\bin"
	$script:OdiParamFile = $OdiBinDir + "\odiparams.bat"
	
	#
	# Parse / validate the odiparams script.
	#
	$text = get-content $OdiParamFile | out-string
	
	write-host "$IM starting evaluation of ODI parameter file <$OdiParamFile>"
	
	if (($text.IndexOf($OdiRepoSECURITY_DRIVER_TEXT) -gt 0) -and
	    ($text.IndexOf($OdiRepoSECURITY_URL_TEXT) -gt 0) -and
	    ($text.IndexOf($OdiRepoSECURITY_USER_TEXT) -gt 0) -and
	    ($text.IndexOf($OdiRepoSECURITY_PWD_TEXT) -gt 0) -and
	    ($text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) -gt 0) -and
	    ($text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT) -gt 0)) {
		
		$script:OdiRepoSECURITY_DRIVER    = $text.Substring($text.IndexOf($OdiRepoSECURITY_DRIVER_TEXT   ) + $OdiRepoSECURITY_DRIVER_LEN   , $text.IndexOf($OdiRepoSECURITY_URL_TEXT)       - $text.IndexOf($OdiRepoSECURITY_DRIVER_TEXT)    - $OdiRepoSECURITY_DRIVER_LEN    - 1).Trim()
		$script:OdiRepoSECURITY_URL       = $text.Substring($text.IndexOf($OdiRepoSECURITY_URL_TEXT      ) + $OdiRepoSECURITY_URL_LEN      , $text.IndexOf($OdiRepoSECURITY_USER_TEXT)      - $text.IndexOf($OdiRepoSECURITY_URL_TEXT)       - $OdiRepoSECURITY_URL_LEN       - 1).Trim()
		$script:OdiRepoSECURITY_USER      = $text.Substring($text.IndexOf($OdiRepoSECURITY_USER_TEXT     ) + $OdiRepoSECURITY_USER_LEN     , $text.IndexOf($OdiRepoSECURITY_PWD_TEXT)       - $text.IndexOf($OdiRepoSECURITY_USER_TEXT)      - $OdiRepoSECURITY_USER_LEN      - 1).Trim()
		$script:OdiRepoSECURITY_PWD       = $text.Substring($text.IndexOf($OdiRepoSECURITY_PWD_TEXT      ) + $OdiRepoSECURITY_PWD_LEN      , $text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) - $text.IndexOf($OdiRepoSECURITY_PWD_TEXT)       - $OdiRepoSECURITY_PWD_LEN       - 1).Trim()
		$script:OdiRepoSECURITY_UNENC_PWD = $text.Substring($text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) + $OdiRepoSECURITY_PWD_UNENC_LEN, $text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT)  - $text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) - $OdiRepoSECURITY_PWD_UNENC_LEN - 1).Trim()
		$script:OdiRepoWORK_REP_NAME      = $text.Substring($text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT ) + $OdiRepoSECURITY_WORK_REP_LEN , $text.IndexOf($OdiRepoUSER_TEXT)               - $text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT ) - $OdiRepoSECURITY_WORK_REP_LEN  - 1).Trim()
		$script:OdiRepoUSER               = $text.Substring($text.IndexOf($OdiRepoUSER_TEXT              ) + $OdiRepoUSER_LEN              , $text.IndexOf($OdiRepoPASSWORD_TEXT)           - $text.IndexOf($OdiRepoUSER_TEXT)               - $OdiRepoUSER_LEN               - 1).Trim()
		$script:OdiRepoPASSWORD           = $text.Substring($text.IndexOf($OdiRepoPASSWORD_TEXT          ) + $OdiRepoPASSWORD_LEN          , $text.IndexOf($OdiRepoLAST)                    - $text.IndexOf($OdiRepoPASSWORD_TEXT)           - $OdiRepoPASSWORD_LEN           - 1).Trim()
		
		write-host "$IM extracted ODI_SECU_DRIVER       <$OdiRepoSECURITY_DRIVER>"
		write-host "$IM extracted ODI_SECU_URL          <$OdiRepoSECURITY_URL>"
		write-host "$IM extracted ODI_SECU_USER         <$OdiRepoSECURITY_USER>"
		write-host "$IM extracted ODI_SECU_ENCODED_PASS <$OdiRepoSECURITY_PWD>"
		write-host "$IM extracted ODI_SECU_PASS         <$OdiRepoSECURITY_UNENC_PWD>"
		write-host "$IM extracted ODI_SECU_WORK_REP     <$OdiRepoWORK_REP_NAME>"
		write-host "$IM extracted ODI_USER              <$OdiRepoUSER>"
		write-host "$IM extracted ODI_ENCODED_PASS      <$OdiRepoPASSWORD>"
		
		[array] $OdiRepoSECURITY_URL_PARTS = @([regex]::split($OdiRepoSECURITY_URL,":"))
		$script:OdiRepoSECURITY_URL_SERVER = $OdiRepoSECURITY_URL_PARTS[3].Replace("@","")
		$script:OdiRepoSECURITY_URL_PORT = $OdiRepoSECURITY_URL_PARTS[4]
		$script:OdiRepoSECURITY_URL_SID = $OdiRepoSECURITY_URL_PARTS[5]
		
		write-host "$IM from ODI_SECURITY_URL extracted server <$OdiRepoSECURITY_URL_SERVER>"
		write-host "$IM from ODI_SECURITY_URL extracted port   <$OdiRepoSECURITY_URL_PORT>"
		write-host "$IM from ODI_SECURITY_URL extracted SID    <$OdiRepoSECURITY_URL_SID>"
		
		if ( ($OdiRepoSECURITY_DRIVER.length -eq 0) -or 
		     ($OdiRepoSECURITY_URL.length -eq 0) -or 
		     ($OdiRepoSECURITY_USER.length -eq 0) -or 
		     ($OdiRepoSECURITY_PWD.length -eq 0) -or 
		     ($OdiRepoSECURITY_UNENC_PWD.length -eq 0) -or 
		     ($OdiRepoWORK_REP_NAME.length -eq 0) -or
		     ($OdiRepoUSER.length -eq 0) -or 
		     ($OdiRepoPASSWORD.length -eq 0)
		   ) {
			write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
			return $False
		}
		else {
			if ( ($OdiRepoSECURITY_DRIVER.Contains("<")) -or 
			     ($OdiRepoSECURITY_URL.Contains("<")) -or 
			     ($OdiRepoSECURITY_USER.Contains("<")) -or
			     ($OdiRepoSECURITY_PWD.Contains("<")) -or
			     ($OdiRepoSECURITY_UNENC_PWD.Contains("<")) -or
			     ($OdiRepoWORK_REP_NAME.Contains("<")) -or
			     ($OdiRepoUSER.Contains("<")) -or
			     ($OdiRepoPASSWORD.Contains("<"))
			   ) {
				write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
				return $False
			}
			else {
				write-host "$IM successfully evaluated ODI parameter file <$OdiParamFile>"
			}
		}
	}
	else {
		write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

# function GetSCMConfiguration {
	
	# $FN = "GetSCMConfiguration"
	# $IM = $FN + ": INFO:"
	# $EM = $FN + ": ERROR:"
	# $DEBUG = $FN + ": DEBUG:"
	
	# write-host "$IM starts"
	
	# ###switch ($SCMSystemTypeName) {
	# ###	"TFS" { GetTFSConfiguration }
	# ###	"SVN" { GetSVNConfiguration }
	# ###	default {} ### do nothing. valid SCM system at start of script exec.
	# ###}
	
	# #
	# # Load the SCM configuration and ODI home location.
	# #
	# write-host "$IM using configuration file <$SCMConfigurationFile>"
	# $CmdOutput = (get-content $SCMConfigurationFile)[-1]
	# if (! $?) {
		# write-host "$EM reading from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	# LogDebug "$FN" "read from configuration file <$CmdOutput>"
	# $CmdOutputParts = @([regex]::split($CmdOutput,","))
	
	# $script:SCMSystemTypeName = $CmdOutputParts[0]		# I.e. "SVN" or "TFS".
	# $script:SCMSystemUrl = $CmdOutputParts[1]			# E.g. "file:///C:/RepoRoot" or "http://MyTFSserver:8080".
	# $script:SCMBranchUrl = $CmdOutputParts[2]			# E.g. "$/MyProject/Trunk" or "file:///C:/SvnRepoRoot/MyApp/Trunk".
	# $script:OdiHomeDir = $CmdOutputParts[3]				# E.g. "C:\OraHome1\oracledi".
	
	# if (($SCMSystemTypeName -eq $Null) -or ($SCMSystemTypeName -eq "")) {
		# write-host "$EM cannot retrieve SCM System Type Name from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	
	# if (($SCMSystemTypeName -ne "TFS" ) -and ($SCMSystemTypeName -ne "SVN")) {
		# write-host "$EM retrieved unrecognised SCM System Type Name <$SCMSystemTypeName> from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	
	# if (($SCMSystemUrl -eq $Null) -or ($SCMSystemUrl -eq "")) {
		# write-host "$EM cannot retrieve SCM System URL from configuration file $<SCMConfigurationFile>"
		# return $False
	# }
	
	# if (($SCMBranchUrl -eq $Null) -or ($SCMBranchUrl -eq "")) {
		# write-host "$EM cannot retrieve SCM Branch URL from configuration file $<SCMConfigurationFile>"
		# return $False
	# }
	
	# if (($OdiHomeDir -eq $Null) -or ($OdiHomeDir -eq "")) {
		# write-host "$EM cannot retrieve ODI home directory path from configuration file $<SCMConfigurationFile>"
		# return $False
	# }
	
	# write-host "$IM using SCM System Type Name <$SCMSystemTypeName>"
	# write-host "$IM using SCM System URL       <$SCMSystemUrl>"
	# write-host "$IM using SCM Branch URL       <$SCMBranchUrl>"
	# write-host "$IM using ODI home directory   <$OdiHomeDir>"
	
	# if (Test-Path $SCMGetLocalControlFile) { 
		# write-host "$IM local workspace update control file <$SCMGetLocalControlFile> already exists"
	# }
	# else {  
		# write-host "$IM creating local workspace update control ChangeSet file <$SCMGetLocalControlFile>"
		# New-Item -itemtype file $SCMGetLocalControlFile 
		# if ($SCMSystemTypeName -eq "TFS") {
			# Set-Content $SCMGetLocalControlFile "1~"
		# }
		# elseif ($SCMSystemTypeName -eq "SVN") {
			# Set-Content $SCMGetLocalControlFile "0~"
		# }
	# }
	
	# if (Test-Path $SCMGetLocalODIControlFile) {
		# write-host "$IM update control ChangeSet file <$SCMGetLocalODIControlFile> already exists"
	# }
	# else {  
		# write-host "$IM creating update control ChangeSet file <$SCMGetLocalODIControlFile>"
		# New-Item -itemtype file $SCMGetLocalODIControlFile 
		# if ($SCMSystemTypeName -eq "TFS") {
			# Set-Content $SCMGetLocalODIControlFile "1~"
		# }
		# elseif ($SCMSystemTypeName -eq "SVN") {
			# Set-Content $SCMGetLocalODIControlFile "0~"
		# }
	# }
	
	# $script:OdiBinDir = $OdiHomeDir + "\bin"
	# $script:OdiParamFile = $OdiBinDir + "\odiparams.bat"
	
	# #
	# # Parse / validate the odiparams script.
	# #
	# $text = get-content $OdiParamFile | out-string
	
	# write-host "$IM starting evaluation of ODI parameter file <$OdiParamFile>"
	
	# if (($text.IndexOf($OdiRepoSECURITY_DRIVER_TEXT) -gt 0) -and
	    # ($text.IndexOf($OdiRepoSECURITY_URL_TEXT) -gt 0) -and
	    # ($text.IndexOf($OdiRepoSECURITY_USER_TEXT) -gt 0) -and
	    # ($text.IndexOf($OdiRepoSECURITY_PWD_TEXT) -gt 0) -and
	    # ($text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) -gt 0) -and
	    # ($text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT) -gt 0)) {
		
		# $script:OdiRepoSECURITY_DRIVER    = $text.Substring($text.IndexOf($OdiRepoSECURITY_DRIVER_TEXT   ) + $OdiRepoSECURITY_DRIVER_LEN   , $text.IndexOf($OdiRepoSECURITY_URL_TEXT)       - $text.IndexOf($OdiRepoSECURITY_DRIVER_TEXT)    - $OdiRepoSECURITY_DRIVER_LEN    - 1).Trim()
		# $script:OdiRepoSECURITY_URL       = $text.Substring($text.IndexOf($OdiRepoSECURITY_URL_TEXT      ) + $OdiRepoSECURITY_URL_LEN      , $text.IndexOf($OdiRepoSECURITY_USER_TEXT)      - $text.IndexOf($OdiRepoSECURITY_URL_TEXT)       - $OdiRepoSECURITY_URL_LEN       - 1).Trim()
		# $script:OdiRepoSECURITY_USER      = $text.Substring($text.IndexOf($OdiRepoSECURITY_USER_TEXT     ) + $OdiRepoSECURITY_USER_LEN     , $text.IndexOf($OdiRepoSECURITY_PWD_TEXT)       - $text.IndexOf($OdiRepoSECURITY_USER_TEXT)      - $OdiRepoSECURITY_USER_LEN      - 1).Trim()
		# $script:OdiRepoSECURITY_PWD       = $text.Substring($text.IndexOf($OdiRepoSECURITY_PWD_TEXT      ) + $OdiRepoSECURITY_PWD_LEN      , $text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) - $text.IndexOf($OdiRepoSECURITY_PWD_TEXT)       - $OdiRepoSECURITY_PWD_LEN       - 1).Trim()
		# $script:OdiRepoSECURITY_UNENC_PWD = $text.Substring($text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) + $OdiRepoSECURITY_PWD_UNENC_LEN, $text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT)  - $text.IndexOf($OdiRepoSECURITY_PWD_UNENC_TEXT) - $OdiRepoSECURITY_PWD_UNENC_LEN - 1).Trim()
		# $script:OdiRepoWORK_REP_NAME      = $text.Substring($text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT ) + $OdiRepoSECURITY_WORK_REP_LEN , $text.IndexOf($OdiRepoUSER_TEXT)               - $text.IndexOf($OdiRepoSECURITY_WORK_REP_TEXT ) - $OdiRepoSECURITY_WORK_REP_LEN  - 1).Trim()
		# $script:OdiRepoUSER               = $text.Substring($text.IndexOf($OdiRepoUSER_TEXT              ) + $OdiRepoUSER_LEN              , $text.IndexOf($OdiRepoPASSWORD_TEXT)           - $text.IndexOf($OdiRepoUSER_TEXT)               - $OdiRepoUSER_LEN               - 1).Trim()
		# $script:OdiRepoPASSWORD           = $text.Substring($text.IndexOf($OdiRepoPASSWORD_TEXT          ) + $OdiRepoPASSWORD_LEN          , $text.IndexOf($OdiRepoLAST)                    - $text.IndexOf($OdiRepoPASSWORD_TEXT)           - $OdiRepoPASSWORD_LEN           - 1).Trim()
		
		# write-host "$IM extracted ODI_SECU_DRIVER       <$OdiRepoSECURITY_DRIVER>"
		# write-host "$IM extracted ODI_SECU_URL          <$OdiRepoSECURITY_URL>"
		# write-host "$IM extracted ODI_SECU_USER         <$OdiRepoSECURITY_USER>"
		# write-host "$IM extracted ODI_SECU_ENCODED_PASS <$OdiRepoSECURITY_PWD>"
		# write-host "$IM extracted ODI_SECU_PASS         <$OdiRepoSECURITY_UNENC_PWD>"
		# write-host "$IM extracted ODI_SECU_WORK_REP     <$OdiRepoWORK_REP_NAME>"
		# write-host "$IM extracted ODI_USER              <$OdiRepoUSER>"
		# write-host "$IM extracted ODI_ENCODED_PASS      <$OdiRepoPASSWORD>"
		
		# [array] $OdiRepoSECURITY_URL_PARTS = @([regex]::split($OdiRepoSECURITY_URL,":"))
		# $script:OdiRepoSECURITY_URL_SERVER = $OdiRepoSECURITY_URL_PARTS[3].Replace("@","")
		# $script:OdiRepoSECURITY_URL_PORT = $OdiRepoSECURITY_URL_PARTS[4]
		# $script:OdiRepoSECURITY_URL_SID = $OdiRepoSECURITY_URL_PARTS[5]
		
		# write-host "$IM from ODI_SECURITY_URL extracted server <$OdiRepoSECURITY_URL_SERVER>"
		# write-host "$IM from ODI_SECURITY_URL extracted port   <$OdiRepoSECURITY_URL_PORT>"
		# write-host "$IM from ODI_SECURITY_URL extracted SID    <$OdiRepoSECURITY_URL_SID>"
		
		# if ( ($OdiRepoSECURITY_DRIVER.length -eq 0) -or 
		     # ($OdiRepoSECURITY_URL.length -eq 0) -or 
		     # ($OdiRepoSECURITY_USER.length -eq 0) -or 
		     # ($OdiRepoSECURITY_PWD.length -eq 0) -or 
		     # ($OdiRepoSECURITY_UNENC_PWD.length -eq 0) -or 
		     # ($OdiRepoWORK_REP_NAME.length -eq 0) -or
		     # ($OdiRepoUSER.length -eq 0) -or 
		     # ($OdiRepoPASSWORD.length -eq 0)
		   # ) {
			# write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
			# return $False
		# }
		# else {
			# if ( ($OdiRepoSECURITY_DRIVER.Contains("<")) -or 
			     # ($OdiRepoSECURITY_URL.Contains("<")) -or 
			     # ($OdiRepoSECURITY_USER.Contains("<")) -or
			     # ($OdiRepoSECURITY_PWD.Contains("<")) -or
			     # ($OdiRepoSECURITY_UNENC_PWD.Contains("<")) -or
			     # ($OdiRepoWORK_REP_NAME.Contains("<")) -or
			     # ($OdiRepoUSER.Contains("<")) -or
			     # ($OdiRepoPASSWORD.Contains("<"))
			   # ) {
				# write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
				# return $False
			# }
			# else {
				# write-host "$IM successfully evaluated ODI parameter file <$OdiParamFile>"
			# }
		# }
	# }
	# else {
		# write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
		# return $False
	# }
	
	# write-host "$IM ends"
	# return $True
# }

# function GetSVNConfiguration {
	
	# $FN = "GetSVNConfiguration"
	# $IM = $FN + ": INFO:"
	# $EM = $FN + ": ERROR:"
	# $DEBUG = $FN + ": DEBUG:"
	
	# write-host "$IM starts"
	
	# #
	# # Load the SVN server configuration (URL and branch).
	# #
	# write-host "$IM using configuration file <$SCMConfigurationFile>"
	# $CmdOutput = (get-content $SCMConfigurationFile)[-1]
	# if (! $?) {
		# write-host "$EM reading from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	# write-host "$DEBUG read from configuration file <$CmdOutput>"
	# $CmdOutputParts = @([regex]::split($CmdOutput,","))
	
	# $script:SVNUrl = $CmdOutputParts[0]					# E.g. "file:///C:/RepoRoot"
	# $script:SVNBranchName = $CmdOutputParts[1]			# E.g. "MyProject/Trunk"
	
	# if (($script:SVNUrl -eq $Null) -or ($script:SVNUrl -eq "")) {
		# write-host "$EM cannot retrieve SVN repository URL from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	
	# if (($script:SVNBranchName -eq $Null) -or ($script:SVNBranchName -eq "")) {
		# write-host "$EM cannot retrieve SVN branch name from configuration file $<SCMConfigurationFile>"
		# return $False
	# }
	
	# write-host "$IM using SVN URL             : <$script:SVNUrl>"
	# write-host "$IM using SVN Code Branch Name: <$script:SVNBranchName>"
	
	# write-host "$IM ends"
	# return $True
# }

# function GetTFSServerConfiguration {
	
	# $FN = "GetTFSServerConfiguration"
	# $IM = $FN + ": INFO:"
	# $EM = $FN + ": ERROR:"
	# $DEBUG = $FN + ": DEBUG:"
	
	# write-host "$IM starts"
	
	# #
	# # Load the TFS server configuration (server, project, and branch).
	# #
	# write-host "$IM using configuration file <$SCMConfigurationFile>"
	# $CmdOutput = (get-content $SCMConfigurationFile)[-1]
	# if (! $?) {
		# write-host "$EM reading from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	# write-host "$DEBUG read from configuration file <$CmdOutput>"
	# $CmdOutputParts = @([regex]::split($CmdOutput,","))
	
	# $script:TFSServer = $CmdOutputParts[0]				# E.g. "http://statfssqlprd02:8080/tfs/bhwdevelopment"
	# $script:TFSMoiProjectName = $CmdOutputParts[1]		# E.g. "MOIInternalReleases"
	# $script:TFSMoiBranchName = $CmdOutputParts[2]		# E.g. "MOI_Production"
	
	# if (($script:TFSServer -eq $Null) -or ($script:TFSServer -eq "")) {
		# write-host "$EM cannot retrieve TFS server URL from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	
	# if (($script:TFSMoiProjectName -eq $Null) -or ($script:TFSMoiProjectName -eq "")) {
		# write-host "$EM cannot retrieve TFS project name from configuration file <$SCMConfigurationFile>"
		# return $False
	# }
	
	# if (($script:TFSMoiBranchName -eq $Null) -or ($script:TFSMoiBranchName -eq "")) {
		# write-host "$EM cannot retrieve TFS branch name from configuration file $<SCMConfigurationFile>"
		# return $False
	# }
	
	# $script:TFSBranchName = "$/" + $script:TFSMoiProjectName + "/" + $script:TFSMoiBranchName
	# $script:LocalBranchRoot = $LocalRootDir + "\$TFSMoiBranchName"
	
	# write-host "$IM using TFS Server URL      : <$script:TFSServer>"
	# write-host "$IM using TFS Project Name    : <$script:TFSMoiProjectName>"
	# write-host "$IM using TFS Code Branch Name: <$script:TFSMoiBranchName>"
	
	# write-host "$IM ends"
	# return $True
# }

#
# The main function.
#
function GetIncremental {
	
	$FN = "GetIncremental"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	write-host "$IM initialising message output system"
	
	$ExitStatus = $False
	
	if (! $loadConstants) {
		return $ExitStatus
	}
	
	if (!(CheckDependencies)) {
		return $ExitStatus
	}
	
	write-host "$IM constants loaded"
	
	###if (!(GetSCMConfiguration)) {
	if (!(GetOdiScmConfiguration)) {
		write-host "$EM error loading SCM server configuration"
		return $False
	}
	
	#
	# Set up the ODI repository SQL access script.
	#
	if (!(SetOdiScmJisqlRepoBatContent)) {
		write-host "$EM error creating custom ODI repository SQL access script"
		return $ExitStatus
	}
	
	#
	# Set up the OdiSvn repository infrastructure creation script.
	#
	if (!(SetOdiSvnRepoCreateInfractureSqlContent)) {
		write-host "$EM error creating OdiSvn infrastructure creation script"
		return $ExitStatus
	}
	
	#
	# Ensure the OdiSvn repository infrastructure has been set up.
	#
	$CmdOutput = ExecOdiRepositorySql("$OdiSvnRepoInfrastructureSetupSql")
	if (! $CmdOutput) {
		write-host "$EM error creating OdiSvn repository infrastructure"
		return $ExitStatus
	}
	###DebuggingPause
	#
	# Get the last Revision number successfully applied to the local workspace
	# from the local metadata.
	#
	$LocalControlChangeSet = $OdiScmConfig["ImportControls"]["WorkingCopyRevision"]
	
	if (($LocalControlChangeSet.substring(($LocalControlChangeSet.length) - 1)) -ne "~") {
		write-host "$EM format of local workspace next import metadata <$LocalControlChangeSet> is invalid"
		write-host "$EM format must be '<last imported ChangeSet>~'"
		return $False
	}
	$LocalControlLastChangeSet = $LocalControlChangeSet.substring(0,($LocalControlChangeSet.length) - 1)
	write-host "$IM local metadata: last Revision applied to the local workspace <$LocalControlLastChangeSet>"
	###DebuggingPause
	#
	# Get the last Revision number successfully applied to the ODI repository
	# from the local metadata.
	#
	$LocalODIControlChangeSet = $OdiScmConfig["ImportControls"]["OracleDIImportedRevision"]
	
	if (($LocalODIControlChangeSet.substring(($LocalODIControlChangeSet.length) - 1) -ne "~")) {
		write-host "$EM format of local workspace next import metadata <$ODIControlChangeSet> is invalid"
		write-host "$EM format must be '<last imported ChangeSet>~'"
		return $False
	}
	$LocalODIControlLastChangeSet = $LocalODIControlChangeSet.substring(0,($LocalODIControlChangeSet.length) - 1)
	write-host "$IM local metadata: last Revision applied to the ODI repository <$LocalODIControlLastChangeSet>"
	###DebuggingPause
	#
	# Check that the Revisions applied to the local workspace have been imported into the
	# ODI repository.
	#
	if ($LocalControlLastChangeSet -ne $LocalODIControlLastChangeSet) {
		write-host "$EM the local workspace version <$LocalControlLastChangeSet> is different to the ODI repository"
		write-host "$EM version <$LocalODIControlLastChangeSet>. The ODI repository must be updated to the same version"
		write-host "$EM before this script can be run again".
		return $False
	}
	###DebuggingPause
	#
	# Get the OdiSvn metadata from the ODI repository.
	#
	$CmdOutput = ExecOdiRepositorySql("$ScriptsRootDir\odisvn_get_last_import.sql")
	if (! $CmdOutput) {
		write-host "$EM error retrieving last imported revision from OdiSvn repository metadata"
		return $ExitStatus
	}
	###DebuggingPause
	$CmdOutput = $CmdOutput.TrimStart("ExecOdiRepositorySql:")
	$StringList = @([regex]::split($CmdOutput.TrimStart("ExecOdiRepositorySql:"),"!!"))
	$OdiRepoBranchName = $StringList[0]
	###DebuggingPause
	$OdiLastImportList = @([regex]::split($StringList[1],"~"))
	[string] $OdiRepoLastImportTo = $OdiLastImportList[0]
	###DebuggingPause
	write-host "$IM from ODI repository: got Branch URL             <$OdiRepoBranchName>"
	write-host "$IM from ODI repository: got Last Imported Revision <$OdiRepoLastImportTo>"
	###DebuggingPause
	#
	# Get the latest Revision number from the SCM repository.
	#
	write-host "$IM getting latest Revision number from the SCM repository"
	$HighChangeSetNumber = GetNewChangeSetNumber
	write-host "$IM latest Revision number returned is <$HighChangeSetNumber>"
	###DebuggingPause
	$difference = $LocalODIControlChangeSet + $HighChangeSetNumber
	write-host "$IM new Revision range to apply to the local workspace is <$difference>"
	
	if (!(ChangeSetRangeIsValid($difference))) {
		write-host "$EM the derived Revision range <$difference> is invalid"
		return $ExitStatus
	}
	###DebuggingPause
	# TODO: pass references to $LocalLastImportFrom/$LocalLastImportTo and make ChangeSetRangeIsValid
	#       set the values.
	$StringList = @([regex]::split($difference,"~"))
	[string] $LocalLastImportFrom = $StringList[0]
	[string] $LocalLastImportTo = $StringList[1]
	###DebuggingPause
	
	$SCMSystemTypeName = $OdiScmConfig["SCMSystem"]["SCMSystemTypeName"]
	if (($OdiScmConfig["SCMSystem"]["SCMSystemTypeName"]) -eq "TFS") {
		if ($LocalLastImportFrom -ne "1") {
			write-host "$IM this is not the initial GetIncremental update. An incremental Get will be run"
			$FullImportInd = $False
		}
		else {
			write-host "$IM this is the initial GetIncremental update. An full/initial Get will be run"
			$FullImportInd = $True
		}
	}
	elseif ($SCMSystemTypeName -eq "SVN") {
		if ($LocalLastImportFrom -ne "0") {
			write-host "$IM this is not the initial GetIncremental update. An incremental Get will be run"
			$FullImportInd = $False
		}
		else {
			write-host "$IM this is the initial GetIncremental update. An full/initial Get will be run"
			$FullImportInd = $True
		}
	}
	###DebuggingPause
	#
	# Check the ODI repository infrastructure metadata against the local workspace metadata.
	#
	if ($FullImportInd) {
		####if (($OdiRepoBranchName -ne "") -or ($OdiRepoLastImportFrom -ne "") -or ($OdiRepoLastImportTo -ne "")) {
		if (($OdiRepoBranchName -ne "") -or ($OdiRepoLastImportTo -ne "")) {
			write-host "$EM The ODI repository metadata indicates that the ODI repository has been previously updated"
			write-host "$EM by this mechanism but the local workspace metadata indicates that a full import operation"
			write-host "$EM should be run. Perform one of the following actions before rerunning this script:"
			write-host "$EM 1) Delete all repository contents via the Designer/Topology Manager GUIs."
			write-host "$EM 2) Create a new repository with a previously unused internal ID and update your odiparams.bat"
			write-host "$EM    with the new repository details."
			write-host "$EM 3) If you fully understand the potential consequences and still REALLY want to perform the"
			write-host "$EM    import into the ODI repository then delete the existing branch and ChangeSet metadata from"
			write-host "$EM    the ODI repository table ODISVN_CONTROLS"
			write-host "$EM NOTE: do not drop the repository and recreate it with the same ID if there is ANY chance of"
			write-host "$EM       objects having been created in it that have been distributed to other repositories"
			write-host "$EM       as this will cause conflicts and potential repository corruption."
			write-host "$EM       In order to perform this action safely you MUST the repository pre-TearDown and and"
			write-host "$EM       post-Rebuild scripts provided in the Scripts directory"
			return $ExitStatus
		}
	}
	###DebuggingPause
	if (!($FullImportInd)) {
		if ($OdiRepoBranchName -ne ($OdiScmConfig["SCMSystem"]["SCMBranchUrl"]).Trim()) {
			write-host "$EM The local workspace metadata indicates that the ODI repository has been previously updated"
			write-host "$EM by this mechanism but the ODI repository branch name does not match the local workspace branch name."
			write-host "$EM Perform one of the following actions before rerunning this script:"
			write-host "$EM 1) Delete all repository contents via the Designer/Topology Manager GUIs."
			write-host "$EM 2) Create a new repository with a previously unused internal ID and update your odiparams.bat"
			write-host "$EM    with the new repository details."
			write-host "$EM 3) If you fully understand the potential consequences and still REALLY want to perform the"
			write-host "$EM    import into the ODI repository then update the existing branch and ChangeSet metadata in"
			write-host "$EM    the ODI repository."
			write-host "$EM NOTE: do not drop the repository and recreate it with the same ID if there is ANY chance of"
			write-host "$EM       objects having been created in it that have been distributed to other repositories"
			write-host "$EM       as this will cause conflicts and potential repository corruption."
			write-host "$EM       In order to perform this action safely you MUST the repository pre-TearDown and and"
			write-host "$EM       post-Rebuild scripts provided in the Scripts directory"
			LogDebug "$FN" "OdiRepoBranchName <$OdiRepoBranchName>"
			LogDebug "$FN" ("OdiScmConfig[SCMSystem][SCMBranchUrl] <" + ($OdiScmConfig["SCMSystem"]["SCMBranchUrl"]).Trim() + ">")
			return $ExitStatus
		}
	}
	###DebuggingPause
	if (!($FullImportInd) -and ($OdiRepoLastImportTo -ne $LocalLastImportFrom)) {
		write-host "$EM the last ODI repository imported ChangeSet <$OdiLastImportTo> number does not match"
		write-host "$EM the last ChangeSet number <$LocalLastImportFrom> from the local workspace"
		return $ExitStatus
	}
	###DebuggingPause
	[array] $fileList = @()
	###DebuggingPause
	if ($LocalLastImportFrom -eq $LocalLastImportTo) {
		write-host "$IM the local workspace is already up to date with the SCM repository"
		$ExitStatus = $True
		return $ExitStatus
	}
	
	#
	# Create a backup of the configuration INI file.
	#
	write-host "$IM creating back-up of configuration file <$SCMConfigurationFile> to <$SCMConfigurationBackUpFile>"
	$SCMConfigurationBackUpFile = $GenScriptRootDir + "\" + $SCMConfigurationFileName + ".BackUp"
	get-content $SCMConfigurationFile | set-content $SCMConfigurationBackUpFile
	
	#
	# Get the update from the SCM system.
	#
	[array] $TFSGetFileList = @()
	[ref] $ArrayRef = [ref]$TFSGetFileList
	if (!(GetFromSCM $HighChangeSetNumber $ArrayRef)) {
		write-host "$EM failure getting latest code from the SCM repository"
		return $False
	}
	
	write-host "$IM GetFromSCM returned ODI source <$($TFSGetFileList.length)> files to import"
	###DebuggingPause
	#
	# Generate the ODI object import commands in the generated script.
	#
	if (!(GenerateOdiImportScript $TFSGetFileList)) { 
		write-host "$EM call to GenerateOdiImportScript failed"
		return $ExitStatus
	}
	###DebuggingPause
	#
	# Set up the OdiSvn next import metadata update script.
	#
	if (!(SetOdiSvnRepoSetNextImportSqlContent($HighChangeSetNumber))) {
		write-host "$EM call to SetOdiSvnRepoSetNextImportSqlContent failed"
		return $ExitStatus
	}
	###DebuggingPause
	#
	# Set up the OdiSvn build note.
	#
	if (!(SetOdiSvnBuildNoteContent $difference)) {
		write-host "$EM call to SetOdiSvnBuildNoteContent failed"
		return $ExitStatus
	}
	###DebuggingPause
	#
	# Set up the OdiSvn repository back-up script content.
	#
	if (!(SetOdiSvnRepositoryBackUpBatContent)) {
		write-host "$EM call to SetOdiSvnRepositoryBackUpBatContent failed"
		return $ExitStatus
	}
	#
	# Set up the pre-ODI import script content.
	#
	if (!(SetOdiSvnPreImportBatContent)) {
		write-host "$EM setting content in pre-ODI import script"
		return $ExitStatus
	}
	###DebuggingPause
	#
	# Set up the post-ODI import script content.
	#
	if (!(SetOdiSvnPostImportBatContent)) {
		write-host "$EM setting content in post-ODI import script"
		return $ExitStatus
	}
	###DebuggingPause
	#
	# Set up the top level build script content.
	#
	if (!(SetTopLevelScriptContent $HighChangeSetNumber)) {
		write-host "$EM setting content in main script"
		return $ExitStatus
	}
	###DebuggingPause
	write-host "$IM your local workspace has been updated. Execute the following script to perform"
	write-host "$IM the ODI source code import, Scenario generation and update the local OdiSvn metadata"
	write-host "$IM"
	write-host "$IM <$OdiSvnBuildBat>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Execute the post-ODI scenario generation procedure.
#
#function GenerateScenarioPost {
#	
#	$IM = "GenerateScenarioPost: INFO:"
#	$EM = "GenerateScenarioPost: ERROR:"
#	
#	write-host "$IM starts"
#	
#	$ExitStatus = $False
#	
#	write-host "$IM executing script <$ScriptsRootDir\OdiSvn_GenScen_PostImport.bat>"
#	#
#	# Capture the command output and display it so that it does not get returned
#	# by this function.
#	#
#	$CmdOutput = cmd /c "$ScriptsRootDir\OdiSvn_GenScen_PostImport.bat" | Out-String
#	$BatchExitCode = $LastExitCode
#	write-host $CmdOutput
#	
#	if ($BatchExitCode -eq 0) {
#		write-host "$IM execution of script $ScriptsRootDir\OdiSvn_GenScen_PostImport.bat completed successfully"
#		$ExitStatus = $True
#	}
#	else {
#		write-host "$EM execution of script $ScriptsRootDir\OdiSvn_GenScen_PostImport.bat failed with exit status $BatchExitCode"
#	}
#	
#	write-host "$IM ends"
#	
#	DebuggingPause
#	
#	return $ExitStatus
#}

#######################################################################################
#
# Set the content of generated scripts.
#
#######################################################################################

#
# Generate the script to back up the ODI repository.
#
function SetOdiSvnRepositoryBackUpBatContent {
	
	$FN = "SetOdiSvnRepositoryBackUpBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	#
	# Set up the OdiSvn ODI repository back-up script.
	#
	$ScriptFileContent = get-content $OdiSvnRepositoryBackUpBatTemplate | out-string
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoUserName>",$OdiRepoSECURITY_USER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPassWord>",$OdiRepoSECURITY_UNENC_PWD)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoServer>",$OdiRepoSECURITY_URL_SERVER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPort>",$OdiRepoSECURITY_URL_PORT)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoSID>",$OdiRepoSECURITY_URL_SID)
	
	$ExportFileName = "$GenScriptRootDir" + "\OdiSvnExportBackUp_${OdiRepoSECURITY_USER}_${OdiRepoSECURITY_URL_SERVER}_${OdiRepoSECURITY_URL_SID}_${VersionString}.dmp"
	$ScriptFileContent = $ScriptFileContent.Replace("<ExportBackUpFile>",$ExportFileName)
	
	set-content -path $OdiSvnRepositoryBackUpBat -value $ScriptFileContent
	
	write-host "$IM ends"
	
	return $True
}

#
# Generate the batch file OdiScmJisqlRepo.bat.
# This batch file is used to execute SQL statements directly against the ODI repository
# whose details are specified in "odiparams.bat".
#
function SetOdiScmJisqlRepoBatContent {
	
	$FN = "SetOdiScmJisqlRepoBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"

	write-host "$IM starts"
	$fileContent = get-content $OdiScmJisqlRepoBatTemplate | out-string 
	
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
# Generate the script to set up the OdiSvn ODI repository metadata infrastructure.
#
function SetOdiSvnRepoCreateInfractureSqlContent {
	
	$FN = "SetOdiSvnRepoCreateIntractureBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	#
	# Set up the OdiSvn metadata infrastructure creation script.
	#
	$ScriptFileContent = get-content $OdiSvnRepoInfrastructureSetupSqlTemplate | out-string
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoUserName>",$OdiRepoSECURITY_USER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPassWord>",$OdiRepoSECURITY_UNENC_PWD)
	
	$OraConn = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$OdiRepoSECURITY_URL_SERVER)(PORT=$OdiRepoSECURITY_URL_PORT))(CONNECT_DATA=(SID=$OdiRepoSECURITY_URL_SID))))"
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoConnectionString>",$OraConn)
	set-content -path $OdiSvnRepoInfrastructureSetupSql -value $ScriptFileContent
	
	write-host "$IM ends"
	
	return $True
}

#
# Generate the script to set up the OdiSvn ODI repository metata infrastructure.
#
function SetOdiSvnRepoSetNextImportSqlContent ($NextImportChangeSetRange) {
	
	$FN = "SetOdiSvnRepoSetNextImportSqlContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	#
	# Set up the OdiSvn metadata update script.
	#
	$ScriptFileContent = get-content $OdiSvnRepoSetNextImportTemplate | out-string
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnBranchUrl>",$SCMBranchUrl)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnNextImportRevison>",$NextImportChangeSetRange)
	
	set-content -path $OdiSvnRepoSetNextImport -value $ScriptFileContent
	
	write-host "$IM ends"
	return $True
}

#
# Generate the build note content.
#
function SetOdiSvnBuildNoteContent ($VersionRange) {
	
	$FN = "SetOdiSvnBuildNoteContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	$NoteText = get-content $OdiSvnBuildNoteTemplate | out-string
	if (!($?)) {
		write-host "$EM getting build note tempate text from template file <$OdiSvnBuildNoteTemplate>"
		return $False
	}
	
	$NoteText = $NoteText.Replace("<ScmSystemTypeName>",$SCMSystemTypeName)
	$NoteText = $NoteText.Replace("<ScmSystemUrl>",$SCMSystemUrl)
	$NoteText = $NoteText.Replace("<ScmBranchUrl>",$SCMBranchUrl)
	$NoteText = $NoteText.Replace("<VersionRange>",$VersionRange)
	$NoteText = $NoteText.Replace("<WorkingCopyRootDir>",$LocalBranchRoot)
	
	set-content $OdiSvnBuildNote $NoteText
	if (!($?)) {
		write-host "$EM setting build note tempate text in file <$OdiSvnBuildNote>"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

#
# Generate the pre-ODI import script.
#
function SetOdiSvnPreImportBatContent {
	
	$FN = "SetOdiSvnPreImportBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using script template file <$OdiSvnGenScenPreImportBatTemplate>"
	write-host "$IM setting content of top level build script file <$OdiSvnGenScenPreImportBat>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiSvnGenScenPreImportBatTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<GenScriptRootDir>",$GenScriptRootDir)
	set-content -path $OdiSvnGenScenPreImportBat -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate the pre-ODI import script.
#
function SetOdiSvnPostImportBatContent {
	
	$FN = "SetOdiSvnPostImportBatContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using script template file <$OdiSvnGenScenPostImportBatTemplate>"
	write-host "$IM setting content of script file <$OdiSvnGenScenPostImportBat>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiSvnGenScenPostImportBatTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<GenScriptRootDir>",$GenScriptRootDir)
	set-content -path $OdiSvnGenScenPostImportBat -value $ScriptFileContent
	
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
	write-host "$IM using top level build script template file <$OdiSvnBuildBatTemplate>"
	write-host "$IM setting content of top level build script file <$OdiSvnBuildBat>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiSvnBuildBatTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnRepositoryBackUpBat>",$OdiSvnRepositoryBackUpBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnGenScenPreImportBat>",$OdiSvnGenScenPreImportBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiImportScriptFile>",$OdiImportScriptFile)	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnValidateRepositoryIntegritySql>",$OdiSvnValidateRepositoryIntegritySql)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnRestoreRepositoryIntegritySql>",$OdiSvnRestoreRepositoryIntegritySql)    
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnGenScenPostImportBat>",$OdiSvnGenScenPostImportBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<SCMConfigurationFile>",$SCMConfigurationFile)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnLatestChangeSet>",$NextImportChangeSetRange)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnSetNextImportSql>",$OdiSvnRepoSetNextImport)
	$ScriptFileContent = $ScriptFileContent.Replace("<GenScriptRootDir>",$GenScriptRootDir)
	
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmUpdateIniAwk>",$OdiScmUpdateIniAwk)
	
	set-content -path $OdiSvnBuildBat -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GetFromSCM ($HighChangeSetNumber, [ref] $FileList) {
	
	switch ($SCMSystemTypeName) {
		"TFS" { GetFromTFS $HighChangeSetNumber $FileList }		# Note: FileList is already a reference, don't cast it again!
		"SVN" { GetFromSVN $HighChangeSetNumber $FileList }		# Note: FileList is already a reference, don't cast it again!
	}
}

#
# Perform an SVN UPDATE operation for the entire branch URL.
#
function GetFromSVN ($HighChangeSetNumber, [ref] $FileList) {
	
	# SVN CHECKOUT/MERGE/UPDATE status codes for a file.
	# A  Added
    # D  Deleted
    # U  Updated
    # C  Conflict
    # G  Merged
    # E  Existed
	
	$FN = "GetFromSVN"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	LogDebug "$FN" "getting from SVN to revision number <${HighChangeSetNumber}>"
	LogDebug "$FN" "changing directory to LocalBranchRoot of <$LocalBranchRoot>"
	
	set-location $LocalBranchRoot
	if (!($?)) {
		write-host "$EM cannot change working directory to branch root directory <$LocalBranchRoot>"
		return $ExitStatus
	}
	
	$CurrentWorkingDir = get-location
	LogDebug "$FN" "CWD is $CurrentWorkingDir"
	
	#
	# need to assume current dir is an svn WC (for now at least) so we can do SVN UPDATE.
	# create the empty WC using SVN CHECKOUT <repo URL> --REVISION 0
	
	write-host "$IM previewing SVN UPDATE using SVN MERGE. Output will be recorded in file <$GetLatestVersionOutputFile>"
	
	$CmdLine = "svn merge --dry-run --revision BASE:" + "${HighChangeSetNumber} . >${GetLatestVersionOutputFile} 2>&1"
	write-host "$IM executing command <$CmdLine>"
	invoke-expression $CmdLine
	if ($LastExitCode -ge 1) {
		write-host "$EM execution of command failed with exit status <$LastExitCode>"
		write-host "$EM check the output file for details. All conflicts must be resolved in order for this"
		write-host "$EM script can run successfully"
		return $ExitStatus
	}
	
	#
	# Check for a conflict summary in the output.
	#
	if ($GetLatestVersionOutputFile.contains("Summary of conflicts:")) {
		write-host "$EM conflicts detected in local working copy versus repository"
		write-host "$EM check the output file for details. All conflicts must be resolved in order for this"
		write-host "$EM script to be executed successfully"
		return $ExitStatus
	}
	
	write-host "$IM no conflicts detected in local working copy versus repository"
	write-host "$IM getting update from SVN to revision <$HighChangeSetNumber>"
	
	$CmdLine = "svn update $LocalBranchRoot --revision " + $HighChangeSetNumber + " >$GetLatestVersionOutputFile 2>&1" # $LocalBranchRoot is optional for this command.
	write-host "$IM executing command <$CmdLine>"
	invoke-expression $CmdLine
	if ($LastExitCode -ge 1) {
		write-host "$EM execution of command failed with exit status <$LastExitCode>"
		return $ExitStatus
	}
	
	#
	# Update the version of the local working copy.
	#
	# Dont use "add-content"? It always writes a newline at the end of the text.
	#(get-content -path $SCMGetLocalControlFile) + [Environment]::NewLine + $HighChangeSetNumber + "~" | set-content -path $SCMGetLocalControlFile
	####([Environment]::NewLine + $HighChangeSetNumber + "~") | add-content $SCMGetLocalControlFile
	$script:OdiScmConfig["ImportControls"]["WorkingCopyRevision"] = $HighChangeSetNumber + "~"
	SetIniContent $OdiScmConfig "$SCMConfigurationFile"
	
	#
	# Parse the output of the UPDATE command to build the list of ODI source sources that we need to import.
	#
	$TfGetOutput = get-content $GetLatestVersionOutputFile
	write-host "$IM processing command output with <$($TfGetOutput.length)> records"
	$FileCount = 0
	
	# Holds the current file type's list of files (to allow us to sort where required before adding to the main output list).
	[array] $currFileTypeList = @()
	
	#
	# Loop through each extension and file files for which to include import commands.
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
		write-host "$IM processing object type <$FileObjType.replace(".","")>"
		
		###DebuggingPause
		
		$ExtensionFileCount = 0
		###$FileToImportPathName = ""
		
		foreach ($TfGetOutputLine in $TfGetOutput) {
			###write-host "$IM processing text line : $TfGetOutputLine"
			###DebuggingPause
			
			if ($TfGetOutputLine.StartsWith("Updated to revision")) {
				write-host "$IM ignoring text line $TfGetOutputLine"
				continue
			}
			
			if ($TfGetOutputLine.StartsWith("Updating")) {
				write-host "$IM ignoring text line $TfGetOutputLine"
				continue
			}
			
			$TfGetOutputLineFlags = $TfGetOutputLine.Substring(0,5)
			$TfGetOutputLineFileDirActionFlag = $TfGetOutputLineFlags.Substring(0,1)
			$TfGetOutputLineFileDirPropertyActionFlag = $TfGetOutputLineFlags.Substring(1,1)
			$TfGetOutputLineLockBrokenFilePropertyActionFlag = $TfGetOutputLineFlags.Substring(2,1)
			$TfGetOutputLineTreeActionFlag = $TfGetOutputLineFlags.Substring(3,1)	# Tree conflicts are signalled with a "C" in this column.
			$TfGetOutputLineFileDir = $TfGetOutputLine.Substring(5)
			
			###write-host "$DEBUG TfGetOutputLineFlags <$TfGetOutputLineFlags>"
			###write-host "$DEBUG TfGetOutputLineFileDirActionFlag <$TfGetOutputLineFileDirActionFlag>"
			###write-host "$DEBUG TfGetOutputLineFileDirPropertyActionFlag <$TfGetOutputLineFileDirPropertyActionFlag>"
			###write-host "$DEBUG TfGetOutputLineLockBrokenFilePropertyActionFlag <$TfGetOutputLineLockBrokenFilePropertyActionFlag>"
			###write-host "$DEBUG TfGetOutputLineTreeActionFlag <$TfGetOutputLineTreeActionFlag>"
			###write-host "$DEBUG TfGetOutputLineFileDir <$TfGetOutputLineFileDir>"
			###DebuggingPause
			
			if ($TfGetOutputLineFileActionFlag -eq "C" -or $TfGetOutputLineTreeActionFlag -eq "C") {
				write-host "$EM conflicts detected in local working copy versus repository for file or directory <$TfGetOutputLineFileDir>"
				write-host "$EM check the output file for details. All conflicts must be resolved in order for this"
				write-host "$EM script to be executed successfully"
				return $ExitStatus
			}
			
			if ($TfGetOutputLineFileDir.EndsWith($FileObjType)) {
				#
				# This is an ODI source object file name.
				#
				LogDebug "$FN" "found an ODI source file <$TfGetOutputLineFileDir> of type <$FileObjType>"
				if ($TfGetOutputLineFileDirActionFlag -eq "D") {
					write-host "$IM found deleted ODI source file <$TfGetOutputLineFileDir>. Delete using the ODI GUI."
				}
				else {
					$ExtensionFileCount += 1
					$currFileTypeList += $TfGetOutputLineFileDir
					LogDebug "$FN" "adding file <$TfGetOutputLineFileDir> to current file type list"
					###DebuggingPause
					$FileCount += 1
				}
			}
		}
		
		LogDebug "$FN" "completed extraction of files for object type <$FileObjType> from SVN UPDATE output. Starting file sorting"
		
		#
		# FOLLOWING CODE COMMON WITH OTHER SCM SYSTEMS.
		# TODO: move out common code to separate function.
		
		#
		# Sort the file list for nestable types.
		#
		$FileTypeIdx = 0
		foreach ($nestableContainerExtension in $nestableContainerExtensions) {
			###write-host "$DEBUG checking if current extension <$Extention> is nestable extension <$nestableContainerExtension>"
			if ($nestableContainerExtension -eq $Extention) {
			
				LogDebug "$FN" "current object type is a nestable container type. Sorting objects into parent-then-child order"
				
				[array] $sortFileList = @()
				#
				# Load the temporary array that we use to sort the files.
				#
				###write-host "$DEBUG loading object parent IDs"
				foreach ($sortFile in $currFileTypeList) {
					###write-host "$DEBUG loading file <$sortFile> into sorting array"
					$strFileDotParent = split-path $sortFile -leaf
					$strFileDotParent = $strFileDotParent.replace($nestableContainerExtension.replace("*",""),"")
					###write-host "$DEBUG point 1 strFileDotParent is <$strFileDotParent>"
					###DebuggingPause
					$strFileParentContent = get-content $sortFile | where {$_ -match $nestableContainerExtensionParentFields[$FileTypeIdx]}
					###write-host "$DEBUG got parent ID string <$strFileParentContent>"
					###DebuggingPause
					if ($strFileParentContent.length -gt 0) {
						$strFileParExtParBegin = $nestableContExtParBegin.replace("XXXXXXXXXXXXXXXXXXXX",$nestableContainerExtensionParentFields[$FileTypeIdx])
						###write-host "$DEBUG strFileParExtParBegin after replace is <$strFileParExtParBegin>"
						###DebuggingPause
						$strFileParent = $strFileParentContent.replace($strFileParExtParBegin,"")
						###write-host "$DEBUG point 1 strFileParent is <$strFileParent>"
						###DebuggingPause
						$strFileParent = $strFileParent.replace($nestableContExtParEnd,"")
						###write-host "$DEBUG point 2 strFileParent is <$strFileParent>"
						###DebuggingPause
						$strFileParent = $strFileParent.replace("null","")
						###write-host "$DEBUG point 3 strFileParent is <$strFileParent>"
						$strFileParent = $strFileParent.trim()		# Remove any white space.
						###DebuggingPause
						if ($strFileParent -ne "") {
							###write-host "$DEBUG strFileParent <> "" strFileParent <$strFileParent> strFileParent.length <"$strFileParent.length">"
							$strFileDotParent += "." + $strFileParent
						}
						###write-host "$DEBUG point 2 strFileDotParent is <$strFileDotParent>"
						###DebuggingPause
					}
					else {
						write-host "$EM cannot find parent ID field for sort input file <$sortFile>"
						return $False
					}
					$sortFileList += $strFileDotParent
					###write-host "$DEBUG adding child.parent <$strFileDotParent> to sort input"
					###write-host "$DEBUG sortFileList is now <"$sortFileList">"
				}
				
				#
				# Bubble sort the array.
				#
				###DebuggingPause
				LogDebug "$FN" "bubble sorting objects"
				do {
					###write-host "$DEBUG starting bubble sort interation"
					
					$blnSwapped = $False
					for ($i = 0; $i -lt $sortFileList.length - 1; $i++) {
						
						###write-host "$DEBUG i <" $i "> sortFileList[i] <" $sortFileList[$i] ">"
						
						[array] $intParentChild = @([regex]::split($sortFileList[$i],"\."))
						
						###write-host "$DEBUG intParentChild.length <"$intParentChild.length"> intParentChild <"$intParentChild">"
						###write-host "$DEBUG checking position of parent for child <" $intParentChild[0] ">"
						
						###DebuggingPause
						
						if ($intParentChild.length -eq 2) {
							#
							# There is a parent. Search for the parent's position in the working list.
							#
							$intChild = $intParentChild[0]
							$intParent = $intParentChild[1]
							
							###write-host "$DEBUG child <"$intParentChild[0]"> child <$intChild > parent <$intParent>"
							###DebuggingPause
							
							$intParentPos = -1
							for ($j = 0; $j -lt $sortFileList.length - 1; $j++) {
								[array] $intSearchParentChild = @([regex]::split($sortFileList[$j],"\."))
								$intSearchChild = $intSearchParentChild[0]
								if ($intSearchChild -eq $intParent) {
									$intParentPos = $j
									###write-host "$DEBUG found parent in sort list as position <$intParentPos>"
									break
								}
							}
							
							###write-host "$DEBUG child position <$i> parent position <$intParentPos>"
							
							if ($intParentPos -gt $i) {
								# Swap the current item with the next item.
								$tempFileListEntry = $sortFileList[$i]
								$sortFileList[$i]  = $sortFileList[$i + 1]
								$sortFileList[$i + 1]  = $tempFileListEntry
								$blnSwapped = $True
								###write-host "$DEBUG swapped entries <"$sortFileList[$i]"> and <"$sortFileList[$i + 1]">"
								###DebuggingPause
							}
						}
					}
				}
				while ($blnSwapped -eq $True)
				
				LogDebug "$FN" "completed bubble sort"
				###write-host "$DEBUG sortFileList is now <"$sortFileList">"
				###DebuggingPause
				
				#
				# Repopulate the current file type list.
				#
				LogDebug "$FN" "populating the sorted full file name list"
				$sortedCurrFileTypeList = @()
				foreach ($sortedFile in $sortFileList) {
					###write-host "$DEBUG doing sortedFile <"$sortedFile">"
					# Find the child entry.
					[array] $intParentChild = @([regex]::split($sortedFile,"\."))
					$intChild = $intParentChild[0]
					###write-host "$DEBUG for sortedFile <"$sortedFile"> got child <"$intChild">"
					for ($k = 0; $k -lt $currFileTypeList.length; $k++) {
						###write-host "$DEBUG looking for <$intChild> in currFileTypeList entry <$k> which contains <"$currFileTypeList[$k]">"
						$strFileName = split-path $currFileTypeList[$k] -leaf
						$intChildFile = $strFileName.replace($nestableContainerExtension.replace("*",""),"")
						if ($intChild -eq $intChildFile) {
							$sortedCurrFileTypeList += $currFileTypeList[$k]
							###write-host "$DEBUG found <$intChild> / <$intChildFile> at currFileTypeList entry <$k>"
							###write-host "$DEBUG adding entry <"$currFileTypeList[$k]"> to sort output"
							###DebuggingPause
							break
						}
						###else {
						###	write-host "$DEBUG didn't find <$intChild> in currFileTypeList entry <$k>"
						###}
					}
					
				}
				###write-host "$DEBUG final sortedCurrFileTypeList <$sortedCurrFileTypeList>"
				$currFileTypeList = @()
				foreach ($sortedCurrFile in $sortedCurrFileTypeList) {
					$currFileTypeList += $sortedCurrFile
				}
				###write-host "$DEBUG final currFileTypeList <$currFileTypeList>"
			}
			$FileTypeIdx += 1
		}
		LogDebug "$FN" "completed sorting of files for object type <$FileObjType>. Adding sort output to function output list"
		
		#
		# Add the current file type's list to the main output list.
		#
		foreach ($currFileTypeFile in $currFileTypeList) {
			$FileList.value += $currFileTypeFile	# We need to use the 'value' property for references to arrays.
		}
		LogDebug "$FN" "completed sorting of files for object type <$FileObjType>"
	}
	
	write-host "$IM total files parsed from command output is <$FileCount>"
	$ExitStatus = $True
	write-host "$IM ends"
	return $ExitStatus
}

#
# Perform a Get Latest Version operation for the entire branch.
#
function GetFromTFS ($HighChangeSetNumber, [ref] $FileList) {
	
	$FN = "GetFromTFS"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	set-location $LocalBranchRoot
	if (!($?)) {
		write-host "$EM cannot change working directory to branch root directory <$LocalBranchRoot>"
		return $ExitStatus
	}
	
	write-host "$IM previewing Get Latest Version. Output will be recorded in file <$GetLatestVersionOutputFile>"
	
	$CmdLine = "tf get $SCMBranchUrl /overwrite /preview /recursive /noprompt /version:C" + $HighChangeSetNumber + " >$GetLatestVersionOutputFile 2>&1"
	write-host "$IM executing command <$CmdLine>"
	invoke-expression $CmdLine
	if ($LastExitCode -ge 2) {
		write-host "$EM execution of command failed with exit status <$LastExitCode>"
		write-host "$EM check the output file for details. All conflicts must be resolved in order for this"
		write-host "$EM script can run successfully"
		return $ExitStatus
	}
	elseif ($LastExitCode -eq 1) {
		write-host "$EM execution of command partially failed with exit status <$LastExitCode>"
		write-host "$EM check the output file for details. All conflicts must be resolved in order for this"
		write-host "$EM script to be executed successfully"
		return $ExitStatus
	}
	
	write-host "$IM no conflicts detected in local working copy versus repository"
	write-host "$IM getting update from TFS to revision <$HighChangeSetNumber>"
	
	set-location $LocalBranchRoot
	if (!($?)) {
		write-host "$EM cannot change working directory to branch root directory <$LocalBranchRoot>"
		return $ExitStatus
	}
	
	$CmdLine = "tf get $SCMBranchUrl /overwrite /recursive /noprompt /version:C" + $HighChangeSetNumber + " >$GetLatestVersionOutputFile 2>&1"
	write-host "$IM executing command <$CmdLine>"
	invoke-expression $CmdLine
	if ($LastExitCode -ge 2) {
		write-host "$EM execution of command failed with exit status <$LastExitCode>"
		return $ExitStatus
	}
	elseif ($LastExitCode -eq 1) {
		write-host "$EM execution of command partially failed with exit status <$LastExitCode>"
		return $ExitStatus
	}
	
	#
	# Update the version of the local workspace.
	#
	# Dont use "add-content"? It always writes a newline at the end of the text.
	#(get-content -path $SCMGetLocalControlFile) + [Environment]::NewLine + $HighChangeSetNumber + "~" | set-content -path $SCMGetLocalControlFile
	####([Environment]::NewLine + $HighChangeSetNumber + "~") | add-content $SCMGetLocalControlFile
	$script:OdiScmConfig["ImportControls"]["WorkingCopyRevision"] = $HighChangeSetNumber + "~"
	SetIniContent $OdiScmConfig "$SCMConfigurationFile"
	
	#
	# Parse the output of the Get command to build the list of ODI source sources that we need to import.
	#
	$TfGetOutput = get-content $GetLatestVersionOutputFile
	write-host "$IM processing command output with <$($TfGetOutput.length)> records"
	$FileCount = 0
	
	# Holds the current file type's list of files (to allow us to sort where reuired before adding to the main output list).
	[array] $currFileTypeList = @()
	
	#
	# Loop through each extension and file files for which to include import commands.
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
		write-host "$IM processing object type <$FileObjType.replace(".","")>"
		
		###DebuggingPause
		
		$ExtensionFileCount = 0
		$FileToImportPathName = ""
		
		foreach ($TfGetOutputLine in $TfGetOutput) {
			#write-host "$IM processing text line : $TfGetOutputLine"
			if (($TfGetOutputLine.StartsWith($LocalRootDir)) -and ($TfGetOutputLine.EndsWith(":"))) {
				#
				# This is a local directory name. Use it as the file name prefix for subsequent records.
				#
				$FileToImportPathName = $TfGetOutputLine.TrimEnd(":")
			}
			
			if ($TfGetOutputLine.EndsWith($FileObjType)) {
				#
				# This is an ODI source object file name.
				#
				$FileToImportName = $TfGetOutputLine -replace("^Getting ","")
				$FileToImportName = $FileToImportName -replace("^Replacing ","")
				$FileToImportName = $FileToImportName -replace("^Adding ","")
				$FileToImportName = $FileToImportName -replace("^Deleting ","")
				
				if ($TfGetOutputLine.StartsWith("Deleting ")) {
					write-host "$IM found deleted ODI source file <$FileToImportName>. Delete using the ODI GUI."
				}
				else {
					$ExtensionFileCount += 1
					$currFileTypeList += "$FileToImportPathName\$FileToImportName"
					###write-host "$DEBUG adding file <$FileToImportPathName\$FileToImportName> to current file type list"
					###DebuggingPause
					$FileCount += 1
				}
			}
		}
		
		#
		# FOLLOWING CODE COMMON WITH OTHER SCM SYSTEMS.
		# TODO: move out common code to separate function.
		
		#
		# Sort the file list for nestable types.
		#
		$FileTypeIdx = 0
		foreach ($nestableContainerExtension in $nestableContainerExtensions) {
			###write-host "$DEBUG checking if current extension <$Extention> is nestable extension <$nestableContainerExtension>"
			if ($nestableContainerExtension -eq $Extention) {
				###write-host "$DEBUG sorting objects into parent-then-child order"
				
				[array] $sortFileList = @()
				#
				# Load the temporary array that we use to sort the files.
				#
				###write-host "$DEBUG loading object parent IDs"
				foreach ($sortFile in $currFileTypeList) {
					###write-host "$DEBUG loading file <$sortFile> into sorting array"
					$strFileDotParent = split-path $sortFile -leaf
					$strFileDotParent = $strFileDotParent.replace($nestableContainerExtension.replace("*",""),"")
					###write-host "$DEBUG point 1 strFileDotParent is <$strFileDotParent>"
					###DebuggingPause
					$strFileParentContent = get-content $sortFile | where {$_ -match $nestableContainerExtensionParentFields[$FileTypeIdx]}
					###write-host "$DEBUG got parent ID string <$strFileParentContent>"
					###DebuggingPause
					if ($strFileParentContent.length -gt 0) {
						$strFileParExtParBegin = $nestableContExtParBegin.replace("XXXXXXXXXXXXXXXXXXXX",$nestableContainerExtensionParentFields[$FileTypeIdx])
						###write-host "$DEBUG strFileParExtParBegin after replace is <$strFileParExtParBegin>"
						###DebuggingPause
						$strFileParent = $strFileParentContent.replace($strFileParExtParBegin,"")
						###write-host "$DEBUG point 1 strFileParent is <$strFileParent>"
						###DebuggingPause
						$strFileParent = $strFileParent.replace($nestableContExtParEnd,"")
						###write-host "$DEBUG point 2 strFileParent is <$strFileParent>"
						###DebuggingPause
						$strFileParent = $strFileParent.replace("null","")
						###write-host "$DEBUG point 3 strFileParent is <$strFileParent>"
						$strFileParent = $strFileParent.trim()		# Remove any white space.
						###DebuggingPause
						if ($strFileParent -ne "") {
							###write-host "$DEBUG strFileParent <> "" strFileParent <$strFileParent> strFileParent.length <"$strFileParent.length">"
							$strFileDotParent += "." + $strFileParent
						}
						###write-host "$DEBUG point 2 strFileDotParent is <$strFileDotParent>"
						###DebuggingPause
					}
					else {
						write-host "$EM cannot find parent ID field for sort input file <$sortFile>"
						return $False
					}
					$sortFileList += $strFileDotParent
					###write-host "$DEBUG adding child.parent <$strFileDotParent> to sort input"
					###write-host "$DEBUG sortFileList is now <"$sortFileList">"
				}
				
				#
				# Bubble sort the array.
				#
				###DebuggingPause
				###write-host "$DEBUG bubble sorting objects"
				do {
					###write-host "$DEBUG starting bubble sort interation"
					
					$blnSwapped = $False
					for ($i = 0; $i -lt $sortFileList.length - 1; $i++) {
						
						###write-host "$DEBUG i <" $i "> sortFileList[i] <" $sortFileList[$i] ">"
						
						[array] $intParentChild = @([regex]::split($sortFileList[$i],"\."))
						
						###write-host "$DEBUG intParentChild.length <"$intParentChild.length"> intParentChild <"$intParentChild">"
						###write-host "$DEBUG checking position of parent for child <" $intParentChild[0] ">"
						
						###DebuggingPause
						
						if ($intParentChild.length -eq 2) {
							#
							# There is a parent. Search for the parent's position in the working list.
							#
							$intChild = $intParentChild[0]
							$intParent = $intParentChild[1]
							
							###write-host "$DEBUG child <"$intParentChild[0]"> child <$intChild > parent <$intParent>"
							###DebuggingPause
							
							$intParentPos = -1
							for ($j = 0; $j -lt $sortFileList.length - 1; $j++) {
								[array] $intSearchParentChild = @([regex]::split($sortFileList[$j],"\."))
								$intSearchChild = $intSearchParentChild[0]
								if ($intSearchChild -eq $intParent) {
									$intParentPos = $j
									###write-host "$DEBUG found parent in sort list as position <$intParentPos>"
									break
								}
							}
							
							###write-host "$DEBUG child position <$i> parent position <$intParentPos>"
							
							if ($intParentPos -gt $i) {
								# Swap the current item with the next item.
								$tempFileListEntry = $sortFileList[$i]
								$sortFileList[$i]  = $sortFileList[$i + 1]
								$sortFileList[$i + 1]  = $tempFileListEntry
								$blnSwapped = $True
								###write-host "$DEBUG swapped entries <"$sortFileList[$i]"> and <"$sortFileList[$i + 1]">"
								###DebuggingPause
							}
						}
					}
				}
				while ($blnSwapped -eq $True)
				
				###write-host "$DEBUG completed bubble sort"
				###write-host "$DEBUG sortFileList is now <"$sortFileList">"
				###DebuggingPause
				
				#
				# Repopulate the current file type list.
				#
				###write-host "$DEBUG populating the sorted full file name list"
				$sortedCurrFileTypeList = @()
				foreach ($sortedFile in $sortFileList) {
					###write-host "$DEBUG doing sortedFile <"$sortedFile">"
					# Find the child entry.
					[array] $intParentChild = @([regex]::split($sortedFile,"\."))
					$intChild = $intParentChild[0]
					###write-host "$DEBUG for sortedFile <"$sortedFile"> got child <"$intChild">"
					for ($k = 0; $k -lt $currFileTypeList.length; $k++) {
						###write-host "$DEBUG looking for <$intChild> in currFileTypeList entry <$k> which contains <"$currFileTypeList[$k]">"
						$strFileName = split-path $currFileTypeList[$k] -leaf
						$intChildFile = $strFileName.replace($nestableContainerExtension.replace("*",""),"")
						if ($intChild -eq $intChildFile) {
							$sortedCurrFileTypeList += $currFileTypeList[$k]
							###write-host "$DEBUG found <$intChild> / <$intChildFile> at currFileTypeList entry <$k>"
							###write-host "$DEBUG adding entry <"$currFileTypeList[$k]"> to sort output"
							###DebuggingPause
							break
						}
						###else {
						###	write-host "$DEBUG didn't find <$intChild> in currFileTypeList entry <$k>"
						###}
					}
					
				}
				###write-host "$DEBUG final sortedCurrFileTypeList <$sortedCurrFileTypeList>"
				$currFileTypeList = @()
				foreach ($sortedCurrFile in $sortedCurrFileTypeList) {
					$currFileTypeList += $sortedCurrFile
				}
				###write-host "$DEBUG final currFileTypeList <$currFileTypeList>"
			}
			$FileTypeIdx += 1
		}
		
		#
		# Add the current file type' list to the main output list.
		#
		foreach ($currFileTypeFile in $currFileTypeList) {
			$FileList.value += $currFileTypeFile	# We need to use the 'value' property for references to arrays.
		}
	}
	
	write-host "$IM total files parsed from command output is <$FileCount>"
	$ExitStatus = $True
	write-host "$IM ends"
	return $ExitStatus
}

function ExecOdiRepositorySql ($SqlScriptFile) {
	
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
	$StdOutLogFile = "$GenScriptRootDir\ExecOdiRepositorySql_${SqlScriptFileName}_StdOut_${VersionString}.log"
	$StdErrLogFile = "$GenScriptRootDir\ExecOdiRepositorySql_${SqlScriptFileName}_StdErr_${VersionString}.log"
	write-host "$IM StdOut will be captured in file <$StdOutLogFile>"
	write-host "$IM StdOut will be captured in file <$StdErrLogFile>"
	
	#write-host "$IM executing command $ScriptsRootDir\MoiJisqlRepo.bat $SqlScriptFile $StdOutLogFile $StdErrLogFile"
	$CmdOutput = cmd /c "$OdiScmJisqlRepoBat $SqlScriptFile $StdOutLogFile $StdErrLogFile"
	$BatchExitCode = $LastExitCode
	
	#write-host "$IM command output >>>"
	#write-host $CmdOutput
	#write-host "$IM <<< end of command output"
	
	#write-host "$IM command captured StdOut >>>"
	#write-host (get-content $StdOutLogFile)
	#write-host "$IM <<< end of command captured StdOut"
	
	#write-host "$IM command captured StdErr >>>"
	#write-host (get-content $StdErrLogFile)
	#write-host "$IM <<< end of command captured StdErr"
	
	if ($BatchExitCode -eq 0) {
		write-host "$IM execution of command completed successfully"
	}
	else {
		write-host "$EM execution of command failed with exit status <$BatchExitCode>"
		$ExitStatus = $False
		return $ExitStatus
	}
	
	$StdOutText = get-content $StdOutLogFile | out-string
	$StdErrText = get-content $StdErrLogFile | out-string
	
	if (($StdErrText.Trim()).length -ne 0) {
		write-host "$EM executed script produced StdErr output"
		$ExitStatus = $False
		return $ExitStatus
	}
	
	write-host "$IM ends"
	
	return ($FN + ":" + $StdOutText.Trim())
}

#
# Main.
#
. "C:\MOI\OdiSvn\odietamo\Configuration\Scripts\PrimeWriteHost.ps1"
. "C:\MOI\OdiSvn\odietamo\Configuration\Scripts\Constants.ps1"
GetIncremental