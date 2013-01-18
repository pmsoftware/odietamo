. "C:\MOI_TEST\MOIPOC\Configuration\Powershell\Constants.ps1"

#We will log all preview results into a unique resultFile as a starter
#So that we will have full visibility if they make a change or not. 
#In future [when we are comfortable we can write the results into the same file with overwriting, 

########################################
## 0. Parameters ##
########################################

write-host "0. [Parameters] Started... "

$searchText="you have a conflicting edit"
$endOfConflictText= "Unable to perform the get"
$summaryText="---- Summary"

write-host "0. [Parameters] Ended... "

########################################
##  1. GetPreview                     ##
########################################
function GetPreview 
{
	$resultValue=$false
	write-host "1. [GetPreview] Started ..."
	write-host "1. [GetPreview] Preview Get Latest and write output to " $resultFile
	
	try
	{
		tf get $OdiFolder /all /preview /recursive /noprompt >$resultFile 2>&1
		$resultValue=$true
	}
	catch
	{
		write-host "1. [GetPreview] Error: " $_.Exception
	}
	write-host "1. [GetPreview] Ended ..."
	return $resultValue
}

########################################
##  2. Try to get from TFS            ##
########################################

function GetFromTFS 
{
	$resultValue=$false
	write-host "2. [GetFromTFS] Started ..."
	write-host "2. [GetFromTFS] Try to get latest from TFS"
	write-host "2. [GetFromTFS] Read the content from "  $resultFile
	write-host "2. [GetFromTFS] Write the output to " $devResultFile

	#Once summary did not have details for the conflicts, we may need to check if it has details/we can capture them.
	$indexSummary= Get-Content $resultFile | out-string |% {$_.IndexOf($summaryText)}
	$indexConflict= Get-Content $resultFile | out-string |% {$_.LastIndexOf($endOfConflictText)}

	$x=Get-Content $resultFile | out-string 
	$searchtextcontent=  "(?<content>.*)" + $searchText 
	if ($x -match  $searchtextcontent )
        { 
        	$message= $matches['content'] +$searchText            
                $a = new-object -comobject wscript.shell
                $b = $a.popup($message,0,"MOI ODI Get Latest",1)
                $message | Out-File -filepath $devResultFile -append
                write-host "2. [GetFromTFS] Finished. There are conflicts. Please check " $devResultFile
                finish
        }
	else
    	{
        	tf get $OdiFolder /all /recursive /noprompt >$resultFile 2>&1
	        write-host "2. [GetFromTFS] Get Latest Finished. There are no conflicts. Getting latest on local working copy."        
		$resultValue=$true
    	}
	write-host "2. [GetFromTFS] Ended ..."
	return $resultValue

}

########################################
##   3. Get Master to be imported
########################################
#By default “Insert_update”  for everything
#For these Do insert first, if fails do update. 
#-project
#-folder
#-model
#-submodel
########################################
function ImportMaster{

    write-host "3. [ImportMaster] Getting master files from: " $OdiFolder 
    write-host "3. [ImportMaster] Writing output to: " $ImportMasterScriptOutput 
    $masterFiles=Get-ChildItem  $OdiFolder -recurse | Where-Object { $_.PSIsContainer } | Where-Object { $_.Name -contains "master" }
    cd $OdiBinFolder

    "cd ${odiBinFolder}"| Out-File -filepath $ImportMasterScriptOutput -encoding ASCII -append
    #we will loop for each extension to generate the import.bat have ordered commands. 
    foreach($ext in $orderedExtensions) 
    { 
        write-host "3. [ImportMaster] ext:" $ext 
        $files= get-childitem $masterFiles.FullName -recurse -include $ext 
        write-host "3. [ImportMaster] files.Count" : $files.Count
        #write-host "3. [ImportMaster] files:" $files
        
        if ($files.Count -ge 1)
        {
            #process all filea with this extension
            foreach($file in $files)
            {     
                    $fileToImport= $masterFiles.FullName + "\"  +  $file.Name 
                    write-host "3. [ImportMaster] fileToImport:" $fileToImport
                    #direct execution did not work, so we are generating commands and put into a batch file.
                    $testCommand= "call startcmd.bat OdiImportObject -file_name=" + $fileToImport + " -IMPORT_MODE=" + $IMPORT_MODE + " -WORK_REP_NAME=" + $WORK_REP_NAME + " -SECURITY_DRIVER=" + $SECURITY_DRIVER + " -SECURITY_URL=" + $SECURITY_URL + "  -SECURITY_USER=" + $SECURITY_USER + " -SECURITY_PWD=" + $SECURITY_PWD + " -USER=" + $USER + " -PASSWORD=" + $PASSWORD + ">" + $ImportMasterLogFolder + $file.Name + " 2>&1" 
    				
                    #write-host $testCommand 
                    $testCommand | Out-File -filepath $ImportMasterScriptOutput -encoding ASCII -append
            }
        }
        
    } 
    write-host "3. [ImportMaster] Finished writing output to: " $ImportMasterScriptOutput 
}
################################################
## 4. Import NonMaster Files
################################################
function ImportNonMaster {
    write-host "4.[ImportNonMaster] Getting non master files from: " $OdiFolder
    write-host "4.[ImportNonMaster] Writing output to: " $ImportNonMasterScriptOutput 
    $nonMasterFileCount =0
    $nonMasterFiles=Get-ChildItem  $OdiFolder -recurse | Where-Object { $_.PSIsContainer } | Where-Object {  !($_.Name -match 'master' ) }
    write-host "4.[ImportNonMaster]" $nonMasterFiles.Count
    
    cd $OdiBinFolder
    "cd ${odiBinFolder}" | Out-File  $ImportNonMasterScriptOutput -encoding ASCII -append
    #we will loop for each extension to generate the import.bat have ordered commands. 
    

    foreach($ext in $orderedExtensions) 
    { 
        #write-host "Looping for ext:" $ext 
        foreach($nonMasterFile in $nonMasterFiles) 
        {
            #write-host $nonMasterFile.FullName
            $files= @(get-childitem $nonMasterFile.FullName -recurse -include $ext) 
            $nonMasterFileCount +=$files.Count
            #write-host "files.Count" : $files.Count
            #write-host "files & count:" $files ", " $files.Count 
            
            if ($files.Count -ge 1)
            {
                #process all filea with this extension
                foreach($file in $files)
                {     
                        $fileToImport= $nonMasterFile.FullName + "\"  +  $file.Name 
                        write-host "5.[ImportNonMaster] fileToImport:" $fileToImport
                        #direct execution did not work, so we are generating commands and put into a batch file.
                        $testCommand= "call startcmd.bat OdiImportObject -file_name=" + $fileToImport + " -IMPORT_MODE=" + $IMPORT_MODE + " -WORK_REP_NAME=" + $WORK_REP_NAME + " -SECURITY_DRIVER=" + $SECURITY_DRIVER + " -SECURITY_URL=" + $SECURITY_URL + " -SECURITY_USER=" + $SECURITY_USER + " -SECURITY_PWD=" + $SECURITY_PWD + " -USER=" + $USER + " -PASSWORD=" + $PASSWORD + ">" + $ImportNonMasterLogFolder + $file.Name + " 2>&1" 
                        
                        
                        $testCommand | Out-File -filepath $ImportNonMasterScriptOutput -encoding ASCII -append
                }
            }
        }
    } 
    write-host "4. [ImportNonMaster] Finished writing output to: " $ImportNonMasterScriptOutput 
    write-host "4. [ImportNonMaster] Expected result" $nonMasterFileCount
    write-host "4. [ImportNonMaster] Actual result: " (Get-Content $ImportNonMasterScriptOutput).Count-1
}
if ($loadConstants) 
{
	write-host "0. LoadConstants successful. Will do Get Preview from TFS."

	if(GetPreview)
	{
		write-host "1. Get Preview successful. Will do Get Latest from TFS."
		if(GetFromTFS)
		{
			write-host "2. Get from TFS successful."
	
		}
		else
		{
			write-host "2. Get from TFS failed."
		}

	}
	else
	{
		"1. Get Preview failed."
	}

}
else
{
	"0. Load constants failed."
}
