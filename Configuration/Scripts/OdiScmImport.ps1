#
# The main function.
#
function GenerateImport {
	
	$FN = "GenerateImport"
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
	
	# if (($LocalControlChangeSet -eq "") -or ($LocalControlChangeSet -eq $Null)) {
		# write-host "$EM format of working copy next import metadata <$LocalControlChangeSet> is invalid"
		# write-host "$EM format must be '<last imported revision number>'"
		# return $False
	# }
	
	# $LocalControlLastChangeSet = $LocalControlChangeSet
	# write-host "$IM local metadata: last Revision applied to the local working copy <$LocalControlLastChangeSet>"
	
	#
	# Get the last Revision number successfully applied to the ODI repository
	# from the local metadata.
	#
	$LocalODIControlChangeSet = $OdiScmConfig["Import Controls"]["OracleDI Imported Revision"]
	
	# if (($LocalODIControlChangeSet -eq "") -or ($LocalODIControlChangeSet -eq $Null)) {
		# write-host "$EM format of local working copy next import metadata <$LocalODIControlChangeSet> is invalid"
		# write-host "$EM format must be <last imported revision number>"
		# return $False
	# }
	
	$LocalODIControlLastChangeSet = $LocalODIControlChangeSet
	# write-host "$IM local metadata: last Revision applied to the ODI repository <$LocalODIControlLastChangeSet>"
	
	#
	# Check that the Revisions applied to the working copy have been imported into the
	# ODI repository.
	#
	# if ($LocalControlLastChangeSet -ne $LocalODIControlLastChangeSet) {
		# write-host "$EM the working copy version <$LocalControlLastChangeSet> is different to the ODI repository"
		# write-host "$EM version <$LocalODIControlLastChangeSet>. The ODI repository must be updated to the same version"
		# write-host "$EM before this script can be run again".
		# return $False
	# }
	
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
	# Get the files from the file system.
	#
	$arrStrOdiFileList = @()
	$arrStrDbDdlFileList = @()
	$arrStrDbSplFileList = @()
	$arrStrDbDmlFileList = @()
	
	$FsOdiFileListRef = [ref] $arrStrOdiFileList
	$FsDbDdlFileListRef = [ref] $arrStrDbDdlFileList
	$FsDbSplFileListRef = [ref] $arrStrDbSplFileList
	$FsDbDmlFileListRef = [ref] $arrStrDbDmlFileList
	
	if (!(GetFromFileSystem $FsOdiFileListRef $FsDbDdlFileListRef $FsDbSplFileListRef $FsDbDmlFileListRef)) {
		write-host "$EM failure getting latest code from the file system"
		return $False
	}
	
	write-host "$IM GetFromFileSystem returned <$($arrStrOdiFileList.length)> ODI source files to import"
	write-host "$IM                            <$($arrStrDbDdlFileList.length)> DDL source files to import"
	write-host "$IM                            <$($arrStrDbSplFileList.length)> SPL source files to import"
	write-host "$IM                            <$($arrStrDbDmlFileList.length)> DML source files to import"
	
	#
	# If the ODI source object import batch size is set to a value >1 then create a set of consolidated
	# import files to enhance import performance (at the cost of easy build failure debugging).
	#
	$ImpObjBatchSizeMax = $OdiScmConfig["Generate"]["Import Object Batch Size Max"]
	
	$ConsolidatedFileList = @()
	
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
	# if (!(SetOdiScmBuildNoteContent $difference)) {
		# write-host "$EM call to SetOdiScmBuildNoteContent failed"
		# return $ExitStatus
	# }
	
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
	if (!(GenerateOdiSrcObjIdScript $arrStrOdiFileList)) {
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
	
	write-host "$IM Execute the following script to perform the ODI source code import,"
	write-host "$IM Scenario generation and update the local OdiScm metadata"
	write-host "$IM"
	write-host "$IM <$OdiScmBuildBat>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Create a list of ordered ODI object source files from the working copy directory tree.
#
function GetFromFileSystem ([ref] $refOdiFileList, [ref] $refDbDdlFileList, [ref] $refDbSplFileList, [ref] $refDbSqlFileList) {
	
	$FN = "GetFromFileSystem"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	$strSourcePathRootDir = $env:ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT
	if (!(test-path $strSourcePathRootDir)) {
		write-host "$EM path <$strSourcePathRootDir> specified in environment variables ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT"
		write-host "$EM and ODI_SCM_SCM_SYSTEM_ORACLEDI_WORKING_COPY_ROOT cannot be accessed"
		return $False
	}
	
	$strSourcePathRootDirBS = $strSourcePathRootDir.Replace("/","\")
	
	write-host "$IM searching for files to import from directory tree <$strSourcePathRootDir>"
	$arrFlInFiles = get-childitem $strSourcePathRootDirBS -recurse
	if (!($?)) {
		write-host "$EM reading list of files from directory tree <$strSourcePathRootDir>"
		return $False
	}
	
	$arrStrInFileNames = @()
	foreach ($flFile in $arrFlInFiles) {
		$arrStrInFileNames += $flFile.fullname
	}
	
	if (!(BuildSourceFileLists $arrStrInFileNames $refOdiFileList $refDbDdlFileList $refDbSplFileList $refDbSqlFileList)) {
		write-host "$EM building source file lists from SCM get output"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

####################################################################
# Main.
####################################################################

$FN = "OdiScmImport"
$IM = $FN + ": INFO:"
$EM = $FN + ": ERROR:"

#
# Perform basic environment check.
#
if (($env:ODI_SCM_HOME -eq $Null) -or ($env:ODI_SCM_HOME -eq "")) {
	write-host "$EM: environment variable ODI_SCM_HOME is not set"
	exit 1
}
else {
	$OdiScmHomeDir = $env:ODI_SCM_HOME
	write-host "$IM using ODI-SCM home directory <$OdiScmHomeDir> from environment variable ODI_SCM_HOME"
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

$ResultMain = GenerateImport
if ($ResultMain) {
	exit 0
}
else {
	exit 1
}