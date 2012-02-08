Documenting ODISVN
==================

pyODISVN
========

THis is a set of tools / helper scripts that will look at and try and bring the management of ODI across multiple repos under control.s

There are a variety of tools provided in pyODISVN

* ODI to TFS cycle 
* fingerprinting repositories and databases
* compare fingerprints 
* version and release management
* source code recovery


Groups of Tools

* Server - Fingerprint
* Server - web based tools
* client - extraction and scenario comparison

Subversion location
-------------------

http://stajprrepo01.internal.bupa.co.uk/repos/moi/branches/AutoTestTool/common/ODISVN

Dependancies:

* mx.ODBC - third party package
* mikado.common.db - own package, providing simplistic db abstraction
* flask - third party OSS package

These dependancies are installed on the "server" BUPA11X714J
They are also available from the c:\downloads of same.


Administration 
==============

The location of the code on server is c:\BUPA_DEPLOY\pyodisvn


Fingerprinter
-------------

The file run_ODI_fingerprint_repos.bat is called at 3am each day by
Scheduled Tasks in the Server.  This will fill out the TBL_FINGERPRINT
table in fingerprint Oracle database running on the Server.

All passwords are stored (in plain text!!!!) on MOI_user_passwords.py

The fingerprinter is used to compare "SOURCE CODE" not Scenarios


It extracts pkg (Package), trt (procedure) and pop (interface) from
the SNP database, rebuilds the SQL underlying each of those, stores
that in local drive as txt files, and runs an md5 hash over the SQL

It takes about 10-12 mins per repo, but with 12+ repos thecycle is 2
hours.  The most likely optimisation is to use LAST_DATE for each
object and only fingerprint objects changed since last run.  THis will
speed up fingerprinting enormously but has not yet happened (Hey -
phase 2).


Web server
----------

There is a very very lightweight web server running.
It needs to be daemonised but is currentlly run by me logging into the Server, and double clicking the 
file c:\BUPA_DEPLOY\pyodisvn\flask\odi_websvr.py
This needs to be daemonised, but can be run by anyone with same rights as my user.


Visit http://bupa11x714j:5000 to see the docs for the web services.

::

    compare specific names across repos ./comparebyname/MUT001W 
    This is much more useful. replace "MUT001W" with name of the ODI object you are about to start work on. If there is more than one copy out there, why? Should you be merging their changes to your repo? 

    compare repo to repo - ./compare/UAT2_WK/DEV3_WK 
    NB - this needs to be cached daily for now it takes upwards of three minutes to complete a repo compare ... (disabled - too resource intensive for web - see Paul 
    specific package data - ./package/1379101 
    NB - this can also take time to build up 
    Scenario Viewer - see scenario live from a repo scenario/CODE_WORK/BUSINESS_OBJECT_FULFILMENTS 
    fingerprint viewer - see the current source code fingerprint by name/id fingerprint/SYS2_WK/423007.0/KIM_SWIFT-MOI_TERADATA_INSERT_ALL 



compare fingerprints 
~~~~~~~~~~~~~~~~~~~~

Use web server - http://bupa11x714j:5000/fingerprint/CODE_WORK/2911101.0/OMT_REPORT549



repo - repo comparison
----------------------

Full across the board comparison 

Run on the Server (takes 4mins + ) 

$ python ODI_compare_lib.py

Change the line LHS, RHS = ('CODE_WORK', 'UAT1_WK') to be the repo_names needed



Repo_names
----------

In MOI_user_passwords, there are dozens of defintions of connections to different databases.
These connections are labelled with a "name" variable - and this name variable is used throughout the system as a unique identifier 
Just running ::

  $ python MOI_user_passwords.py 

will output the repo_names (see below) and then test the ODI connections.


The names:

+--------------+
|DEV1_WK       |
+--------------+
|DEV2_WK       |
+--------------+
|DEV3_WK       |
+--------------+
|DEV4_WK       |
+--------------+
|SYS1_WK       |
+--------------+
|SYS2_WK       |
+--------------+
|SYS3_WK       |
+--------------+
|SYS4_WK       |
+--------------+
|UAT1_WK       |
+--------------+
|UAT2_WK       |
+--------------+
|UAT3_WK       |
+--------------+
|UAT4_WK       |
+--------------+
|PRODCODE      |
+--------------+
|PRODEXE       |
+--------------+
|BUPADEV3      |
+--------------+
|FINGERPRINT   |
+--------------+
|CODE_WORK     |
+--------------+
|BUPADEVL      |
+--------------+
|BUPADEV4      |
+--------------+
|td_dev2_brianp|
+--------------+
|td_sys3_brianp|
+--------------+
|td_dev4_brianp|
+--------------+
|td_sys2_brianp|
+--------------+
|td_uat3_brianp|
+--------------+
|td_devc_brianp|
+--------------+
|td_sysi_brianp|
+--------------+
|td_devs_brianp|
+--------------+
|td_tt10_brianp|
+--------------+
|td_uata_brianp|
+--------------+
|td_sysc_brianp|
+--------------+
|td_uatc_brianp|
+--------------+
|td_prod_brianp|
+--------------+
 



View_hierarchy_of_repo.py
-------------------------

This is a throw away 



Decompilation
-------------

We want to compare scenarios with scenarios in another repository.
This will help us to *baseline* our code.  

A complete decompilation is a slightly complicted beasst and I will write up how and smooth it out Thursday.
Honest guv.





