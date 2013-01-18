function DebuggingPause {
	
	$IM = "DebuggingPause: INFO:"
	$EM = "DebuggingPause: ERROR:"
	
	write-host "$IM you're debugging. Press any key to continue"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
}

function LogDebug ($strSource, $strToPrint) {
	
	write-host "$strSource: DEBUG: $strToPrint"
}

function LogDebugArray ($strSource, $strArrName, [array] $strToPrint) {
	
	$intIdx = 0
	
	foreach ($x in $strToPrint) {
		write-host "$strSource: DEBUG: $strArrName[$intIdx]: $x"
		$intIdx += 1
	}
}

#
# Check that the required external commands are available.
#
function CheckDependencies {
	
	$FN = "CheckDependencies"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
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

#
# Get the latest ChangeSet number from the TFS server.
#
function GetNewChangeSetNumber {
	
	$FN = "GetNewChangeSetNumber"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	
	write-host "$IM Getting the latest ChangeSet number from the TFS server"
	
	#
	# Generate a unique file name (with path included).
	#
	$TempFileNameStub = "$GenScriptRootDir\psexec_out_${VersionString}"
	
	$RegKey = get-itemproperty HKLM:\SOFTWARE\Microsoft\VisualStudio\10.0
	$TfDir = [string] (get-itemproperty $RegKey.InstallDir)
	
	$CmdArgs = '"' + "changeset /noprompt /latest /server:${TFSServer}" + '"'
	$CmdLine = "psexec.exe -u GBBUPAGROUP\moidevdeploy -p P1rsl3y cmd.exe /c " + '"' + "$ScriptsRootDir\OdiSvnRedirCmd.bat" + '" "' + "$TfDir" + "tf.exe" + '" "' + "$TempFileNameStub" + '"' + " $CmdArgs"
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
function GetDifference ([string] $difference) {
	
	$IM = "GetDifference: INFO:"
	$EM = "GetDifference: ERROR:"
	$DEBUG = "GetDifference: DEBUG:"
	
	write-host "$IM starts"
	write-host "$IM getting changed files list from TFS for Changesets <$difference>"
	
	$difference = $difference.Replace(" ","")
	
	write-host "$IM command to be executed <tf history $TFSBranchName /format:detailed /recursive /collection:${TFSServer} /version:${difference}>"
	
	$CmdLine = "tf history " + '"' + $LocalBranchRoot + '"' + " /format:detailed /recursive /collection:${TFSServer} /version:${difference} | out-string"
	$ChangeHistoryDiff = invoke-expression $CmdLine
	
	#write-host "$DEBUG ChangeHistoryDiff: " $ChangeHistoryDiff
	$IndexCheckinNotes = $ChangeHistoryDiff.IndexOf("Check-in Notes:")
	#write-host "$DEBUG IndexOf `'Check-in Notes`':" $IndexCheckinNotes
	$IndexItems = $ChangeHistoryDiff.IndexOf("Items:") 
	#write-host "$DEBUG IndexOf Items: " $IndexItems
	
	$CountOfItemInList = 0
	[array] $outFileList = @()
		
	if ($ChangeHistoryDiff.IndexOf("Check-in Notes:") -gt 0) {
		
		$ChangeLogList = @([regex]::split($ChangeHistoryDiff,"Changeset: "))
		
		foreach ($item in $ChangeLogList) { 
		
			#
			# Don't process the first/empty element.
			#
			if ($CountOfItemInList -ne 0) {
				
				$IndexCheckinNotes = $item.IndexOf("Check-in Notes:")
				$IndexItems = $item.IndexOf("Items:") 
				#write-host "$DEBUG IndexCheckinNotes:" $IndexCheckinNotes
				#write-host "$DEBUG IndexTtems: " $IndexItems
				
				$item2 = $item.Substring($item.IndexOf("Items:") + 6, $item.IndexOf("Check-in Notes:") - $item.IndexOf("Items:") - 6)
				$item2 = $item2.Trim()
				#write-host "$DEBUG item2: " $item2
				
				$item3 = @([regex]::split($item2,[Environment]::NewLine))
				#write-host "$DEBUG item3: " $item3
				foreach ($item4 in $item3) {
					$item5 = $item4.Replace("add ", "").Replace("edit ", "").Trim()
					$item5 = $item5.Replace(("$/" + $TFSMoiProjectName + "/"),"")
					#write-host ("$IM final parsed item>>>" + $item5 + "<<<")
					#
					################## Ensure we add a file system rather than a string object to the output array.
					#
					#$item6 = get-childitem $item5
					$item6 = $item5
					#write-host "$IM adding to list" $item6.Fullname
					#$outFileList += @($item6)
					#
					# Ignore the creation of the actual branch root in TFS.
					#
					if ($item6 -ne $TFSMoiBranchName) {
						#write-host "$IM adding to list" $item6
						$outFileList += $item6
					}
					#DebuggingPause
				}
			}
			$CountOfItemInList += 1
		}
	}
	else {
		write-host "$IM there are no changed files"
	}
	
	# 
	# Exception trap for any exception raised in all code in this function up until this point.
	#
	&{trap	{
			write-host "$EM exception trapped <$_.Exception>"
			#
			# Return an null array upon failure.
			#
			return
		}
	}
	
	write-host "$IM ends"
	return $outFileList
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
	
	#
	# Import script initialisation commands - CWD to the ODI bin directory.
	#
	"@echo off" | out-file $OdiImportScriptFile -encoding ASCII -append
	("set IM=$OdiImportScriptName" + ": INFO:") | out-file $OdiImportScriptFile -encoding ASCII -append
	("set EM=$OdiImportScriptName" + ": ERROR:") | out-file $OdiImportScriptFile -encoding ASCII -append
	"cd /d ${odiBinFolder}" | out-file $OdiImportScriptFile -encoding ASCII -append
	
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
				
				$ImportText = "echo %IM% date time: %date% %time%" + [Environment]::NewLine
				$ImportText += "set MSG=importing file " + '"' + $FileToImportName + '"' + " from directory " + '"' + $FileToImportPathName + '"' + [Environment]::NewLine
				
				if (!($containerExtensions -contains $ext)) {
					$ImportText += "call startcmd.bat OdiImportObject -FILE_NAME=" + '"' + $fileToImport + '"' + " -IMPORT_MODE=$ODIImportModeInsertUpdate -WORK_REP_NAME=$WORK_REP_NAME" + [Environment]::NewLine
				}
				else {
					$ImportText += "call startcmd.bat OdiImportObject -FILE_NAME=" + '"' + $fileToImport + '"' + " -IMPORT_MODE=$ODIImportModeInsert -WORK_REP_NAME=$WORK_REP_NAME" + [Environment]::NewLine
					$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
					$ImportText += "call startcmd.bat OdiImportObject -FILE_NAME=" + '"' + $fileToImport + '"' + " -IMPORT_MODE=$ODIImportModeUpdate -WORK_REP_NAME=$WORK_REP_NAME" + [Environment]::NewLine
				}
				$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
				$ImportText += "echo " + $OdiImportScriptName + ": INFO: import of file " + $FileToImportName + " completed succesfully" + [Environment]::NewLine
				$ImportText | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
			}
		}
	}
	
	#
	# Import script termination commands - the common Exit labels.
	#
	":ExitOk" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append 
	"echo INFO: import process completed" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append 
	"exit /b 0" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	":ExitFail" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"echo %EM% %MSG%" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	"exit /b 1" | out-file -filepath $OdiImportScriptFile -encoding ASCII -append
	
	write-host "$IM lines in generated script content <$(((get-content $OdiImportScriptFile).Count)-1)>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GetTFSServerConfiguration {
	
	$FN = "GetTFSServerConfiguration"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	#
	# Load the TFS server configuration (server, project, and branch).
	#
	write-host "$IM using configuration file <$TFSServerConfigurationFile>"
	$CmdOutput = (get-content $TFSServerConfigurationFile)[-1]
	if (! $?) {
		write-host "$EM reading from configuration file <$TFSServerConfigurationFile>"
		return $False
	}
	write-host "$DEBUG read from configuration file <$CmdOutput>"
	$CmdOutputParts = @([regex]::split($CmdOutput,","))
	
	$script:TFSServer = $CmdOutputParts[0]				# E.g. "http://statfssqlprd02:8080/tfs/bhwdevelopment"
	$script:TFSMoiProjectName = $CmdOutputParts[1]		# E.g. "MOIInternalReleases"
	$script:TFSMoiBranchName = $CmdOutputParts[2]		# E.g. "MOI_Production"
	
	if (($script:TFSServer -eq $Null) -or ($script:TFSServer -eq "")) {
		write-host "$EM cannot retrieve TFS server URL from configuration file <$TFSServerConfigurationFile>"
		return $False
	}
	
	if (($script:TFSMoiProjectName -eq $Null) -or ($script:TFSMoiProjectName -eq "")) {
		write-host "$EM cannot retrieve TFS project name from configuration file <$TFSServerConfigurationFile>"
		return $False
	}
	
	if (($script:TFSMoiBranchName -eq $Null) -or ($script:TFSMoiBranchName -eq "")) {
		write-host "$EM cannot retrieve TFS branch name from configuration file $<TFSServerConfigurationFile>"
		return $False
	}
	
	$script:TFSBranchName = "$/" + $script:TFSMoiProjectName + "/" + $script:TFSMoiBranchName
	$script:LocalBranchRoot = $LocalRootDir + "\$TFSMoiBranchName"
	
	write-host "$IM using TFS Server URL      : <$script:TFSServer>"
	write-host "$IM using TFS Project Name    : <$script:TFSMoiProjectName>"
	write-host "$IM using TFS Code Branch Name: <$script:TFSMoiBranchName>"
	
	write-host "$IM ends"
	return $True
}

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
	
	if (!(GetTFSServerConfiguration)) {
		write-host "$EM error loading TFS server configuration"
		return $False
	}
	
	#
	# Set up the ODI repository SQL access script.
	#
	if (!(SetMoiJisqlRepoBatContent)) {
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
	# Get the last ChangeSet number successfully applied to the local workspace
	# from the local metadata.
	#
	write-host "$IM getting last ChangeSet applied to the local workspace from local metadata"
	write-host "$IM file <$TFSGetLocalControlFile>"
	$LocalControlChangeSet = get-content $TFSGetLocalControlFile | select-object -last 1
	if (($LocalControlChangeSet.substring(($LocalControlChangeSet.length) - 1)) -ne "~") {
		write-host "$EM format of local workspace next import metadata <$LocalControlChangeSet> is invalid"
		write-host "$EM format must be '<last imported ChangeSet>~'"
		return $False
	}
	$LocalControlLastChangeSet = $LocalControlChangeSet.substring(0,($LocalControlChangeSet.length) - 1)
	write-host "$IM local metadata: last ChangeSet applied to the local workspace <$LocalControlLastChangeSet>"
	###DebuggingPause
	#
	# Get the last ChangeSet number successfully applied to the ODI repository
	# from the local metadata.
	#
	write-host "$IM getting last ChangeSet applied to the ODI repository from local metadata"
	write-host "$IM file <$TFSGetLocalODIControlFile>"
	$LocalODIControlChangeSet = get-content $TFSGetLocalODIControlFile | select-object -last 1
	if (($LocalODIControlChangeSet.substring(($LocalODIControlChangeSet.length) - 1) -ne "~")) {
		write-host "$EM format of local workspace next import metadata <$ODIControlChangeSet> is invalid"
		write-host "$EM format must be '<last imported ChangeSet>~'"
		return $False
	}
	$LocalODIControlLastChangeSet = $LocalODIControlChangeSet.substring(0,($LocalODIControlChangeSet.length) - 1)
	write-host "$IM local metadata: last ChangeSet applied to the ODI repository <$LocalODIControlLastChangeSet>"
	###DebuggingPause
	#
	# Check that the ChangeSets applied to the local workspace (with 'tf get') have been imported into the
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
		write-host "$EM error creating OdiSvn repository infrastructure"
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
	write-host "$IM from ODI repository: got Branch Name     : <$OdiRepoBranchName>"
	write-host "$IM from ODI repository: got Last Import To  : <$OdiRepoLastImportTo>"
	###DebuggingPause
	#
	# Get the latest ChangeSet number from the TFS server.
	#
	write-host "$IM getting latest ChangeSet number from the TFS server"
	$HighChangeSetNumber = GetNewChangeSetNumber
	write-host "$IM latest ChangeSet number returned is <$HighChangeSetNumber>"
	###DebuggingPause
	$difference = $LocalODIControlChangeSet + $HighChangeSetNumber
	write-host "$IM new ChangeSet range to apply to the local workspace is <$difference>"
	
	if (!(ChangeSetRangeIsValid($difference))) {
		write-host "$EM the derived ChangeSet range <$difference> is invalid"
		return $ExitStatus
	}
	###DebuggingPause
	# TODO: pass references to $LocalLastImportFrom/$LocalLastImportTo and make ChangeSetRangeIsValid
	#       set the values.
	$StringList = @([regex]::split($difference,"~"))
	[string] $LocalLastImportFrom = $StringList[0]
	[string] $LocalLastImportTo = $StringList[1]
	###DebuggingPause
	if ($LocalLastImportFrom -ne "1") {
		write-host "$IM this is not the initial GetIncremental update. An incremental Get will be run"
		$FullImportInd = $False
	}
	else {
		write-host "$IM this is the initial GetIncremental update. An full/initial Get will be run"
		$FullImportInd = $True
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
		if ($OdiRepoBranchName -ne $TFSBranchName) {
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
		write-host "$IM the local workspace is already up to date with the TFS repository"
		$ExitStatus = $True
		return $ExitStatus
	}
	
	[array] $TFSGetFileList = @()
	[ref] $ArrayRef = [ref]$TFSGetFileList
	if (!(GetFromTFS $HighChangeSetNumber $ArrayRef)) {
		write-host "$EM failure getting latest code from TFS"
		return $False
	}
	
	write-host "$IM GetFromTFS returned ODI source <$($TFSGetFileList.length)> files to import"
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
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoUserName>",$SECURITY_USER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPassWord>",$SECURITY_UNENC_PWD)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoServer>",$SECURITY_URL_SERVER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPort>",$SECURITY_URL_PORT)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoSID>",$SECURITY_URL_SID)
	
	$ExportFileName = "$GenScriptRootDir" + "\OdiSvnExportBackUp_${SECURITY_USER}_${SECURITY_URL_SERVER}_${SECURITY_URL_SID}_${VersionString}.dmp"
	$ScriptFileContent = $ScriptFileContent.Replace("<ExportBackUpFile>",$ExportFileName)
	
	set-content -path $OdiSvnRepositoryBackUpBat -value $ScriptFileContent
	
	write-host "$IM ends"
	
	return $True
}

#
# Generate the batch file MoiJisqlRepo.bat.
# This batch file is used to execute SQL statements directly against the ODI repository
# whose details are specified in "odiparams.bat".
#
function SetMoiJisqlRepoBatContent {

	$IM = "SetMoiJisqlRepoBatContent: INFO:"
	$EM = "SetMoiJisqlRepoBatContent: ERROR:"

	write-host "$IM starts"
	$fileContent = get-content $MoiJisqlRepoBatTemplate | out-string 
	
	$fileContent = $fileContent.Replace("<SECURITY_DRIVER>",$SECURITY_DRIVER)
	$fileContent = $fileContent.Replace("<SECURITY_URL>",$SECURITY_URL)
	$fileContent = $fileContent.Replace("<SECURITY_USER>",$SECURITY_USER)  
	$fileContent = $fileContent.Replace("<SECURITY_UNENC_PWD>",$SECURITY_UNENC_PWD)
	
	set-content $MoiJisqlRepoBat -value $fileContent
	
	write-host "$IM completed modifying content of <$MoiJisqlRepoBat>"
	write-host "$IM ends"
	
	return $True
}

#
# Generate the script to set up the OdiSvn ODI repository metata infrastructure.
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
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoUserName>",$SECURITY_USER)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiWorkRepoPassWord>",$SECURITY_UNENC_PWD)
	
	$OraConn = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$SECURITY_URL_SERVER)(PORT=$SECURITY_URL_PORT))(CONNECT_DATA=(SID=$SECURITY_URL_SID))))"
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
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnBranchName>",$TFSBranchName)
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
	
	$NoteText = $NoteText.Replace("<TFSServer>",$TFSServer)
	$NoteText = $NoteText.Replace("<TFSMoiProjectName>",$TFSMoiProjectName)
	$NoteText = $NoteText.Replace("<TFSMoiBranchName>",$TFSMoiBranchName)
	$NoteText = $NoteText.Replace("<LocalBranchRoot>",$LocalBranchRoot)
	$NoteText = $NoteText.Replace("<VersionRange>",$VersionRange)
	
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
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnGenScenPostImportBat>",$OdiSvnGenScenPostImportBat)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnChangeSetsFile>",$TFSGetLocalODIControlFile)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnLatestChangeSet>",$NextImportChangeSetRange)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiSvnSetNextImportSql>",$OdiSvnRepoSetNextImport)
	$ScriptFileContent = $ScriptFileContent.Replace("<GenScriptRootDir>",$GenScriptRootDir)
	
	set-content -path $OdiSvnBuildBat -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Preview Get Latest Version operations to check for conflicts between the local working
# copy and the TFS repository.
#
#function GetPreview ($HighChangeSetNumber) {
#	
#	$FN = "GetPreview"
#	$IM = $FN + ": INFO:"
#	$EM = $FN + ": ERROR:"
#	$DEBUG = $FN + ": DEBUG:"
#	
#	write-host "$IM starts"
#	write-host "$IM getting preview of TFS Get operation of version <$HighChangeSetNumber>"
#	
#	$ExitStatus = $False
#	
#	set-location $LocalBranchRoot
#	if (!($?)) {
#		write-host "$EM cannot change working directory to branch root directory <$LocalBranchRoot>"
#		return $ExitStatus
#	}
#	
#	write-host "$IM previewing Get Latest Version and writing output to <$GetLatestVersionOutputFile>"
#	
#	$intFileCount = 0
#	
#	$CmdLine = "tf get $TFSBranchName /force /preview /recursive /noprompt /version:C" + $HighChangeSetNumber + " >$GetLatestVersionOutputFile 2>&1"
#	write-host "$IM executing command <$CmdLine>"
#	invoke-expression $CmdLine
#	if ($LastExitCode -ge 2) {
#		write-host "$EM execution of command failed with exit status <$LastExitCode>"
#		return $ExitStatus
#	}
#	elseif ($LastExitCode -eq 1) {
#		write-host "$EM execution of command partially failed"
#		return $ExitStatus
#	}
#	
#	$ExitStatus = $True
#	
#	write-host "$IM ends"
#	return $ExitStatus
#}
#
#function GetPreviewIncremental ([array] $filesToGetLatest) {
#	
#	$FN = "GetPreviewIncremental"
#	$IM = $FN + ": INFO:"
#	$EM = $FN + ": ERROR:"
#	$DEBUG = $FN + ": DEBUG:"
#	
#	write-host "$IM starts"
#	
#	$resultValue = $False
#	
#	set-location $LocalBranchRoot
#	if (!($?)) {
#		write-host "$EM cannot change working directory to branch root directory $LocalBranchRoot"
#		return $resultValue
#	}
#	
#	write-host "$IM previewing Get Latest Version and writing output to $GetLatestVersionOutputFile"
#	
#	$intFileCount = 0
#	
#	foreach ($fileToGetLatest in $filesToGetLatest) {
#		
#		$intFileCount += 1
#		#
#		# Add command output separator so we can separate later.
#		# Don't add it before the first file in the list.
#		#
#		if ($intFileCount -gt 1) {
#			out-file -filepath $GetLatestVersionOutputFile -append -noclobber -inputobject $strOdiSvnCmdOutputSeparator
#		}
#		
#		$CmdLine = "tf get " + '"' + $fileToGetLatest + '"' + " /force /preview /recursive /noprompt >>$GetLatestVersionOutputFile 2>&1"
#		write-host "$IM executing command: $CmdLine"
#		invoke-expression $CmdLine
#		if ($LastExitCode -ge 2) {
#			write-host "$EM execution of command failed with exit status $LastExitCode"
#			return $resultValue
#		}
#		elseif ($LastExitCode -eq 1) {
#			write-host "$EM execution of command partially failed"
#			return $resultValue
#		}
#	}
#	
#	$resultValue = $True
#	
#	write-host "$IM ends"
#	return $resultValue
#}

#
# Check for conflicts between the working copy and the TFS repository.
#
#function CheckOutputForConflicts {
#	
#	$FN = "CheckOutputForConflictsFull"
#	$IM = $FN + ": INFO:"
#	$EM = $FN + ": ERROR:"
#	$DEBUG = $FN + ": DEBUG:"
#	
#	$resultValue = $True
#	
#	write-host "$IM starts"
#	write-host "$IM input file is <$GetLatestVersionOutputFile>"
#	write-host "$IM output file is <$GetLatestVersionConflictsOutputFile>"
#	
#	DebuggingPause
#	
#	$getPreviewOutputs = get-content $GetLatestVersionOutputFile
#	$getPreviewOutput = @([regex]::split($getPreviewOutputs, $strOdiSvnCmdOutputSeparator))
#	write-host "$IM input file contains results from <$($getPreviewOutput.length) commands>"
#	DebuggingPause
#	foreach ($getPreviewFileOutput in $getPreviewOutput) {
#		
#		write-host "$IM start of input file text part>>>"
#		write-host $getPreviewFileOutput
#		write-host "$IM <<< end of input file text part"
#		write-host "$IM length of text file part is <$($getPreviewFileOutput.length)>"
#		DebuggingPause
#		#
#		# Check if it has details/we can capture them.
#		#
#		$indexSummary = $getPreviewFileOutput | out-string | foreach { $_.IndexOf($GetLatestSummaryText) }
#		DebuggingPause
#		$indexConflict = $getPreviewFileOutput | out-string | foreach { $_.LastIndexOf($endOfConflictText) }
#		DebuggingPause
#		$x = $getPreviewFileOutput | out-string 
#		$searchtextcontent = "(?<content>.*)" + $GetLatestSearchText 
#		DebuggingPause
#		if ($x -match $searchtextcontent) {
#			#
#			# Conflicts detected.
#			#
#			DebuggingPause
#			$message = $matches['content'] + $searchText            
#			$message | Out-File -filepath $GetLatestVersionConflictsOutputFile -append
#			write-host "$IM conflicts have been detected. Please check file <$GetLatestVersionConflictsOutputFile>"
#			$resultValue = $False
#			return $resultValue
#		}
#		DebuggingPause
#	}
#	DebuggingPause
#	write-host "$IM ends"
#	return $resultValue
#}
#
#function CheckOutputForConflictsIncremental {
#	
#	$FN = "CheckOutputForConflictsIncremental"
#	$IM = $FN + ": INFO:"
#	$EM = $FN + ": ERROR:"
#	$DEBUG = $FN + ": DEBUG:"
#	
#	$resultValue = $True
#	
#	write-host "$IM starts"
#	write-host "$IM input file is $GetLatestVersionOutputFile"
#	write-host "$IM output file is $GetLatestVersionConflictsOutputFile"
#	
#	$getPreviewOutputs = get-content $GetLatestVersionOutputFile
#	$getPreviewOutput = @([regex]::split($getPreviewOutputs, $strOdiSvnCmdOutputSeparator))
#	write-host "$IM input file contains results from" $($getPreviewFiles.length) "commands"
#	
#	foreach ($getPreviewFileOutput in $getPreviewOutput) {
#		
#		write-host "$IM start of input file text part>>>"
#		write-host $getPreviewFileOutput
#		write-host "$IM <<< end of input file text part"
#		
#		#
#		# Check if it has details/we can capture them.
#		#
#		$indexSummary = $getPreviewFileOutput | out-string | foreach { $_.IndexOf($GetLatestSummaryText) }
#		$indexConflict = $getPreviewFileOutput | out-string | foreach { $_.LastIndexOf($endOfConflictText) }
#		
#		$x = $getPreviewFileOutput | out-string 
#		$searchtextcontent = "(?<content>.*)" + $GetLatestSearchText 
#		
#		if ($x -match $searchtextcontent) {
#			#
#			# Conflicts detected.
#			#
#			$message = $matches['content'] + $searchText            
#			$message | Out-File -filepath $GetLatestVersionConflictsOutputFile -append
#			write-host "$IM conflicts have been detected. Please check file $GetLatestVersionConflictsOutputFile"
#			$resultValue = $False
#			return $resultValue
#		}
#	}
#	
#	write-host "$IM ends"
#	return $resultValue
#}

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
	
	$CmdLine = "tf get $TFSBranchName /overwrite /preview /recursive /noprompt /version:C" + $HighChangeSetNumber + " >$GetLatestVersionOutputFile 2>&1"
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
		write-host "$EM script can run successfully"
		return $ExitStatus
	}
	
	write-host "$IM no conflicts detected in local working copy versus repository"
	write-host "$IM getting update from TFS to version <$HighChangeSetNumber>"
	
	set-location $LocalBranchRoot
	if (!($?)) {
		write-host "$EM cannot change working directory to branch root directory <$LocalBranchRoot>"
		return $ExitStatus
	}
	
	$CmdLine = "tf get $TFSBranchName /overwrite /recursive /noprompt /version:C" + $HighChangeSetNumber + " >$GetLatestVersionOutputFile 2>&1"
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
	#(get-content -path $TFSGetLocalControlFile) + [Environment]::NewLine + $HighChangeSetNumber + "~" | set-content -path $TFSGetLocalControlFile
	([Environment]::NewLine + $HighChangeSetNumber + "~") | add-content $TFSGetLocalControlFile
	
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
	$CmdOutput = cmd /c "$ScriptsRootDir\MoiJisqlRepo.bat $SqlScriptFile $StdOutLogFile $StdErrLogFile"
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
. "C:\MOI\Configuration\Scripts\PrimeWriteHost.ps1"
. "C:\MOI\Configuration\Scripts\Constants.ps1"
GetIncremental