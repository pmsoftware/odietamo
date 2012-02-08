import pprint
import os
import re
import sys

"""
Use in conjunction with x_userviews_extract.py
The above will output a file suitable for nick to run on priduction
Then He returns a file, which this then parses into hundreds of correctly named userviews.
I hope...

Now we use x_renameuserviews.py

Manual fixes :

SOme userviews have syntax

CREATE PROD_B_UKM_USER_VIEW. addresses

THe space kills my regex and is really poor practise even if Teradata accetps it so manually fix this in nicks file

introduce a test for this?

"""

SRCFLDR = r'C:\$WELLKNOWNINSURER_DATA\UserViews'
NICKSRETURNEDFILE = os.path.join(SRCFLDR, 'AllProdUVs4Brains_20120105.txt')
TGTFLDR = r'C:\$WELLKNOWNINSURER_DATA\UserViews\extracted_uv'

def outputtext(currtext, filename):
    ''' output currtext into a file'''
    print filename
    open(os.path.join(TGTFLDR, filename), "w").write(currtext)

def test_for_horrors():
    for line in open(NICKSRETURNEDFILE):
        if line.lower().find("user_view. "):
            print "possible syntax challenge ", line)
    raw_input("continue?")
    
def extract_views():
    f = NICKSRETURNEDFILE
    regex = re.compile("CREATE +VIEW.*?;|REPLACE +VIEW.*?;",re.DOTALL)
    txt = open(f).read()
    m = regex.findall(txt)
    return m
    
    
    

def sanitise_view(view):
    '''
    take a replace view stmt, with prod_ in it, and clean it up
    some of this is duplicated in the fingerprinter...

    >>> view = "PROD_A_BHA_TARTAN_BASE_VIEWS.MONTH_END_DATES;"
    >>> sanitise_view(view)
    '${context}_A_BHA_TARTAN_BASE_VIEWS.MONTH_END_DATES;'

    '''

    replacestrings = [('prod_[aA]_', '${context}_A_')
                    , ('prod_[bB]_', '${context}_B_')
                       ]

    for rstr, tostr in replacestrings:
        rx = re.compile(rstr, re.IGNORECASE|re.DOTALL)
        view = rx.sub(tostr, view)    

    return view

def get_filename(view):
    '''
    >>> view = """REPLACE VIEW PROD_A_UKM_MCRY_USER_VIEWS.ACCOUNT_DELEGATES\
                  (USER_PARTY_ID,DELEGATE_USER_PARTY_ID,"""
    >>> get_filename(view)
    'moi_a_ukm_mcry_createview_account_delegates_t2.sql'
    '''
    regex = re.compile("VIEW.*?(PROD_.*?)\.(\w+)",re.IGNORECASE|re.DOTALL)
    r = regex.search(view)
    try:
        dbase, viewname = r.groups()
    except:
        print "Whoops", view[:50]
        return "error"

    ########################################
    replacestrings = [('prod_a_', 'moi_a_')
                    , ('prod_b_', 'moi_b_')
                     ]
                       
    clean_dbase = dbase.lower().replace("_user_views", "")
    for rstr, tostr in replacestrings:
        clean_dbase = clean_dbase.replace(rstr, tostr)

        
    return "%s_createview_%s_t2.sql" %  (clean_dbase.lower(), viewname.lower())

def dtest():
    import doctest
    doctest.testmod()


if __name__ == '__main__':

    
    #run()
#    dtest()

    test_for_horrors()
    m = extract_views()
    print len(m), "items"
    for view in m:
        filename =  get_filename(view)
        cleanview = sanitise_view(view)
        try:
            outputtext(cleanview, filename)
        except Exception, e:
            print m[:100]
            print "******"
            print filename
            print "******"
            print cleanview
            
            raise e