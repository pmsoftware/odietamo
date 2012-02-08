import os
from stat import *

def since():
    ''' highly specialised - ai am watching this dir for new files,
    and anything newer than '''
    try:
        oldestfile_mtime = float(open("oldestfile.dat").read())
    except:
        oldestfile_mtime = 0 #when no timer file, return all files 
    max_mtime = 0
    
    fldr = SCENFOLDER_$DBCONNREF
    files = os.listdir(fldr)
#    newfiles = [f for f in files if os.stat(f).st_mtime > oldestfile_mtime]
    newfiles = []
    for f in files:
        fpath = os.path.join(fldr, f)
        ftime = os.stat(fpath).st_mtime
        if ftime > oldestfile_mtime: #if I do not >= then unless i change a file the most recent mtime stays continuous
            newfiles.append(f)
        if max_mtime < ftime: max_mtime = ftime
            
    open("oldestfile.dat", "w").write(str(max_mtime))
    return newfiles


    
#decompile config settings - only run those files that modified in pbrian_allscen after last datetime recorded
ONLY_RUN_THESE = False

#COMPARISONFLDR = r'C:\downloads\ODI\exported002.tar'
#COMPARISONFLDR = r'D:\downloads\ODI\the_trough'
#COMPARISONFLDR = r'c:\ODI\code_recovery'
COMPARISONFLDR = r'D:\downloads\ODI\the_trough'

####### These are fairly fixed - we will need to update however but they are changed by business
#SCENFOLDER_$DBCONNREF = r'C:\ODICodeForComparison\Reconcilliation\$DBCONNREFscens20111102.tar'
#DECOMPILEDFOLDER_$DBCONNREF = r'C:\ODICodeForComparison\Reconcilliation\$DBCONNREF_decompile'

#SCENFOLDER_EXE = r'C:\ODICodeForComparison\Reconcilliation\prod_exe_scens_20110112.tar' #<- newest
#DECOMPILEDFOLDER_EXE = r'C:\ODICodeForComparison\Reconcilliation\$DBCONNREF_decompile'

##windows
#SCENFOLDER_$DBCONNREF =  os.path.join(COMPARISONFLDR, 'exe_scenarios') #<- newest
SCENFOLDER_$DBCONNREF =  os.path.join(COMPARISONFLDR, '$DBCONNREFscens20111212') #<- newest 
DECOMPILEDFOLDER_$DBCONNREF =  os.path.join(COMPARISONFLDR, 'exe_scenarios_decompiled')


SCENFOLDER_$DBCONNREF = os.path.join(COMPARISONFLDR, '$DBCONNREF_scenarios')
DECOMPILEDFOLDER_$DBCONNREF = os.path.join(COMPARISONFLDR, '$DBCONNREF_scenarios_decompiled')

DIFF_$DBCONNREF_$DBCONNREF =  os.path.join(COMPARISONFLDR, 'diff_codework-exe')

valid_folders = [DIFF_$DBCONNREF_$DBCONNREF, ]

# for decompile_xml2sql.py
src_pairs = [[SCENFOLDER_$DBCONNREF, DECOMPILEDFOLDER_$DBCONNREF],
             [SCENFOLDER_$DBCONNREF, DECOMPILEDFOLDER_$DBCONNREF],
             ]


#these are the comparisons... supplying left_decompile, right_decompile, results_folder, name 
comparison_sets = [

#uatcopy-exe
 [DECOMPILEDFOLDER_$DBCONNREF, DECOMPILEDFOLDER_$DBCONNREF, DIFF_$DBCONNREF_$DBCONNREF, "codework-exe"],

        ]


