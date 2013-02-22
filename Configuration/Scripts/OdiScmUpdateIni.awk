BEGIN {
	ProcessingSection = 0;
	###print "Using KeyValue: " KeyValue
}

#^[ImportControls]$ 
#{
	###print "Found section using expression"
#}

/^\[ImportControls\]$/ {
	###print "Found section using regular expression"
	ProcessingSection = 1;
}

/^OracleDIImportedRevision=/ {
	if (ProcessingSection) {
		###print "Found key"
		print "OracleDIImportedRevision=" KeyValue;
	}
	WrittenKey = 1
}

/^\[$/ {
	# Start of a section clear the flag (actions above already processed).
	ProcessingSection = 0;
}

/.*/ {
	if (WrittenKey)
		WrittenKey = 0;
	else
		print $0;
}