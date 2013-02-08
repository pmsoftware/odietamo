# Clear the flag
BEGIN {
    FoundSection = 0;
}

# Entering the section, set the flag.
/^\[ARGV[1]/ {
    FoundSection = 1;
}

# Modify the line if we're in the section.
/^ARGV[2]=/ {
    if (FoundSection) {
        print ARGV[2]=ARGV[3];
        skip = 1;
    }
}

# Clear the section flag (as we're in a new section)
/^\[$/ {
    FoundSection = 0;
}

# Output a line (that we didn't output above)
/.*/ {
    if (skip)
        skip = 0;
    else
        print $0;
}