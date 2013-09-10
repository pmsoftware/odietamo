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
	#DebuggingPause
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
			LogDebug "$FN" "got a comment"
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

function CreateSetEnvScript
{
	$FN = "OdiScmIni: CreateSetEnvScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	#
	# Load the INI file.
	#
	#DebuggingPause
	$IniTable = GetIniContent($env:ODI_SCM_INI)
	if ($IniTable -eq $False) {
		write-error "$EM loading configuration INI file <$env:ODI_SCM_INI>"
		return $False
	}
	
	foreach ($i in $IniTable.keys)
	{
		if (!($($IniTable[$i].GetType().Name) -eq "Hashtable"))
		{
			#
			# The top level hash table entry is not a section.
			#
			if ($i -match "^Comment[\d]+") {
				#
				# The top level hash table entry is a comment.
				#
				#write-output "processing a top level comment"
				$strOutText = "REM " + $($IniTable[$i]) #+ [Environment]::NewLine
				write-output $strOutText
				#DebuggingPause
			}
			else {
				#
				# The top level hash table entry is a key.
				#
				#write-output "processing a top level key: " $($IniTable[$i])
				$strKeyName = $i
				$strKeyValue = $($IniTable[$i])
				$strEnvVarName = "ODI_SCM_" + $strKeyName.ToUpper()
				$strEnvVarName = $strEnvVarName.Replace(" ","_")
				
				#
				# If setting the variable to empty (i.e. removing the variable definition) only do this if the variable is actually set.
				# Otherwise (certainly in Windows XP) the SET command sets a non 0 ERRORLEVEL.
				#
				if ($strKeyValue -eq "" -or $strKeyValue -eq $Null) {
					$strOutText = "if DEFINED $strEnvVarName set $strEnvVarName="
				}
				else {
					$strOutText = "set $strEnvVarName=$strKeyValue" #+ [Environment]::NewLine
				}
				
				write-output $strOutText
				DebuggingPause
			}
		}
		else {
			#
			# The top level hash table entry is a section.
			#
			#write-output "processing a top level section: " $i
			#DebuggingPause
			
			foreach ($j in ($IniTable[$i].keys | sort-object))
			{
				if ($j -match "^Comment[\d]+") {
					#write-output "processing a section comment: " $($IniTable[$i][$j])
					#DebuggingPause
				}
				else {
					#write-output "processing a section key: section: " $i ", key: " $j ", value: " $($IniTable[$i][$j])
					$strSectionName = $i
					$strKeyName = $j
					$strKeyValue = $($IniTable[$i][$j])
					$strEnvVarName = "ODI_SCM_" + $strSectionName.ToUpper() + "_" + $strKeyName.ToUpper()
					$strEnvVarName = $strEnvVarName.Replace(" ","_")
					
					#
					# If setting the variable to empty (i.e. removing the variable definition) only do this if the variable is actually set.
					# Otherwise (certainly in Windows XP) the SET command sets a non 0 ERRORLEVEL.
					#
					if ($strKeyValue -eq "" -or $strKeyValue -eq $Null) {
						write-output "if DEFINED $strEnvVarName set $strEnvVarName="
						write-output "if ERRORLEVEL 1 exit /b 1"
					}
					else {
						write-output "set $strEnvVarName=$strKeyValue" #+ [Environment]::NewLine
						write-output "if ERRORLEVEL 1 exit /b 1"
					}
					
					if ($strEnvVarName -eq "ODI_SCM_ORACLEDI_SECU_URL") {
						# jdbc:oracle:thin:@localhost:1521:xe
						$strKeyValueFields = $strKeyValue.split(":")
						$strUrlHost = $($strKeyValueFields[3]).replace("@","")
						$strUrlPort = $strKeyValueFields[4]
						$strUrlSID = $strKeyValueFields[5]
						
						if ($strUrlHost -eq "" -or $strUrlHost -eq $Null) {
							write-output "if defined ODI_SCM_ORACLEDI_SECU_URL_HOST set ODI_SCM_ORACLEDI_SECU_URL_HOST="
							write-output "if ERRORLEVEL 1 exit /b 1"
						}
						else {
							write-output "set ODI_SCM_ORACLEDI_SECU_URL_HOST=$strUrlHost"
							write-output "if ERRORLEVEL 1 exit /b 1"
						}
						
						if ($strUrlPort -eq "" -or $strUrlPort -eq $Null) {
							write-output "if defined ODI_SCM_ORACLEDI_SECU_URL_PORT set ODI_SCM_ORACLEDI_SECU_URL_PORT="
							write-output "if ERRORLEVEL 1 exit /b 1"
						}
						else {
							write-output "set ODI_SCM_ORACLEDI_SECU_URL_PORT=$strUrlPort"
							write-output "if ERRORLEVEL 1 exit /b 1"
						}
						
						if ($strUrlSID -eq "" -or $strUrlSID -eq $Null) {
							write-output "if defined ODI_SCM_ORACLEDI_SECU_URL_SID set ODI_SCM_ORACLEDI_SECU_URL_SID="
							write-output "if ERRORLEVEL 1 exit /b 1"
						}
						else {
							write-output "set ODI_SCM_ORACLEDI_SECU_URL_SID=$strUrlSID"
							write-output "if ERRORLEVEL 1 exit /b 1"
						}
					}
					#DebuggingPause
				}
			}
		}
	}
	write-output 'rem'
	write-output 'rem Add derived configuration.'
	write-output 'rem'
	write-output 'set ODI_SCM_SCM_SYSTEM_SYSTEM_URL_FS=%ODI_SCM_SCM_SYSTEM_SYSTEM_URL:\=/%'
	write-output 'set ODI_SCM_SCM_SYSTEM_BRANCH_URL_FS=%ODI_SCM_SCM_SYSTEM_BRANCH_URL:\=/%'
	write-output 'set ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT_FS=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT:\=/%'
	write-output 'set ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT_BS=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT:/=\%'
	write-output ''
	write-output 'if "%ODI_SCM_SCM_SYSTEM_TYPE_NAME%" == "TFS" ('
	write-output '	rem'
	write-output '	rem For TFS or any unspecfied SCM system we do not need to append anything to the specified working copy root directory.'
	write-output '	rem'
	write-output '	set WCAPPEND='
	write-output '	set ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT_BS%%WCAPPEND%'
	write-output '	exit /b 0'
	write-output ')'
	write-output ''
	write-output 'rem'
	write-output 'rem For SVN we need to take the final part of the system URL and/or branch URL and append to the specified working copy path.'
	write-output 'rem This is because the last path component will have a working copy directory created for it when we check out of SVN.'
	write-output 'rem Note: beware of extra spaces at the end of the variable expansion.'
	write-output 'rem'
	write-output ('for /f "tokens=* delims=/" %%g in (' + "'echo %ODI_SCM_SCM_SYSTEM_SYSTEM_URL_FS%^| tr [/] [\n]') do (")
	write-output '	set SCMSYSTEMURLLASTPATH=%%g'
	write-output ')'
	write-output ''
	write-output 'if "!SCMSYSTEMURLLASTPATH!" == "" ('
	write-output '	echo %EM% last path component of SCM system URL ^<%ODI_SCM_SCM_SYSTEM_SYSTEM_URL%^> is empty 1>&2'
	write-output '	exit /b 1'
	write-output ')'
	write-output ''
	write-output ('for /f "tokens=* delims=/" %%g in (' + "'echo %ODI_SCM_SCM_SYSTEM_BRANCH_URL_FS%^| tr [/] [\n]') do (")
	write-output '	set SCMBRANCHURLLASTPATH=%%g'
	write-output ')'
	write-output ''
	write-output 'if "%SCMBRANCHURLLASTPATH%" == "" ('
	write-output '	echo %EM% last path component of SCM branch URL ^<%ODI_SCM_SCM_SYSTEM_BRANCH_URL%^> is empty 1>&2'
	write-output '	exit /b 1'
	write-output ')'
	write-output ''
	write-output 'if "%SCMBRANCHURLLASTPATH%" == "." ('
	write-output '	set WCAPPEND=\%SCMSYSTEMURLLASTPATH%'
	write-output ') else ('
	write-output '	set WCAPPEND=\%SCMBRANCHURLLASTPATH%'
	write-output ')'
	write-output ''
	write-output 'set ODI_SCM_SCM_SYSTEM_WORKING_COPY_CODE_ROOT=%ODI_SCM_SCM_SYSTEM_WORKING_COPY_ROOT_BS%%WCAPPEND%'
}

$FN = "OdiScmIni"
$IM = $FN + ": INFO:"
$EM = $FN + ": ERROR:"

$DebuggingActive = $False

if ($args.Count -ne 1) {
	write-error "OdiScmCreateSetEnvScript: missing output script name"
	write-error "OdiScmCreateSetEnvScript: usage: OdiScmCreateSetEnv <output batch script path and name>"
}

if (($env:ODI_SCM_INI -eq $Null) -or ($env:ODI_SCM_INI -eq "")) {
	write-error "$EM configuration INI file not specified in environment variable ODI_SCM_INI"
	exit 1
}

if (!(test-path "$env:ODI_SCM_INI")) {
	write-error "$EM cannot access configuration INI file <$env:ODI_SCM_INI>"
	exit 1
}

$BatContent=CreateSetEnvScript
if ($BatContent -eq $False) {
	exit 1
}

set-content -path $args[0] -value $BatContent
if (!($?)) {
	write-error "$EM cannot create batch script file <$($args[0])>"
	exit 1
}

exit 0