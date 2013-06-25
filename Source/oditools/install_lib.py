"""
These are Library functions for the demo-installer


FIr reference as we go: deletefrom main docs
:: 

    3. Install dependencies and configure the environment
    3.1. Install Windows PowerShell
    3.2. Oracle Data Integrator
    3.3. Install Subversion
    3.4. Install UnxUtils
    3.5. Install Jisql
    3.6. Install Java
    3.7. Install Oracle Client
    4. Export the standard ODI demo repository
    4.1. Start the standard ODI demo repository
    4.2. Export the standard ODI demo repository
    5. Create a new linked master and work repository
    5.1. Create a new Oracle user
    5.2. Create a new master repository
    5.3. Create a new Work Repository in the Master Repository DB schema
    6. Import the standard ODI demo repository into the new Oracle-based repository
    6.1. Create an OdiScm configuration file for the import
    7. Install and configure the ODI-SCM repository components


areas for library
-----------------
::

  I shall namespace functions as the part of the install process they represent
 
  depends_
  exportrepo_
  newrepo_
  importrepo_




"""


### library like functions #####################################

import subprocess
import logging
import os
import shutil


logging.basicConfig(level=logging.DEBUG)
lgr = logging.getLogger("ODISVN-installer")

def common_subprocess(cmdlist):
    """run and return output of a shell command

    notes

    >>> cmdlist = ["echo", "Hello World"]
    >>> common_subprocess(cmdlist)
    'Hello World\\r\\n'

    
    """
    txt = subprocess.check_output(cmdlist)
    return txt


def depends_checkdeps():
    """
    """
    output_txt = ""
    output_txt += depends_checkpowershell()
    print output_txt
    
def depends_checkpowershell():
    """
    """
    try:
        common_subprocess(['powershell', '-h'])
        return "powershell installed"
    except:
        return "No powershell found"
    
    
def depends_get_file(urlsrc, to_path):
    """
    
    $ depends_get_file("http://www.google.com", "c:/foo.html")

    :params urlsrc: The src as http URL to GET from
    :params to_path: THe on disk path to write the file retrieved
    """
    r = requests.get(urlsrc)
    fo = open(to_path, "wb")
    fo.write(r.content)
    fo.close()
    
def depends_mkroottree(rootdir):
    """
    assuming an empty rootdir, create a tree
    """
    os.makedirs(rootdir)
    os.makedirs(os.path.join(rootdir, "staging"))
    os.makedirs(os.path.join(rootdir, "production"))

def depends_prepare_root(confd):
    """
    prepare the root directory that will hold all relevant parts to this install
    apart from the binaries for ODI
    """
    #prepare the location
    rootdir = confd['odisvn']['install_root_dir']
    if not os.path.isdir(rootdir):
        depends_mkroottree(rootdir)
    else:
        shutil.rmtree(rootdir)
        depends_mkroottree(rootdir)

def depends_install_odisvn(confd):
    """
    """
    lgr.info("install odisvn called")
    ### odisvn expand
    ziptgtpath = os.path.join(confd['odisvn']['install_root_dir'], 'staging', 'master.zip')
    depends_get_file("https://github.com/pmsoftware/odietamo/archive/master.zip",
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


if __name__ == '__main__':
    import doctest
    doctest.testmod()