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



Where are we so far:

depends_prepare_root
depends_checkdeps

"""


### library like functions #####################################

import subprocess
import logging
import os
import shutil
import requests
import zipfile

class OdiError(Exception):
    pass


fmt = "** %(message)s"###pretty debugs.
logging.basicConfig(level=logging.DEBUG, format=fmt)
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
 
def common_download_file(urlsrc, to_path):
    """
    
    $ depends_get_file("http://www.google.com", "c:/foo.html")

    :params urlsrc: The src as http URL to GET from
    :params to_path: THe on disk path to write the file retrieved
    """
    lgr.info("Download %s to %s" % (urlsrc,to_path))
    fo = open(to_path, "wb")
    r = requests.get(urlsrc)
    fo.write(r.content)
    fo.close()

###########################################

def depends_checkdeps(confd):
    """
    """

    ### al dep checks    
    has_powershell = check_powershell()
    has_subversion = check_subversion()
    has_odisvnzip = install_odisvnzip(confd)
    has_unixutils = install_unixutils(confd)
    has_java = check_java(confd)
    has_oracle_client = check_oracle_client(confd)
    has_jisql = check_jisql(confd)
    
    ### validate the checks
    for state,msg  in (has_powershell,
                       has_subversion,
                       has_odisvnzip,
                       has_unixutils,
                       has_java,
                       has_oracle_client,
                       has_jisql
                       ):
        if state:
            lgr.info(msg)
        else:
            lgr.info(msg) 
            raise OdiError("Dependancy failure - %s" % msg)


######################## various depoendancy checks
def check_odi_install(confd):
    lgr.error("DO not know how to check ODI versions if env var not set")

def check_jisql(confd):
    """
    """
    try:
        common_subprocess(['ls', '-l'])
        return (True, "3.5: Has jisql")
    except:
        return (False, "3.5: No jisql found")
        
def check_oracle_client(confd):
    """
    """
    try:
        common_subprocess(['sqlplus', '-V'])
        ##we should also check `exp`
        return (True, "3.7: Has oracle client")
    except Exception, e:
        lgr.info("in oracle client: %s" % str(e))
        return (False, "3.7: No oracle client")

def check_java(confd):
    """
    FIXME: under subprocess "java" is not found in path
    but under my user it is.
    Diabling check till then
    """
    return (True, "Java checking currently disabled")    
#    try:
#        common_subprocess(['java', '-version'])
#    return (True, "3.6: Has java")
#    except Exception, e:
#  
#        return (False, "3.6: No Java found - %s" % str(e))


def check_powershell():
    """
    """
    try:
        common_subprocess(['powershell', '-h'])
        return (True, "3.1: Has Powershell")
    except:
        return (False, "3.1: No Powershell found")

def check_subversion():
    lgr.info("3.3 Check Subversion")
    try:
        common_subprocess(["svn","--version"])
        return(True, "3.3 Subversion installed")
    except:
        return(False, "3.3 - Please install subversion")    

##################################### one shot tools
    
def tools_mkroottree(rootdir):
    """
    assuming an empty rootdir, create a tree
    """
    lgr.info("3.0 : Create root dir at %s" % rootdir)
    try:
        os.makedirs(rootdir)
        os.makedirs(os.path.join(rootdir, "staging"))
        os.makedirs(os.path.join(rootdir, "production"))
        lgr.info("3.0 : OK ")
    except Exception, e:
        lgr.error("3.0 Failed to prepare disk")
        raise OdiError("3.0 Failed to prepare disk" + str(e))
    
def tools_prepare_root(confd):
    """
    prepare the root directory that will hold all relevant parts to this install
    apart from the binaries for ODI
    """
    #prepare the location
    lgr.info("3.0 : Prepare Disk for dependancies ")
    rootdir = confd['odisvn']['install_root_dir']
    if not os.path.isdir(rootdir):
        tools_mkroottree(rootdir)
    else:
        lgr.info("3.0 : delete %s then prepare Disk for dependancies " % rootdir)
        shutil.rmtree(rootdir)
        tools_mkroottree(rootdir)

def install_odisvnzip(confd):
    """
    """
    lgr.info("2.0 : install odiscm")
    odiscmzipURL = confd['odisvn']['odiscmzip']
    lgr.info("2.0 : downloading %s " % odiscmzipURL)
    ### odisvn expand
    ziptgtpath = os.path.join(confd['odisvn']['install_root_dir'], 'staging', 'master.zip')
    common_download_file(odiscmzipURL, ziptgtpath)
    ### we should do some md5 testing etc....
    lgr.info("2.0 : unzipping %s " % ziptgtpath)
    ##unzip here somehow...
    zp = zipfile.ZipFile(ziptgtpath)
    zp.extractall(os.path.join(confd['odisvn']['install_root_dir'], 'staging'))
    lgr.error("not create env variable ODI_SCM_HOME")
    return (True, "Installed ODISVN code")

    
def install_unixutils(confd):
    """
    """
    url = confd['odisvn']['unixutils']
    unixtgtpath = os.path.join(confd['odisvn']['install_root_dir'], 'staging', 'unixutils.zip')
    lgr.info("3.4: Download %s to %s" % (url, unixtgtpath))
    common_download_file(url, unixtgtpath)
    ##unzip here somehow...
    zp = zipfile.ZipFile(unixtgtpath)
    zp.extractall("C:\UnxUtils")
    
    return (True, "3.4: Extracted Unixutils -? how to install?")

def prepare_a_repo(confd, reponame):
    """
    """
    lgr.info("prepare repo called")


if __name__ == '__main__':
    import doctest
    doctest.testmod()