#
# The main function.
#
function GenerateUnitTestExecScript($strOutputFile) {
	
	$FN = "GenerateUnitTestExecScript"
	$IM = $FN + ": INFO:"
	$EM = $FN + ": ERROR:"
	$DEBUG = $FN + ": DEBUG:"
	
	write-host "$IM starts"
	$ExitStatus = $False
	write-host "$IM output will be written to file <$strOutputFile>"
	
	#
	# Generate the list of FitNesse command line calls.
	#
	$CmdOutput = ExecOdiRepositorySql "$ScriptsRootDir\OdiScmGenerateUnitTestExecs.sql" "$env:TEMPDIR" "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmJisqlRepo.bat"
	if (! $CmdOutput) {
		write-host "$EM error generating ODI unit test execution calls list"
		return $ExitStatus
	}
	
	#
	# Write the output batch file.
	#
	$arrOutFileLines = @()
	$arrOutFileLines += '@echo off'
	
	$strOutPutFileName = (split-path $strOutputFile -leaf) -replace ".bat", ""
	
	$arrOutFileLines += ('set PROC=' + $strOutPutFileName)
	$arrOutFileLines += 'set IM=%PROC%: INFO:'
	$arrOutFileLines += 'set EM=%ERROR%: INFO:'
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
	$arrOutFileLines += 'set TOTALTESTFAILURES=0'
	$arrOutFileLines += 'set TOTALTESTPAGEPASSES=0'
	$arrOutFileLines += 'set TOTALTESTPAGEFAILURES=0'
	$arrOutFileLines += 'set TOTALTESTPAGESMISSING=0'
	$arrOutFileLines += 'setlocal enabledelayedexpansion'
	$arrOutFileLines += ''
	
	$arrCmdOutput = ($CmdOutput -replace "ExecOdiRepositorySql:", "").split("`n")
	
	foreach ($CmdOutputLine in $arrCmdOutput) {
		
		###write-host "$IM processing query result row <$CmdOutputLine>"
		$strNoCR = $CmdOutputLine -replace "`r", ""
		$strNoCR = $strNoCR -replace "`n", ""
		$strNoCR = $strNoCR.Trim()
		$arrOutputLineParts = $strNoCR.split("/")
		$strOdiObj = "Type:" + $arrOutputLineParts[1] + '/ID:' + $arrOutputLineParts[2] + '/Name:' + $arrOutputLineParts[3]
		$arrOutFileLines += ('echo %IM% executing unit tests for ODI object ^<' + $strOdiObj + '^>')
		$arrOutFileLines += 'set /a TOTALTESTPAGES=%TOTALTESTPAGES% + 1'
		
		$strFitNesseCmd  = ('"' + $env:ODI_SCM_TOOLS_FITNESSE_JAVA_HOME + '\bin\java.exe" -jar lib/fitnesse-standalone.jar ')
		$strFitNesseCmd += ('-d "' + $env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT +'" -r "' + $env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME + '" ')
		$strFitNesseCmd += ('-p ' + $env:ODI_SCM_TEST_FITNESSE_PORT + ' ')
		$strFitNesseCmd += '-c "'
		
		$strTestPagePath = ""
		
		if ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME -ne "") {
			$strTestPagePath += ($env:ODI_SCM_TEST_FITNESSE_UNIT_TEST_ROOT_PAGE_NAME + '.')
		}
		
		if (($arrOutputLineParts[0] -ne "") -and ($arrOutputLineParts[0] -ne $Null)) {
			$strTestPagePath += ('OdiProject' + $arrOutputLineParts[0] + '.')
		}
		
		$strTestPagePath += ('Odi' + $arrOutputLineParts[1] + $arrOutputLineParts[2])
		$strFitNesseCmd += $strTestPagePath
		$strFitNesseCmd += '?test&format=text"'
		
		$strTestPageFilePath = ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_ROOT).Replace("/","\") + "\" + ($env:ODI_SCM_TEST_FITNESSE_ROOT_PAGE_NAME).Replace(".","\") + "\" + $strTestPagePath.Replace(".","\")

		$arrOutFileLines += 'if not EXIST "' + $strTestPageFilePath + '\content.txt"'
		$arrOutFileLines += '	set /a TOTALTESTPAGESMISSING=!TOTALTESTPAGESMISSING! + 1'
		$arrOutFileLines += ') else ('
		$arrOutFileLines += ('	' + $strFitNesseCmd)
		$arrOutFileLines += '	set TESTFAILURES=!ERRORLEVEL!'
		$arrOutFileLines += '	if not "!TESTFAILURES!" == "0" ('
		$arrOutFileLines += '		echo %EM% tests failed 1>&2'
		$arrOutFileLines += '		set /a TOTALTESTFAILURES=!TOTALTESTFAILURES! + !TESTFAILURES!'
		$arrOutFileLines += '		set /a TOTALTESTPAGEFAILURES=!TOTALTESTPAGEFAILURES! + 1'
		$arrOutFileLines += '	) else ('
		$arrOutFileLines += '		echo %EM% tests passed'
		$arrOutFileLines += '		set /a TOTALTESTPAGEPASSES=!TOTALTESTPAGEPASSES! + 1'
		$arrOutFileLines += '	)'
		$arrOutFileLines += ')'
		$arrOutFileLines += 'set /a TOTALTESTFAILURES=!TOTALTESTFAILURES! + !TESTFAILURES!'
		$arrOutFileLines += ''
	}
	
	$arrOutFileLines += 'echo %IM% total test pages attempted ^<%TOTALTESTPAGES%^>'
	$arrOutFileLines += 'echo %IM% total test page failures ^<%TOTALTESTPAGEFAILURES%^>'
	$arrOutFileLines += 'echo %IM% total test page passes ^<%TOTALTESTPAGEPASSES%^>'
	$arrOutFileLines += 'echo %IM% total test pages missing ^<%TOTALTESTPAGESMISSING%^>'
	$arrOutFileLines += 'echo %IM% total test failures ^<%TOTALTESTFAILURES%^>'
	$arrOutFileLines += ''
	$arrOutFileLines += 'if not "%TOTALTESTFAILURES%" == "0" ('
	$arrOutFileLines += '	echo %EM% unit tests have failed 1>&2'
	$arrOutFileLines += '	goto ExitFail'
	$arrOutFileLines += ')'
	$arrOutFileLines += ''
	$arrOutFileLines += ':ExitOk'
	$arrOutFileLines += 'exit %IsBatchExit% 0'
	$arrOutFileLines += ''
	$arrOutFileLines += ':ExitFail'
	$arrOutFileLines += 'exit %IsBatchExit% 1'
	
	$arrOutFileLines | set-content $strOutputFile
	$ExitStatus = $True
	
	write-host "$IM ends"
	return $ExitStatus
}

####################################################################
# Main.
####################################################################

$FN = "OdiScmGenerateUnitTestExec"
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
	write-host "$EM: environment variable ODI_SCM_HOME is not set"
	exit 1
}
else {
	$OdiScmHomeDir = $env:ODI_SCM_HOME
	write-host "$IM using ODI-SCM home directory <$OdiScmHomeDir> from environment variable ODI_SCM_HOME"
}

if (($env:ODI_SCM_INI -eq $Null) -or ($env:ODI_SCM_INI -eq "")) {
	write-host "$EM: environment variable ODI_SCM_INI is not set"
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

if (($args.length -ne 1) -or (($args[0] -eq "") -or ($args[0] -eq $Null))) {
	write-host "$EM invalid arguments specified"
	write-host "$EM usage: $FN <output path and file name>"
	return $False
}

#
# Execute the central function.
#
$ResultMain = GenerateUnitTestExecScript $args[0]
if ($ResultMain) {
	exit 0
}
else {
	exit 1
}