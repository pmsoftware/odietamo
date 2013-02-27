/^\[<SectionName>\]$/ {
	###print "Found section using regular expression";
	FoundSection = 1;
	ProcessingSection = 1;
}

/^<KeyName>=/ {
	if (ProcessingSection) {
		###print "Found key";
		FoundKey = 1
		print "<KeyName>=<KeyValue>";
	}
	WrittenKey = 1;
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

END {
	if (FoundKey)
		exit 0;
	else if (FoundSection)
		exit 1;
}