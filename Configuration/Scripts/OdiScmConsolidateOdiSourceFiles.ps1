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
		
		#write-host "doing file "$file
		$RecordList = get-content $File
		
		$blnFoundXmlDocHeader           = $False
		#$blnFoundXmlDocTrailer         = $False
		$blnFoundExportHeader           = $False
		#$blnFoundExportTrailer         = $False
		$blnFoundAdminRepositoryVersion = $False
		$blnFoundSummaryHeader          = $False
		#$blnFoundSummaryTrailer        = $False
		
		foreach ($Record in $RecordList) {
			
			$blnSuppressRecord = $False
			
			if ($Record -eq "") {
				if (!($blnFoundXmlDocHeader)) {
					#
					# Unexpected records before the XML doc header.
					#
					write-error "$EM found unexpected blank line before the XML doc header"
					return $False
				}
				if (!($blnFoundExportHeader)) {
					#
					# Unexpected records before the export header.
					#
					write-error "$EM found unexpected blank line before the export header"
					return $False
				}
			}
			
			if ($Record -eq '<?xml version="1.0" encoding="ISO-8859-1"?>') {
				if ($blnFoundXmlDocHeader) {
					# Another XML doc header found.
					write-error "$EM found duplicate XML doc header"
					return $False
				}
				else {
					$blnFoundXmlDocHeader = $True
					$blnSuppressRecord = $True
				}
			}
			
			if ($Record -eq '<SunopsisExport>') {
				if ($blnFoundExportHeader) {
					# Another export header found.
					write-error "$EM found duplicate export header"
					return $False
				}
				else {
					$blnFoundExportHeader = $True
					$blnSuppressRecord = $True
				}
			}
			
			if ($Record.StartsWith('<Admin RepositoryVersion="')) {
				$blnSuppressRecord = $True
			}
			
			if ($Record -eq '<Object class="com.sunopsis.dwg.DwgExportSummary">') {
				if ($blnFoundSummaryHeader) {
					# Another summary start found.
					write-error "$EM found duplicate summary start"
					return $False
				}
				else {
					$blnFoundSummaryHeader = $True
					$blnSuppressRecord = $True
				}
			}
			
			#
			# Decide what to do with the record.
			#
			if (!($blnFoundSummaryHeader)) {
				# Only output records before the start of the summary section.
				if ($blnFoundXmlDocHeader) {
					if ($blnFoundExportHeader) {
						if (!($blnSuppressRecord)) {
							# The current record is a source object/object attribute.
							$outRecordList += $Record
						}
					}
				}
			}
		}
	}
	
	$outRecordList += '</SunopsisExport>'
	$outRecordList | set-content $outFile
	return $True
}