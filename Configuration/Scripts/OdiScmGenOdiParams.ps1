$FN = "OdiScmGenOdiParams"
$IM = $FN + ": INFO:"
$EM = $FN + ": ERROR:"

#
# Source common functions.
#
. "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmCommon.ps1"

#
# Validate arguments.
#
if ($args.count -ne 1) {
	write-output "$EM usage: $FN <output path and file name>"
	exit 1
}

if (($env:ODI_SCM_ORACLEDI_HOME -eq $Null) -or ($env:ODI_SCM_ORACLEDI_HOME -eq "")) {
	write-output "$EM environment variable ODI_SCM_ORACLEDI_HOME is not set"
	exit 1
}

$OdiParamsBat = $env:ODI_SCM_ORACLEDI_HOME + "\bin\odiparams.bat"

if (!(test-path $OdiParamsBat)) {
	write-output "$EM ODI odiparams.bat batch script not found in ODI bin directory <$env:ODI_SCM_ORACLEDI_HOME\bin>"
	exit 1
}

$ResultMain = CreateOdiParamsExpandedBatchScript $args[0]
if ($ResultMain) {
	exit 0
}
else {
	exit 1
}