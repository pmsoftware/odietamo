#
# Check that the required external commands are available.
#
function CheckDependencies {
	
	$FN = "CheckDependencies"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	$SCMSystemTypeName = $OdiScmConfig["SCM System"]["Type Name"]
	
	if ($SCMSystemTypeName -eq "TFS") {
		if (($env:ODI_SCM_TOOLS_TEAM_EXPLORER_EVERYWHERE_JAVA_HOME -ne "") -and ($env:ODI_SCM_TOOLS_TEAM_EXPLORER_EVERYWHERE_JAVA_HOME -ne $Null)) {
			$strJavaHome = $env:ODI_SCM_TOOLS_TEAM_EXPLORER_EVERYWHERE_JAVA_HOME
			$strJavaHome = $strJavaHome.Replace("/", "\")
			$env:PATH = $strJavaHome + "\bin;" + $env:PATH
		}
		# Execute the TFS command line client.
		$ToNull = tf
		if ($LastExitCode -ne 0) {
			write-host "$EM command tf is not available. Ensure PATH is correctly set"
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
	
	write-host "$IM completed checking dependencies"
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
	$ExitStatus = $False
	
	if (!(GetOdiScmConfiguration)) {
		write-host "$EM error loading ODI-SCM configuration from INI file"
		return $False
	}
	
	if (!(SetOutputNames)) {
		write-host "$EM error setting output file and directory names"
		return $False
	}
	
	if (!(CheckDependencies)) {
		return $ExitStatus
	}
	
	#
	# Set up the ODI repository SQL access script.
	#
	if (!(SetOdiScmJisqlRepoBatContent)) {
		write-host "$EM error creating custom ODI repository SQL access script"
		return $ExitStatus
	}
	
	#
	# Set up the OdiScm repository infrastructure creation script.
	#
	if (!(SetOdiScmRepoCreateInfractureSqlContent)) {
		write-host "$EM error creating OdiScm infrastructure creation script"
		return $ExitStatus
	}
	
	#
	# Ensure the OdiScm repository infrastructure has been set up.
	#
	$CmdOutput = ExecOdiRepositorySql "$OdiScmRepoInfrastructureSetupSql" $GenScriptRootDir $OdiScmJisqlRepoBat
	if (! $CmdOutput) {
		write-host "$EM error creating OdiScm repository infrastructure"
		return $ExitStatus
	}
	
	#
	# Get the last Revision number successfully applied to the working copy
	# from the local metadata.
	#
	$LocalControlChangeSet = $OdiScmConfig["Import Controls"]["Working Copy Revision"]
	
	if (($LocalControlChangeSet -eq "") -or ($LocalControlChangeSet -eq $Null)) {
		write-host "$EM format of working copy next import metadata <$LocalControlChangeSet> is invalid"
		write-host "$EM format must be '<last imported revision number>'"
		return $False
	}
	
	$LocalControlLastChangeSet = $LocalControlChangeSet
	write-host "$IM local metadata: last Revision applied to the local working copy <$LocalControlLastChangeSet>"
	
	#
	# Get the last Revision number successfully applied to the ODI repository
	# from the local metadata.
	#
	$LocalODIControlChangeSet = $OdiScmConfig["Import Controls"]["OracleDI Imported Revision"]
	
	if (($LocalODIControlChangeSet -eq "") -or ($LocalODIControlChangeSet -eq $Null)) {
		write-host "$EM format of local working copy next import metadata <$LocalODIControlChangeSet> is invalid"
		write-host "$EM format must be <last imported revision number>"
		return $False
	}
	
	$LocalODIControlLastChangeSet = $LocalODIControlChangeSet
	write-host "$IM local metadata: last Revision applied to the ODI repository <$LocalODIControlLastChangeSet>"
	
	#
	# Check that the Revisions applied to the working copy have been imported into the
	# ODI repository.
	#
	if ($LocalControlLastChangeSet -ne $LocalODIControlLastChangeSet) {
		write-host "$EM the working copy version <$LocalControlLastChangeSet> is different to the ODI repository"
		write-host "$EM version <$LocalODIControlLastChangeSet>. The ODI repository must be updated to the same version"
		write-host "$EM before this script can be run again".
		return $False
	}
	
	#
	# Get the OdiScm metadata from the ODI repository.
	#
	$CmdOutput = ExecOdiRepositorySql "$ScriptsRootDir\OdiScmGetLastImport.sql" $GenScriptRootDir $OdiScmJisqlRepoBat
	if (! $CmdOutput) {
		write-host "$EM error retrieving last imported revision from OdiScm repository metadata"
		return $ExitStatus
	}
	
	$CmdOutput = $CmdOutput.TrimStart("ExecOdiRepositorySql:")
	$StringList = @([regex]::split($CmdOutput.TrimStart("ExecOdiRepositorySql:"),"!!"))
	$OdiRepoBranchName = $StringList[0]
	[string] $OdiRepoLastImportTo = $StringList[1]
	write-host "$IM from ODI repository: got Branch URL             <$OdiRepoBranchName>"
	write-host "$IM from ODI repository: got Last Imported Revision <$OdiRepoLastImportTo>"
	
	#
	# Get the latest Revision number from the SCM repository.
	#
	write-host "$IM getting latest Revision number from the SCM system"
	$HighChangeSetNumber = GetNewChangeSetNumber
	if ($HighChangeSetNumber -eq $False) {
		write-host "$EM getting new ChangeSet/revision number from SCM system"
		return $False
	}
	write-host "$IM latest Revision number returned is <$HighChangeSetNumber>"
	
	$difference = $LocalODIControlChangeSet + "~" + $HighChangeSetNumber
	write-host "$IM new revision range to apply to the local working copy is <$difference>"
	
	if (!(ChangeSetRangeIsValid($difference))) {
		write-host "$EM the derived revision range <$difference> is invalid"
		return $ExitStatus
	}
	
	# TODO: pass references to $LocalLastImportFrom/$LocalLastImportTo and make ChangeSetRangeIsValid
	#       set the values.
	$StringList = @([regex]::split($difference,"~"))
	[string] $LocalLastImportFrom = $StringList[0]
	[string] $LocalLastImportTo = $StringList[1]
	
	$SCMSystemTypeName = $OdiScmConfig["SCM System"]["Type Name"]
	if ($SCMSystemTypeName -eq "TFS") {
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
	
	#
	# Check the ODI repository infrastructure metadata against the working copy metadata.
	#
	if ($FullImportInd) {
		if (($OdiRepoBranchName -ne "") -or ($OdiRepoLastImportTo -ne "")) {
			write-host "$EM The ODI repository metadata indicates that the ODI repository has been previously updated"
			write-host "$EM by this mechanism but the working copy metadata indicates that a full import operation"
			write-host "$EM should be run. Perform one of the following actions before rerunning this script:"
			write-host "$EM 1) Delete all repository contents via the Designer/Topology Manager GUIs."
			write-host "$EM 2) Create a new repository with a previously unused internal ID and update your odiparams.bat"
			write-host "$EM    with the new repository details."
			write-host "$EM 3) If you fully understand the potential consequences and still REALLY want to perform the"
			write-host "$EM    import into the ODI repository then delete the existing branch and ChangeSet metadata from"
			write-host "$EM    the ODI repository table ODISCM_CONTROLS"
			write-host "$EM NOTE: do not drop the repository and recreate it with the same ID if there is ANY chance of"
			write-host "$EM       objects having been created in it that have been distributed to other repositories"
			write-host "$EM       as this will cause conflicts and potential repository corruption."
			write-host "$EM       In order to perform this action safely you MUST the repository pre-TearDown and and"
			write-host "$EM       post-Rebuild scripts provided in the Scripts directory"
			return $ExitStatus
		}
	}
	
	if (!($FullImportInd)) {
		if ($OdiRepoBranchName -ne ($OdiScmConfig["SCM System"]["Branch Url"]).Trim()) {
			write-host "$EM The working copy metadata indicates that the ODI repository has been previously updated"
			write-host "$EM by this mechanism but the ODI repository branch name does not match the working copy branch name."
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
	
	if (!($FullImportInd) -and ($OdiRepoLastImportTo -ne $LocalLastImportFrom)) {
		write-host "$EM the last ODI repository imported revision <$OdiLastImportTo> number does not match"
		write-host "$EM the last revision number <$LocalLastImportFrom> from the working copy"
		return $ExitStatus
	}
	
	[array] $fileList = @()
	if ($LocalLastImportFrom -eq $LocalLastImportTo) {
		write-host "$IM the working copy is already up to date with the SCM repository"
		#
		# We do not exit on this condition. We provide a consistent process instead.
		#
	}
	
	#
	# Create a backup of the configuration INI file.
	#
	$SCMConfigurationBackUpFile = $GenScriptRootDir + "\" + $SCMConfigurationFileName + ".BackUp"
	write-host "$IM creating back-up of configuration file <$SCMConfigurationFile> to <$SCMConfigurationBackUpFile>"
	get-content $SCMConfigurationFile | set-content $SCMConfigurationBackUpFile
	
	#
	# Get the update from the SCM system.
	#
	$arrStrOdiFileList = @()
	$arrStrDbDdlFileList = @()
	$arrStrDbSplFileList = @()
	$arrStrDbDmlFileList = @()
	
	$arrStrOdiFileListRef = [ref] $arrStrOdiFileList
	$arrStrDbDdlFileListRef = [ref] $arrStrDbDdlFileList
	$arrStrDbSplFileListRef = [ref] $arrStrDbSplFileList
	$arrStrDbDmlFileListRef = [ref] $arrStrDbDmlFileList
	
	if (!(GetFromSCM $HighChangeSetNumber $arrStrOdiFileListRef $arrStrDbDdlFileListRef $arrStrDbSplFileListRef $arrStrDbDmlFileListRef)) {
		write-host "$EM failure getting latest code from the SCM repository"
		return $False
	}
	
	write-host "$IM GetFromSCM returned <$($arrStrOdiFileList.length)> ODI source files to import"
	write-host "$IM                     <$($arrStrDbDdlFileList.length)> DDL source files to import"
	write-host "$IM                     <$($arrStrDbSplFileList.length)> SPL source files to import"
	write-host "$IM                     <$($arrStrDbDmlFileList.length)> DML source files to import"
	
	#
	# If the ODI source object import batch size is set to a value >1 then create a set of consolidated
	# import files to enhance import performance (at the cost of easy build failure debugging).
	#
	$ImpObjBatchSizeMax = $OdiScmConfig["Generate"]["Import Object Batch Size Max"]
	
	$ConsolidatedFileList = @()
	$blnConsolidatedFilesList = $False
	
	if (($ImpObjBatchSizeMax -ne "") -and ($ImpObjBatchSizeMax -ne $Null) -and ($ImpObjBatchSizeMax -ne "1")) {
		
		write-host "$IM consolidation of ODI object sources files requested"
		write-host "$IM maximum batch size is <$ImpObjBatchSizeMax> ODI objects"
		
		$strInConsFileNamesList = $GenScriptRootDir + "\" + "OdiScmFilesToConsolidate.txt"
		
		#
		# Set the content of the consolidation process input file.
		# Be sure not to pipe content into set-content as previous file content is not overwritten when
		# the piped data is any empty array.
		#
		set-content -path $strInConsFileNamesList -value $arrStrOdiFileList
		$strOutConsFileNamesList = $GenScriptRootDir + "\" + "OdiScmConsolidatedOdiObjectSourceFiles.txt"
		
		$strCmdLineCmd   = "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmExecJava.bat"
		$strCmdLineArgs  = 'odietamo.OdiScm.ConsolidateObjectSourceFiles ' + '"' + $strInConsFileNamesList + '" "' + $GenScriptConsObjSrcDir
		$strCmdLineArgs += '" "' + $strOutConsFileNamesList + '" ' + $ImpObjBatchSizeMax
		write-host "$IM executing command line <$strCmdLineCmd $strCmdLineArgs>"
		$strCmdStdOutStdErr = & $strCmdLineCmd /p $strCmdLineArgs 2>&1
		if ($LastExitCode -ne 0) {
			write-host "$EM executing command <$strCmdLineCmd $strCmdLineArgs>"
			write-host "$EM stdout/stderr output <$strCmdStdOutStdErr>"
			return $False
		}
		
		$ConsolidatedFileList = get-content $strOutConsFileNamesList
		
		if ($ConsolidatedFileList -eq $null) {
			#
			# Reinitialise the array as get-content returns $Null for an empty file.
			#
			$ConsolidatedFileList = @()
		}
		else {
			$blnConsolidatedFilesList = $True
		}
	}
	else {
		#
		# No batching of object source files.
		#
		write-host "$IM no consolidation of ODI object sources files requested"
		$ConsolidatedFileList = $arrStrOdiFileList
	}
	
	#
	# Generate the ODI object import commands in the generated script.
	#
	if (!(GenerateOdiImportScript $ConsolidatedFileList)) { 
		write-host "$EM call to GenerateOdiImportScript failed"
		return $ExitStatus
	}
	
	#
	# Generate the ODI Scenario source object ID insert commands script.
	#
	if (!(GenerateOdiSrcObjIdInsertScript $arrStrOdiFileList)) { 
		write-host "$EM call to GenerateOdiSrcObjIdInsertScript failed"
		return $ExitStatus
	}
	
	#
	# Generate the SQL DDL object import commands in the generated script.
	#
	if (!(GenerateDdlImportScript $arrStrDbDdlFileList)) { 
		write-host "$EM call to GenerateDdlImportScript failed"
		return $ExitStatus
	}
	
	#
	# Generate the SQL SPL object import commands in the generated script.
	#
	if (!(GenerateSplImportScript $arrStrDbSplFileList)) { 
		write-host "$EM call to GenerateSplImportScript failed"
		return $ExitStatus
	}
	
	#
	# Generate the SQL DML script execution commands in the generated script.
	#
	if (!(GenerateDmlExecutionScript $arrStrDbDmlFileList)) { 
		write-host "$EM call to GenerateDmlExecutionScript failed"
		return $ExitStatus
	}
	
	#
	# Set up the startcmd script.
	#
	if (!(SetStartCmdContent)) {
		write-host "$EM call to SetStartCmdContent failed"
		return $ExitStatus
	}
	
	#
	# Set up the OdiScm next import metadata update script.
	#
	if (!(SetOdiScmRepoSetNextImportSqlContent $HighChangeSetNumber)) {
		write-host "$EM call to SetOdiScmRepoSetNextImportSqlContent failed"
		return $ExitStatus
	}
	
	#
	# Set up the OdiScm build note.
	#
	if (!(SetOdiScmBuildNoteContent $difference)) {
		write-host "$EM call to SetOdiScmBuildNoteContent failed"
		return $ExitStatus
	}
	
	#
	# Set up the OdiScm repository back-up script content.
	#
	if (!(SetOdiScmRepositoryBackUpBatContent)) {
		write-host "$EM call to SetOdiScmRepositoryBackUpBatContent failed"
		return $ExitStatus
	}
	
	#
	# Set up the pre-ODI import Scenario deletion generator script content.
	#
	if (!(SetOdiScmGenScenPreImpDelOldBatSqlContent)) {
		write-host "$EM call to SetOdiScmGenScenPreImpDelOldBatSqlContent failed"
		return $False
	}
	
	#
	# Set up the pre-ODI import object ID sequence tracking metadata update script content.
	#
	if (!(GenerateOdiSrcObjIdScript $ConsolidatedFileList $blnConsolidatedFilesList)) {
		write-host "$EM call to GenerateOdiSrcObjIdScript failed"
		return $False
	}
	
	#
	# Set up the pre-ODI import script content.
	#
	if (!(SetOdiScmPreImportBatContent)) {
		write-host "$EM setting content in pre-ODI import script"
		return $ExitStatus
	}
	
	#
	# Set up the post-ODI import Scenario deletion generator script content.
	#
	if (!(SetOdiScmGenScenDeleteOldSqlContent)) {
		write-host "$EM call to SetOdiScmGenScenDeleteOldSqlContent failed"
		return $ExitStatus
	}
	
	#
	# Set up the post-ODI import Scenario generation generator script content.
	#
	if (!(SetOdiScmGenScenNewSqlContent)) {
		write-host "$EM call to SetOdiScmGenScenNewSqlContent failed"
		return $ExitStatus
	}
	
	#
	# Set up the post-ODI import script content.
	#
	if (!(SetOdiScmPostImportBatContent)) {
		write-host "$EM setting content in post-ODI import script"
		return $ExitStatus
	}
	
	#
	# Set up the top level build script content.
	#
	if (!(SetTopLevelScriptContent $HighChangeSetNumber)) {
		write-host "$EM setting content in main script"
		return $ExitStatus
	}
	
	write-host "$IM your working copy has been updated. Execute the following script to perform"
	write-host "$IM the ODI source code import, Scenario generation and update the local OdiScm metadata"
	write-host "$IM"
	write-host "$IM <$OdiScmBuildBat>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Get a list of new/changed files from the SCM system.
#
function GetFromSCM ($HighChangeSetNumber, [ref] $refOdiFileList, [ref] $refDbDdlFileList, [ref] $refDbSplFileList, [ref] $refDbSqlFileList) {
	
	$FN = "GetFromSCM"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DM = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	$script:GetLatestVersionOutputFile = $GenScriptRootDir + "\GetFromSCM_" + $script:OutputTag + ".txt"
	write-host "$IM output from SCM will be written to <$GetLatestVersionOutputFile>"
	$script:GetLatestVersionConflictsOutputFile = $GenScriptRootDir + "\GetLatestVersionConflicts_Results_" + $script:OutputTag + ".txt"
	
	#
	# Get the list of files from the SCM system.
	#
	$arrScmFiles = @()
	
	switch ($SCMSystemTypeName) {
		"TFS" {
			$GetFromExitStatus = GetFromTFS $HighChangeSetNumber ([ref] $arrScmFiles)
			break
		}
		"SVN" {
			$GetFromExitStatus = GetFromSVN $HighChangeSetNumber ([ref] $arrScmFiles)
			break
		}
	}
	
	if (!($GetFromExitStatus)) {
		write-host "$EM getting code from SCM system"
		return $ExitStatus
	}
	
	if (!(BuildSourceFileLists $arrScmFiles $refOdiFileList $refDbDdlFileList $refDbSplFileList $refDbSqlFileList)) {
		write-host "$EM building source file lists from SCM get output"
		return $False
	}
	
	$ExitStatus = $True
	write-host "$IM ends"
	return $ExitStatus
}

#
# Perform an SVN UPDATE operation for the entire branch URL.
#
function GetFromSVN ($HighChangeSetNumber, [ref] $refFileList) {
	
	$FN = "GetFromSVN"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	# SVN CHECKOUT/MERGE/UPDATE status codes for a file.
	# A  Added
	# D  Deleted
	# U  Updated
	# C  Conflict
	# G  Merged
	# E  Existed
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	write-host "$IM previewing SVN UPDATE using SVN MERGE. Output will be recorded in file <$GetLatestVersionOutputFile>"
	
	$SCMUserName = $OdiScmConfig["SCM System"]["Global User Name"]
	$SCMUserPassword = $OdiScmConfig["SCM System"]["Global User Password"]
	
	if ($SCMUserName -ne "" -and $SCMUserName -ne $Null) {
		$SCMAuthText = "--username $SCMUserName --password $SCMUserPassword"
	}
	else {
		$SCMAuthText = ""
	}
	
	$ScmSystemSystemUrl = $OdiScmConfig["SCM System"]["System Url"]
	$ScmSystemSystemUrl.split("/") | foreach { $ScmSystemSystemUrlLastPart = $_ }
	if ($ScmSystemSystemUrlLastPart -eq "" -or $ScmSystemSystemUrlLastPart -eq $Null) {
		write-host "%EM last path component of SCM system URL <$ScmSystemSystemUrl> is empty"
		return $ExitStatus
	}
	
	$ScmSystemBranchUrl = $OdiScmConfig["SCM System"]["Branch Url"]
	$ScmSystemSystemUrl.split("/") | foreach { $ScmSystemBranchUrlLastPart = $_ }
	if ($ScmSystemBranchUrlLastPart -eq "" -or $ScmSystemBranchUrlLastPart -eq $Null) {
		write-host "%EM last path component of SCM branch URL <$ScmSystemBranchUrl> is empty"
		return $ExitStatus
	}
	
	if ($ScmSystemBranchUrlLastPart -eq ".") {
		$WcAppend = "\" + $ScmSystemSystemUrlLastPart
	}
	else {
		$WcAppend = "\" + $ScmSystemBranchUrlLastPart
	}
	
	$WcPath = ($WorkingCopyRootDir + $WcAppend) -replace "/", "\"
	set-location $WcPath
	if (!($?)) {
		write-host "$EM cannot change working directory to working copy root directory <$WcPath>"
		return $ExitStatus
	}
	
	$CmdLine = "svn merge --dry-run --revision BASE:" + "${HighChangeSetNumber} . $SCMAuthText >${GetLatestVersionOutputFile} 2>&1"
	write-host "$IM executing command <$CmdLine>"
	$CmdOutputText = invoke-expression $CmdLine
	if ($LastExitCode -ge 1) {
		write-host "$EM execution of command failed with exit status <$LastExitCode>"
		write-host "$EM check the output file for details. All conflicts must be resolved in order for this"
		write-host "$EM script to run successfully"
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
	
	$CmdLine = "svn update . --revision " + $HighChangeSetNumber + " $SCMAuthText >$GetLatestVersionOutputFile 2>&1" # $WorkingCopyRootDir is optional for this command.
	write-host "$IM executing command <$CmdLine>"
	$CmdOutputText = invoke-expression $CmdLine
	if ($LastExitCode -ge 1) {
		write-host "$EM execution of command failed with exit status <$LastExitCode>"
		return $ExitStatus
	}
	
	#
	# Update the version of the local working copy.
	#
	# Dont use "add-content"? It always writes a newline at the end of the text.
	$script:OdiScmConfig["Import Controls"]["Working Copy Revision"] = $HighChangeSetNumber
	SetIniContent $OdiScmConfig "$SCMConfigurationFile"
	
	#
	# Parse the output of the UPDATE command to build the list of ODI source sources that we need to import.
	#
	$SCMGetOutput = get-content $GetLatestVersionOutputFile
	write-host "$IM processing command output with <$($SCMGetOutput.length)> records"
	$FileCount = 0
	
	# The list of files extracted from the SCM get output.
	[array] $listFiles = @()
	
	foreach ($SCMGetOutputLine in $SCMGetOutput) {
		
		if ($SCMGetOutputLine.StartsWith("Updated to revision")) {
			continue
		}
		
		if ($SCMGetOutputLine.StartsWith("Updating")) {
			continue
		}
		
		$SCMGetOutputLineFlags = $SCMGetOutputLine.Substring(0,5)
		$SCMGetOutputLineFileDirActionFlag = $SCMGetOutputLineFlags.Substring(0,1)
		$SCMGetOutputLineFileDirPropertyActionFlag = $SCMGetOutputLineFlags.Substring(1,1)
		$SCMGetOutputLineLockBrokenFilePropertyActionFlag = $SCMGetOutputLineFlags.Substring(2,1)
		$SCMGetOutputLineTreeActionFlag = $SCMGetOutputLineFlags.Substring(3,1)	# Tree conflicts are signalled with a "C" in this column.
		$SCMGetOutputLineFileDir = $SCMGetOutputLine.Substring(5)
		
		if ($SCMGetOutputLineFileActionFlag -eq "C" -or $SCMGetOutputLineTreeActionFlag -eq "C") {
			write-host "$EM conflicts detected in local working copy versus repository for file or directory <$SCMGetOutputLineFileDir>"
			write-host "$EM check the output file for details. All conflicts must be resolved in order for this"
			write-host "$EM script to be executed successfully"
			return $ExitStatus
		}
		
		if ($SCMGetOutputLineFileDirActionFlag -eq "D") {
			write-host "$IM found deleted source file <$SCMGetOutputLineFileDir>. Review for impact and clean up actions"
		}
		
		$listFiles += $WcPath + "\" + $SCMGetOutputLineFileDir
	}
	
	#
	# Copy the file list into the output list.
	#
	foreach ($strFile in $listFiles) {
		$refFileList.value += $strFile
	}
	
	$ExitStatus = $True
	write-host "$IM ends"
	return $ExitStatus
}

#
# Perform a Get Latest Version operation for the entire branch.
#
function GetFromTFS ($HighChangeSetNumber, [ref] $refFileList) {
	
	$FN = "GetFromTFS"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	set-location $WorkingCopyRootDir
	if (!($?)) {
		write-host "$EM cannot change working directory to branch root directory <$WorkingCopyRootDir>"
		return $ExitStatus
	}
	
	write-host "$IM previewing Get Latest Version. Output will be recorded in file <$GetLatestVersionOutputFile>"
	
	$SCMBranchUrl = $OdiScmConfig["SCM System"]["Branch Url"]
	
	$SCMUserName = $OdiScmConfig["SCM System"]["Global User Name"]
	$SCMUserPassword = $OdiScmConfig["SCM System"]["Global User Password"]
	if ($SCMUserName -ne "") {
		$SCMAuthText = "/login:$SCMUserName,$SCMUserPassword"
	}
	else {
		$SCMAuthText = ""
	}
	
	if (($env:ODI_SCM_TOOLS_TEAM_EXPLORER_EVERYWHERE_JAVA_HOME -ne "") -and ($env:ODI_SCM_TOOLS_TEAM_EXPLORER_EVERYWHERE_JAVA_HOME -ne $Null)) {
		$strJavaHome = $env:ODI_SCM_TOOLS_TEAM_EXPLORER_EVERYWHERE_JAVA_HOME
		$strJavaHome = $strJavaHome.Replace("/", "\")
		$env:PATH = $strJavaHome + "\bin;" + $env:PATH
	}
	
	$CmdLine = "tf get $SCMBranchUrl /overwrite /preview /recursive /noprompt /version:C" + $HighChangeSetNumber + " $SCMAuthText >$GetLatestVersionOutputFile 2>&1"
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
	
	set-location $WorkingCopyRootDir
	if (!($?)) {
		write-host "$EM cannot change working directory to branch root directory <$WorkingCopyRootDir>"
		return $ExitStatus
	}
	
	$CmdLine = "tf get $SCMBranchUrl /overwrite /recursive /noprompt /version:C" + $HighChangeSetNumber + " $SCMAuthText >$GetLatestVersionOutputFile 2>&1"
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
	# Update the version of the working copy.
	#
	# Dont use "add-content"? It always writes a newline at the end of the text.
	$script:OdiScmConfig["Import Controls"]["Working Copy Revision"] = $HighChangeSetNumber
	SetIniContent $OdiScmConfig "$SCMConfigurationFile"
	
	#
	# Parse the output of the Get command to build the list of ODI source sources that we need to import.
	#
	$SCMGetOutput = get-content $GetLatestVersionOutputFile
	write-host "$IM processing command output with <$($SCMGetOutput.length)> records"
	
	# The list of files to import, extracted from the SCM get output.
	[array] $listFiles = @()
	
	$blnDirInWorkingCopy = $False
	
	$WorkingCopyRootDirUC = $WorkingCopyRootDir.ToUpper()
	$WorkingCopyRootDirUCBS = $WorkingCopyRootDirUC.Replace("/","\")
	
	foreach ($SCMGetOutputLine in $SCMGetOutput) {
		
		if ($SCMGetOutputLine.EndsWith(":")) {
			#
			# This is a local directory name.
			# Ensure it's part of the working copy directory tree before using it.
			#
			if ($SCMGetOutputLine.ToUpper().StartsWith($WorkingCopyRootDirUCBS)) {
				#
				# Use this directory as it's in the working copy
				#
				$blnDirInWorkingCopy = $True
				$FileToImportPathName = $SCMGetOutputLine.TrimEnd(":")
			}
			else {
				#
				# Don't use this directory as it's not in the working copy.
				#
				$blnDirInWorkingCopy = $False
			}
		}
		else {
			if ($blnDirInWorkingCopy) {
				$FileToImportName = $SCMGetOutputLine -replace("^Getting ","")
				$FileToImportName = $FileToImportName -replace("^Replacing ","")
				$FileToImportName = $FileToImportName -replace("^Adding ","")
				$FileToImportName = $FileToImportName -replace("^Deleting ","")
				
				if ($SCMGetOutputLine.StartsWith("Deleting ")) {
					write-host "$WM found deleted source file <$FileToImportName>. Review for impact and clean up actions"
				}
				else {
					$listFiles += "$FileToImportPathName\$FileToImportName"
				}
			}
		}
	}
	
	#
	# Copy the file list into the output list.
	#
	foreach ($strFile in $listFiles) {
		$refFileList.value += $strFile
	}
	
	$ExitStatus = $True
	write-host "$IM ends"
	return $ExitStatus
}

####################################################################
# Main.
####################################################################

$FN = "OdiScmGet"
$IM = $FN + ": INFO:"
$EM = $FN + ": ERROR:"

#
# Global debugging on/off switch.
#
###$DebuggingActive = $True
$DebuggingActive = $False

#
# Perform basic environment check.
#
if (($env:ODI_SCM_HOME -eq $Null) -or ($env:ODI_SCM_HOME -eq "")) {
	write-host "$EM environment variable ODI_SCM_HOME is not set"
	exit 1
}
else {
	$OdiScmHomeDir = $env:ODI_SCM_HOME
	write-host "$IM using ODI-SCM home directory <$OdiScmHomeDir> from environment variable ODI_SCM_HOME"
}

if (($env:ODI_SCM_INI -eq $Null) -or ($env:ODI_SCM_INI -eq "")) {
	write-host "$EM environment variable ODI_SCM_INI is not set"
	exit 1
}
else {
	write-host "$IM using ODI-SCM INI file <$env:ODI_SCM_INI> from environment variable ODI_SCM_INI"
}

#
# Load common functions.
#
. "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmCommon.ps1"

#
# Global debugging on/off switch.
#
$DebuggingActive = $False

#
# Prime the write-host mechanism to avoid bug in large outputs.
#
PrimeWriteHost

#
# The following strings are used to derive data from TFS by parsing the output
# of the command line interface tool "tf".
#
$GetLatestSearchText = "you have a conflicting edit"
$endOfConflictText= "Unable to perform the get"
$GetLatestSummaryText = "---- Summary"

#
# The following string is used to delimit output of multiple commands in a
# single text file.
#
$strOdiScmCmdOutputSeparator = "xxxOdiScm_Output_Separatorxxx"

#
# Create the standard logging/generated scripts directory tree.
#
if (Test-Path $LogRootDir) { 
	write-host "$IM logs root directory $LogRootDir already exists"
}
else {  
	write-host "$IM creating logs root diretory $LogRootDir"
	New-Item -itemtype directory $LogRootDir 
}

if (Test-Path $MoiTempEmptyFile) { 
	write-host "$IM empty file check file $MoiTempEmptyFile already exists" 
}
else {  
	write-host "$IM creating empty file check file $MoiTempEmptyFile"
	New-Item -itemtype file $MoiTempEmptyFile 
}

#
# Strings used to extract ODI repository connection details from the odiparams script.
#
$OdiRepoSECURITY_DRIVER_TEXT ='set ODI_SECU_DRIVER='
$OdiRepoSECURITY_DRIVER_LEN = $OdiRepoSECURITY_DRIVER_TEXT.length

$OdiRepoSECURITY_URL_TEXT ='set ODI_SECU_URL='
$OdiRepoSECURITY_URL_LEN = $OdiRepoSECURITY_URL_TEXT.length

$OdiRepoSECURITY_USER_TEXT ='set ODI_SECU_USER='
$OdiRepoSECURITY_USER_LEN = $OdiRepoSECURITY_USER_TEXT.length

$OdiRepoSECURITY_PWD_TEXT ='set ODI_SECU_ENCODED_PASS='
$OdiRepoSECURITY_PWD_LEN = $OdiRepoSECURITY_PWD_TEXT.length

$OdiRepoSECURITY_PWD_UNENC_TEXT = 'set ODI_SECU_PASS='
$OdiRepoSECURITY_PWD_UNENC_LEN = $OdiRepoSECURITY_PWD_UNENC_TEXT.length

$OdiRepoSECURITY_WORK_REP_TEXT ='set ODI_SECU_WORK_REP='
$OdiRepoSECURITY_WORK_REP_LEN = $OdiRepoSECURITY_WORK_REP_TEXT.length 

$OdiRepoUSER_TEXT = 'set ODI_USER='
$OdiRepoUSER_LEN = $OdiRepoUSER_TEXT.length

$OdiRepoPASSWORD_TEXT ='set ODI_ENCODED_PASS='
$OdiRepoPASSWORD_LEN = $OdiRepoPASSWORD_TEXT.length

#
# ODI repository details extracted from the odiparams script and optionally overridden by
# values in the INI file.
#
$OdiRepoSECURITY_DRIVER    = ""
$OdiRepoSECURITY_URL       = ""
$OdiRepoSECURITY_USER      = ""
$OdiRepoSECURITY_PWD       = ""
$OdiRepoSECURITY_UNENC_PWD = ""
$OdiRepoWORK_REP_NAME      = ""
$OdiRepoUSER               = ""
$OdiRepoPASSWORD           = ""
# Parts of the URL.
$OdiRepoSECURITY_URL_SERVER = ""
$OdiRepoSECURITY_URL_PORT   = ""
$OdiRepoSECURITY_URL_SID    = ""

#
# Execute the central function.
#
$ResultMain = GetIncremental
if ($ResultMain -eq $True) {
	write-host "$IM call to GetIncremental returned successful exit status"
	exit 0
}
elseif ($ResultMain -eq $False) {
	write-host "$EM call to GetIncremental returned failure exit status"
	exit 1
}
else {
	write-host "$EM call to GetIncremental returned unrecognised exit status"
	exit 2
}

