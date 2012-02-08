#!/usr/local/bin/python

import os

import decompile_xml2sql
import decompile_config

fldr = r'C:\Documents and Settings\brianp\Desktop\daily\genScenTest'
files = [f for f in os.listdir(fldr) if os.path.isfile(f) == True]
print files
files = ['SCEN_INTERMEDIARY_STATEMENTS001_localautogen.xml',]
for f in files:
    src =  os.path.join(fldr, f)
    tgt = src + ".decompiled"
    txt = decompile_xml2sql.decompile_xml(src)
    open(tgt,'w').write(txt)

    
