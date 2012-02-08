.. ODISVN documentation master file, created by
   sphinx-quickstart on Thu Sep 29 16:56:06 2011.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to ODISVN's documentation!
==================================

Executive Summary
-----------------

We are lacking in basic Automated testing, source control and automated build
solutions, and comprehensive code reviews.

We have developed tools to help us achieve this end, and are in process of putting them into place

We have created a means of crytpographically fingerprinting repositories on a per object basis in near-ish realtime, allowing us to version what has been tested, what is being moved from repo to repo.

We have created Java driver for Teradata for dbFit, meaning simple, automated testing is feasible.

We have created means of extracting object by object, code from Repos to enable storage in a real source control environment
 


Useful links
------------
WHere much of the stuff is backed up

\\\\manfs08\\p5066-crm-scv\\Scrum 2 (Warehouse Crunchers) Stories\\SECTA

Release Notes
-------------

H: = \\manfs08\\P5066-crm-scv
H:\\Prod Release CMSR1A\\Release Notes\\Release_20111006




Background
----------

We have 12 ODI repositories, plus one production and one production-code repo.
Production-code is used to store what we *think* is the code that was used to compile the *scenarios* on live.

The other 12 are used by the various MOI teams for development purposes.

::

    | DEV1_WK | AOETLW_DEV1 |
    | DEV2_WK | AOETLW_DEV2 |
    | DEV3_WK | AOETLW_DEV3 |
    | DEV4_WK | AOETLW_DEV4 |
    | SYS1_WK | AOETLW_SYS1 |
    | SYS2_WK | AOETLW_SYS2 |
    | SYS3_WK | AOETLW_SYS3 |
    | SYS4_WK | AOETLW_SYS4 |
    | UAT1_WK | AOETLW_UAT1 |
    | UAT2_WK | AOETLW_UAT2 |
    | UAT3_WK | AOETLW_UAT3 |
    | UAT4_WK | AOETLW_UAT4 |
    | PRODCODE | AOODIWKCODE |


Current release process
-----------------------

1. A change request is identified 
2. Code is found in a given teams environment, and work is begun on it.
   It is usually checked that the code is same in 2 MOI scrum repos.
   No attempt is made to check code is same as live, or if being changed in
   other repos
3. code is worked on in the funnel leading up to UAT.  Development is done
4. An email release note (see above) is sent to config team (personal mailboxes)
5. 



Crytographic fingerprinting
---------------------------

THis was sort of straw to drowning man
I think it is going to be useful (see release notes)
THe problem lies in this::

    BUILD_PROD
    UAT2_WK.hashes trt::1215101.0::BUILD_PROD::ODISVN_V1.0-8bba1492f57122ed039f26178fe7f13d  
    SYS2_WK.hashes trt::264006.0::BUILD_PROD_BEN_GRP_MEM_SUMMS::ODISVN_V1.0-84dda2605ee5ce0885f3eaa625de633f  
    PRODCODE.hashes trt::264006.0::BUILD_PROD_BEN_GRP_MEM_SUMMS::ODISVN_V1.0-84dda2605ee5ce0885f3eaa625de633f  
    DEV2_WK.hashes trt::264006.0::BUILD_PROD_BEN_GRP_MEM_SUMMS::ODISVN_V1.0-84dda2605ee5ce0885f3eaa625de633f  
    BUPADEV3.hashes trt::264006.0::BUILD_PROD_BEN_GRP_MEM_SUMMS::ODISVN_V1.0-84dda2605ee5ce0885f3eaa625de633f::2011-10-04T19:20:32.012000  

    --------------------------------------------------------------------------------

    BUILD_PROH
    UAT2_WK.hashes trt::1245101.0::BUILD_PROH::ODISVN_V1.0-a3a18f1fa9a16401e46aa038091f1f18  
    SYS2_WK.hashes trt::1245101.0::BUILD_PROH::ODISVN_V1.0-e4f93a30d25f316334f6ae8fd77f1f4b  
    PRODCODE.hashes trt::1245101.0::BUILD_PROH::ODISVN_V1.0-f9d44f95dc68a221192ef6f378b2d8b1  
    DEV2_WK.hashes trt::1245101.0::BUILD_PROH::ODISVN_V1.0-58a03a645e751f7d8ce8bb5d6a87fa33  
    BUPADEV3.hashes trt::1245101.0::BUILD_PROH::ODISVN_V1.0-a3a18f1fa9a16401e46aa038091f1f18::2011-10-04T19:20:17.122000  

    --------------------------------------------------------------------------------



    <<<

So BUILD_PROD needs to be moved from DEV2_WK where ravi wrote it into UAT2.
it seems to already have been moved.


but BUILD_PROH is not, but will it conflict with any changes in SYS2_WK that we have been testing against...

I would like to hash across a whole repo.  Its feasible, but with such a mess what does it tell us?




Example as discussion point
---------------------------

MUT002W is a *package* 

It consists of a multiple "steps" executed one after the other::

    <MUT002W from PRODUCTION CODE REPO>
    0.0 - UTL_SCENARIO_SESSION_WRITER
    1.0 - BUILD_PATY
    2.0 - BUILD_PRTY
    3.0 - BUILD_CSTY
    4.0 - BUILD_CALE
    5.0 - BUILD_ORGA_ORGX
    6.0 - BUILD_ADDR_ADDX
    7.0 - BUILD_PERS_PERX_1
    8.0 - BUILD_PERS_PERX_2
    9.0 - BUILD_PERSON_ORPHANS
    10.0 - BUILD_PERSON_DELETIONS
    11.0 - BUILD_PARO
    12.0 - BUILD_PRCD
    13.0 - BUILD_PRDE
    14.0 - BUILD_PRAD
    15.0 - BUILD_PRRE
    16.0 - BUILD_COSU
    17.0 - BUILD_PRCD_TPS
    18.0 - SET_LOAD_VAR_1
    19.0 - UTL_SCENARIO_SESSION_PURGER


BUILD_PRAD is a Treatment in the package.  It is found in multiple forms thoughout our 12 repos.

MUT002W exists as a scenario in actual live.
The scenario (compiled object) is viewable with the others at \\manfs08\p5066-crm-scv\Scrum 2 (Warehouse Crunchers) Stories\SECTA



UAT2_WK
-------

::

 DATE		AUTHOR		DESCRIPTION
 01-NOV-2010	M. Matten		Renamed step BUILD_UKM_UPD_PRCD_TPS_TELEPHONES to BUILD_PRCD_TPS in line with procedure renaming.
 20-JAN-2011		R. Shinde		Added BUILD_ORGA_ORGX in MUT002W from MUT003W as part of WP1 and WP3 (Product Summary) integration
 				This procedure is required to populate parties.
 05-AUG-2011	M. Matten		Updated name of step that executes MUBUILD_PARD from BUILD_PRAD to MUBUILD_PARD in line with standards.


SYS2_WK
-------

::

 DATE		AUTHOR		DESCRIPTION
 01-NOV-2010	M. Matten		Renamed step BUILD_UKM_UPD_PRCD_TPS_TELEPHONES to BUILD_PRCD_TPS in line with procedure renaming.
 20-01-2011 		R. Shinde		Added BUILD_ORGA_ORGX in MUT002W from MUT003W as part of WP1 and WP3 (Product Summary) integration
 				This procedure is required to populate parties
 21/09/2011		Rohit Singh        	Added column Intermediary Reference Number In party_roles table(PBI 17920)


 <<<


Scenario MUT002W from PRODUCTION CODE REPO
------------------------------------------

\\\\manfs08\\p5066-crm-scv\\Scrum 2 (Warehouse Crunchers) Stories\\SECTA\\ODI Scen from Code Repo\\SCEN_MUT002W Version 005.xml

::

 DATE		AUTHOR		DESCRIPTION
 01-NOV-2010	M. Matten		Renamed step BUILD_UKM_UPD_PRCD_TPS_TELEPHONES to BUILD_PRCD_TPS in line with procedure renaming. 
 20-01-2011 		R. Shinde		Added BUILD_ORGA_ORGX in MUT002W from MUT003W as part of WP1 and WP3 (Product Summary) integration
 				This procedure is required to populate parties


 <<<

Scenario MUT002W from PRODUCTION LIVE REPO
------------------------------------------

\\\\manfs08\\p5066-crm-scv\\Scrum 2 (Warehouse Crunchers) Stories\\SECTA\\ODI Scens Prod\\MUT002W.xml

::

 DATE		AUTHOR		DESCRIPTION
 01-NOV-2010	M. Matten		Renamed step BUILD_UKM_UPD_PRCD_TPS_TELEPHONES to BUILD_PRCD_TPS in line with procedure renaming.
 20-JAN-2011		R. Shinde		Added BUILD_ORGA_ORGX in MUT002W from MUT003W as part of WP1 and WP3 (Product Summary) integration
				 This procedure is required to populate parties.
 05-AUG-2011	M. Matten		Updated name of step that executes MUBUILD_PARD from BUILD_PRAD to MUBUILD_PARD in line with standards.

 <<<


So, we pushed direct from UAT2 into production, using a scenario pre compiled, then not followed up with the right code.
But we now risk pushing from SYS2 into UAT2 and overwriting the changes !

So how much more often are we doing this - is there a way to see what treatments made up a package which became a scenario
This is both hard, and even if we do, all we can do is prove that % of the production code is not compilable to scenario code.

Total number of versions being looked at
----------------------------------------

We have 3260 distinct named emodules/objects (limited to packages, interfaces and treatments) across our 12 ODI repos.
Of these 2828 are commonly named.

However, we can uniquely fingerprint the code objects, giving a version number to each.

We have 2828 file names that are in every repo, and 3260 filenames in total, making 432 files to possibly throw
(see attached txt files)
We have 2992 versions of the above files, and 3741 versions in total

For just Prod and UAT2_WK We have 2832 file names that are in every repo, and 3004 filenames in total, making 172 files to possibly throw
however, if we looked at obvious junk files, with this regex("_\d+$") matching things like ' POP_ERP_CORP_SUBSCRIBER_OP_2100223' we can remove 
311 files.


ROughly speaking 2500 module names co-exist everywhere, with 5% of them having different versions.

But ...


A different way *might* be to decompile the scenarios from Production, and so we would have the code objects and then might be able to build




OKI have written  decompiler of sorts for the ODI scenarios
It works in limited circumstances, and is in F:\repos
It correctly fingerprints code out of the scenario, doing translation as needed.
THen it can be used to compare against existing Production code in the prod repo.

Its not very reassuring on md5 hashes

But it could beused for diff'ing too, so we do have a way to go from scenraios back to code 


Tools

* hash based fingerprinting
* search for single named module across all repos



Misc
----

http://stackoverflow.com/questions/7193727/running-jython-in-oracle-data-integrator-odi-how-do-i-access-the-odi-packages


