#
# Import modes used when importing ODI objects.
#
$ODIImportModeInsertUpdate = 'SYNONYM_INSERT_UPDATE'
$ODIImportModeInsert = 'SYNONYM_INSERT'
$ODIImportModeUpdate = 'SYNONYM_UPDATE'

#
# Strings used to correctly generate the ODI object imports for nestable object types.
#
$orderedExtensions = @("*.SnpTechno", "*.SnpLang", "*.SnpConnect", "*.SnpPschema", "*.SnpLschema", "*.SnpContext", "*.SnpPschemaCont", "*.SnpProject", "*.SnpGrpState", "*.SnpFolder","*.SnpVar", "*.SnpUfunc", "*.SnpTrt", "*.SnpModFolder", "*.SnpModel", "*.SnpSubModel", "*.SnpTable", "*.SnpJoin", "*.SnpSequence", "*.SnpPop", "*.SnpPackage", "*.SnpObjState")
$containerExtensions = @("*.SnpTechno","*.SnpConnect","*.SnpContext","*.SnpModFolder","*.SnpModel","*.SnpSubModel","*.SnpProject","*.SnpFolder")
#
# Valid exported master repository code XML file name extensions.
#
$masterRepoExtensions = @("SnpTechno", "SnpLang", "SnpConnect", "SnpPschema", "SnpLschema", "SnpContext", "SnpPschemaCont")
#####$masterRepoExtensionTabs = @("SNP_TECHNO", "SNP_LANG", "SNP_CONNECT", "SNP_PSCHEMA", "SNP_LSCHEMA", "SNP_CONTEXT", "SNP_PSCHEMA_CONT")
#
# ODI class names of objects in exported code XML for which we need to analyse internal IDs in order to adjust SNP_ENT_ID.
#
$masterRepoClassNames = @("SnpTechno", "SnpLang", "SnpConnect", "SnpPschema", "SnpLschema", "SnpContext", "SnpMtxt", "SnpAction", "SnpAgent", "SnpData", "SnpDt", "SnpField", "SnpFlexField", "SnpGrpAction", "SnpIndexType", "SnpLangElt", "SnpMeth", "SnpModule", "SnpObject", "SnpPlanAgent", "SnpProfile", "SnpPwdPolicy", "SnpPwdRule", "SnpSubLang", "SnpUser")
$masterRepoClassIdNames = @("ITechno", "ILang", "IConnect", "IPschema", "ILschema", "IContext", "ITxt", "IAction", "IAgent", "IData", "IDt", "IField", "IFf", "IGrpAction", "IIndexType", "ILangElt", "IMeth", "IModule", "IObjects", "IPlanAgent", "IProf", "IPwdPolicy", "IPwdRule", "ISubLang", "IWuser")
$masterRepoClassTableNames = @("SNP_TECHNO", "SNP_LANG", "SNP_CONNECT", "SNP_PSCHEMA", "SNP_LSCHEMA", "SNP_CONTEXT", "SNP_MTXT", "SNP_ACTION", "SNP_AGENT", "SNP_DATA", "SNP_DT", "SNP_FIELD", "SNP_FLEX_FIELD", "SNP_GRP_ACTION", "SNP_INDEX_TYPE", "SNP_LANG_ELT", "SNP_METH", "SNP_MODULE", "SNP_OBJECT", "SNP_PLAN_AGENT", "SNP_PROFILE", "SNP_PWD_POLICY", "SNP_PWD_RULE", "SNP_SUB_LANG", "SNP_USER")
#
# Valid exported work repository code XML file name extensions.
#
$workRepoExtensions = @("SnpProject", "SnpGrpState", "SnpFolder", "SnpVar", "SnpUfunc", "SnpTrt", "SnpModFolder", "SnpModel", "SnpSubModel", "SnpTable", "SnpJoin", "SnpSequence", "SnpPop", "SnpPackage", "SnpObjState")
#####$workRepoExtensionTabs = @("SNP_PROJECT", "SNP_GRP_STATE", "SNP_FOLDER", "SNP_VAR", "SNP_UFUNC", "SNP_TRT", "SNP_MOD_FOLDER", "SNP_MODEL", "SNP_SUB_MODEL", "SNP_TABLE", "SNP_JOIN", "SNP_SEQUENCE", "SNP_POP", "SNP_PACKAGE", "SNP_OBJ_STATE")
#
# ODI class names of objects in exported code XML for which we need to analyse internal IDs in order to adjust SNP_ID.
#
$workRepoClassNames = @("SnpProject", "SnpGrpState", "SnpFolder", "SnpVar", "SnpUserExit", "SnpUfunc", "SnpTrt", "SnpModFolder", "SnpModel", "SnpSubModel", "SnpTable", "SnpJoin", "SnpSequence", "SnpPop", "SnpPackage", "SnpObjState", "SnpExpTxt", "SnpExpTxtHeader", "SnpLpInst", "SnpObjectTrace", "SnpTxt", "SnpTxtHeader", "SnpCol", "SnpCond", "SnpDataSet", "SnpDiagram", "SnpEntity", "SnpEss", "SnpLink", "SnpLinkCoord", "SnpLoadPlan", "SnpLookup", "SnpPartition", "SnpPopClause", "SnpPopCol", "SnpScen", "SnpScenFolder", "SnpSolution", "SnpSourceTab", "SnpSrcSet", "SnpState", "SnpState2", "SnpStep", "SnpUfuncImpl")
#, "SnpOrigTxt" - these object types do not have the usual format. They can be less that 4 digits so they cannot be comprised of an object ID and a repo ID.
$workRepoClassIdNames = @("IProject", "IGrpState", "IFolder", "IVar", "IUserExit", "IUfunc", "ITrt", "IModFolder", "IMod", "ISmod", "ITable", "IJoin", "SeqId", "IPop", "IPackage", "IObjState", "ITxt", "ITxt", "ILpInst", "IObjTrace", "ITxt", "ITxt", "ICol", "ICond", "IDataSet", "IDiagram", "IEntity", "IEss", "ILink", "ICoord", "ILoadPlan", "ILookup", "IPartition", "IPopClause", "IPopCol", "ScenNo", "IScenFolder", "ISolution", "ISourceTab", "ISrcSet", "IState", "IState", "IStep", "IUfuncImpl")
#, "ITxtOrig" - these object types do not have the usual format. They can be less that 4 digits so they cannot be comprised of an object ID and a repo ID.
$workRepoClassTableNames = @("SNP_PROJECT", "SNP_GRP_STATE", "SNP_FOLDER", "SNP_VAR", "SNP_USER_EXIT", "SNP_UFUNC", "SNP_TRT", "SNP_MOD_FOLDER", "SNP_MODEL", "SNP_SUB_MODEL", "SNP_TABLE", "SNP_JOIN", "SNP_SEQUENCE", "SNP_POP", "SNP_PACKAGE", "SNP_OBJ_STATE", "SNP_EXP_TXT", "SNP_EXP_TXT_HEADER", "SNP_LP_INST", "SNP_OBJ_TRACE", "SNP_TXT", "SNP_TXT_HEADER", "SNP_COL", "SNP_COND", "SNP_DATA_SET", "SNP_DIAGRAM", "SNP_ENTITY", "SNP_ESS", "SNP_LINK", "SNP_LINK_COORD", "SNP_LOAD_PLAN", "SNP_LOOKUP", "SNP_PARTITION", "SNP_POP_CLAUSE", "SNP_POP_COL", "SNP_SCEN", "SNP_SCEN_FOLDER", "SNP_SOLUTION", "SNP_SOURCE_TAB", "SNP_SRC_SET", "SNP_STATE", "SNP_STATE2", "SNP_STEP", "SNP_UFUNC_IMPL")
#, "SNP_ORIG_TXT" - these object types do not have the usual format. They can be less that 4 digits so they cannot be comprised of an object ID and a repo ID.

$scenarioSourceExtensions = @("*.SnpVar","*.SnpTrt","*.SnpPop","*.SnpPackage")
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
		write-host "${strSource}: DEBUG: $strToPrint"
	}
}

function LogDebugArray ($strSource, $strArrName, [array] $strToPrint) {
	
	$intIdx = 0
	
	if ($DebuggingActive) {
		foreach ($x in $strToPrint) {
			write-host "${strSource}: DEBUG: $strArrName[$intIdx]: $x"
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

function BuildOdiSourceFileList ($arrStrInputFiles, [ref] $refOdiFileList) {
	
	$FN = "BuildOdiSourceFileList"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DM = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	write-host "$IM received" $arrStrInputFiles.length "files to examine"
	$arrStrOdiFiles = @()
	
	$strWcRootDir = $env:ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT
	$strWcRootDirUC = $strWcRootDir.ToUpper()
	$strWcRootDirUCBS = $strWcRootDirUC.Replace("/","\")
	
	$strOdiWcRootDir = $env:ODI_SCM_SCM_SYSTEM_ORACLEDI_WORKING_COPY_ROOT
	$strOdiWcRootDirUC = $strOdiWcRootDir.ToUpper()
	$strOdiWcRootDirUCBS = $strOdiWcRootDirUC.Replace("/","\")
	
	$strOdiWcDirAbsUCBS = $strWcRootDirUCBS
	
	if ($strOdiWcRootDirUCBS -ne ".") {
		$strOdiWcDirAbsUCBS += "\" + $strOdiWcRootDirBS
	}
	
	foreach ($Extention in $orderedExtensions) {
		#
		# Remove the asterisk from the file type name pattern.
		#
		$strFileObjType = $Extention.Replace("*","")
		$FileObjTypeExt = $strFileObjType.replace(".","")
		write-host "$IM processing object type <$FileObjTypeExt>"
		
		foreach ($strFile in $arrStrInputFiles) {
		
			$strFileUC = $strFile.ToUpper()
			$strFileUCBS = $strFileUC.Replace("/","\")
			
			if (($strFileUCBS.StartsWith($strOdiWcDirAbsUCBS)) -and ($strFile.EndsWith($strFileObjType))) {
				#
				# This is an ODI source object file name.
				#
				$arrStrOdiFiles += $strFile
			}
		}
	}
	
	#
	# Sort the ODI object source files into import dependency order.
	#
	if (!(OrderOdiImports $arrStrOdiFiles $refOdiFileList)) {
		write-host "$EM ordering ODI source files"
		return $False
	}
	
	write-host "$IM ends"
	return $True
}

function BuildDdlSourceFileList ($arrStrInputFiles, [ref] $refDbDdlFileList) {
	
	$FN = "BuildDdlSourceFileList"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DM = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	write-host "$IM received" $arrStrInputFiles.length "files to examine"
	$arrStrDdlFiles = @()
	$strPattern = "^ddl\-.+\-.+\-.*\.sql"
	
	foreach ($strFile in $arrStrInputFiles) {
		
		$strFileName = split-path -path $strFile -leaf
		if ($strFileName -match $strPattern) {
			$arrStrDdlFiles += $strFile
		}
	}
	
	#
	# Sort the DDL script array into file name (excluding the path) order.
	#
	# $arrObjDdlFile = @()
	# foreach ($strFile in $arrStrDdlFiles) {
		# $objFile = new-object PSObject
		# $strFileName = split-path -path $strFile -leaf
		# add-member -inputobject $objFile -membertype noteproperty -name "FileName" -value $strFileName
		# add-member -inputobject $objFile -membertype noteproperty -name "FilePathName" -value $strFile
		# $arrObjDdlFile += $objFile
	# }
	
	# $arrStrSortedDdlFiles = @()
	
	# if ($arrObjDdlFile.length -gt 0) {
		# $arrStrSortedDdlFiles = $arrObjDdlFile | sort-object -property FileName
	# }
	
	#
	# Copy the DDL script file list into the output list.
	#
	#foreach ($strSortedDdlFile in $arrStrSortedDdlFiles) {
	foreach ($strDdlFile in $arrStrDdlFiles) {
		#$refDbDdlFileList.value += $strSortedDdlFile.FilePathName
		$refDbDdlFileList.value += $strDdlFile
	}
	
	write-host "$IM ends"
	return $True
}

function BuildSplSourceFileList ($arrStrInputFiles, [ref] $refDbSplFileList) {
	
	$FN = "BuildSplSourceFileList"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DM = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	write-host "$IM received" $arrStrInputFiles.length "files to examine"
	$arrStrSplFiles = @()
	$strPattern = "^spl\-.+\-.+\-.*\.sql"
	
	foreach ($strFile in $arrStrInputFiles) {
		
		$strFileName = split-path -path $strFile -leaf
		
		if ($strFileName -match $strPattern) {
			$arrStrSplFiles += $strFile
		}
	}
	
	#
	# Sort the SPL script array into file name (excluding the path) order.
	#
	# $arrObjSplFile = @()
	# foreach ($strFile in $arrStrSplFiles) {
		# $objFile = new-object PSObject
		# $strFileName = split-path -path $strFile -leaf
		# add-member -inputobject $objFile -membertype noteproperty -name "FileName" -value $strFileName
		# add-member -inputobject $objFile -membertype noteproperty -name "FilePathName" -value $strFile
		# $arrObjSplFile += $objFile
	# }
	
	# $arrStrSortedSplFiles = @()
	
	# if ($arrObjSplFile.length -gt 0) {
		# $arrStrSortedSplFiles = $arrObjSplFile | sort-object -property FileName
	# }
	
	#
	# Copy the SPL script file list into the output list.
	#
	#foreach ($strSortedSplFile in $arrStrSortedSplFiles) {
	#foreach ($strSortedSplFile in $arrStrSortedSplFiles) {
	foreach ($strSplFile in $arrStrSplFiles) {
		#$refDbSplFileList.value += $strSortedSplFile.FilePathName
		$refDbSplFileList.value += $strSplFile
	}
	
	write-host "$IM ends"
	return $True
}

function BuildDmlSourceFileList ($arrStrInputFiles, [ref] $refDbDmlFileList) {
	
	$FN = "BuildDmlSourceFileList"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DM = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	write-host "$IM received" $arrStrInputFiles.length "files to examine"
	$arrStrDmlFiles = @()
	$intPatternNo = 0
	
	do {
		$strVarName = "ODI_SCM_GENERATE_DML_SCRIPT_FILE_NAME_PATTERN_" + $intPatternNo
		$strPattern = [Environment]::GetEnvironmentVariable($strVarName)
		
		if (($strPattern -ne "") -and ($strPattern -ne $Null)) {
			
			$blnProcessedPattern = $True
			write-host "$IM processing database DML script file name pattern number <$intPatternNo> pattern string <$strPattern>"
			
			foreach ($strFile in $arrStrInputFiles) {
				
				$strFileName = split-path -path $strFile -leaf
				
				if ($strFileName -match $strPattern) {
					$arrStrDmlFiles += $strFile
				}
			}
		}
		else {
			$blnProcessedPattern = $False
		}
		$intPatternNo += 1
	}
	while ($blnProcessedPattern)
	
	#
	# Sort the DML script array into file name (excluding the path) order.
	#
	# $arrObjDmlFile = @()
	
	# foreach ($strFile in $arrStrDmlFiles) {
		# $objFile = new-object PSObject
		# $strFileName = split-path -path $strFile -leaf
		# add-member -inputobject $objFile -membertype noteproperty -name "FileName" -value $strFileName
		# add-member -inputobject $objFile -membertype noteproperty -name "FilePathName" -value $strFile
		# $arrObjSqlFile += $objFile
	# }
	
	# $arrStrSortedDmlFiles = @()
	
	# if ($arrObjDmlFile.length -gt 0) {
		# $arrStrSortedDmlFiles = $arrObjDmlFile | sort-object -property FileName
	# }
	
	#
	# Copy the SQL script file list into the output list.
	#
	#foreach ($strSortedDmlFile in $arrStrSortedDmlFiles) {
	foreach ($strDmlFile in $arrStrDmlFiles) {
		#$refDbDmlFileList.value += $strSortedDmlFile.FilePathName
		$refDbDmlFileList.value += $strDmlFile
	}
	
	write-host "$IM ends"
	return $True
}

function BuildSourceFileLists ($arrStrInputFiles, [ref] $refOdiFileList, [ref] $refDbDdlFileList, [ref] $refDbSplFileList, [ref] $refDbDmlFileList) {
	
	$FN = "BuildSourceFileLists"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DM = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	
	if (!(BuildOdiSourceFileList $arrStrInputFiles $refOdiFileList)) {
		write-host "$EM creating ODI source file list"
		return $False
	}
	
	if (!(BuildDdlSourceFileList $arrStrInputFiles $refDbDdlFileList)) {
		write-host "$EM creating DDL source file list"
		return $False
	}
	
	if (!(BuildSplSourceFileList $arrStrInputFiles $refDbSplFileList)) {
		write-host "$EM creating SPL source file list"
		return $False
	}
	
	if (!(BuildDmlSourceFileList $arrStrInputFiles $refDbDmlFileList)) {
		write-host "$EM creating DML source file list"
		return $False
	}
	
	write-host "$IM ends"
	return $True
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
								$sortFileList[$i + 1] = $tempFileListEntry
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

function GenerateOdiImportScript ([array] $arrStrFilesToImport) {
	
	$FN = "GenerateOdiImportScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG"
	
	write-host "$IM starts"
	
	$ExitStatus = $False
	
	write-host "$IM passed <$($arrStrFilesToImport.length)> files to import"
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
		
		foreach ($fileToImport in $arrStrFilesToImport) {
			
			if ($fileToImport.EndsWith($fileObjType)) {
				
				$FileToImportName = split-path $fileToImport -leaf
				$FileToImportPathName = split-path $fileToImport -parent
				$SourceFile = $fileToImport
				$extensionFileCount += 1
				
				$ImportText = "echo %IM% date ^<%date%^> time ^<%time%^>" + [Environment]::NewLine
				$ImportText += "set MSG=importing file ^^^<" + $fileToImport + "^^^>" + [Environment]::NewLine
				$ImportText += "echo %IM% %MSG%" + [Environment]::NewLine
				
				#
				# Work around (yet another) bug in ODI (as of 11.1.1.6.4) where an SnpProject can't be imported
				# unless it has the file name prefix "PROJ_".
				#
				if ($fileObjType -eq "SnpProject") {
					$ImportText += "echo %IM% creating renamed SnpProject file for source file ^<$FileToImportName^>" + [Environment]::NewLine
					if (!($FileToImportName.StartsWith("Consolidated"))) {
						# Create the renamed file copy in the Windows temp directory we created.
						$FileToImportPathName = "%TEMPDIR%"
					}
					$FileToImportName = "PROJ_" + $FileToImportName + ".xml"
					$SourceFile = $FileToImportPathName + "\" + $FileToImportName
					$ImportText += 'copy "' + $fileToImport + '" "' + $SourceFile + '" >NUL' + [Environment]::NewLine
				}
				
				#
				# Work around (yet another) bug in ODI (as of 11.1.1.7.0) where an SnpModel can't be imported
				# unless it has the file name prefix "MOD_".
				#
				if ($fileObjType -eq "SnpModel") {
					$ImportText += "echo %IM% creating renamed SnpModel file for source file ^<$FileToImportName^>" + [Environment]::NewLine
					if (!($FileToImportName.StartsWith("Consolidated"))) {
						# Create the renamed file copy in the temp directory we created.
						$FileToImportPathName = "%TEMPDIR%"
					}
					$FileToImportName = "MOD_" + $FileToImportName + ".xml"
					$SourceFile = $FileToImportPathName + "\" + $FileToImportName
					$ImportText += 'copy "' + $fileToImport + '" "' + $SourceFile + '" >NUL' + [Environment]::NewLine
				}
				
				#
				# Work around (yet another) bug in ODI (as of 11.1.1.7.0) where an SnpPop can't be imported
				# unless it has the file name prefix "POP_".
				#
				if ($fileObjType -eq "SnpPop") {
					$ImportText += "echo %IM% creating renamed SnpPop file for source file ^<$FileToImportName^>" + [Environment]::NewLine
					if (!($FileToImportName.StartsWith("Consolidated"))) {
						# Create the renamed file copy in the temp directory we created.
						$FileToImportPathName = "%TEMPDIR%"
					}
					$FileToImportName = "POP_" + $FileToImportName + ".xml"
					$SourceFile = $FileToImportPathName + "\" + $FileToImportName
					$ImportText += 'copy "' + $fileToImport + '" "' + $SourceFile + '" >NUL' + [Environment]::NewLine
				}
				
				#
				# Work around (yet another) bug in ODI (as of 11.1.1.7.0) where an SnpTrt can't be imported
				# unless it has the file name prefix "TRT_".
				#
				if ($fileObjType -eq "SnpTrt") {
					$ImportText += "echo %IM% creating renamed SnpTrt file for source file ^<$FileToImportName^>" + [Environment]::NewLine
					if (!($FileToImportName.StartsWith("Consolidated"))) {
						# Create the renamed file copy in the temp directory we created.
						$FileToImportPathName = "%TEMPDIR%"
					}
					$FileToImportName = "TRT_" + $FileToImportName + ".xml"
					$SourceFile = $FileToImportPathName + "\" + $FileToImportName
					$ImportText += 'copy "' + $fileToImport + '" "' + $SourceFile + '" >NUL' + [Environment]::NewLine
				}
				
				#
				# Work around (yet another) bug in ODI (as of 11.1.1.7.0) where an SnpPackage can't be imported
				# unless it has the file name prefix "PACK_".
				#
				if ($fileObjType -eq "SnpPackage") {
					$ImportText += "echo %IM% creating renamed SnpPackage file for source file ^<$FileToImportName^>" + [Environment]::NewLine
					if (!($FileToImportName.StartsWith("Consolidated"))) {
						# Create the renamed file copy in the temp directory we created.
						$FileToImportPathName = "%TEMPDIR%"
					}
					$FileToImportName = "PACK_" + $FileToImportName + ".xml"
					$SourceFile = $FileToImportPathName + "\" + $FileToImportName
					$ImportText += 'copy "' + $fileToImport + '" "' + $SourceFile + '" >NUL' + [Environment]::NewLine
				}
				
				#
				# Work around (yet another) bug in ODI (as of 11.1.1.7.0) where an SnpTable can't be imported
				# unless it has the file name prefix "TAB_".
				#
				if ($fileObjType -eq "SnpTable") {
					$ImportText += "echo %IM% creating renamed SnpTable file for source file ^<$FileToImportName^>" + [Environment]::NewLine
					if (!($FileToImportName.StartsWith("Consolidated"))) {
						# Create the renamed file copy in the temp directory we created.
						$FileToImportPathName = "%TEMPDIR%"
					}
					$FileToImportName = "TAB_" + $FileToImportName + ".xml"
					$SourceFile = $FileToImportPathName + "\" + $FileToImportName
					$ImportText += 'copy "' + $fileToImport + '" "' + $SourceFile + '" >NUL' + [Environment]::NewLine
				}
				
				if (!($containerExtensions -contains $ext)) {
					$ImportText += 'call "' + $ScriptsRootDir + '\OdiScmFork.bat" ^"' + $OdiScmOdiStartCmdBat + '^" OdiImportObject ' + '"-FILE_NAME=' + $SourceFile + '" ' + "-IMPORT_MODE=$ODIImportModeInsertUpdate -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
				}
				else {
					$ImportText += 'call "' + $ScriptsRootDir + '\OdiScmFork.bat" ^"' + $OdiScmOdiStartCmdBat + '^" OdiImportObject ' + '"-FILE_NAME=' + $SourceFile + '" ' + "-IMPORT_MODE=$ODIImportModeInsert -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
					$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
					$ImportText += 'call "' + $ScriptsRootDir + '\OdiScmFork.bat" ^"' + $OdiScmOdiStartCmdBat + '^" OdiImportObject ' + '"-FILE_NAME=' + $SourceFile + '" ' + "-IMPORT_MODE=$ODIImportModeUpdate -WORK_REP_NAME=$OdiRepoWORK_REP_NAME" + [Environment]::NewLine
				}
				$ImportText += "if ERRORLEVEL 1 goto ExitFail" + [Environment]::NewLine
				$ImportText += "echo %IM% import of file ^<" + $FileToImportName + "^> completed successfully" + [Environment]::NewLine
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
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateOdiSrcObjIdInsertScript ([array] $arrStrFilesToImport) {
	
	$FN = "GenerateOdiSrcObjIdInsertScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG"
	
	write-host "$IM starts"
	
	$templateText = get-content $OdiScmGenScenPreImpDelOldSqlTemplate | out-string
	if (!($?)) {
		write-host "$EM getting contents of template file <$OdiScmGenScenPreImpDelOldSqlTemplate>"
		return $False
	}
	
	write-host "$IM writing output to <$OdiScmGenScenPreImpDelOldSql>"
	$ImportText = ""
	
	#
	# Loop through each extension and file files for which to include object ID insert commands.
	#
	foreach ($ext in $scenarioSourceExtensions) {
		
		$fileObjType = $ext.Replace("*.","")
		write-host "$IM processing object type <$fileObjType>"
		
		$extensionFileCount = 0
		
		foreach ($fileToImport in $arrStrFilesToImport) {
			
			if ($fileToImport.EndsWith($fileObjType)) {
				
				$FileToImportName = split-path $fileToImport -leaf
				$FileToImportPathName = split-path $fileToImport -parent
				$FileToImportID = $FileToImportName.split(".")
				$extensionFileCount += 1
				
				switch ($fileObjType) {
					"SnpPop" {
						$FileToImportTypeID = 3100
					}
					"SnpTrt" {
						$FileToImportTypeID = 3600
					}
					"SnpPackage" {
						$FileToImportTypeID = 3200
					}
					"SnpVar" {
						$FileToImportTypeID = 3500
					}
				}
				
				$ImportText += "INSERT" + [Environment]::NewLine
				$ImportText += "  INTO odiscm_imports" + [Environment]::NewLine
				$ImportText += "       (" + [Environment]::NewLine
				$ImportText += "       source_object_id" + [Environment]::NewLine
				$ImportText += "     , source_type_id" + [Environment]::NewLine
				$ImportText += "       )" + [Environment]::NewLine
				$ImportText += "VALUES (" + [Environment]::NewLine
				$ImportText += "       " + $FileToImportID[0] + [Environment]::NewLine
				$ImportText += "     , " + $FileToImportTypeID + [Environment]::NewLine
				$ImportText += "       )" + [Environment]::NewLine
				$ImportText += "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine
				$ImportText += "" + [Environment]::NewLine
			}
		}
	}
	
	$outputText = $templateText.Replace("<OdiScmInsertSrcObjIds>",$ImportText)
	$outputText | out-file -filepath $OdiScmGenScenPreImpDelOldSql -encoding ASCII
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateOdiSrcObjIdScript ([array] $arrStrFilesToImport, $blnConsolidatedFilesList) {
	
	$FN = "GenerateOdiSrcObjIdScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	write-host "$IM writing output to <$OdiScmPreImpMergeSnpIDsSql>"
	$SqlText = ""
	
	#
	# Analyse each ODI source file and look for objects previously created in a repository with our repository ID.
	# First initialise arrays to store the highest ID found for each object type.
	#
	$arrMasterRepoID = @()
	foreach ($strClassName in $masterRepoClassNames) {
		# Create and initialise a new element of the object IDs array.
		$arrMasterRepoID += -1
	}
	
	$arrWorkRepoID = @()
	foreach ($strClassName in $workRepoClassNames) {
		# Create and initialise a new element of the object IDs array.
		$arrWorkRepoID += -1
	}
	
	#set-content "c:\DebugDir\arrStrFilesToImport.txt" $arrStrFilesToImport
	#
	#for ($intClassIdx = 0; $intClassIdx -lt $masterRepoClassNames.length; $intClassIdx++) {
	#	write-host "$DEBUG intClassIdx <$intClassIdx> masterRepoClassName <" $masterRepoClassNames[$intClassIdx] "> ID attribute <" $masterRepoClassIdNames[$intClassIdx] "> table name <" $masterRepoClassTableNames[$intClassIdx] ">"
	#}
	#for ($intClassIdx = 0; $intClassIdx -lt $workRepoClassNames.length; $intClassIdx++) {
	#	write-host "$DEBUG intClassIdx <$intClassIdx> workRepoClassName <" $workRepoClassNames[$intClassIdx] "> ID attribute <" $workRepoClassIdNames[$intClassIdx] "> table name <" $workRepoClassTableNames[$intClassIdx] ">"
	#}
	write-host "$IM starting analysis of code export files for repository ID <$env:ODI_SCM_ORACLEDI_REPOSITORY_ID>"
	
	foreach ($strFileToImport in $arrStrFilesToImport) {
		
		$strFileName = split-path -path $strFileToImport -leaf
		$arrStrFileRecords = get-content $strFileToImport
		
		$strFileToImportName = split-path $strFileToImport -leaf
		$strFileToImportNameParts = $strFileToImportName.split(".")
		$strFileToImportNameClassName = $strFileToImportNameParts[$strFileToImportNameParts.length - 1]
		###$strFileToImportNameClassName = $strFileToImportNameParts[1]
		
		if (!($blnConsolidatedFilesList)) {
			$strFileToImportRepoID = $strFileToImportNameParts[0].Substring($strFileToImportNameParts[0].length - 3)
			$strFileToImportObjID =  $strFileToImportNameParts[0].Substring(0, $strFileToImportNameParts[0].length - 3)
			$strFileToImportObjID = [int]::Parse($strFileToImportObjID)
		}
		
		if ((!($masterRepoExtensions -contains "$strFileToImportNameClassName")) -and (!($workRepoExtensions -contains "$strFileToImportNameClassName"))) {
			write-host "$WM ignoring file type <$strFileToImportNameClassName> in code export file name <$strFileToImportName>"
			continue
		}
		
		if ($masterRepoExtensions -contains "$strFileToImportNameClassName") {
			write-host "$IM analysing master repository code export file <$strFileName>"
			#
			# Look for each master repository class in the current file and in the file name.
			#
			for ($intClassIdx = 0; $intClassIdx -lt $masterRepoClassNames.length; $intClassIdx++) {
				$strClassName = $masterRepoClassNames[$intClassIdx]
				$strClassIDName = $masterRepoClassIDNames[$intClassIdx]
				
				#
				# We only examine file names for object IDs if we're not using a set of consolidated files.
				#
				if (!($blnConsolidatedFilesList)) {
					if ($strFileToImport.EndsWith($strClassName)) {
						if ($strFileToImportRepoID -eq $env:ODI_SCM_ORACLEDI_REPOSITORY_ID) {
							if ($strFileToImportObjID -gt $arrMasterRepoID[$intClassIdx]) {
								$arrMasterRepoID[$intClassIdx] = $strFileToImportObjID
							}
						}
					}
				}
				
				$blnFoundObj = $False
				foreach ($strFileRec in $arrStrFileRecords) {
					if (!($blnFoundObj)) {
						if ($strFileRec.Contains('<Object class="com.sunopsis.dwg.dbobj.' + $strClassName + '">')) {
							# Find the ID attribute for this object object. Examples: -
							# 	<Field name="ITxt" type="com.sunopsis.sql.DbInt"><![CDATA[2120]]></Field>
							$blnFoundObj = $True
							continue
						}
					}
					else {
						if ($strFileRec.Contains('</Object>')) {
							$blnFoundObj = $False
							continue
						}
						else {
							if ($strFileRec.Contains('<Field name="' + $strClassIDName + '" type="com.sunopsis.sql.DbInt"><![CDATA[')) {
								$strObjFullID = $strFileRec.Replace('<Field name="' + $strClassIDName + '" type="com.sunopsis.sql.DbInt"><![CDATA[',"")
								$strObjFullID = $strObjFullID.Replace(']]></Field>',"").Trim()
								$strObjFullLen = $strObjFullID.Length
								if ($strObjFullID.Length -lt 4) {
									write-host "$EM found strObjFullID <$strObjFullID> with length less than 4 characters"
									write-host "$EM file <$strFileToImport>"
									write-host "$EM record <$strFileRec>"
									write-host "$EM class name <$strClassName>"
									write-host "$EM ID attribute name <$strClassIDName>"
									return $False
								}
								$strObjID = $strObjFullID.Substring(0, ($strObjFullLen - 3))
								$strObjID = [int]::Parse($strObjID)
								$strObjRepoID = $strObjFullID.Substring(($strObjFullLen - 3), 3)
								
								if ($strObjRepoID -eq $env:ODI_SCM_ORACLEDI_REPOSITORY_ID) {
									if ($strObjID -gt $arrMasterRepoID[$intClassIdx]) {
										$arrMasterRepoID[$intClassIdx] = $strObjID
									}
								}
							}
						}
					}
				}
			}
		}
		else {
			if ($workRepoExtensions -contains "$strFileToImportNameClassName") {
				write-host "$IM analysing work repository code export file <$strFileName>"
				#
				# Look for each work repository class in the current file and in the file name.
				#
				for ($intClassIdx = 0; $intClassIdx -lt $workRepoClassNames.length; $intClassIdx++) {
					$strClassName = $workRepoClassNames[$intClassIdx]
					$strClassIDName = $workRepoClassIDNames[$intClassIdx]
					
					#
					# We only examine file names for object IDs if we're not using a set of consolidated files.
					#
					if (!($blnConsolidatedFilesList)) {
						if ($strFileToImport.EndsWith($strClassName)) {
							if ($strFileToImportRepoID -eq $env:ODI_SCM_ORACLEDI_REPOSITORY_ID) {
								if ($strFileToImportObjID -gt $arrWorkRepoID[$intClassIdx]) {
									$arrWorkRepoID[$intClassIdx] = $strFileToImportObjID
								}
							}
						}
					}
					
					$blnFoundObj = $False
					foreach ($strFileRec in $arrStrFileRecords) {
						if (!($blnFoundObj)) {
							if ($strFileRec.Contains('<Object class="com.sunopsis.dwg.dbobj.' + $strClassName + '">')) {
								# Find the ID attribute for this object object. Examples: -
								# 	<Field name="ITxt" type="com.sunopsis.sql.DbInt"><![CDATA[2120]]></Field>
								$blnFoundObj = $True
								continue
							}
						}
						else {
							if ($strFileRec.Contains('</Object>')) {
								$blnFoundObj = $False
								continue
							}
							else {
								if ($strFileRec.Contains('<Field name="' + $strClassIDName + '" type="com.sunopsis.sql.DbInt"><![CDATA[')) {
									$strObjFullID = $strFileRec.Replace('<Field name="' + $strClassIDName + '" type="com.sunopsis.sql.DbInt"><![CDATA[',"")
									$strObjFullID = $strObjFullID.Replace(']]></Field>',"").Trim()
									$strObjFullLen = $strObjFullID.Length
									if ($strObjFullID.Length -lt 4) {
										write-host "$EM found strObjFullID <$strObjFullID> with length less than 4 characters"
										write-host "$EM file <$strFileToImport>"
										write-host "$EM record <$strFileRec>"
										write-host "$EM class name <$strClassName>"
										write-host "$EM ID attribute name <$strClassIDName>"
										return $False
									}
									$strObjID = $strObjFullID.Substring(0, ($strObjFullLen - 3))
									$strObjID = [int]::Parse($strObjID)
									$strObjRepoID = $strObjFullID.Substring(($strObjFullLen - 3), 3)
									
									if ($strObjRepoID -eq $env:ODI_SCM_ORACLEDI_REPOSITORY_ID) {
										if ($strObjID -gt $arrWorkRepoID[$intClassIdx]) {
											$arrWorkRepoID[$intClassIdx] = $strObjID
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	#
	# Build the SQL to update the SNP_ENT_ID table.
	#
	for ($intClassIdx = 0; $intClassIdx -lt $masterRepoClassNames.length; $intClassIdx++) {
		$strClassName = $masterRepoClassNames[$intClassIdx]
		$intOutID = $arrMasterRepoID[$intClassIdx]
		###write-host "$DEBUG highest ID found for class <$strClassName> is <$intOutID>"
		if ($arrMasterRepoID[$intClassIdx] -ne -1) {
			$SqlText += "MERGE" + [Environment]::NewLine
			$SqlText += " INTO snp_ent_id t" + [Environment]::NewLine
			$SqlText += "USING (" + [Environment]::NewLine
			$SqlText += "      SELECT '" + $masterRepoClassTableNames[$intClassIdx] + "'" + [Environment]::NewLine
			$SqlText += "                 AS id_tbl" + [Environment]::NewLine
			$SqlText += "           , " + $intOutID + [Environment]::NewLine
			$SqlText += "                 AS id_next" + [Environment]::NewLine
			$SqlText += "           , 1" + [Environment]::NewLine
			$SqlText += "                 AS id_seq" + [Environment]::NewLine
			$SqlText += "        FROM dual" + [Environment]::NewLine
			$SqlText += "      ) s" + [Environment]::NewLine
			$SqlText += "   ON (t.id_tbl = s.id_tbl)" + [Environment]::NewLine
			$SqlText += " WHEN MATCHED" + [Environment]::NewLine
			$SqlText += " THEN UPDATE" + [Environment]::NewLine
			$SqlText += "         SET t.id_next = s.id_next" + [Environment]::NewLine
			$SqlText += "       WHERE s.id_next > t.id_next" + [Environment]::NewLine
			$SqlText += " WHEN NOT MATCHED" + [Environment]::NewLine
			$SqlText += " THEN INSERT (id_seq, id_tbl, id_next)" + [Environment]::NewLine
			$SqlText += "      VALUES (s.id_seq, s.id_tbl, s.id_next)" + [Environment]::NewLine
			$SqlText += "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine
			$SqlText += "" + [Environment]::NewLine
		}
	}
	
	#
	# Build the SQL to update the SNP_ID table.
	#
	# We need to merge values for SnpTxt/SnpTxtHeader and SnpExpTxt/SnpExpTxtHeader.
	#
	$intExpTxtID = -1
	$intTxtID = -1
	
	for ($intClassIdx = 0; $intClassIdx -lt $workRepoClassNames.length; $intClassIdx++) {
		if (($workRepoClassNames[$intClassIdx] -eq "SnpExpTxt") -or ($workRepoClassNames[$intClassIdx] -eq "SnpExpTxtHeader")) {
			if ($arrWorkRepoID[$intClassIdx] -gt $intExpTxtID) {
				$intExpTxtID = $arrWorkRepoID[$intClassIdx]
			}
		}
	}
	
	for ($intClassIdx = 0; $intClassIdx -lt $workRepoClassNames.length; $intClassIdx++) {
		if (($workRepoClassNames[$intClassIdx] -eq "SnpTxt") -or ($workRepoClassNames[$intClassIdx] -eq "SnpTxtHeader")) {
			if ($arrWorkRepoID[$intClassIdx] -gt $intTxtID) {
				$intTxtID = $arrWorkRepoID[$intClassIdx]
			}
		}
	}
	
	for ($intClassIdx = 0; $intClassIdx -lt $workRepoClassNames.length; $intClassIdx++) {
		$strClassName = $workRepoClassNames[$intClassIdx]
		
		if (($strClassName -eq "SnpExpTxt") -or ($strClassName -eq "SnpExpTxtHeader")) {
			$intOutID = $intExpTxtID
		}
		else {
			if (($strClassName -eq "SnpTxt") -or ($strClassName -eq "SnpTxtHeader")) {
				$intOutID = $intTxtID
			}
			else {
				$intOutID = $arrWorkRepoID[$intClassIdx]
			}
		}
		###write-host "$DEBUG highest ID found for class <$strClassName> is <$intOutID>"
		if ($intOutID -ne -1) {
			$SqlText += "MERGE" + [Environment]::NewLine
			$SqlText += " INTO snp_id t" + [Environment]::NewLine
			$SqlText += "USING (" + [Environment]::NewLine
			$SqlText += "      SELECT '" + $workRepoClassTableNames[$intClassIdx] + "'" + [Environment]::NewLine
			$SqlText += "                 AS id_tbl" + [Environment]::NewLine
			$SqlText += "           , " + $intOutID + [Environment]::NewLine
			$SqlText += "                 AS id_next" + [Environment]::NewLine
			$SqlText += "           , 1" + [Environment]::NewLine
			$SqlText += "                 AS id_seq" + [Environment]::NewLine
			$SqlText += "        FROM dual" + [Environment]::NewLine
			$SqlText += "      ) s" + [Environment]::NewLine
			$SqlText += "   ON (t.id_tbl = s.id_tbl)" + [Environment]::NewLine
			$SqlText += " WHEN MATCHED" + [Environment]::NewLine
			$SqlText += " THEN UPDATE" + [Environment]::NewLine
			$SqlText += "         SET t.id_next = s.id_next" + [Environment]::NewLine
			$SqlText += "       WHERE s.id_next > t.id_next" + [Environment]::NewLine
			$SqlText += " WHEN NOT MATCHED" + [Environment]::NewLine
			$SqlText += " THEN INSERT (id_seq, id_tbl, id_next)" + [Environment]::NewLine
			$SqlText += "      VALUES (s.id_seq, s.id_tbl, s.id_next)" + [Environment]::NewLine
			$SqlText += "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine
			$SqlText += "" + [Environment]::NewLine
		}
	}
	
	$SqlText += "COMMIT" + [Environment]::NewLine
	$SqlText += "<OdiScmGenerateSqlStatementDelimiter>" + [Environment]::NewLine
	
	$SqlText | out-file -filepath $OdiScmPreImpMergeSnpIDsSql -encoding ASCII
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

function GenerateDdlImportScript ([array] $arrStrFiles) {
	
	$FN = "GenerateDdlImportScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG"
	
	write-host "$IM starts"
	
	write-host "$IM passed <$($arrStrFiles.length)> files to import"
	write-host "$IM writing output to <$DdlImportScriptFile>"
	
	$OutScriptContent = @()
	$OutScriptContent += '@echo off'
	$OutScriptContent += ''
	$OutScriptContent += 'if "%ODI_SCM_HOME%" == "" ('
	$OutScriptContent += '	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME'
	$OutScriptContent += '	goto ExitFail'
	$OutScriptContent += ')'
	$OutScriptContent += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0'
	$OutScriptContent += 'echo %IM% starts'
	$OutScriptContent += ''
	$OutScriptContent += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*'
	$OutScriptContent += 'if ERRORLEVEL 1 ('
	$OutScriptContent += '	echo %EM% processing script arguments 1>&2'
	$OutScriptContent += '	goto ExitFail'
	$OutScriptContent += ')'
	$OutScriptContent += ''
	$OutScriptContent += 'set OLDPWD=%CD%'
	
	$intFileErrors = 0
	$intMaxTierInt = 0
	
	#
	# Find the highest tier number in the list of files.
	#
	foreach ($strFile in $arrStrFiles) {
		
		if ($strFile -eq "" -or $strFile -eq $Null) {
			write-host "$EM DDL source file path/name is invalid"
			return $False
		}
		
		$strFileName = split-path $strFile -leaf
		
		$arrStrFileNameParts = $strFileName.split("-")
		$strTierNumber = $arrStrFileNameParts[3]
		
		if (!($strTierNumber.startswith("t"))) {
			write-host "$EM DDL script file <$strFile> has unrecognised tier string prefix <$strTierNumber>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strTierInt = $strTierNumber.substring(1)
		if (($strTierInt -as [int]) -eq $Null) {
			write-host "$EM DDL script file <$strFile> has unrecognised tier number <$strTierInt>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if ($strTierInt -gt $intMaxTierInt) {
			$intMaxTierInt = $strTierInt
		}
	}
	
	if ($intFileErrors -gt 0) {
		write-host "$EM total errors encountered whilst identifying maximum tier number <$intFileErrors>"
		return $False
	}
	
	write-host "$IM highest DDL script tier number found <$intMaxTierInt>"
	
	#
	# Sort the files into ascending tier order.
	#
	write-host "$IM sorting DDL files into tier number order"
	
	$arrTieredFiles = @()
	
	for ($intCurrTier = 0; $intCurrTier -le $intMaxTierInt; $intCurrTier++) {
		
		$intTierFileCount = 0
		
		foreach ($strFile in $arrStrFiles) {
			
			if ($strFile -eq "" -or $strFile -eq $Null) {
				write-host "$EM DDL source file path/name is invalid"
				return $False
			}
			
			$strFileName = split-path $strFile -leaf
			$arrStrFileNameParts = $strFileName.split("-")
			$strTierNumber = $arrStrFileNameParts[3]
			$strTierInt = $strTierNumber.substring(1)
			
			if ($strTierInt -eq $intCurrTier) {
				$arrTieredFiles += $strFile
				$intTierFileCount++
			}
		}
		write-host "$IM found <$intTierFileCount> tier <$intCurrTier> DDL script files"
	}
	
	write-host "$IM building output script content"
	$intFileErrors = 0
	
	foreach ($strFile in $arrTieredFiles) {
		
		$strFileName = split-path $strFile -leaf
		write-host "$IM processing file <$strFileName>"
		$arrStrFileNameParts = $strFileName.split("-")
		
		#
		# Extract the file name parts and validate them.
		#
		$strDdlPrefix = $arrStrFileNameParts[0]
		$strScopeType = $arrStrFileNameParts[1]
		$strLogicalSchemaName = $arrStrFileNameParts[2]
		$strTierNumber = $arrStrFileNameParts[3]
		$strRemainder = $arrStrFileNameParts[4]
		
		if ($strRemainder -eq $Null) {
			write-host "$IM cannot split file name for file <$strFile>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$arrStrRemainderParts = $strRemainder.split(".")
		$arrStrRemainderMain = $arrStrRemainderParts[0]
		$arrStrRemainderExtension = $arrStrRemainderParts[1]
		
		if ($strDdlPrefix -ne "ddl") {
			write-host "$EM DDL script file <$strFile> does not have expected name <ddl> prefix"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if (($strScopeType -ne "schema") -and ($strScopeType -ne "obj")) {
			write-host "$EM DDL script file <$strFile> does not have recognised scope type <schema | obj> prefix"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if ($arrStrRemainderExtension -ne "sql") {
			write-host "$EM file <$strFile> does not have expected name <sql> extension"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		#
		# Get the logical schema's physical mapping details from the corresponding environment variable.
		#
		$strLogicalSchemaEnvMapping = [Environment]::GetEnvironmentVariable("ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_" + $strLogicalSchemaName)
		
		if (($strLogicalSchemaEnvMapping -eq "") -or ($strLogicalSchemaEnvMapping -eq $Null)) {
			write-host "$EM no value found for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strLogicalSchemaEnvMappingParts = $strLogicalSchemaEnvMapping.split("+")
		$strDataServerKeyName = $strLogicalSchemaEnvMappingParts[0]
		$strDataServerKeyValue = $strLogicalSchemaEnvMappingParts[1]
		
		if ($strDataServerKeyName -ne "Data Server") {
			write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			write-host "$EM expected <Data Server> in field position <1> but found <$strDataServerKeyName>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if (($strDataServerKeyValue -eq "") -or ($strDataServerKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			write-host "$EM no value found for data server variable name in field position <2>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strDatabaseKeyName = $strLogicalSchemaEnvMappingParts[2]
		$strDatabaseKeyValue = $strLogicalSchemaEnvMappingParts[3]
		
		if (($strDatabaseKeyName -ne "") -and ($strDatabaseKeyName -ne $Null)) {
			if ($strDatabaseKeyName -ne "Database") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Database> in field position <3> but found <$strDatabaseKeyName>"
				$intFileErrors += 1
				#DebuggingPause
				continue
			}
		}
		
		$strDefPhysSchemaKeyName = $strLogicalSchemaEnvMappingParts[4]
		$strDefPhysSchemaKeyValue = $strLogicalSchemaEnvMappingParts[5]
		
		if (($strDefPhysSchemaKeyName -ne "") -and ($strDefPhysSchemaKeyName -ne $Null)) {
			if ($strDefPhysSchemaKeyName -ne "Schema") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Schema> in field position <5> but found <$strDefPhysSchemaKeyName>"
				$intFileErrors += 1
				#DebuggingPause
				continue
			}
		}
		
		$strTokensKeysName = $strLogicalSchemaEnvMappingParts[6]
		$strTokensKeysValue = $strLogicalSchemaEnvMappingParts[7]
		
		if (($strTokensKeysName -ne "") -and ($strTokensKeysName -ne $Null)) {
			if ($strTokensKeysName -ne "Token Values") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Token Values> in field position <5> but found <$strTokensKeysName>"
				$intFileErrors += 1
				#DebuggingPause
				continue
			}
		}
		
		#
		# Read the DDL script and replace any tokens specified in the environment variable.
		#
		$arrDdlScriptContent = get-content -path $strFile
		#$arrStrOutDdlScriptContent = @()
		
		if (($strTokensKeysValue -ne "") -and ($strTokensKeysValue -ne $Null)) {
			
			$arrStrTokensKeyValuePairs = $strTokensKeysValue.split("/")
			
			foreach ($strTokensKeyValuePair in $arrStrTokensKeyValuePairs) {
				#write-host "$DEBUG processing token key/value pair <$strTokensKeyValuePair>"
				$arrStrTokensKeyValuePairsParts = $strTokensKeyValuePair.split("=")
				$strTokensKeyValuePairsPartsKeyName = $arrStrTokensKeyValuePairsParts[0]
				$strTokensKeyValuePairsPartsKeyValue = $arrStrTokensKeyValuePairsParts[1]
				
				$arrDdlScriptContent = $arrDdlScriptContent -replace "\$strTokensKeyValuePairsPartsKeyName", $strTokensKeyValuePairsPartsKeyValue
				#foreach ($strDdlScriptLine in $arrDdlScriptContent) {
					#write-host "$DEBUG doing input script line <$strDdlScriptLine>"
					#if ($strDdlScriptLine.contains($strTokensKeyValuePairsPartsKeyName)) {
						#write-host "$IM replacing token in file <$strFile>"
						#write-host "$IM token <$strTokensKeyValuePairsPartsKeyName> value <$strTokensKeyValuePairsPartsKeyValue>"
					#}
					#$arrStrOutDdlScriptContent = $arrDdlScriptContent -replace $strTokensKeyValuePairsPartsKeyName, $strTokensKeyValuePairsPartsKeyValue
					
					#$arrStrOutDdlScriptContent += ($strDdlScriptLine.replace($strTokensKeyValuePairsPartsKeyName, $strTokensKeyValuePairsPartsKeyValue))
				#}
			}
		}
		
		#
		# Write the modified script content.
		#
		$strOutFile = $GenScriptDbObjsDir + "\" + "substituted_" + $strFileName
		set-content -path $strOutFile -value $arrDdlScriptContent
		
		#
		# Get the logical schema's physical data server details from the corresponding environment variable.
		#
		$strDataServer = [Environment]::GetEnvironmentVariable("ODI_SCM_DATA_SERVERS_" + $strDataServerKeyValue)
		
		if (($strDataServer -eq "") -or ($strDataServer -eq $Null)) {
			write-host "$EM no value found for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		#
		# Extract the data server field values and validate them.
		#
		$arrStrDataServerParts = $strDataServer.split("+")
		$strDbmsTypeKeyName = $arrStrDataServerParts[0]
		$strDbmsTypeKeyValue = $arrStrDataServerParts[1]
		
		if ($strDbmsTypeKeyName -ne "DBMS Type") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <DBMS Type> in field position <1> but found <$strDbmsTypeKeyName>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if (($strDataServerKeyValue -eq "") -or ($strDataServerKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for DBMS type name in field position <2>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strJdbcUrlKeyName = $arrStrDataServerParts[2]
		$strJdbcUrlKeyValue = $arrStrDataServerParts[3]
		
		if ($strJdbcUrlKeyName -ne "JDBC URL") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <JDBC URL> in field position <3> but found <$strJdbcUrlKeyName>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if (($strJdbcUrlKeyValue -eq "") -or ($strJdbcUrlKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for JDBC URL in field position <4>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strUserNameKeyName = $arrStrDataServerParts[4]
		$strUserNameKeyValue = $arrStrDataServerParts[5]
		
		if ($strUserNameKeyName -ne "User Name") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <User Name> in field position <5> but found <$strUserNameKeyName>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if (($strUserNameKeyValue -eq "") -or ($strUserNameKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for user name in field position <6>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strPasswordKeyName = $arrStrDataServerParts[6]
		$strPasswordKeyValue = $arrStrDataServerParts[7]
		
		if ($strPasswordKeyName -ne "Password") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <Password> in field position <7> but found <$strPasswordKeyName>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if (($strPasswordKeyValue -eq "") -or ($strPasswordKeyValue -eq $Null)) {
			write-host "$WM no value found for password in field position <8> for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
		}
		
		if ($strScopeType -eq "schema") {
			#
			# Add the output script command to tear down the database schema.
			#
			$OutScriptContent += 'echo %IM% date ^<%date%^> time ^<%time%^>'
			
			$strDbContainerName = ""
			if ($strDatabaseKeyValue -ne "" -and $strDatabaseKeyValue -ne $Null) {
				$strDbContainerName = $strDatabaseKeyValue
			}
			if ($strDefPhysSchemaKeyValue -ne "" -and $strDefPhysSchemaKeyValue -ne $Null) {
				if ($strDbContainerName -ne "") {
					$strDbContainerName += "."
				}
				$strDbContainerName += $strDatabaseKeyValue
			}
			
			$OutScriptContent += ('set MSG=tearing down database environment ^^^<' + $strDbContainerName + '@' + $strJdbcUrlKeyValue + '^^^>')
			$OutScriptContent += 'echo %IM% %MSG%'
			
			$strCmd =  'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownDatabaseSchema.bat" /p '
			$strCmd += '"' + $strDbmsTypeKeyValue + '" "' + $strUserNameKeyValue + '" "' + $strPasswordKeyValue + '" "' + $strJdbcUrlKeyValue + '" '
			$strCmd += '"' + $strDatabaseKeyValue + '" "' + $strDefPhysSchemaKeyValue + '"'
			
			$OutScriptContent += $strCmd
			$OutScriptContent += 'if ERRORLEVEL 1 ('
			$OutScriptContent += '	goto ExitFail'
			$OutScriptContent += ')'
			$OutScriptContent += ''
			$OutScriptContent += 'echo %IM% database tearDown completed succcessfully'
			$OutScriptContent += ''
			
			#
			# Add the output script command to set up the database environment.
			#
			$OutScriptContent += 'echo %IM% date ^<%date%^> time ^<%time%^>'
			$OutScriptContent += ('set MSG=setting up database environment ^^^<' + $strDbContainerName + '@' + $strJdbcUrlKeyValue + '^^^>')
		}
		else {
			$OutScriptContent += 'echo %IM% date ^<%date%^> time ^<%time%^>'
			$OutScriptContent += ('set MSG=executing object creation DDL script ^^^<' + $strOutFile + '^^^>')
		}
		
		$OutScriptContent += 'echo %IM% %MSG%'
		$strCmd =  'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecDatabaseSqlScript.bat" /p '
		$strCmd += '"' + $strDbmsTypeKeyValue + '" "' + $strUserNameKeyValue + '" "' + $strPasswordKeyValue + '" "' + $strJdbcUrlKeyValue + '" '
		$strCmd += '"' + $strDatabaseKeyValue + '" "' + $strDefPhysSchemaKeyValue + '" "' + $strOutFile + '" "True"'
		
		$OutScriptContent += $strCmd
		$OutScriptContent += 'if ERRORLEVEL 1 ('
		$OutScriptContent += '	goto ExitFail'
		$OutScriptContent += ')'
		$OutScriptContent += ''
		$OutScriptContent += 'echo %IM% DDL script execution completed succcessfully'
		$OutScriptContent += ''
	}
	
	write-host "$IM total errors encountered <$intFileErrors>"
	if ($intFileErrors -gt 0) {
		return $False
	}
	
	#
	# Script termination commands - the common Exit labels.
	#
	$OutScriptContent += ':ExitOk'
	$OutScriptContent += 'cd /d %OLDPWD%'
	$OutScriptContent += 'echo %IM% ends'
	$OutScriptContent += 'exit %IsBatchExit% 0'
	$OutScriptContent += ''
	$OutScriptContent += ':ExitFail'
	$OutScriptContent += 'echo %EM% %MSG%'
	$OutScriptContent += 'cd /d %OLDPWD%'
	$OutScriptContent += 'echo %EM% ends'
	$OutScriptContent += 'exit %IsBatchExit% 1'
	
	set-content -path $DdlImportScriptFile -value $OutScriptContent
	
	write-host "$IM ends"
	return $True
}

function GenerateSplImportScript ([array] $arrStrFiles) {
	
	$FN = "GenerateSplImportScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG"
	
	write-host "$IM starts"
	
	write-host "$IM passed <$($arrStrFiles.length)> files to import"
	write-host "$IM writing output to <$SplImportScriptFile>"
	
	$OutScriptContent = @()
	$OutScriptContent += '@echo off'
	$OutScriptContent += ''
	$OutScriptContent += 'if "%ODI_SCM_HOME%" == "" ('
	$OutScriptContent += '	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME'
	$OutScriptContent += '	goto ExitFail'
	$OutScriptContent += ')'
	$OutScriptContent += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0'
	$OutScriptContent += 'echo %IM% starts'
	$OutScriptContent += ''
	$OutScriptContent += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*'
	$OutScriptContent += 'if ERRORLEVEL 1 ('
	$OutScriptContent += '	echo %EM% processing script arguments 1>&2'
	$OutScriptContent += '	goto ExitFail'
	$OutScriptContent += ')'
	$OutScriptContent += ''
	$OutScriptContent += 'set OLDPWD=%CD%'
	
	$intFileErrors = 0
	$intMaxTierInt = 0
	
	#
	# Find the highest tier number in the list of files.
	#
	foreach ($strFile in $arrStrFiles) {
		
		$strFileName = split-path $strFile -leaf
		
		$arrStrFileNameParts = $strFileName.split("-")
		$strTierNumber = $arrStrFileNameParts[3]
		
		if (!($strTierNumber.startswith("t"))) {
			write-host "$EM SPL script file <$strFile> has unrecognised tier string prefix <$strTierNumber>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strTierInt = $strTierNumber.substring(1)
		if (($strTierInt -as [int]) -eq $Null) {
			write-host "$EM SPL script file <$strFile> has unrecognised tier number <$strTierInt>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if ($strTierInt -gt $intMaxTierInt) {
			$intMaxTierInt = $strTierInt
		}
	}
	
	if ($intFileErrors -gt 0) {
		write-host "$EM total errors encountered whilst identifying maximum tier number <$intFileErrors>"
		return $False
	}
	
	#
	# Sort the files into ascending tier order.
	#
	$arrTieredFiles = @()
	
	for ($intCurrTier = 0; $intCurrTier -le $intMaxTierInt; $intCurrTier++) {
	
		foreach ($strFile in $arrStrFiles) {
		
			$strFileName = split-path $strFile -leaf
			$arrStrFileNameParts = $strFileName.split("-")
			$strTierNumber = $arrStrFileNameParts[3]
			$strTierInt = $strTierNumber.substring(1)
			
			if ($strTierInt -eq $intCurrTier) {
				$arrTieredFiles += $strFile
			}
		}
	}
	
	$intFileErrors = 0
	
	foreach ($strFile in $arrTieredFiles) {
		
		$strFileName = split-path $strFile -leaf
		write-host "$IM processing file <$strFileName>"
		$arrStrFileNameParts = $strFileName.split("-")
		
		#
		# Extract the file name parts and validate them.
		#
		$strPrefix = $arrStrFileNameParts[0]
		$strScopeType = $arrStrFileNameParts[1]
		$strLogicalSchemaName = $arrStrFileNameParts[2]
		$strTierNumber = $arrStrFileNameParts[3]
		$strRemainder = $arrStrFileNameParts[4]
		$arrStrRemainderParts = $strRemainder.split(".")
		$arrStrRemainderMain = $arrStrRemainderParts[0]
		$arrStrRemainderExtension = $arrStrRemainderParts[1]
		
		if ($strPrefix -ne "spl") {
			write-host "$EM SPL script file <$strFile> does not have expected name <spl> prefix"
			$intFileErrors += 1
			continue
		}
		
		if (($strScopeType -ne "schema") -and ($strScopeType -ne "obj")) {
			write-host "$EM SPL script file <$strFile> does not have recognised scope type <schema | obj> prefix"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if ($arrStrRemainderExtension -ne "sql") {
			write-host "$EM file <$strFile> does not have expected name <sql> extension"
			$intFileErrors += 1
			continue
		}
		
		#
		# Get the logical schema's physical mapping details from the corresponding environment variable.
		#
		$strLogicalSchemaEnvMapping = [Environment]::GetEnvironmentVariable("ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_" + $strLogicalSchemaName)
		
		if (($strLogicalSchemaEnvMapping -eq "") -or ($strLogicalSchemaEnvMapping -eq $Null)) {
			write-host "$EM no value found for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			$intFileErrors += 1
			continue
		}
		
		$strLogicalSchemaEnvMappingParts = $strLogicalSchemaEnvMapping.split("+")
		$strDataServerKeyName = $strLogicalSchemaEnvMappingParts[0]
		$strDataServerKeyValue = $strLogicalSchemaEnvMappingParts[1]
		
		if ($strDataServerKeyName -ne "Data Server") {
			write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			write-host "$EM expected <Data Server> in field position <1> but found <$strDataServerKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strDataServerKeyValue -eq "") -or ($strDataServerKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			write-host "$EM no value found for data server variable name in field position <2>"
			$intFileErrors += 1
			continue
		}
		
		$strDatabaseKeyName = $strLogicalSchemaEnvMappingParts[2]
		$strDatabaseKeyValue = $strLogicalSchemaEnvMappingParts[3]
		
		if (($strDatabaseKeyName -ne "") -and ($strDatabaseKeyName -ne $Null)) {
			if ($strDatabaseKeyName -ne "Database") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Database> in field position <3> but found <$strDatabaseKeyName>"
				$intFileErrors += 1
				continue
			}
		}
		
		$strDefPhysSchemaKeyName = $strLogicalSchemaEnvMappingParts[4]
		$strDefPhysSchemaKeyValue = $strLogicalSchemaEnvMappingParts[5]
		
		if (($strDefPhysSchemaKeyName -ne "") -and ($strDefPhysSchemaKeyName -ne $Null)) {
			if ($strDefPhysSchemaKeyName -ne "Schema") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Schema> in field position <5> but found <$strDefPhysSchemaKeyName>"
				$intFileErrors += 1
				continue
			}
		}
		
		$strTokensKeysName = $strLogicalSchemaEnvMappingParts[6]
		$strTokensKeysValue = $strLogicalSchemaEnvMappingParts[7]
		
		if (($strTokensKeysName -ne "") -and ($strTokensKeysName -ne $Null)) {
			if ($strTokensKeysName -ne "Token Values") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Token Values> in field position <5> but found <$strTokensKeysName>"
				$intFileErrors += 1
				continue
			}
		}
		
		#
		# Read the SPL script and replace any tokens specified in the environment variable.
		#
		$arrScriptContent = get-content -path $strFile
		#$arrStrOutScriptContent = @()
		
		if (($strTokensKeysValue -ne "") -and ($strTokensKeysValue -ne $Null)) {
			
			$arrStrTokensKeyValuePairs = $strTokensKeysValue.split("/")
			
			foreach ($strTokensKeyValuePair in $arrStrTokensKeyValuePairs) {
				
				$arrStrTokensKeyValuePairsParts = $strTokensKeyValuePair.split("=")
				$strTokensKeyValuePairsPartsKeyName = $arrStrTokensKeyValuePairsParts[0]
				$strTokensKeyValuePairsPartsKeyValue = $arrStrTokensKeyValuePairsParts[1]
				
				$arrScriptContent = $arrScriptContent -replace "\$strTokensKeyValuePairsPartsKeyName", $strTokensKeyValuePairsPartsKeyValue
				
				#foreach ($strScriptLine in $arrScriptContent) {
				#	if ($strScriptLine.contains($strTokensKeyValuePairsPartsKeyName)) {
				#		write-host "$IM replacing token in file <$strFile>"
				#		write-host "$IM token <$strTokensKeyValuePairsPartsKeyName> value <$strTokensKeyValuePairsPartsKeyValue>"
				#	}
					#$arrStrOutScriptContent += ($strScriptLine.replace($strTokensKeyValuePairsPartsKeyName, $strTokensKeyValuePairsPartsKeyValue))
				#}
			}
		}
		
		#
		# Write the modified script content.
		#
		$strOutFile = $GenScriptDbObjsDir + "\" + "substituted_" + $strFileName
		set-content -path $strOutFile -value $arrScriptContent
		
		#
		# Get the logical schema's physical data server details from the corresponding environment variable.
		#
		$strDataServer = [Environment]::GetEnvironmentVariable("ODI_SCM_DATA_SERVERS_" + $strDataServerKeyValue)
		
		if (($strDataServer -eq "") -or ($strDataServer -eq $Null)) {
			write-host "$EM no value found for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			$intFileErrors += 1
			continue
		}
		
		#
		# Extract the data server field values and validate them.
		#
		$arrStrDataServerParts = $strDataServer.split("+")
		$strDbmsTypeKeyName = $arrStrDataServerParts[0]
		$strDbmsTypeKeyValue = $arrStrDataServerParts[1]
		
		if ($strDbmsTypeKeyName -ne "DBMS Type") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <DBMS Type> in field position <1> but found <$strDbmsTypeKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strDataServerKeyValue -eq "") -or ($strDataServerKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for DBMS type name in field position <2>"
			$intFileErrors += 1
			continue
		}
		
		$strJdbcUrlKeyName = $arrStrDataServerParts[2]
		$strJdbcUrlKeyValue = $arrStrDataServerParts[3]
		
		if ($strJdbcUrlKeyName -ne "JDBC URL") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <JDBC URL> in field position <3> but found <$strJdbcUrlKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strJdbcUrlKeyValue -eq "") -or ($strJdbcUrlKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for JDBC URL in field position <4>"
			$intFileErrors += 1
			continue
		}
		
		$strUserNameKeyName = $arrStrDataServerParts[4]
		$strUserNameKeyValue = $arrStrDataServerParts[5]
		
		if ($strUserNameKeyName -ne "User Name") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <User Name> in field position <5> but found <$strUserNameKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strUserNameKeyValue -eq "") -or ($strUserNameKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for user name in field position <6>"
			$intFileErrors += 1
			continue
		}
		
		$strPasswordKeyName = $arrStrDataServerParts[6]
		$strPasswordKeyValue = $arrStrDataServerParts[7]
		
		if ($strPasswordKeyName -ne "Password") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <Password> in field position <7> but found <$strPasswordKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strPasswordKeyValue -eq "") -or ($strPasswordKeyValue -eq $Null)) {
			write-host "$WM no value found for password in field position <8> for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
		}
	
	# For now, treat all SPL scripts as schema wide (until we can rename the scripts in source control!)
	$strScopeType = "schema"
	if ($strScopeType -eq "schema") {
			#
			# Add the output script command to tear down the database schema.
			#
			$OutScriptContent += 'echo %IM% date ^<%date%^> time ^<%time%^>'
			
			$strDbContainerName = ""
			if ($strDatabaseKeyValue -ne "" -and $strDatabaseKeyValue -ne $Null) {
				$strDbContainerName = $strDatabaseKeyValue
			}
			if ($strDefPhysSchemaKeyValue -ne "" -and $strDefPhysSchemaKeyValue -ne $Null) {
				if ($strDbContainerName -ne "") {
					$strDbContainerName += "."
				}
				$strDbContainerName += $strDatabaseKeyValue
			}
			
			$OutScriptContent += ('set MSG=tearing down database environment ^^^<' + $strDbContainerName + '@' + $strJdbcUrlKeyValue + '^^^>')
			$OutScriptContent += 'echo %IM% %MSG%'
			
			$strCmd =  'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmTearDownDatabaseSchema.bat" /p '
			$strCmd += '"' + $strDbmsTypeKeyValue + '" "' + $strUserNameKeyValue + '" "' + $strPasswordKeyValue + '" "' + $strJdbcUrlKeyValue + '" '
			$strCmd += '"' + $strDatabaseKeyValue + '" "' + $strDefPhysSchemaKeyValue + '"'
			
			$OutScriptContent += $strCmd
			$OutScriptContent += 'if ERRORLEVEL 1 ('
			$OutScriptContent += '	goto ExitFail'
			$OutScriptContent += ')'
			$OutScriptContent += ''
			$OutScriptContent += 'echo %IM% database tearDown completed succcessfully'
			$OutScriptContent += ''
			
			#
			# Add the output script command to set up the database environment.
			#
			$OutScriptContent += 'echo %IM% date ^<%date%^> time ^<%time%^>'
			$OutScriptContent += ('set MSG=setting up database environment ^^^<' + $strDbContainerName + '@' + $strJdbcUrlKeyValue + '^^^>')
		}
		else {
			$OutScriptContent += 'echo %IM% date ^<%date%^> time ^<%time%^>'
			$OutScriptContent += ('set MSG=executing object creation DDL script ^^^<' + $strOutFile + '^^^>')
		}
		
		$OutScriptContent += ('set MSG=executing object creation SPL script ^^^<' + $strOutFile + '^^^>')
		$OutScriptContent += 'echo %IM% %MSG%'
		$strCmd =  'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecDatabaseSqlScript.bat" '
		$strCmd += '"' + $strDbmsTypeKeyValue + '" "' + $strUserNameKeyValue + '" "' + $strPasswordKeyValue + '" "' + $strJdbcUrlKeyValue + '" '
		$strCmd += '"' + $strDatabaseKeyValue + '" "' + $strDefPhysSchemaKeyValue + '" "' + $strOutFile + '" "True"'
		
		$OutScriptContent += $strCmd
		$OutScriptContent += 'if ERRORLEVEL 1 ('
		$OutScriptContent += '	goto ExitFail'
		$OutScriptContent += ')'
		$OutScriptContent += ''
		$OutScriptContent += 'echo %IM% SPL script execution completed succcessfully'
		$OutScriptContent += ''
	}
	
	if ($intFileErrors -gt 0) {
		write-host "$EM total errors encountered <$intFileErrors>"
		return $False
	}
	
	#
	# Script termination commands - the common Exit labels.
	#
	$OutScriptContent += ':ExitOk'
	$OutScriptContent += 'cd /d %OLDPWD%'
	$OutScriptContent += 'echo %IM% ends'
	$OutScriptContent += 'exit %IsBatchExit% 0'
	$OutScriptContent += ''
	$OutScriptContent += ':ExitFail'
	$OutScriptContent += 'echo %EM% %MSG%'
	$OutScriptContent += 'cd /d %OLDPWD%'
	$OutScriptContent += 'echo %EM% ends'
	$OutScriptContent += 'exit %IsBatchExit% 1'
	
	set-content -path $SplImportScriptFile -value $OutScriptContent
	
	write-host "$IM ends"
	return $True
}

function GenerateDmlExecutionScript ([array] $arrStrFiles) {
	
	$FN = "GenerateDmlExecutionScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG"
	
	write-host "$IM starts"
	
	write-host "$IM passed <$($arrStrFiles.length)> files to import"
	write-host "$IM writing output to <$DmlExecutionScriptFile>"
	
	$OutScriptContent = @()
	$OutScriptContent += '@echo off'
	$OutScriptContent += ''
	$OutScriptContent += 'if "%ODI_SCM_HOME%" == "" ('
	$OutScriptContent += '	echo OdiScm: ERROR no OdiScm home directory specified in environment variable ODI_SCM_HOME'
	$OutScriptContent += '	goto ExitFail'
	$OutScriptContent += ')'
	$OutScriptContent += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmSetMsgPrefixes.bat" %~0'
	$OutScriptContent += 'echo %IM% starts'
	$OutScriptContent += ''
	$OutScriptContent += 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmProcessScriptArgs.bat" %*'
	$OutScriptContent += 'if ERRORLEVEL 1 ('
	$OutScriptContent += '	echo %EM% processing script arguments 1>&2'
	$OutScriptContent += '	goto ExitFail'
	$OutScriptContent += ')'
	$OutScriptContent += ''
	$OutScriptContent += 'set OLDPWD=%CD%'
	
	$intFileErrors = 0
	$intMaxTierInt = 0
	
	#
	# Find the highest tier number in the list of files.
	#
	foreach ($strFile in $arrStrFiles) {
		
		$strFileName = split-path $strFile -leaf
		
		$arrStrFileNameParts = $strFileName.split("-")
		$strTierNumber = $arrStrFileNameParts[3]
		
		if (!($strTierNumber.startswith("t"))) {
			write-host "$EM DDL script file <$strFile> has unrecognised tier string prefix <$strTierNumber>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		$strTierInt = $strTierNumber.substring(1)
		if (($strTierInt -as [int]) -eq $Null) {
			write-host "$EM DDL script file <$strFile> has unrecognised tier number <$strTierInt>"
			$intFileErrors += 1
			#DebuggingPause
			continue
		}
		
		if ($strTierInt -gt $intMaxTierInt) {
			$intMaxTierInt = $strTierInt
		}
	}
	
	if ($intFileErrors -gt 0) {
		write-host "$EM total errors encountered whilst identifying maximum tier number <$intFileErrors>"
		return $False
	}
	
	#
	# Sort the files into ascending tier order.
	#
	$arrTieredFiles = @()
	
	for ($intCurrTier = 0; $intCurrTier -le $intMaxTierInt; $intCurrTier++) {
	
		foreach ($strFile in $arrStrFiles) {
		
			if ($strFile -eq $Null) {
				write-host "$IM doing file <$strFile> - but it's null!"
				return $False
			}
			$strFileName = split-path $strFile -leaf
			$arrStrFileNameParts = $strFileName.split("-")
			$strTierNumber = $arrStrFileNameParts[3]
			$strTierInt = $strTierNumber.substring(1)
			
			if ($strTierInt -eq $intCurrTier) {
				$arrTieredFiles += $strFile
			}
		}
	}
	
	$intFileErrors = 0
	
	foreach ($strFile in $arrTieredFiles) {
		
		$strFileName = split-path $strFile -leaf
		write-host "$IM processing file <$strFileName>"
		$arrStrFileNameParts = $strFileName.split("-")
		
		#
		# Extract the file name parts and validate them.
		#
		$strDmlPrefix = $arrStrFileNameParts[0]
		$strScopeType = $arrStrFileNameParts[1]
		$strLogicalSchemaName = $arrStrFileNameParts[2]
		$strTierNumber = $arrStrFileNameParts[3]
		$strRemainder = $arrStrFileNameParts[4]
		$arrStrRemainderParts = $strRemainder.split(".")
		$arrStrRemainderMain = $arrStrRemainderParts[0]
		$arrStrRemainderExtension = $arrStrRemainderParts[1]
		
		if ($strDmlPrefix -ne "dml") {
			write-host "$EM DML script file <$strFile> does not have expected name <dml> prefix"
			$intFileErrors += 1
			continue
		}
		
		if ($strScopeType -ne "schema") {
			write-host "$EM DML script file <$strFile> does not have recognised scope type <schema> prefix"
			$intFileErrors += 1
			continue
		}
		
		if ($arrStrRemainderExtension -ne "sql") {
			write-host "$EM file <$strFile> does not have expected name <sql> extension"
			$intFileErrors += 1
			continue
		}
		
		#
		# Get the logical schema's physical mapping details from the corresponding environment variable.
		#
		$strLogicalSchemaEnvMapping = [Environment]::GetEnvironmentVariable("ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_" + $strLogicalSchemaName)
		
		if (($strLogicalSchemaEnvMapping -eq "") -or ($strLogicalSchemaEnvMapping -eq $Null)) {
			write-host "$EM no value found for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			$intFileErrors += 1
			continue
		}
		
		$strLogicalSchemaEnvMappingParts = $strLogicalSchemaEnvMapping.split("+")
		$strDataServerKeyName = $strLogicalSchemaEnvMappingParts[0]
		$strDataServerKeyValue = $strLogicalSchemaEnvMappingParts[1]
		
		if ($strDataServerKeyName -ne "Data Server") {
			write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			write-host "$EM expected <Data Server> in field position <1> but found <$strDataServerKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strDataServerKeyValue -eq "") -or ($strDataServerKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
			write-host "$EM no value found for data server variable name in field position <2>"
			$intFileErrors += 1
			continue
		}
		
		$strDatabaseKeyName = $strLogicalSchemaEnvMappingParts[2]
		$strDatabaseKeyValue = $strLogicalSchemaEnvMappingParts[3]
		
		if (($strDatabaseKeyName -ne "") -and ($strDatabaseKeyName -ne $Null)) {
			if ($strDatabaseKeyName -ne "Database") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Database> in field position <3> but found <$strDatabaseKeyName>"
				$intFileErrors += 1
				continue
			}
		}
		
		$strDefPhysSchemaKeyName = $strLogicalSchemaEnvMappingParts[4]
		$strDefPhysSchemaKeyValue = $strLogicalSchemaEnvMappingParts[5]
		
		if (($strDefPhysSchemaKeyName -ne "") -and ($strDefPhysSchemaKeyName -ne $Null)) {
			if ($strDefPhysSchemaKeyName -ne "Schema") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Schema> in field position <5> but found <$strDefPhysSchemaKeyName>"
				$intFileErrors += 1
				continue
			}
		}
		
		$strTokensKeysName = $strLogicalSchemaEnvMappingParts[6]
		$strTokensKeysValue = $strLogicalSchemaEnvMappingParts[7]
		
		if (($strTokensKeysName -ne "") -and ($strTokensKeysName -ne $Null)) {
			if ($strTokensKeysName -ne "Token Values") {
				write-host "$EM invalid value for environment variable <ODI_SCM_LOGICAL_PHYSICAL_SCHEMA_MAPPINGS_${strLogicalSchemaName}>"
				write-host "$EM expected <Token Values> in field position <5> but found <$strTokensKeysName>"
				$intFileErrors += 1
				continue
			}
		}
		
		#
		# Read the DML script and replace any tokens specified in the environment variable.
		#
		$arrScriptContent = get-content -path $strFile
		$arrStrOutScriptContent = @()
		
		if (($strTokensKeysValue -ne "") -and ($strTokensKeysValue -ne $Null)) {
			
			$arrStrTokensKeyValuePairs = $strTokensKeysValue.split("/")
			
			foreach ($strTokensKeyValuePair in $arrStrTokensKeyValuePairs) {
				
				$arrStrTokensKeyValuePairsParts = $strTokensKeyValuePair.split("=")
				$strTokensKeyValuePairsPartsKeyName = $arrStrTokensKeyValuePairsParts[0]
				$strTokensKeyValuePairsPartsKeyValue = $arrStrTokensKeyValuePairsParts[1]
				
				$arrScriptContent = $arrScriptContent -replace "\$strTokensKeyValuePairsPartsKeyName", $strTokensKeyValuePairsPartsKeyValue
				
				# foreach ($strScriptLine in $arrScriptContent) {
					# if ($strScriptLine.contains($strTokensKeyValuePairsPartsKeyName)) {
						# write-host "$IM replacing token in file <$strFile>"
						# write-host "$IM token <$strTokensKeyValuePairsPartsKeyName> value <$strTokensKeyValuePairsPartsKeyValue>"
					# }
					# $arrStrOutScriptContent += ($strScriptLine.replace($strTokensKeyValuePairsPartsKeyName, $strTokensKeyValuePairsPartsKeyValue))
				# }
			}
		}
		
		#
		# Write the modified script content.
		#
		$strOutFile = $GenScriptDbObjsDir + "\" + "substituted_" + $strFileName
		set-content -path $strOutFile -value $arrScriptContent
		
		#
		# Get the logical schema's physical data server details from the corresponding environment variable.
		#
		$strDataServer = [Environment]::GetEnvironmentVariable("ODI_SCM_DATA_SERVERS_" + $strDataServerKeyValue)
		
		if (($strDataServer -eq "") -or ($strDataServer -eq $Null)) {
			write-host "$EM no value found for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			$intFileErrors += 1
			continue
		}
		
		#
		# Extract the data server field values and validate them.
		#
		$arrStrDataServerParts = $strDataServer.split("+")
		$strDbmsTypeKeyName = $arrStrDataServerParts[0]
		$strDbmsTypeKeyValue = $arrStrDataServerParts[1]
		
		if ($strDbmsTypeKeyName -ne "DBMS Type") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <DBMS Type> in field position <1> but found <$strDbmsTypeKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strDataServerKeyValue -eq "") -or ($strDataServerKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for DBMS type name in field position <2>"
			$intFileErrors += 1
			continue
		}
		
		$strJdbcUrlKeyName = $arrStrDataServerParts[2]
		$strJdbcUrlKeyValue = $arrStrDataServerParts[3]
		
		if ($strJdbcUrlKeyName -ne "JDBC URL") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <JDBC URL> in field position <3> but found <$strJdbcUrlKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strJdbcUrlKeyValue -eq "") -or ($strJdbcUrlKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for JDBC URL in field position <4>"
			$intFileErrors += 1
			continue
		}
		
		$strUserNameKeyName = $arrStrDataServerParts[4]
		$strUserNameKeyValue = $arrStrDataServerParts[5]
		
		if ($strUserNameKeyName -ne "User Name") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <User Name> in field position <5> but found <$strUserNameKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strUserNameKeyValue -eq "") -or ($strUserNameKeyValue -eq $Null)) {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM no value found for user name in field position <6>"
			$intFileErrors += 1
			continue
		}
		
		$strPasswordKeyName = $arrStrDataServerParts[6]
		$strPasswordKeyValue = $arrStrDataServerParts[7]
		
		if ($strPasswordKeyName -ne "Password") {
			write-host "$EM invalid value for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
			write-host "$EM expected <Password> in field position <7> but found <$strPasswordKeyName>"
			$intFileErrors += 1
			continue
		}
		
		if (($strPasswordKeyValue -eq "") -or ($strPasswordKeyValue -eq $Null)) {
			write-host "$WM no value found for password in field position <8> for environment variable <ODI_SCM_DATA_SERVERS_${strDataServer}>"
		}
		
		$OutScriptContent += 'echo %IM% date ^<%date%^> time ^<%time%^>'
		$OutScriptContent += ('set MSG=executing object creation DML script ^^^<' + $strOutFile + '^^^>')
		
		$OutScriptContent += 'echo %IM% %MSG%'
		$strCmd =  'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat" "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecDatabaseSqlScript.bat" /p '
		$strCmd += '"' + $strDbmsTypeKeyValue + '" "' + $strUserNameKeyValue + '" "' + $strPasswordKeyValue + '" "' + $strJdbcUrlKeyValue + '" '
		$strCmd += '"' + $strDatabaseKeyValue + '" "' + $strDefPhysSchemaKeyValue + '" "' + $strOutFile + '" "True"'
		
		$OutScriptContent += $strCmd
		$OutScriptContent += 'if ERRORLEVEL 1 ('
		$OutScriptContent += '	goto ExitFail'
		$OutScriptContent += ')'
		$OutScriptContent += ''
		$OutScriptContent += 'echo %IM% DML script execution completed succcessfully'
		$OutScriptContent += ''
	}
	
	if ($intFileErrors -gt 0) {
		write-host "$EM total errors encountered <$intFileErrors>"
		return $False
	}
	
	#
	# Script termination commands - the common Exit labels.
	#
	$OutScriptContent += ':ExitOk'
	$OutScriptContent += 'cd /d %OLDPWD%'
	$OutScriptContent += 'echo %IM% ends'
	$OutScriptContent += 'exit %IsBatchExit% 0'
	$OutScriptContent += ''
	$OutScriptContent += ':ExitFail'
	$OutScriptContent += 'echo %EM% %MSG%'
	$OutScriptContent += 'cd /d %OLDPWD%'
	$OutScriptContent += 'echo %EM% ends'
	$OutScriptContent += 'exit %IsBatchExit% 1'
	
	set-content -path $DmlExecutionScriptFile -value $OutScriptContent
	
	write-host "$IM ends"
	return $True
}

#############################################################################################################
## TODO: TURN THIS INTO THE CENTRAL BUILD GENERATOR CALLED FROM THE GET AND IMPORT ENTRY POINTS.
#############################################################################################################

#
# The main function.
#
function GenerateBuild ($StrSourceTypeName) {
	
	$FN = "GenerateBuild"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	
	if (!(GetOdiScmConfiguration)) {
		write-host "$EM error loading ODI-SCM configuration from INI file"
		return $False
	}
	
	if (!(SetOutputNames)) {
		write-host "$EM error setting output file and directory names"
		return $False
	}
	
	if (!(CheckDependencies)) {
		return $False
	}
	
	#
	# Set up the ODI repository SQL access script.
	#
	if (!(SetOdiScmJisqlRepoBatContent)) {
		write-host "$EM error creating custom ODI repository SQL access script"
		return $False
	}
	
	#
	# Set up the OdiScm repository infrastructure creation script.
	#
	if (!(SetOdiScmRepoCreateInfractureSqlContent)) {
		write-host "$EM error creating OdiScm infrastructure creation script"
		return $False
	}
	
	#
	# Ensure the OdiScm repository infrastructure has been set up.
	#
	$CmdOutput = ExecOdiRepositorySql "$OdiScmRepoInfrastructureSetupSql" $GenScriptRootDir $OdiScmJisqlRepoBat
	if (! $CmdOutput) {
		write-host "$EM error creating OdiScm repository infrastructure"
		return $False
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
		return $False
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
		return $False
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
			return $False
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
			return $False
		}
	}
	
	if (!($FullImportInd) -and ($OdiRepoLastImportTo -ne $LocalLastImportFrom)) {
		write-host "$EM the last ODI repository imported revision <$OdiLastImportTo> number does not match"
		write-host "$EM the last revision number <$LocalLastImportFrom> from the working copy"
		return $False
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
		return $False
	}
	
	#
	# Generate the SQL DDL object import commands in the generated script.
	#
	if (!(GenerateDdlImportScript $arrStrDbDdlFileList)) { 
		write-host "$EM call to GenerateDdlImportScript failed"
		return $False
	}
	
	#
	# Generate the SQL SPL object import commands in the generated script.
	#
	if (!(GenerateSplImportScript $arrStrDbSplFileList)) { 
		write-host "$EM call to GenerateSplImportScript failed"
		return $False
	}
	
	#
	# Generate the SQL DML script execution commands in the generated script.
	#
	if (!(GenerateDmlExecutionScript $arrStrDbDmlFileList)) { 
		write-host "$EM call to GenerateDmlExecutionScript failed"
		return $False
	}
	
	#
	# Set up the startcmd script.
	#
	if (!(SetStartCmdContent)) {
		write-host "$EM call to SetStartCmdContent failed"
		return $False
	}
	
	#
	# Set up the OdiScm next import metadata update script.
	#
	if (!(SetOdiScmRepoSetNextImportSqlContent $HighChangeSetNumber)) {
		write-host "$EM call to SetOdiScmRepoSetNextImportSqlContent failed"
		return $False
	}
	
	#
	# Set up the OdiScm build note.
	#
	if (!(SetOdiScmBuildNoteContent $difference)) {
		write-host "$EM call to SetOdiScmBuildNoteContent failed"
		return $False
	}
	
	#
	# Set up the OdiScm repository back-up script content.
	#
	if (!(SetOdiScmRepositoryBackUpBatContent)) {
		write-host "$EM call to SetOdiScmRepositoryBackUpBatContent failed"
		return $False
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
		return $False
	}
	
	#
	# Set up the post-ODI import Scenario deletion generator script content.
	#
	if (!(SetOdiScmGenScenDeleteOldSqlContent)) {
		write-host "$EM call to SetOdiScmGenScenDeleteOldSqlContent failed"
		return $False
	}
	
	#
	# Set up the post-ODI import Scenario generation generator script content.
	#
	if (!(SetOdiScmGenScenNewSqlContent)) {
		write-host "$EM call to SetOdiScmGenScenNewSqlContent failed"
		return $False
	}
	
	#
	# Set up the post-ODI import script content.
	#
	if (!(SetOdiScmPostImportBatContent)) {
		write-host "$EM setting content in post-ODI import script"
		return $False
	}
	
	#
	# Set up the top level build script content.
	#
	if (!(SetTopLevelScriptContent $HighChangeSetNumber)) {
		write-host "$EM setting content in main script"
		return $False
	}
	
	write-host "$IM your working copy has been updated. Execute the following script to perform"
	write-host "$IM the ODI source code import, Scenario generation and update the local OdiScm metadata"
	write-host "$IM"
	write-host "$IM <$OdiScmBuildBat>"
	
	write-host "$IM ends"
	return $True
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
	
	$OdiWorkingCopyRootDir = $OdiScmConfig["SCM System"]["OracleDI Working Copy Root"]
	
	if (($OdiWorkingCopyRootDir -eq $Null) -or ($OdiWorkingCopyRootDir -eq "")) {
		write-host "$EM cannot retrieve OracleDI working copy root directory from configuration INI file"
		return $False
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
	
	# Supported formats:
	# jdbc:oracle:thin:@localhost:1521:xe               (i.e. SID)
	# jdbc:oracle:thin:@//localhost:1521/orcl.acme.com  (i.e. service name)
	$strFixedAndVariable = $OdiRepoSECURITY_URL.split("@")
	$strFixed = $strFixedAndVariable[0]
	$strVariable = $strFixedAndVariable[1]
	
	if ($strVariable.StartsWith("//")) {
		$strKeyValueFields = $strVariable.split(":")
							
		$script:OdiRepoSECURITY_URL_SERVER = $strKeyValueFields[0]
		$script:OdiRepoSECURITY_URL_SERVER = $OdiRepoSECURITY_URL_SERVER.Substring(2)
		
		$strPortServiceName = $strKeyValueFields[1]
		$strPortServiceNameParts = $strPortServiceName.split("/")
		$script:OdiRepoSECURITY_URL_PORT = $strPortServiceNameParts[0]
		$script:OdiRepoSECURITY_URL_SID = $strPortServiceNameParts[1]
	}
	else {
		$strKeyValueFields = $strVariable.split(":")
		
		$script:OdiRepoSECURITY_URL_SERVER = $strKeyValueFields[0]
		$script:OdiRepoSECURITY_URL_PORT = $strKeyValueFields[1]
		$script:OdiRepoSECURITY_URL_SID = $strKeyValueFields[2]
	}
		
	if ($OdiRepoSECURITY_URL_SERVER.length -eq 0) {
		write-host "$EM no value for server field of connection parameter OracleDI Secu Url in INI file"
		return $False
	}
	
	if ($OdiRepoSECURITY_URL_PORT.length -eq 0) {
		write-host "$EM no value for port field of connection parameter OracleDI Secu Url in INI file"
		return $False
	}
	
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
# Set output file and directory name constants.
#
function SetOutputNames {
	
	$FN = "SetOutputNames"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$WM = $FN + ": WARNING:"
	$DEBUG = $FN + ": DEBUG:"
	
	if (($env:ODI_SCM_GENERATE_OUTPUT_TAG -eq $Null) -or ($env:ODI_SCM_GENERATE_OUTPUT_TAG -eq "")) {
		$script:OutputTag = ${VersionString}
		write-host "$IM using variable output tag <$OutputTag>"
	}
	else {
		$script:OutputTag = $env:ODI_SCM_GENERATE_OUTPUT_TAG
		write-host "$IM using fixed output tag <$OutputTag>"
	}
	
	#
	# Generated script locations and names.
	#
	$script:GenScriptRootDir = $LogRootDir + "\${OutputTag}"
	$script:GenScriptConsObjSrcDir = $GenScriptRootDir + "\" + "ConsolidatedObjSources"
	$script:GenScriptDbObjsDir = $GenScriptRootDir + "\" + "DatabaseObjects"
	
	$script:OdiScmOdiStartCmdBat = $GenScriptRootDir + "\OdiScmStartCmd_${OutputTag}.bat"
	$script:OdiScmJisqlRepoBat = $GenScriptRootDir + "\OdiScmJisqlRepo_${OutputTag}.bat"
	$script:OdiScmRepositoryBackUpBat = $GenScriptRootDir + "\OdiScmRepositoryBackUp_${OutputTag}.bat"
	$script:OdiScmBuildBat = $GenScriptRootDir + "\OdiScmBuild_${OutputTag}.bat"
	$script:OdiScmPreImpMergeSnpIDsSql = $GenScriptRootDir + "\OdiScmPreImp13MergeSnpIDs_${OutputTag}.sql"
	$script:OdiScmGenScenPreImpDelOldSql = $GenScriptRootDir + "\OdiScmGenScen15InsertSrcObjIds_${OutputTag}.sql"
	$script:OdiScmGenScenPreImpDelOldBatSql = $GenScriptRootDir + "\OdiScmGenScen17PreImpDelOldBat_${OutputTag}.sql"
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
	
	$script:DdlImportScriptStubName = "OdiScmDdlImport_" + ${OutputTag}
	$script:DdlImportScriptName = $DdlImportScriptStubName + ".bat"
	$script:DdlImportScriptFile = $GenScriptRootDir + "\$DdlImportScriptName"
	
	$script:SplImportScriptStubName = "OdiScmSplImport_" + ${OutputTag}
	$script:SplImportScriptName = $SplImportScriptStubName + ".bat"
	$script:SplImportScriptFile = $GenScriptRootDir + "\$SplImportScriptName"
	
	$script:DmlExecutionScriptStubName = "OdiScmDmlExecution_" + ${OutputTag}
	$script:DmlExecutionScriptName = $DmlExecutionScriptStubName + ".bat"
	$script:DmlExecutionScriptFile = $GenScriptRootDir + "\$DmlExecutionScriptName"
	
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
	
	if (Test-Path $GenScriptDbObjsDir) { 
		write-host "$IM generated consolidated ODI object source files directory <$GenScriptDbObjsDir> already exists"
	}
	else {  
		write-host "$IM generated consolidated ODI object source files directory <$GenScriptDbObjsDir> already exists"
		New-Item -itemtype directory $GenScriptDbObjsDir 
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
	
	#
	# Set the flag to indicate these names have been defined.
	#
	$script:OdiScmOutputNamesSet = $True
	
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
	
	set-content -path $OdiScmJisqlRepoBat -value $fileContent
	
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
	$OraConn = "${OdiRepoSECURITY_URL_SERVER}:$OdiRepoSECURITY_URL_PORT/$OdiRepoSECURITY_URL_SID"
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
		write-host "$EM getting build note template text from template file <$OdiScmBuildNoteTemplate>"
		return $False
	}
	
	$NoteText = $NoteText.Replace("<ScmSystemTypeName>" , $OdiScmConfig["SCM System"]["Type Name"])
	$NoteText = $NoteText.Replace("<ScmSystemUrl>"      , $OdiScmConfig["SCM System"]["System Url"])
	$NoteText = $NoteText.Replace("<ScmBranchUrl>"      , $OdiScmConfig["SCM System"]["Branch Url"])
	$NoteText = $NoteText.Replace("<VersionRange>"      , $VersionRange)
	$NoteText = $NoteText.Replace("<WorkingCopyRootDir>", $WorkingCopyRootDir)
	
	set-content -path $OdiScmBuildNote $NoteText
	if (!($?)) {
		write-host "$EM setting build note template text in file <$OdiScmBuildNote>"
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
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenScenPreImpDelOldSql>",$OdiScmGenScenPreImpDelOldSql)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenScenPreImpDelOldBatSql>",$OdiScmGenScenPreImpDelOldBatSql)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmPreImpMergeSnpIDsSql>",$OdiScmPreImpMergeSnpIDsSql)
	
	set-content -path $OdiScmGenScenPreImportBat -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate the pre import Scenario deletion script generation script.
#
function SetOdiScmGenScenPreImpDelOldBatSqlContent {
	
	$FN = "SetOdiScmGenScenPreImpDelOldBatSqlContent"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	write-host "$IM starts"
	write-host "$IM using script template file <$OdiScmGenScenPreImpDelOldBatSqlTemplate>"
	write-host "$IM setting content of pre ODI import script file <$OdiScmGenScenPreImpDelOldBatSql>"
	
	$ExitStatus = $False
	
	$ScriptFileContent = get-content $OdiScmGenScenPreImpDelOldBatSqlTemplate | out-string
	
	#
	# Set the script path/names.
	#
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmOdiStartCmdBat>",$OdiScmOdiStartCmdBat)
	set-content -path $OdiScmGenScenPreImpDelOldBatSql -value $ScriptFileContent
	
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

#
# Generate the post import Scenario deletion script generation script.
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
# Generate the post import Scenario generation script generation script.
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
function GenerateUnitTestExecScript($strOutputFile, $strIncrementalOrFull, $strIndividualOrSuite) {
	
	$FN = "GenerateUnitTestExecScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	write-host "$IM output will be written to file <$strOutputFile>"
	
	$strGenType = $strIncrementalOrFull.ToLower()
	
	if (!(($strGenType -eq "incremental") -or ($strGenType -eq "full"))) {
		write-host "$EM invalid test generation type <$strGenType> specified"
		write-host "$EM generation type must be <incremental> or <full>"
		return $False
	}
	
	$strTestsOrSuite = $strIndividualOrSuite.ToLower()
	
	if (!(($strTestsOrSuite -eq "individual") -or ($strTestsOrSuite -eq "suite"))) {
		write-host "$EM invalid test generation type <$strTestsOrSuite> specified"
		write-host "$EM generation type must be <individual> or <suite>"
		return $False
	}
	
	if (($strGenType -eq "incremental") -and ($strTestsOrSuite -eq "suite")) {
		write-host "$EM invalid parameter argument combination:"
		write-host "$EM incremental test execution can be specified only with individual ODI scenario"
		write-host "$EM test execution, not suite-level execution"
		return $False
	}
	
	if (!($OdiScmOutputNamesSet)) {
		if (!(SetOutputNames)) {
			write-host "$EM setting output file system object names"
			return $ExitStatus
		}
	}
	
	if ($strTestsOrSuite -eq "individual") {
		$strGenerateUnitTestExecScriptContent = get-content "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateUnitTestExecs.sql"
		if (!($?)) {
			write-host "$EM getting content of script file <$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmGenerateUnitTestExecs.sql>"
			return $False
		}
		
		if ($strGenType -eq "incremental") {
			#
			# Replace tokens in the script template and create a new script file.
			#
			$strFilterText  = "AND o.last_date >" + [Environment]::NewLine
			$strFilterText += "              (" + [Environment]::NewLine
			$strFilterText += "              SELECT import_start_datetime" + [Environment]::NewLine
			$strFilterText += "                FROM odiscm_controls" + [Environment]::NewLine
			$strFilterText += "              )"
		
			$strGenerateUnitTestExecScriptContent = $strGenerateUnitTestExecScriptContent -replace "<OdiScmModifiedObjectsOnlyFilterText>", $strFilterText
		}
		else {
			$strGenerateUnitTestExecScriptContent = $strGenerateUnitTestExecScriptContent -replace "<OdiScmModifiedObjectsOnlyFilterText>", ""
		}
		$strGenerateUnitTestExecScriptContent = $strGenerateUnitTestExecScriptContent -replace "<OdiScmScenarioSourceMarkers>", "$env:ODI_SCM_GENERATE_SCENARIO_SOURCE_MARKERS"
		
		$strTempScriptFile = "$env:TEMPDIR\OdiScmGenerateUnitTestExecsExpanded.sql"
		set-content -path $strTempScriptFile -value $strGenerateUnitTestExecScriptContent
		if (!($?)) {
			write-host "$EM setting content of script file <$strTempScriptFile>"
			return $False
		}
		
		#
		# Generate the list of FitNesse command line calls.
		#
		$CmdOutput = ExecOdiRepositorySql "$strTempScriptFile" "$env:TEMPDIR" "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmJisqlRepo.bat"
		if (! $CmdOutput) {
			write-host "$EM error generating ODI unit test execution calls list"
			return $ExitStatus
		}
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
	$arrOutFileLines += 'set TOTALTESTSUITES=0'
	$arrOutFileLines += 'set TOTALTESTFAILURES=0'
	$arrOutFileLines += 'set TOTALTESTPAGEPASSES=0'
	$arrOutFileLines += 'set TOTALTESTSUITEPASSES=0'
	$arrOutFileLines += 'set TOTALTESTPAGEFAILURES=0'
	$arrOutFileLines += 'set TOTALTESTSUITEFAILURES=0'
	$arrOutFileLines += 'set TOTALTESTPAGESMISSING=0'
	$arrOutFileLines += 'set TOTALTESTSUITESMISSING=0'
	$arrOutFileLines += 'setlocal enabledelayedexpansion'
	$arrOutFileLines += ''
	
	if ($strTestsOrSuite -eq "individual") {
		#
		# Build the calls to each ODI object, marked as having a scenario, unit test.
		#
		$arrCmdOutput = ($CmdOutput -replace "ExecOdiRepositorySql:", "").split("`n")
		
		foreach ($CmdOutputLine in $arrCmdOutput) {
			
			$strNoCR = $CmdOutputLine -replace "`r", ""
			$strNoCR = $strNoCR -replace "`n", ""
			$strNoCR = $strNoCR.Trim()
			$arrOutputLineParts = $strNoCR.split("/")
			$strOdiObj = "Type:" + $arrOutputLineParts[1] + '/ID:' + $arrOutputLineParts[2] + '/Name:' + $arrOutputLineParts[3]
			$arrOutFileLines += ('echo %IM% executing unit tests for ODI object ^<' + $strOdiObj + '^>')
			$arrOutFileLines += 'set /a TOTALTESTPAGES=%TOTALTESTPAGES% + 1'
			
			$strFitNesseCmd  = 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat"'
			$strFitNesseCmd += ' ^"%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecFitNesseCmd.bat^" /p '
			
			$strTestPagePath = ""
			
			if ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME -ne "") {
				$strTestPagePath += ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME + '.')
			}
			
			if (($arrOutputLineParts[0] -ne "") -and ($arrOutputLineParts[0] -ne $Null)) {
				$strTestPagePath += ('OdiProject' + $arrOutputLineParts[0] + '.')
			}
			
			$strTestPagePath += ('Odi' + $arrOutputLineParts[1] + $arrOutputLineParts[2])
			$strFitNesseCmd += ($strTestPagePath + " test " + $GenScriptRootDir + "\UnitTestResults")
			
			#
			# Use the FitNesse root page directory override if specified, else the working copy root directory.
			#
			if ("$env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT" -ne "") {
				$strTestPageFilePath = ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT).Replace("/","\")
			}
			else {
				$strTestPageFilePath = ($env:ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT).Replace("/","\")
			}
			$strTestPageFilePath += "\" + ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME).Replace(".","\") + "\" + $strTestPagePath.Replace(".","\")
			
			$arrOutFileLines += 'if not EXIST "' + $strTestPageFilePath + '\content.txt" ('
			$arrOutFileLines += ('	echo %EM% cannot find FitNesse test content file ^<' + $strTestPageFilePath + '^> 1>&2')
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
	}
	else {
		#
		# Build the call to the test suite.
		#
		$arrOutFileLines += ('echo %IM% executing unit test suite')
		$arrOutFileLines += 'set /a TOTALTESTSUITES=%TOTALTESTSUITES% + 1'
		
		$strFitNesseCmd  = 'call "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmFork.bat"'
		$strFitNesseCmd += ' "%ODI_SCM_HOME%\Configuration\Scripts\OdiScmExecFitNesseCmd.bat" /p '
		
		$strTestPagePath = ""
		
		if ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME -ne "") {
			$strTestPagePath += ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME)
		}
		
		$strFitNesseCmd += ($strTestPagePath + " suite " + $GenScriptRootDir + "\UnitTestResults")
		
		#
		# Use the FitNesse root page directory override if specified, else the working copy root directory.
		#
		if ("$env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT" -ne "") {
			$strTestPageFilePath = ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT).Replace("/","\")
		}
		else {
			$strTestPageFilePath = ($env:ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT).Replace("/","\")
		}
		$strTestPageFilePath += "\" + ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME).Replace(".","\") + "\" + $strTestPagePath.Replace(".","\")
		
		$arrOutFileLines += 'if not EXIST "' + $strTestPageFilePath + '\content.txt" ('
		$arrOutFileLines += ('	echo %EM% cannot find FitNesse test content file ^<' + $strTestPageFilePath + '^> 1>&2')
		$arrOutFileLines += '	set TESTFAILURES=0'
		$arrOutFileLines += '	set /a TOTALTESTSUITESMISSING=!TOTALTESTSUITESMISSING! + 1'
		$arrOutFileLines += ') else ('
		$arrOutFileLines += ('	' + $strFitNesseCmd)
		$arrOutFileLines += '	set TESTFAILURES=!ERRORLEVEL!'
		$arrOutFileLines += '	if not "!TESTFAILURES!" == "0" ('
		$arrOutFileLines += '		echo %EM% tests failed 1>&2'
		$arrOutFileLines += '		set /a TOTALTESTFAILURES=!TOTALTESTFAILURES! + !TESTFAILURES!'
		$arrOutFileLines += '		set /a TOTALTESTSUITEFAILURES=!TOTALTESTSUITEFAILURES! + 1'
		$arrOutFileLines += '	) else ('
		$arrOutFileLines += '		echo %IM% tests passed'
		$arrOutFileLines += '		set /a TOTALTESTSUITEPASSES=!TOTALTESTSUITEPASSES! + 1'
		$arrOutFileLines += '	)'
		$arrOutFileLines += ')'
		$arrOutFileLines += 'set /a TOTALTESTFAILURES=!TOTALTESTFAILURES! + !TESTFAILURES!'
		$arrOutFileLines += ''		
	}
	
	$arrOutFileLines += 'echo %IM% total test pages attempted ^<%TOTALTESTPAGES%^>'
	$arrOutFileLines += 'echo %IM% total test page failures ^<%TOTALTESTPAGEFAILURES%^>'
	$arrOutFileLines += 'echo %IM% total test page passes ^<%TOTALTESTPAGEPASSES%^>'
	$arrOutFileLines += 'echo %IM% total test pages missing ^<%TOTALTESTPAGESMISSING%^>'
	$arrOutFileLines += 'echo %IM% total test suites attempted ^<%TOTALTESTSUITES%^>'
	$arrOutFileLines += 'echo %IM% total test suites failures ^<%TOTALTESTSUITEFAILURES%^>'
	$arrOutFileLines += 'echo %IM% total test suites passes ^<%TOTALTESTSUITEPASSES%^>'
	$arrOutFileLines += 'echo %IM% total test suites missing ^<%TOTALTESTSUITESMISSING%^>'
	$arrOutFileLines += 'echo %IM% total test failures ^<%TOTALTESTFAILURES%^>'
	$arrOutFileLines += ''
	$arrOutFileLines += 'set /a TOTALFAILURES=%TOTALTESTFAILURES% + %TOTALTESTPAGESMISSING% + %TOTALTESTSUITESMISSING%'
	$arrOutFileLines += ''
	$arrOutFileLines += 'echo %IM% total failures ^<%TOTALFAILURES%^>'
	$arrOutFileLines += ''
	$arrOutFileLines += 'if not "%TOTALFAILURES%" == "0" ('
	$arrOutFileLines += '	echo %EM% unit tests have failed 1>&2'
	$arrOutFileLines += '	goto ExitFail'
	$arrOutFileLines += ')'
	$arrOutFileLines += ''
	$arrOutFileLines += ':ExitOk'
	$arrOutFileLines += 'echo %IM% ends'
	$arrOutFileLines += 'exit %IsBatchExit% 0'
	$arrOutFileLines += ''
	$arrOutFileLines += ':ExitFail'
	$arrOutFileLines += 'echo %EM% starts 1>&2'
	$arrOutFileLines += 'exit %IsBatchExit% 1'
	
	$arrOutFileLines | set-content -path $strOutputFile
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
	
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenerateBuildTestScope>", $env:ODI_SCM_GENERATE_BUILD_TEST_SCOPE)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmGenerateODIScenarioUnitTestExecutionType>", $env:ODI_SCM_GENERATE_ODI_SCENARIO_UNIT_TEST_EXECUTION_TYPE)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmFitNesseJavaHomeDir>", $env:ODI_SCM_TOOLS_FITNESSE_JAVA_HOME)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmFitNesseHomeDir>", $env:ODI_SCM_TOOLS_FITNESSE_HOME)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmFitNesseOutputFormat>", $env:ODI_SCM_TEST_FITNESSE_OUTPUT_FORMAT)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmFitNesseRootPageName>", $env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME)
	$ScriptFileContent = $ScriptFileContent.Replace("<OdiScmFitNesseUnitTestPageName>", $env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME)
	
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
	
	$objNewChangeSetNumber = $Null
	
	switch ($SCMSystemTypeName) {
		"TFS" { 
			$objNewChangeSetNumber = GetNewTFSChangeSetNumber
		}
		"SVN" {
			$objNewChangeSetNumber = GetNewSVNRevisionNumber
		}
	}
	
	if ($objNewChangeSetNumber -eq $False) {
		write-host "$EM getting new ChangeSet/revision number from SCM system"
		return $False
	}
	
	return $objNewChangeSetNumber
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
	LogDebug "$FN" "cleaned command output <$changesetText>"
	
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
		if (($ChangeSetTextUserPos - $ChangeSetTextChangeSetPos - $TfChangeSetTextLen - 1) -lt 0) {
			write-host "$EM calculating position of ChangeSet number in ChangeSet text"
			write-host "$EM start of ChangeSet text <"
			write-host $changesetText
			write-host "$EM > end of ChangeSet text"
			return $False
		}
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
	$outRecordList | set-content -path $outFile
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
$OdiWorkingCopyRootDir = ""

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

$OdiScmGenScenPreImpDelOldSqlTemplate = $ScriptsRootDir + "\OdiScmGenScen15InsertSrcObjIdsTemplate.sql"
$OdiScmGenScenPreImpDelOldBatSqlTemplate = $ScriptsRootDir + "\OdiScmGenScen17DeleteOldScenTemplate.sql"
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
