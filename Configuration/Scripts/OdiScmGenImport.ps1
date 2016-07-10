function GenerateOdiImport {
	
	$FN = "GenerateOdiImport"
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
	# Set a dummy revision number to which the ODI metadata will be set (currently required to be set).
	# We choose an invalid number so indicate that no imports directly driven by changes in an SCM
	# system (i.e. the OdiScmGet process) have been run.
	#
	$HighChangeSetNumber = 1
	
	#
	# Create a backup of the configuration INI file.
	#
	$SCMConfigurationBackUpFile = $GenScriptRootDir + "\" + $SCMConfigurationFileName + ".BackUp"
	write-host "$IM creating back-up of configuration file <$SCMConfigurationFile> to <$SCMConfigurationBackUpFile>"
	get-content $SCMConfigurationFile | set-content $SCMConfigurationBackUpFile
	
	#
	# Get the files from the file system.
	#
	$arrStrFileList = @()
	$arrStrOdiFileList = @()
	
	$FsFileListRef = [ref] $arrStrFileList
	$FsOdiFileListRef = [ref] $arrStrOdiFileList
	
	if (!(GetFromFileSystem $FsFileListRef)) {
		write-host "$EM failure getting source code file list from the file system"
		return $False
	}
	
	if (!(BuildOdiSourceFileList $arrStrFileList $FsOdiFileListRef)) {
		write-host "$EM building ODI source file list from file system source file list"
		return $False
	}
	
	write-host "$IM found <$($arrStrOdiFileList.length)> ODI source files to import"
	
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
	# Set up the startcmd script.
	#
	if (!(SetStartCmdContent)) {
		write-host "$EM call to SetStartCmdContent failed"
		return $ExitStatus
	}
	
	#
	# Set up the OdiScm next import metadata update script.
	# Note that we use a dummy revision number for imports (rather than the Get process).
	#
	if (!(SetOdiScmRepoSetNextImportSqlContent $HighChangeSetNumber)) {
		write-host "$EM call to SetOdiScmRepoSetNextImportSqlContent failed"
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
	
	write-host "$IM Execute the following script to perform the ODI source code import,"
	write-host "$IM Scenario generation and update the local OdiScm metadata"
	write-host "$IM"
	write-host "$IM <$OdiScmBuildBat>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateDdlImport {
	
	$FN = "GenerateDdlImport"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	if (!(SetOutputNames)) {
		write-host "$EM error setting output file and directory names"
		return $False
	}
	
	#
	# Get the files from the file system.
	#
	$arrStrFileList = @()
	$arrStrDbDdlFileList = @()
	
	$FsFileListRef = [ref] $arrStrFileList
	$FsDbDdlFileListRef = [ref] $arrStrDbDdlFileList
	
	if (!(GetFromFileSystem $FsFileListRef)) {
		write-host "$EM failure getting source code file list from the file system"
		return $False
	}
	
	if (!(BuildDdlSourceFileList $arrStrFileList $FsDbDdlFileListRef)) {
		write-host "$EM building DDL source file list from file system source file list"
		return $False
	}
	
	write-host "$IM found <$($arrStrDbDdlFileList.length)> DDL source files to import"
	
	#
	# Generate the SQL DDL object import commands in the generated script.
	#
	if (!(GenerateDdlImportScript $arrStrDbDdlFileList)) { 
		write-host "$EM call to GenerateDdlImportScript failed"
		return $ExitStatus
	}
	
	write-host "$IM Execute the following script to perform the DDL source code processing"
	write-host "$IM"
	write-host "$IM <$DdlImportScriptFile>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateSplImport {
	
	$FN = "GenerateSplImport"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	if (!(SetOutputNames)) {
		write-host "$EM error setting output file and directory names"
		return $False
	}
	
	#
	# Get the files from the file system.
	#
	$arrStrFileList = @()
	$arrStrDbSplFileList = @()
	
	$FsFileListRef = [ref] $arrStrFileList
	$FsDbSplFileListRef = [ref] $arrStrDbSplFileList
	
	if (!(GetFromFileSystem $FsFileListRef)) {
		write-host "$EM failure getting source code file list from the file system"
		return $False
	}
	
	if (!(BuildSplSourceFileList $arrStrFileList $FsDbSplFileListRef)) {
		write-host "$EM building SPL source file list from file system source file list"
		return $False
	}
	
	write-host "$IM found <$($arrStrDbSplFileList.length)> SPL source files to import"
	
	#
	# Generate the SQL SPL object import commands in the generated script.
	#
	if (!(GenerateSplImportScript $arrStrDbSplFileList)) { 
		write-host "$EM call to GenerateSplImportScript failed"
		return $ExitStatus
	}
	
	write-host "$IM Execute the following script to perform the SPL source code processing"
	write-host "$IM"
	write-host "$IM <$SplImportScriptFile>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateDmlImport {
	
	$FN = "GenerateDmlImport"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	if (!(SetOutputNames)) {
		write-host "$EM error setting output file and directory names"
		return $False
	}
	
	#
	# Get the files from the file system.
	#
	$arrStrFileList = @()
	$arrStrDbDmlFileList = @()
	
	$FsFileListRef = [ref] $arrStrFileList
	$FsDbDmlFileListRef = [ref] $arrStrDbDmlFileList
	
	if (!(GetFromFileSystem $FsFileListRef)) {
		write-host "$EM failure getting source code file list from the file system"
		return $False
	}
	
	if (!(BuildDmlSourceFileList $arrStrFileList $FsDbDmlFileListRef)) {
		write-host "$EM building DML source file list from file system source file list"
		return $False
	}
	
	write-host "$IM found <$($arrStrDbDmlFileList.length)> DML source files to import"
	
	#
	# Generate the SQL DML object import commands in the generated script.
	#
	if (!(GenerateDmlExecutionScript $arrStrDbDmlFileList)) { 
		write-host "$EM call to GenerateDmlExecutionScript failed"
		return $ExitStatus
	}
	
	write-host "$IM Execute the following script to perform the DML source code processing"
	write-host "$IM"
	write-host "$IM <$DmlExecutionScriptFile>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateSsisImport {
	
	$FN = "GenerateSsisImport"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	if (!(SetOutputNames)) {
		write-host "$EM error setting output file and directory names"
		return $False
	}
	
	#
	# Get the files from the file system.
	#
	$arrStrFileList = @()
	$arrStrSsisFileList = @()
	
	$FsFileListRef = [ref] $arrStrFileList
	$FsSsisFileListRef = [ref] $arrStrSsisFileList
	
	if (!(GetFromFileSystem $FsFileListRef)) {
		write-host "$EM failure getting source code file list from the file system"
		return $False
	}
	
	if (!(BuildSsisSourceFileList $arrStrFileList $FsSsisFileListRef)) {
		write-host "$EM building SSIS source file list from file system source file list"
		return $False
	}
	
	write-host "$IM found <$($arrStrSsisFileList.length)> SSIS source files to import"
	
	#
	# Generate the SSIS object import commands in the generated script.
	#
	if (!(GenerateSsisImportScript $arrStrSsisFileList)) { 
		write-host "$EM call to GenerateSsisImportScript failed"
		return $ExitStatus
	}
	
	write-host "$IM Execute the following script to perform the SSIS source code processing"
	write-host "$IM"
	write-host "$IM <$SsisImportScriptFile>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateSsasImport {
	
	$FN = "GenerateSsasImport"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	if (!(SetOutputNames)) {
		write-host "$EM error setting output file and directory names"
		return $False
	}
	
	#
	# Get the files from the file system.
	#
	$arrStrFileList = @()
	$arrStrSsasFileList = @()
	
	$FsFileListRef = [ref] $arrStrFileList
	$FsSsasFileListRef = [ref] $arrStrSsasFileList
	
	if (!(GetFromFileSystem $FsFileListRef)) {
		write-host "$EM failure getting source code file list from the file system"
		return $False
	}
	
	if (!(BuildSsasSourceFileList $arrStrFileList $FsSsasFileListRef)) {
		write-host "$EM building SSAS source file list from file system source file list"
		return $False
	}
	
	write-host "$IM found <$($arrStrSsasFileList.length)> SSAS source files to import"
	
	#
	# Generate the SSAS object import commands in the generated script.
	#
	if (!(GenerateSsasImportScript $arrStrSsasFileList)) { 
		write-host "$EM call to GenerateSsasImportScript failed"
		return $ExitStatus
	}
	
	write-host "$IM Execute the following script to perform the SSAS source code processing"
	write-host "$IM"
	write-host "$IM <$SsasImportScriptFile>"
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateAllImports {
	
	$FN = "GetFromFileSystem"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	if (!(GenerateOdiImport)) {
		write-host "$EM generating ODI import scripts"
		return $ExitStatus
	}
	
	if (!(GenerateDdlImport)) {
		write-host "$EM generating DDL import scripts"
		return $ExitStatus
	}
	
	if (!(GenerateSplImport)) {
		write-host "$EM generating SPL import scripts"
		return $ExitStatus
	}
	
	if (!(GenerateDmlImport)) {
		write-host "$EM generating DML import scripts"
		return $ExitStatus
	}
	
	if (!(GenerateSsisImport)) {
		write-host "$EM generating SSIS import scripts"
		return $ExitStatus
	}
	
	if (!(GenerateSsasImport)) {
		write-host "$EM generating SSAS import scripts"
		return $ExitStatus
	}
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Create a list of source files from the working copy directory tree.
#
function GetFromFileSystem ([ref] $refFileList) {
	
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
	
	# Copy the list to the referenced output list.
	foreach ($strFile in $arrStrInFileNames) {
		$refFileList.value += $strFile
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
	write-host "$EM environment variable ODI_SCM_HOME is not set"
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

$strType = $args[0].ToLower()

switch ($strType) {
	"all" {
		$blnRes = GenerateAllImports
	}
	"odi" {
		$blnRes = GenerateOdiImport
	}
	"ddl" {
		$blnRes = GenerateDdlImport
	}
	"spl" {
		$blnRes = GenerateSplImport
	}
	"dml" {
		$blnRes = GenerateDmlImport
	}
	"ssis" {
		$blnRes = GenerateSsisImport
	}
	"ssas" {
		$blnRes = GenerateSsasImport
	}
	default {
		write-host "$EM invalid generation type <$strType> specified"
		write-host "$IM valid options: all | odi | ddl | ddl-patch | spl | dml | ssis | ssas"
		$blnRes = $False
	}
}

if (!($blnRes)) {
	write-host "$EM failure generating import scripts"
	exit 1
}
else {
	write-host "$IM ends"
	exit 0
}