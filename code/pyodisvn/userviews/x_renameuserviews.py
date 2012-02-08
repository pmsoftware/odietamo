#
import os

"""
related to x_userviews_extract.py and x_userviews_extract_parse.py

I have now got Nicks file,
and I want to convert that into seperate sql files.
DO so using x_userviews_extract_parse.py


"""

SRCFLDR = r'C:\$WELLKNOWNINSURER_DATA\UserViews'
NICKSRETURNEDFILE = os.path.join(SRCFLDR, 'AllProdUVs4Brains_20120105.txt')
TGTFLDR = r'C:\$WELLKNOWNINSURER_DATA\UserViews\extracted_uv'


def oneoff2():

    names_of_files_from_live = os.listdir(TGTFLDR)
    cmdo = open(os.path.join(SRCFLDR,"foo.bat"), "w")
    foundfiles = []
    for root, dirs, files in  os.walk(r'C:\$WELLKNOWNINSURER_CODE\MOI_SVN'):
        for f in files:
            if f in names_of_files_from_live:
                print ".",
                foundfiles.append(f)

                cmd = "diff -ibwEB %s %s > %s"  % (os.path.join(TGTFLDR, f),
                               os.path.join(root, f),
                               "%s.diff" % os.path.join(r'C:\odi\code_recovery\diff_exe_new_decompile', f)
                                           )   
                cmdo.write(cmd + "\n")

    sfoundfiles = set(foundfiles)
    snames_of_files_from_live = set(names_of_files_from_live)

    print "FOund %s files in live baseline that are in SVN" % len(sfoundfiles)
    print "%s files not found in SVN" % len(snames_of_files_from_live - sfoundfiles)
    for missingfile in  sorted(snames_of_files_from_live - sfoundfiles):
        print missingfile


#oneoff2()
oneoff2()