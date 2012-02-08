

'''
Build a HTML report for any given ODI object,
consisting of

* which environments it exists in
* What the hashes are for each existing item
* Has it been tested


How to build a export or execution pack?



CREATE TABLE tbl_fingerprint_current_batch
(
curr_batch_start_time VARCHAR(64)
)


 
'''
import os
import re
import pprint
import datetime
import random

from mikado.common.db import tdlib
import MOI_user_passwords
from ODI_lib import safe_file_name

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


def find_odiobject(odiobjectname, limitto=[], folder=r'C:\ODICodeForComparison\direct_compare_results'):
    '''look at the hash files stored,
       for each match, return (hashfile, line_matching)

       supports passing in a specific folder of hashfiles

    TODO: replace with lookup on TBL_FINGERPRINT
    '''
    lst = []
    ### looking at hashes
#   Added the ability to pass in a diff folder to look at 
#    folder = ROOTFOLDER
#    folder = bkup_201111101651
    files = [f for f in os.listdir(folder) if f.find(".hashes") >= 0]
    #limit
    if limitto == []:
        files = files
    else:
        files = [f for f in files if f in limitto]
    search_string = odiobjectname#'PNT_ACC_ADDR_CONT'

    for file in files:
        for line in open(os.path.join(folder, file)):
            if line.find("::" + search_string+"::") >= 0:
                lst.append( [file, line] )
    return lst


def find_odiobject_db(odiobjectname, limitto=[], folder=r'C:\ODICodeForComparison\direct_compare_results'):

    '''look at the hash files stored,
       for each match, return (hashfile, line_matching)

       supports passing in a specific folder of hashfiles


    trt::286008.0::BUILD_MOI_CONT::ODISVN_V1.0-c503ab75cdbc405846c3d65650d9e233
    TODO: replace with lookup on TBL_FINGERPRINT
    '''
    lst = []
    SQL = '''SELECT * FROM TBL_FINGERPRINT
             WHERE BATCH_START_TIME IN 
             (SELECT  curr_batch_start_time
              FROM tbl_fingerprint_current_batch) 
             AND SNP_NAME ='%s'
            ORDER BY SNP_NAME, CHKSUM
             ''' % odiobjectname
    connfinger = tdlib.getConn(MOI_user_passwords.get_dsn_details('FINGERPRINT'))
    rs = tdlib.query2obj(connfinger, SQL)
    open(r"c:\sqllog.txt", "a").write(SQL+"\n\n")  

    for row in rs:
        line = "%s::%s::%s::%s" % (row.OBJECTTYPE, row.SNP_ID, 
                                   row.SNP_NAME, row.CHKSUM)    
        lst.append( [row.REPO, line] )
        
    #return lst
    return rs 

def build_html_section_which_env(rs):
    '''
    lst = [    [file, line], [file, line]...
    lsts = [lst,lst


    NB more than one hash stored only shows last one chronologically.
    probbably not good idea
    
    '''

    USER_DIR = r'C:\$WELLKNOWNINSURER_DEPLOY\_interim_ODI_version_mgmt'
    use_this_hash_folder = ''#"bkup_201111101718" #or ''
    ROOTFOLDER = r'C:\ODICodeForComparison\direct_compare_results'
    OUTPUT_HTML_FILEPATH = os.path.join(USER_DIR, "XRepoCompare.html")
    TXT_FILE_OF_TABLES_TO_WATCH = os.path.join(USER_DIR, 'compare_objects.txt')

    colours = ("green", "red", "blue", "grey", "black", "silver","orange")
    #lst.reverse()
    html = '<h3>%s</h3><table border="1">' % rs[0].SNP_NAME

    seen_chksum = ''   

    for row in rs:
        if seen_chksum != row.CHKSUM:
            seen_chksum = row.CHKSUM
            href = r'''../fingerprint/%s/%s/%s''' % (row.REPO, row.SNP_ID, row.SNP_NAME)
            colour = colours[random.randint(0,6)]

        html += '<tr><td>%s</td> <td><font color="%s">%s-%s-%s-%s</font></td><td><a href="%s">link</a></tr>\n' % (row.REPO,
                                                                                                                  colour,
                                                                                                             row.OBJECTTYPE,
                                                                                                             row.SNP_ID,
                                                                                                             row.SNP_NAME,
                                                                                                             row.CHKSUM,href)

    return html + "</table> <hr/>"


def build_html(rs, odiobjectname):
    '''
    compare the obnjectnames to the lsts
    '''
    USER_DIR = r'C:\$WELLKNOWNINSURER_DEPLOY\_interim_ODI_version_mgmt'
    use_this_hash_folder = ''#"bkup_201111101718" #or ''
    ROOTFOLDER = r'C:\ODICodeForComparison\direct_compare_results'
    OUTPUT_HTML_FILEPATH = os.path.join(USER_DIR, "XRepoCompare.html")
    TXT_FILE_OF_TABLES_TO_WATCH = os.path.join(USER_DIR, 'compare_objects.txt')
    
    fo = open(OUTPUT_HTML_FILEPATH, "w")
    html = ''
    html += "<h3>Comparing hash-codes for different objects.</h3>"
    if len(rs) == 0:
        return "No results found"
        
    html += build_html_section_which_env(rs)
    fo.write(html)
    fo.close()
    return html

def sillygrep(lst, searchstring):
    for file, line in lst:
        tgt = safe_file_name(line.split("::")[2]) + ".log"
        file = file.replace(".hashes", "")
        filepath = os.path.join(os.path.join(ROOTFOLDER, file), tgt)
        for l in open(filepath):
            if l.find(searchstring) >=0 :
                print "%s\n%s" % (filepath, l)

def get_objects_from_file(TXT_FILE_OF_TABLES_TO_WATCH):
    ''' '''
    odiobjectnames = []
    f = TXT_FILE_OF_TABLES_TO_WATCH
    for line in open(f):
        odiobjectnames.append(line.strip().replace("\n","").replace("\r",""))
    return odiobjectnames
        

def main():
    '''used to compare many file names from a text file '''

    #CONST
    USER_DIR = r'C:\$WELLKNOWNINSURER_DEPLOY\_interim_ODI_version_mgmt'
    use_this_hash_folder = ''#"bkup_201111101718" #or ''
    ROOTFOLDER = r'C:\ODICodeForComparison\direct_compare_results'
    OUTPUT_HTML_FILEPATH = os.path.join(USER_DIR, "XRepoCompare.html")
    TXT_FILE_OF_TABLES_TO_WATCH = os.path.join(USER_DIR, 'compare_objects.txt')
    
    
    odiobjectnames = get_objects_from_file(TXT_FILE_OF_TABLES_TO_WATCH)
    html = ''  
    odiobjectnames = [o.strip() for o in odiobjectnames]
    print odiobjectnames
    for objectname in odiobjectnames:
        rs = find_odiobject_db(objectname)
        html += build_html(rs, objectname)

    open(OUTPUT_HTML_FILEPATH, 'w').write(html)
    

def comparebyname(objectname):

    lsts = []
    limitto = []
    ## get back rs of SELECT * FROM TBL_FINGERPRINT
    rs = find_odiobject_db(objectname, limitto=limitto)# folder=os.path.join(ROOTFOLDER, use_this_hash_folder))

    html = build_html(rs, objectname)
    return html



if __name__ == '__main__':

    main()
