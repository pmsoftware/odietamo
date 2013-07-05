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
from install_lib import (common_download_file,
                         tools_mkroottree,
                         tools_prepare_root,
                         install_odisvnzip,
                         install_unixutils,
                         prepare_a_repo,
                         depends_checkdeps)
## simple ini to dict
import conf

### controlling functions, calling lib. #######################################
 
def main(confd):
    """
    
    """

    tools_prepare_root(confd)
    depends_checkdeps(confd)
    
#    install_odi(confd)
#    install_odisvn(confd)
#    prepare_a_repo(confd, "test1")
    

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
    fmt = "** %(message)s"
    logging.basicConfig(level=logging.DEBUG, format=fmt)
    lgr = logging.getLogger("ODISVN-installer")
    opts, args = parse_args()
    confd = conf.get_config(opts.conf)
    lgr.info("starting main")
    main(confd)
                    