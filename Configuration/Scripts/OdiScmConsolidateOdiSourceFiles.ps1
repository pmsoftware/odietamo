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
	$outRecordList | set-content $outFile
	write-host "$IM finished writing file <$outFile>"
	return $True
}