$FN = "OdiScmMakeStartCmd"
$IM = $FN + ": INFO:"
$EM = $FN + ": ERROR:"

if ($args.count -ne 1) {
	write-output "$EM usage: OdiScmMakeStartCmd <output path and file name>"
	exit 1
}

if (($env:ODI_HOME -eq $Null) -or ($env:ODI_HOME -eq "")) {
	write-output "$EM environment variable ODI_HOME is not set"
	exit 1
}

$StartCmdBat = $env:ODI_HOME + "\bin\startcmd.bat"

if (!(test-path $StartCmdBat)) {
	write-output "$EM ODI startcmd.bat batch script not found in ODI bin directory <$env:ODI_HOME\bin>"
	exit 1
}

$ScriptFileContent = get-content $StartCmdBat | out-string
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_HOME%",$env:ODI_HOME)
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_SECU_DRIVER%",$env:ODI_SECU_DRIVER)
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_SECU_URL%",$env:ODI_SECU_URL)
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_SECU_USER%",$env:ODI_SECU_USER)
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_SECU_ENCODED_PASS%",$env:ODI_SECU_ENCODED_PASS)
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_USER%",$env:ODI_USER)
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_ENCODED_PASS%",$env:ODI_ENCODED_PASS)
$ScriptFileContent = $ScriptFileContent.Replace("%ODI_SECU_WORK_REP%",$env:ODI_SECU_WORK_REP)

set-content -path $args[0] -value $ScriptFileContent
if (!($?)) {
	write-output "$EM writing output file"
	exit 1
}
else {
	exit 0
}