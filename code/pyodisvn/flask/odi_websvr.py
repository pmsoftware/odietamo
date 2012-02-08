import os
from flask import Flask
#from flaskext.cache import Cache

app = Flask(__name__)
#set up simple cacheing
#cache = Cache(app)


import sys
sys.path.append(r'C:\$WELLKNOWNINSURER_DEPLOY\pyodisvn')
#sys.path.append(r'C:\downloads\dropbox.com\Dropbox\com.mikadosoftware\code\python\pyodisvn')
import ODI_compare_lib
import ODI_compare_hashes_across_repos
import output_pkg_as_html
import fingerprint_scenario_lib as scenlib
import fingerprint_lib


@app.route("/")
def hello():
    return """<h3>$WELLKNOWNINSURER ODI COde recovery scheme</h3>
    <P> THis is a Proof of concept web service for using the Interim fingerprinting
    service.  It is designed to allow people to
    </P>
<ul>


<li> compare specific names across repos <a href="http://$WELLKNOWNINSURER11x714j:5000/comparebyname/MUT001W">./comparebyname/MUT001W</a>
     <br/>This is much more useful.  replace "MUT001W" with name of the ODI object you are about to start work on.
     If there is more than one copy out there, why?  Should you be merging their changes to your repo?
     NB - this can be useful as a link to the fingerprint as well.

<p>

<li> compare repo to repo - <a href="#">./compare/$DBCONNREF/$DBCONNREF</a>
     <br/>NB - this needs to be cached daily for now it takes upwards of three minutes to complete a repo compare ...
     (disabled - too resource intensive for web - see Paul

<li> specific package data - <a href="http://$WELLKNOWNINSURER11x714j:5000/package/1379101">./package/1379101</a>
     <br/>NB - this can also take time to build up

<li> Scenario Viewer - see scenario live from a repo
     <a href="http://$WELLKNOWNINSURER11x714j:5000/scenario/$DBCONNREF/BUSINESS_OBJECT_FULFILMENTS">scenario/$DBCONNREF/BUSINESS_OBJECT_FULFILMENTS</a>


<li> Scenario diff Viewer - useful to compare the diff between a scenaario on live and in clean code.
     <a href="http://$WELLKNOWNINSURER11x714j:5000/scenariodiff/$DBCONNREF/BUSINESS_OBJECT_FULFILMENTS/$DBCONNREF/BUSINESS_OBJECT_FULFILMENTS">/scenariodiff/$DBCONNREF/BUSINESS_OBJECT_FULFILMENTS/$DBCONNREF/BUSINESS_OBJECT_FULFILMENTS</a>


<li> fingerprint viewer - see the current source code fingerprint by name/id
     <a href="http://$WELLKNOWNINSURER11x714j:5000/fingerprint/$DBCONNREF/423007.0/KIM_SWIFT-MOI_TERADATA_INSERT_ALL">fingerprint/$DBCONNREF/423007.0/KIM_SWIFT-MOI_TERADATA_INSERT_ALL</a>


</ul>

<p>
It is rough around the edges, so go easy on it please.

"""

def html_safe(txt):
    ''' '''
    txt = txt.replace("<", "&lt;").replace(">", "&gt;")

    #awful hack to support colorising scenario diff
    txt = txt.replace("_ODIREPLACELT_", "<")
    txt = txt.replace("_ODIREPLACEGT_", ">")
    
    txt = txt.replace("\n", "<br/>") #make sure <<br> last
    return txt


@app.route("/fingerprintengine/status")
def fingerprint_engine_status():
    ''' '''
    return fingerprint_lib.fingerprint_engine_status()

@app.route("/compare/<lreponame>/<rreponame>")
def compare_repo(lreponame, rreponame):
    #return "I will compare LHS:%s and RHS: %s" % (lreponame, rreponame)
    return ODI_compare_lib.compare_repo(lreponame, rreponame)

@app.route("/reports/main")
def read_report():
    f =r'D:\downloads\ODI\the_trough\diffreport_codework-exe.html'
    return open(f).read()

@app.route("/comparebyname/<objectname>")
def comparebyname(objectname):
    #return "I will compare LHS:%s and RHS: %s" % (lreponame, rreponame)
    return ODI_compare_hashes_across_repos.comparebyname(objectname)

@app.route("/package/<i_pkg>")
def view_package(i_pkg):
    #return "I will compare LHS:%s and RHS: %s" % (lreponame, rreponame)
    return output_pkg_as_html.pkg_from_id(i_pkg)

@app.route("/fingerprint/<repo_name>/<id>/<name>")
def fingerprint(repo_name, id, name):
    ###god knows how I know to build this url... 
    rootfolder = r'C:\ODICodeForComparison\direct_compare_results'
    thisfile = os.path.join(rootfolder, repo_name, "%s_%s" % (id, name))+".log"
    try:
        fo = open(thisfile)
        txt = fo.read()
        fo.close()
    except IOError, e:
        #this is an issue where storing KM names that have spaces in htem
        #safe_file_name(s, i_trt) in fingerprint_lib would be useful
        thisfile = os.path.join(rootfolder, repo_name, "%s_%s" % (id, name.replace(" ","_")))+".log"
        fo = open(thisfile)
        txt = fo.read()
        fo.close()
    return html_safe(txt)

@app.route("/scenario/<repo_name>/<scen_name>")
def scenario(repo_name, scen_name):
    ''' '''
    try:
        txt = scenlib.latest_scen_by_name(repo_name,scen_name)
        return html_safe(txt) 
    except Exception, e:
        return str(e) 

#diff_scenarios
@app.route("/scenariodiff/<lrepo_name>/<lscen_name>/<rrepo_name>/<rscen_name>")
def scenariodiff(lrepo_name, lscen_name, rrepo_name, rscen_name):
    ''' '''
    try:
        txt = scenlib.diff_scenarios(lrepo_name, lscen_name, rrepo_name, rscen_name)
        return txt
        #return html_safe(txt) #how to indicate its latin1?? 
    except Exception, e:
        return str(e) 


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
