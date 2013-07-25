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
	$FN = "CreateSetEnvScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	
	if (($env:ODI_SCM_INI -eq $Null) -or ($env:ODI_SCM_INI -eq "")) {
		write-error "$EM configuration INI file not specified in environment variable ODI_SCM_INI"
		exit 1
	}
	
	if (!(test-path "$env:ODI_SCM_INI")) {
		write-error "$EM cannot access configuration INI file <$env:ODI_SCM_INI>"
		exit 1
	}
	
	#
	# Load the INI file.
	#
	#$OutputPathFile = new-item -itemtype file -path $OutputPathFile -force
	write-host "loaded ini file"
	DebuggingPause
	$IniTable = GetIniContent($env:ODI_SCM_INI)
	
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
				$strOutText = ";" + $($IniTable[$i])
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
				$strOutText = $strKeyName + "=" + $strKeyValue
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
					$strOutText = "set " + $strEnvVarName + "=" + $strKeyValue
					write-output $strOutText
					#DebuggingPause
					#add-content -path $outFile -value $strOutText.ToUpper()
					#DebuggingPause
				}
			}
			#add-content -path $OutputPathFile -value ""
		}
    }
}

$DebuggingActive = $True
CreateSetEnvScript