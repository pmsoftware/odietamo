#
# The following strings are used to prefix messages output from this script to aid identifation
# of the source of the messages.
#
$FN = "Constants"
$IM = $FN + ": INFO:"
$EM = $FN + ": ERROR:"

#
# This variable can be used when calling this script to determine if the complete
# script executed without a known failure. 
# It is set to $True at the end of this script is this script completes successfully.
#
$loadConstants = $False

#
# A string used to create unique generated script and log file names.
#
$VersionString = get-date -format "yyyyMMdd_HHmmss"

##############################################################
# Workstation environment definition.
##############################################################

$LocalRootDir = "C:\MOI"

$LocalBranchRoot = ""
$OdiSourceRoot = $LocalBranchRoot + "\ODI\Source"

$ConfigurationFolder = $LocalRootDir + "\Configuration"

#
# Local / TFS server environment definition.
#
$TFSServerConfigurationFile = $ConfigurationFolder + "\TFSConfiguration.tfs"
#
# This file stores records the changesets that have been updated into the
# local workspace using 'tf get'.
#
$TFSGetLocalControlFile = $ConfigurationFolder + "\TFSGetChangeSetsLocalControls.tfs"
#
# This file stores records the changesets that have been updated into the
# ODI repository using the OdiSvn solution.
#
$TFSGetLocalODIControlFile = $ConfigurationFolder + "\TFSGetChangeSetsODIRepoControls.tfs"

$TFSServer = ""
$TFSMoiProjectName = ""
$TFSMoiBranchName = ""
$TFSBranchName = ""

$ScriptsRootDir = $ConfigurationFolder + "\Scripts"

#
# Fixed utility script and file locations and names.
#
$MoiTempEmptyFile = $ConfigurationFolder + "\EmptyFileDoNotDelete.txt"
$MoiJisqlRepoBat = $ScriptsRootDir + "\MoiJisqlRepo.bat"
$MoiPreImport = $ScriptsRootDir + "\OdiSvn_GenScen_PreImport.bat" 
$OdiSvnMoiPreImport = $ScriptsRootDir + "\OdiSvn_GenScen_PreImport.bat" 
$OdiSvnValidateRepositoryIntegritySql = $ScriptsRootDir + "\OdiSvnValidateRepositoryIntegrity.sql"

#
# Script Template locations and names.
#
$OdiSvnRepositoryBackUpBatTemplate = $ScriptsRootDir + "\OdiSvnRepositoryBackUpTemplate.bat"
$MoiJisqlRepoBatTemplate = $ScriptsRootDir + "\MoiJisqlRepoTemplate.bat"
$OdiSvnBuildBatTemplate = $ScriptsRootDir + "\OdiSvnBuildTemplate.bat"
$OdiSvnGenScenPreImportBatTemplate = $ScriptsRootDir + "\OdiSvnGenScenPreImportTemplate.bat"
$OdiSvnGenScenPostImportBatTemplate = $ScriptsRootDir + "\OdiSvnGenScenPostImportTemplate.bat"
$OdiSvnRepoInfrastructureSetupSqlTemplate = $ScriptsRootDir + "\odisvn_create_infrastructure.sql"
$OdiSvnRepoSetNextImportTemplate = $ScriptsRootDir + "\odisvn_set_next_import_template.sql"
$OdiSvnBuildNoteTemplate = $ScriptsRootDir + "\OdiSvnBuildNoteTemplate.txt"

#
# Logging directory structure.
#
$LogRootDir = $LocalRootDir + "\Logs"
$GenScriptRootDir = $LogRootDir + "\${VersionString}"

#
# Generated script locations and names.
#
$OdiSvnRepositoryBackUpBat = $GenScriptRootDir + "\OdiSvnRepositoryBackUp_${VersionString}.bat"
$OdiSvnBuildBat = $GenScriptRootDir + "\OdiSvnBuild_${VersionString}.bat"
$OdiSvnGenScenPreImportBat = $GenScriptRootDir + "\OdiSvnGenScenPreImport_${VersionString}.bat"
$OdiSvnGenScenPostImportBat = $GenScriptRootDir + "\OdiSvnGenScenPostImport_${VersionString}.bat"
$OdiSvnRepoInfrastructureSetupSql = $GenScriptRootDir + "\odisvn_create_infrastructure_${VersionString}.sql"
$OdiSvnRepoSetNextImport = $GenScriptRootDir + "\odisvn_set_next_import_${VersionString}.sql"
$OdiSvnBuildNote = $GenScriptRootDir + "\OdiSvnBuildNote_${VersionString}.txt"

$ImportScriptStubName = "Import_" + $VersionString
$OdiImportScriptName = $ImportScriptStubName + ".bat"
$OdiImportScriptFile = $GenScriptRootDir + "\$OdiImportScriptName"

#
# ODI configuration.
#
$OdiBinFolder = $ConfigurationFolder + "\Tools\odi\bin"
$OdiParamFile = $OdiBinFolder + "\odiparams.bat"

#
# The following strings are used to derive data from TFS by parsing the output
# of the command line interface tool "tf.exe".
#
$GetLatestSearchText = "you have a conflicting edit"
$endOfConflictText= "Unable to perform the get"
$GetLatestSummaryText = "---- Summary"

#
# The following string is used to delimit output of multiple commands in a
# single text file.
#
$strOdiSvnCmdOutputSeparator = "xxxOdiSvn_Output_Separatorxxx"

#
# Create the standard Log directory tree.
#
if (Test-Path $LogRootDir) { 
	write-host "$IM logs root directory $LogRootDir already exists"
}
else {  
	write-host "$IM creating logs root diretory $LogRootDir"
	New-Item -itemtype directory $LogRootDir 
}

if (Test-Path $ScriptsRootDir) { 
	write-host "$IM scripts root directory $ScriptsRootDir already exists"
}
else {  
	write-host "$IM creating scripts root directory $ScriptsRootDir"
	New-Item -itemtype directory $ScriptsRootDir 
}

#if (Test-Path $UpdateLogFolder) { 
#	write-host "$IM working copy update control directory $UpdateLogFolder already exists"
#}
#else {  
#	write-host "$IM creating working copy update control directory $UpdateLogFolder"
#	New-Item -itemtype directory $UpdateLogFolder 
#}
#
if (Test-Path $GenScriptRootDir) { 
	write-host "$IM generated scripts root directory $GenScriptRootDir already exists"
}
else {  
	write-host "$IM creating generated scripts root directory $GenScriptRootDir"
	New-Item -itemtype directory $GenScriptRootDir 
}

if (Test-Path $MoiTempEmptyFile) { 
	write-host "$IM empty file check file $MoiTempEmptyFile already exists" 
}
else {  
	write-host "$IM creating empty file check file $MoiTempEmptyFile"
	New-Item -itemtype file $MoiTempEmptyFile 
}

##################################################
### 1. Get Latest Results                      ### 
##################################################

#
# GetIncremental will look at this directory to check the latest successful changeset imported.
#
$UpdateLogFolder = $LogRootDir + "\Update"

$GetLatestVersionOutputFile = $GenScriptRootDir + "\GetLatestVersion_Results_" + $VersionString + ".txt"
write-host "$IM GetIncremental output will be written to $GetLatestVersionOutputFile"
$GetLatestVersionConflictsOutputFile = $GenScriptRootDir + "\GetLatestVersionConflicts_Results_" + $VersionString + ".txt"

if (Test-Path $OdiImportScriptFile) {
	write-host "$IM generated ODI import batch file <$OdiImportScriptFile> already exists"
}
else {
	write-host "$IM creating empty generated ODI import batch file <$OdiImportScriptFile>"
	New-Item -itemtype file $OdiImportScriptFile 
}

if (Test-Path $TFSGetLocalControlFile) { 
	write-host "$IM local workspace update control file <$TFSGetLocalControlFile> already exists"
}
else {  
	write-host "$IM creating local workspace update control ChangeSet file <$TFSGetLocalControlFile>"
	New-Item -itemtype file $TFSGetLocalControlFile 
	Set-Content $TFSGetLocalControlFile "1~"
}

if (Test-Path $TFSGetLocalODIControlFile) { 
	write-host "$IM update control ChangeSet file <$TFSGetLocalODIControlFile> already exists"
}
else {  
	write-host "$IM creating update control ChangeSet file <$TFSGetLocalODIControlFile>"
	New-Item -itemtype file $TFSGetLocalODIControlFile 
	Set-Content $TFSGetLocalODIControlFile "1~"
}

#
# Import modes used when importing ODI objects.
#
$ODIImportModeInsertUpdate = 'SYNONYM_INSERT_UPDATE'
$ODIImportModeInsert = 'SYNONYM_INSERT'
$ODIImportModeUpdate = 'SYNONYM_UPDATE'

#
# Strings used to extract ODI repository connection details from "odiparams.bat".
#
$SECURITY_DRIVER_TEXT ='set ODI_SECU_DRIVER='
$SECURITY_DRIVER_LEN = $SECURITY_DRIVER_TEXT.length

$SECURITY_URL_TEXT ='set ODI_SECU_URL='
$SECURITY_URL_LEN = $SECURITY_URL_TEXT.length

$SECURITY_USER_TEXT ='set ODI_SECU_USER='
$SECURITY_USER_LEN = $SECURITY_USER_TEXT.length

$SECURITY_PWD_TEXT ='set ODI_SECU_ENCODED_PASS='
$SECURITY_PWD_LEN = $SECURITY_PWD_TEXT.length

$SECURITY_PWD_UNENC_TEXT = 'set ODI_SECU_PASS='
$SECURITY_PWD_UNENC_LEN = $SECURITY_PWD_UNENC_TEXT.length

$SECURITY_WORK_REP_TEXT ='set ODI_SECU_WORK_REP='
$SECURITY_WORK_REP_LEN = $SECURITY_WORK_REP_TEXT.length 

$USER_TEXT = 'set ODI_USER='
$USER_LEN = $USER_TEXT.length

$PASSWORD_TEXT ='set ODI_ENCODED_PASS='
$PASSWORD_LEN = $PASSWORD_TEXT.length

#
# The custom end-of-section entry in "odiparams.bat" added for this automation.
#
$LAST = 'rem ODI CONNECTION PARAMETERS FINISH'

$text = get-content $OdiParamFile | out-string

write-host "$IM starting evaluation of ODI parameter file $OdiPraramFile"

if ( ($text.IndexOf($SECURITY_DRIVER_TEXT) -gt 0) -and
     ($text.IndexOf($SECURITY_URL_TEXT) -gt 0) -and
     ($text.IndexOf($SECURITY_USER_TEXT) -gt 0) -and
     ($text.IndexOf($SECURITY_PWD_TEXT) -gt 0) -and
     ($text.IndexOf($SECURITY_PWD_UNENC_TEXT) -gt 0) -and
     ($text.IndexOf($SECURITY_WORK_REP_TEXT)  -gt 0) ) {
	 
	$SECURITY_DRIVER    = $text.Substring($text.IndexOf($SECURITY_DRIVER_TEXT   ) + $SECURITY_DRIVER_LEN   , $text.IndexOf($SECURITY_URL_TEXT)       - $text.IndexOf($SECURITY_DRIVER_TEXT)    - $SECURITY_DRIVER_LEN    - 1).Trim()
	$SECURITY_URL       = $text.Substring($text.IndexOf($SECURITY_URL_TEXT      ) + $SECURITY_URL_LEN      , $text.IndexOf($SECURITY_USER_TEXT)      - $text.IndexOf($SECURITY_URL_TEXT)       - $SECURITY_URL_LEN       - 1).Trim()
	$SECURITY_USER      = $text.Substring($text.IndexOf($SECURITY_USER_TEXT     ) + $SECURITY_USER_LEN     , $text.IndexOf($SECURITY_PWD_TEXT)       - $text.IndexOf($SECURITY_USER_TEXT)      - $SECURITY_USER_LEN      - 1).Trim()
	$SECURITY_PWD       = $text.Substring($text.IndexOf($SECURITY_PWD_TEXT      ) + $SECURITY_PWD_LEN      , $text.IndexOf($SECURITY_PWD_UNENC_TEXT) - $text.IndexOf($SECURITY_PWD_TEXT)       - $SECURITY_PWD_LEN       - 1).Trim()
	$SECURITY_UNENC_PWD = $text.Substring($text.IndexOf($SECURITY_PWD_UNENC_TEXT) + $SECURITY_PWD_UNENC_LEN, $text.IndexOf($SECURITY_WORK_REP_TEXT)  - $text.IndexOf($SECURITY_PWD_UNENC_TEXT) - $SECURITY_PWD_UNENC_LEN - 1).Trim()
	$WORK_REP_NAME      = $text.Substring($text.IndexOf($SECURITY_WORK_REP_TEXT ) + $SECURITY_WORK_REP_LEN , $text.IndexOf($USER_TEXT)               - $text.IndexOf($SECURITY_WORK_REP_TEXT ) - $SECURITY_WORK_REP_LEN  - 1).Trim()
	$USER               = $text.Substring($text.IndexOf($USER_TEXT              ) + $USER_LEN              , $text.IndexOf($PASSWORD_TEXT)           - $text.IndexOf($USER_TEXT)               - $USER_LEN               - 1).Trim()
	$PASSWORD           = $text.Substring($text.IndexOf($PASSWORD_TEXT          ) + $PASSWORD_LEN          , $text.IndexOf($LAST)                    - $text.IndexOf($PASSWORD_TEXT)           - $PASSWORD_LEN           - 1).Trim()

	write-host "$IM extracted ODI_SECU_DRIVER: $SECURITY_DRIVER"
	write-host "$IM extracted ODI_SECU_URL: $SECURITY_URL"
	write-host "$IM extracted ODI_SECU_USER: $SECURITY_USER"
	write-host "$IM extracted ODI_SECU_PWD: $SECURITY_PWD"
	write-host "$IM extracted ODI_SECU_UNENC_PWD: $SECURITY_UNENC_PWD"
	write-host "$IM extracted ODI_SECU_WORK_REP_NAME: $WORK_REP_NAME"
	write-host "$IM extracted ODI_USER: $USER"
	write-host "$IM extracted ODI_PASSWORD: $PASSWORD"
	
	[array] $SECURITY_URL_PARTS = @([regex]::split($SECURITY_URL,":"))
	$SECURITY_URL_SERVER = $SECURITY_URL_PARTS[3].Replace("@","")
	$SECURITY_URL_PORT = $SECURITY_URL_PARTS[4]
	$SECURITY_URL_SID = $SECURITY_URL_PARTS[5]
	
	if ( ($SECURITY_DRIVER.length -eq 0) -or ($SECURITY_URL.length -eq 0) -or ($SECURITY_USER.length -eq 0) -or ($SECURITY_PWD.length -eq 0) -or ($SECURITY_UNENC_PWD.length -eq 0) -or ($WORK_REP_NAME.length -eq 0) -or ($USER.length -eq 0) -or ($PASSWORD.length -eq 0) ) {
		$loadConstants = $False
		write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
	}
	else {
		if ( ($SECURITY_DRIVER.Contains("<")) -or ($SECURITY_URL.Contains("<")) -or ($SECURITY_USER.Contains("<")) -or ($SECURITY_PWD.Contains("<")) -or ($SECURITY_UNENC_PWD.Contains("<")) -or ($WORK_REP_NAME.Contains("<")) -or ($USER.Contains("<")) -or ($PASSWORD.Contains("<")) ) {
			$loadConstants = $False
			write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
		}
		else {
			$orderedExtensions = @("*.SnpTechno","*.SnpLang","*.SnpContext","*.SnpConnect","*.SnpPschema","*.SnpLschema","*.SnpProject","*.SnpGrpState","*.SnpFolder","*.SnpVar","*.SnpUfunc","*.SnpTrt","*.SnpModFolder","*.SnpModel","*.SnpSubModel","*.SnpTable","*.SnpJoin","*.SnpSequence","*.SnpPop","*.SnpPackage","*.SnpObjState")
			$containerExtensions = @("*.SnpConnect","*.SnpModFolder","*.SnpModel","*.SnpSubModel","*.SnpProject","*.SnpFolder")
			$nestableContainerExtensions = @("*.SnpModFolder","*.SnpSubModel","*.SnpFolder")
			$nestableContainerExtensionParentFields = @("ParIModFolder","ISmodParent","ParIFolder")
			$nestableContExtParBegin = '<Field name="XXXXXXXXXXXXXXXXXXXX" type="com.sunopsis.sql.DbInt"><![CDATA['
			$nestableContExtParEnd = ']]></Field>'
			$loadConstants = $True 
			write-host "$IM successfully evaluated ODI parameter file <$OdiParamFile>"
		}
	}
	$loadConstants = $true
}
else {
	write-host "$EM failure evaluating ODI parameter file <$OdiParamFile>"
	$loadConstants = $false
}
