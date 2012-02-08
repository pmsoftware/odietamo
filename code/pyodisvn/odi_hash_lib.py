

'''
Build a HTML report for any given ODI object,
consisting of

* which environments it exists in
* What the hashes are for each existing item
* Has it been tested

AS CURRENTLY SET WILL COMPARE HASHESH BETWEEN TWO RUNS

'''
import os
import re
import pprint

#from ODI_text_concate import safe_file_name

def get_hashes_as_set(hashfilepath, fingerprinttype):
    ''' '''
    setf = set()
    for line in open(hashfilepath):
        if fingerprinttype == "NAMEONLY":
            hash = line.split("::")[2]
        elif fingerprinttype == "NAMEANDHASH":
            hash = line.split("::")[2] +  "+" + line.split("::")[3]
        else:
            raise "Error wrong fingerprinttype"
        setf.add(hash)
    return setf

def intersection_of_hashes(fingerprinttype):
    '''
    trt::286008.0::BUILD_MOI_CONT::ODISVN_V1.0-c503ab75cdbc405846c3d65650d9e233
    type : NAMEONLY    - BUILD_MOI_CONT
         : NAMEANDHASH - BUILD_MOI_CONT+ODISVN_V1.0-c503ab75cdbc405846c3d65650d9e233
    '''
    setdict = {}
    files = [f for f in os.listdir(ROOTFOLDER) if f.find(".hashes") >= 0]
    for f in files:
        setf =  get_hashes_as_set(os.path.join(ROOTFOLDER, f), fingerprinttype)
        setdict[f] = setf
    setlist = [setdict[st] for st in sorted(setdict.keys())]
    intersection = setlist[0].intersection(*setlist[1:])
    union = setlist[0].union(*setlist[1:])
    return (intersection, union)

def compare_uat_prod(fingerprinttype):
    #fingerprinttype = "NAMEONLY"
    files = ['$DBCONNREF.hashes', '$DBCONNREF.hashes']
    setprod =  get_hashes_as_set(os.path.join(ROOTFOLDER, '$DBCONNREF.hashes'), fingerprinttype)
    setuat =  get_hashes_as_set(os.path.join(ROOTFOLDER, '$DBCONNREF.hashes'), fingerprinttype)
    intersection = setprod.intersection(setuat)
    union = setprod.union(setuat)
    return (intersection, union)

def compare_uat_uat(fingerprinttype):
    #fingerprinttype = "NAMEONLY"
    files = ['$DBCONNREF.hashes', '$DBCONNREF.hashes']
    setleft =  get_hashes_as_set(os.path.join(lhsfolder, '$DBCONNREF.hashes'), fingerprinttype)
    setright =  get_hashes_as_set(os.path.join(rhsfolder, '$DBCONNREF.hashes'), fingerprinttype)
    intersection = setleft.intersection(setright)
    union = setleft.union(setright)
    print len(setleft), len(setright)
    return (intersection, union, setleft, setright)


def find_obiobject(odiobjectname, limitto=["$DBCONNREF.hashes",]):
    '''
    '''
    lst = []
    ### looking at hashes
    folder = ROOTFOLDER
    files = [f for f in os.listdir(folder) if f.find(".hashes") >= 0]
    #limit
    files = [f for f in files if f in limitto]
    search_string = odiobjectname#'PNT_ACC_ADDR_CONT'

    for file in files:
        for line in open(os.path.join(folder, file)):
            if line.find(search_string) >= 0:
                lst.append( [file, line] )
    return lst

def build_html_section_which_env(lst):
    '''
    lst = [    [file, line], [file, line]...
    lsts = [lst,lst


    NB more than one hash stored only shows last one chronologically.
    probbably not good idea
    
    '''
    lst.reverse()
    html = '<h3>%s</h3><table border="1">' % lst[0][1].split("::")[2]

    seenfile = ''     
    for file, line in lst:
        if seenfile != file:
            html += "<tr><td>%s</td> <td>%s</td></tr>\n" % (file, line)
            seenfile = file
        else:
            pass
    return html + "</table> <hr/>"


def build_html(lsts):
    '''
    ''' 
    fo = open("foo.html", "w")
    for lst in lsts:
        fo.write(build_html_section_which_env(lst))
    fo.close()

def sillygrep(lst, searchstring):
    for file, line in lst:
        tgt = safe_file_name(line.split("::")[2]) + ".log"
        file = file.replace(".hashes", "")
        filepath = os.path.join(os.path.join(ROOTFOLDER, file), tgt)
        for l in open(filepath):
            if l.find(searchstring) >=0 :
                print "%s\n%s" % (filepath, l)


def intersection():
    
    intersection, union = intersection_of_hashes("NAMEONLY")
    print "We have %s file names that are in every repo, and %s filenames in total, making %s files to possibly throw" % (len(intersection), len(union), len(union)-len(intersection))

    intersection2, union2 = intersection_of_hashes("NAMEANDHASH")
    print "We have %s in common file fingerprints, and %s filefingerprints in total" % (len(intersection2), len(union2))

    
    open("possible_junk.txt","w").write(pprint.pformat(sorted(union-intersection)))
    open("in_every_repo.txt","w").write(pprint.pformat(sorted(intersection)))

    open("possible_junkwithhash.txt","w").write(pprint.pformat(sorted(union2-intersection2)))
    open("in_every_repowithhash.txt","w").write(pprint.pformat(sorted(intersection2)))


    i, u = compare_uat_prod("NAMEONLY")
    ihash, uhash = compare_uat_prod("NAMEANDHASH")

    print "For just Prod and $DBCONNREF We have %s file names that are in every repo, and %s filenames in total, making %s files to possibly throw" % (len(i), len(u), len(u)-len(i))

    open("uatprod_possible_junk.txt","w").write(pprint.pformat(sorted(u-i)))
    open("uatprod_in_every_repo.txt","w").write(pprint.pformat(sorted(i)))

    open("uatprod_possible_junkwithhash.txt","w").write(pprint.pformat(sorted(uhash-ihash)))
    open("uatprod_in_every_repowithhash.txt","w").write(pprint.pformat(sorted(ihash)))

    print """however, if we looked at obvious junk files, with this regex("_\d+$") matching things like
    ' POP_ERP_CORP_SUBSCRIBER_OP_2100223' we can remove 
    """
    rgx = re.compile("_\d+$")
    junklist = []
    for file in intersection:
        if rgx.search(file) is not None:
            junklist.append(file)
    print len(junklist)
    open("regexjunklist.txt","w").write(pprint.pformat(sorted(junklist)))
        

def main():
#    odiobjectnames = ['MUBUILD_PEXR', 'MUT007']
    odiobjectnames = ['BUILD_PERS_PERX_2', 'BUILD_PRAD']
    lsts = []
    for odiobjectname in odiobjectnames:
        lst = find_obiobject(odiobjectname,limitto=["$DBCONNREF.hashes", "$DBCONNREF.hashes",
                                                    "$DBCONNREF.hashes", "$DBCONNREF.hashes", "$DBCONNREF.hashes"])
        lsts.append(lst)
    build_html(lsts)

    #sillygrep(lst, "Determine the earliest and latest dates for the role in effect at the time of the load.")


    

if __name__ == '__main__':
    #CONST
    ROOTFOLDER = r'C:\ODICodeForComparison\direct_compare_results'
    ROOTFOLDER = r'C:\ODICodeForComparison\direct_compare_results\bkup_201110101146'
#    fingerprinttype = "NAMEANDHASH"
#    lhsfolder = r'C:\ODICodeForComparison\direct_compare_results\bkup_201110072131'
#    rhsfolder = r'C:\ODICodeForComparison\direct_compare_results'
#    i,u,l,r =  compare_uat_uat(fingerprinttype)
    main()
    