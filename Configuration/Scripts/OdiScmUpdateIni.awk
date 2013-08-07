BEGIN {
	ProcessingSection = 0;
	###print "Using KeyValue: " KeyValue
}

#^[Import Controls]$ 
#{
	###print "Found section using expression"
#}

/^\[Import Controls\]$/ {
	###print "Found section using regular expression"
	ProcessingSection = 1;
}

/^OracleDI Imported Revision=/ {
	if (ProcessingSection) {
		###print "Found key"
		print "OracleDI Imported Revision=" KeyValue;
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