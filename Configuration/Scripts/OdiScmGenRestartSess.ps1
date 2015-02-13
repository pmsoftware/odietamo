$FN = "OdiScmGenRestartSess"
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

$RestartSessBat = $env:ODI_SCM_ORACLEDI_HOME + "\bin\restartsession.bat"

if (!(test-path $RestartSessBat)) {
	write-output "$EM ODI restartsession.bat batch script not found in ODI bin directory <$env:ODI_SCM_ORACLEDI_HOME\bin>"
	exit 1
}

$OdiParamsBat = $env:ODI_SCM_ORACLEDI_HOME + "\bin\odiparams.bat"

if (!(test-path $OdiParamsBat)) {
	write-output "$EM ODI odiparams.bat batch script not found in ODI bin directory <$env:ODI_SCM_ORACLEDI_HOME\bin>"
	exit 1
}

#
# Load odiparams.bat into an array.
#
[array] $arrOdiParamsContent = get-content $OdiParamsBat

#
# Build comments around the odiparams.bat script text.
#
$arrOdiParamsOutText = @()

$arrOdiParamsOutText += "REM"
$arrOdiParamsOutText += "REM OdiScm: start of odiparams.bat insertion"
$arrOdiParamsOutText += "REM"

foreach ($x in $arrOdiParamsContent) {
	$arrOdiParamsOutText += $x
}

$arrOdiParamsOutText += "REM"
$arrOdiParamsOutText += "REM OdiScm: end of odiparams.bat insertion"
$arrOdiParamsOutText += "REM"

#
# Add an execution of an empty (NUL) Jython script to prime the package cache.
# Discard stderr so it doesn't interfere with our dectecting of if the ODI command actually completed successfully.
#
$arrOdiParamsOutText += "REM"
$arrOdiParamsOutText += "REM OdiScm: start of Jython package cache priming insertion"
$arrOdiParamsOutText += "REM"
$arrOdiParamsOutText += '%ODI_JAVA_START% org.python.util.jython "-Dpython.home=%ODI_HOME%/lib/scripting" NUL 2>NUL'
$arrOdiParamsOutText += "if ERRORLEVEL 1 ("
$arrOdiParamsOutText += "     echo %EM% priming Jython package cache"
$arrOdiParamsOutText += "     exit /b 1"
$arrOdiParamsOutText += ")"
$arrOdiParamsOutText += "REM"
$arrOdiParamsOutText += "REM OdiScm: end of Jython package cache priming insertion"
$arrOdiParamsOutText += "REM"

#
# Define the script text that calls odiparams.bat from restartsession.bat.
# We will replace the call with the actual odiparams.bat script text.
#
$RestartSessOdiParamsCallText = '^call \"%ODI_HOME%\\bin\\odiparams.bat.*$'

#
# Load restartsession.bat into an array.
#
$arrRestartSessContent = get-content $RestartSessBat

$OutRestartSessScriptFileContent = $arrRestartSessContent | foreach {
	if ($_ -match $RestartSessOdiParamsCallText) {
		#
		# Replace the call to odiparams.bat in the pipeline output.
		#
		foreach ($x in $arrOdiParamsOutText) {
			write-output $x
		}
	}
	else {
		#
		# Pass through the current record to the pipeline output.
		#
		write-output $_
	}
}

#
# Expand variable values and complete SET statements.
#
$OutExpandedRestartSessScriptFileContent = OdiExpandedBatchScriptText $OutRestartSessScriptFileContent

#
# Define output file names.
#
$OutWrapperBat = $args[0]
$OutWrapperBatFile = split-path $OutWrapperBat -leaf
$OutDir = split-path $OutWrapperBat -parent

$OutRestartSessBatFile = $OutWrapperBatFile -replace ".bat$", ""
$OutRestartSessBatFile += "_OdiScmRestartSess.bat"
$OutRestartSessBat = $OutDir + "\" + $OutRestartSessBatFile

#
# Create the RestartSess script file.
#
set-content -path $OutRestartSessBat -value $OutExpandedRestartSessScriptFileContent
if (!($?)) {
	write-output "$EM writing RestartSess script file <$OutRestartSessBat>"
	exit 1
}

#
# Create the wrapper script, used to capture and stderr from the RestartSess script.
#
$strStdOutFile = $OutRestartSessBat + ".stdout"
$strStdErrFile = $OutRestartSessBat + ".stderr"
$strStdErrNoWarnsFile = $OutRestartSessBat + ".NoWarns.stderr"
$strStdErrOnlyWarnsFile = $OutRestartSessBat + ".OnlyWarns.stderr"
$strEmptyFile = $OutRestartSessBat + ".empty"

$strProc = $OutWrapperBatFile.replace(".bat","")

$ScriptFileContent = ""
$ScriptFileContent += "@echo off" + [Environment]::NewLine
$ScriptFileContent += "set PROC=" + $strProc + [Environment]::NewLine
$ScriptFileContent += "set IM=" + $strProc + ": INFO:" + [Environment]::NewLine
$ScriptFileContent += "set EM=" + $strProc + ": ERROR:" + [Environment]::NewLine
$ScriptFileContent += "set WM=" + $strProc + ": WARNING:" + [Environment]::NewLine

$ScriptFileContent += 'type NUL 1>"' + $strEmptyFile + '"' + [Environment]::NewLine
$ScriptFileContent += "if ERRORLEVEL 1 (" + [Environment]::NewLine
$ScriptFileContent += "	echo %EM% creating empty file ^<" + $strEmptyFile + "^>" + [Environment]::NewLine
$ScriptFileContent += "	goto ExitFail" + [Environment]::NewLine
$ScriptFileContent += ")" + [Environment]::NewLine

$ScriptFileContent += "echo %IM% executing OracleDI command ^<%*^>" + [Environment]::NewLine
$ScriptFileContent += 'call "' + $OutRestartSessBat + '" %*' 
$ScriptFileContent += ' 1>"' + $strStdOutFile +'"'
$ScriptFileContent += ' 2>"' + $strStdErrFile +'"'
$ScriptFileContent += [Environment]::NewLine

$ScriptFileContent += "if ERRORLEVEL 1 (" + [Environment]::NewLine
$ScriptFileContent += "	echo %EM% calling OracleDI command. StdErr text ^<" + [Environment]::NewLine
$ScriptFileContent += '	type "' + $strStdErrFile + '"' + [Environment]::NewLine
$ScriptFileContent += "	echo ^>" + [Environment]::NewLine
$ScriptFileContent += "	goto ExitFail" + [Environment]::NewLine
$ScriptFileContent += ")" + [Environment]::NewLine

#
# Bugs in JRockit present messages about performance counters, on Windows, being inaccessible. Report them.
#
$ScriptFileContent += 'grep "\[WARN \]\[osal   \]" "' + $strStdErrFile + '" > "' + ${strStdErrOnlyWarnsFile} + '"' + [Environment]::NewLine
#
# ODI writes info messages about SqlUnload starting/finishing to stderr. Grrrrrrr. Report them.
#
$ScriptFileContent += 'grep "NOTIFICATION ODI-.*: SqlUnload" "' + ${strStdErrFile} + '" >> "' + ${strStdErrOnlyWarnsFile} + '"' + [Environment]::NewLine
$ScriptFileContent += 'fc "' + $strEmptyFile + '" "' + ${strStdErrOnlyWarnsFile} + '" >NUL' + [Environment]::NewLine
$ScriptFileContent += "if ERRORLEVEL 1 (" + [Environment]::NewLine
$ScriptFileContent += "	echo %WM% command StdErr text contains warning text ^<" + [Environment]::NewLine
$ScriptFileContent += '	type "' + $strStdErrOnlyWarnsFile + '"' + [Environment]::NewLine
$ScriptFileContent += "	echo ^>" + [Environment]::NewLine
$ScriptFileContent += ")" + [Environment]::NewLine
$ScriptFileContent += [Environment]::NewLine

#
# Bugs in JRockit present messages about performance counters, on Windows, being inaccessible. Ignore them.
#
$ScriptFileContent += 'grep -v "\[WARN \]\[osal   \]" "' + $strStdErrFile + '" > "' + "${strStdErrNoWarnsFile}.1" + '"' + [Environment]::NewLine
#
# ODI writes info messages about SqlUnload starting/finishing to stderr. Grrrrrrr. Ignore them.
#
$ScriptFileContent += 'grep -v "NOTIFICATION ODI-.*: SqlUnload" "' + "${strStdErrNoWarnsFile}.1" + '" > "' + "${strStdErrNoWarnsFile}.2" + '"' + [Environment]::NewLine
$ScriptFileContent += 'fc "' + $strEmptyFile + '" "' + "${strStdErrNoWarnsFile}.2" + '" >NUL' + [Environment]::NewLine
$ScriptFileContent += "if ERRORLEVEL 1 (" + [Environment]::NewLine
$ScriptFileContent += "	echo %EM% calling OracleDI command. StdErr text ^<" + [Environment]::NewLine
$ScriptFileContent += '	type "' + $strStdErrFile + '"' + [Environment]::NewLine
$ScriptFileContent += "	echo ^>" + [Environment]::NewLine
$ScriptFileContent += "	goto ExitFail" + [Environment]::NewLine
$ScriptFileContent += ")" + [Environment]::NewLine
$ScriptFileContent += [Environment]::NewLine
$ScriptFileContent += ":ExitOk" + [Environment]::NewLine
$ScriptFileContent += "exit 0" + [Environment]::NewLine
$ScriptFileContent += ":ExitFail" + [Environment]::NewLine
$ScriptFileContent += "exit 1" + [Environment]::NewLine

set-content -path $OutWrapperBat -value $ScriptFileContent
if (!($?)) {
	write-output "$EM writing output file"
	exit 1
}

#
# Exit with a success code.
#
exit 0
