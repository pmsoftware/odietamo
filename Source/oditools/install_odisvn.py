#!/usr/bin/env python
#! -*- coding: utf-8 -*-

### Copyright Paul Brian 2013 

# This program is licensed, without  under the terms of the
# GNU General Public License version 2 (or later).  Please see
# LICENSE.txt for details

###

"""
:author:  paul@mikadosoftware.com <Paul Brian>

We want to automate as fully as possible a complete
ODI-SVN demo install.  This will need to include
install of the ODI binary, install of Oracle DBAse
and install of the ODI-SVN code and the appropriate
prepatation.


We are aiming to create the following on-disk layout

::

    root/
        staging/
              <various>
       ...
        production/
                 /oracledi
                 /repos/
                       /workrepo1
                       /workrepo2


current run cmd::

    c:\src\odietamo\Source\oditools>python install_odisvn.py --config=odi.ini
    INFO:ODISVN-installer:prepare odi called
    INFO:ODISVN-installer:install odisvn called
    INFO:ODISVN-installer:prepare repo called


"""
import os
import shutil
import urllib
import requests
from optparse import OptionParser
import zipfile  #check jython support?

#### simplest logging possible
import logging
logging.basicConfig(level=logging.DEBUG)
lgr = logging.getLogger("ODISVN-installer")

### simple ini to dict
import conf

### library like functions
#: not currently worth putting in seperate library 

def get_file(urlsrc, to_path):
    """
    >>> install_odisvn.get_file("http://www.google.com", "c:/foo.html")


    :params urlsrc: The src as http URL to GET from
    :params to_path: THe on disk path to write the file retrieved
    """
    r = requests.get(urlsrc)
    fo = open(to_path, "wb")
    fo.write(r.content)
    fo.close()
    
def mkroottree(rootdir):
    """
    assuming an empty rootdir, create a tree
    """
    os.makedirs(rootdir)
    os.makedirs(os.path.join(rootdir, "staging"))
    os.makedirs(os.path.join(rootdir, "production"))

def prepare_root(confd):
    """
    prepare the root directory that will hold all relevant parts to this install
    apart from the binaries for ODI
    """
    #prepare the location
    rootdir = confd['odisvn']['install_root_dir']
    if not os.path.isdir(rootdir):
        mkroottree(rootdir)
    else:
        shutil.rmtree(rootdir)
        mkroottree(rootdir)

def install_odisvn(confd):
    """
    """
    lgr.info("install odisvn called")
    ### odisvn expand
    ziptgtpath = os.path.join(confd['odisvn']['install_root_dir'], 'staging', 'master.zip')
    get_file("https://github.com/pmsoftware/odietamo/archive/master.zip",
             ziptgtpath)
    ### we should do some md5 testing etc....
    
    ##unzip here somehow...
    zp = zipfile.ZipFile(ziptgtpath)
    zp.extractall(os.path.join(confd['odisvn']['install_root_dir'], 'staging'))
    
    

def install_odi(confd):
    """
    """
    lgr.info("prepare odi called")

def prepare_a_repo(confd, reponame):
    """
    """
    lgr.info("prepare repo called")


### controlling functions, calling lib.
 
def main():
    """
    """
    opts, args = parse_args()
    confd = conf.get_config(opts.conf)
    prepare_root(confd)
    install_odi(confd)
    install_odisvn(confd)
    prepare_a_repo(confd, "test1")
    

def parse_args():
    """
    parse the args for the main install script
    """
    parser = OptionParser()
    parser.add_option("--config", dest="conf",
                      help="Path to config file.")
    (options, args) = parser.parse_args()
    return (options, args)



if __name__ == '__main__':
    main()
                    