
'''
The decompile "process"
-----------------------

We are attempting to compare our code base for 

Given a set of decompiled scnearios (ie stripped out SQL)
run diff over them all and output the diff if any



'''
import os
import sys
import re
from stat import *
import datetime
import decompile_config

from mikado.common.db import tdlib
import MOI_user_passwords
import ODI_objects_from_repo as odi_lib

def mkbat(name, left_decompile, right_decompile, results_folder, diffable):
    fo = open(os.path.join(COMPARISONFLDR, "diffme_%s.bat" % name), "w")

    if decompile_config.ONLY_RUN_THESE == True:
        diffable = [f + ".decompiled" for f in decompile_config.since()]

    for f in diffable:
        lhs = os.path.join(left_decompile, f)
        rhs = os.path.join(right_decompile, f)
        tgt = os.path.join(results_folder, f.replace(".decompiled", ".diff"))
        fo.write('diff "%s" "%s" > "%s"\n' % (lhs, rhs, tgt))
    fo.close()

def logjob():
    logfile = r'D:\downloads\ODI\the_trough\decompile.log'
    title = raw_input("Title Of Run: ")
    dt = datetime.datetime.today().strftime("%Y%m%d-%H%M")
    open(logfile, 'a').write("%s::%s::\n" % (title, dt))

def guess_folder(scen_name):
    '''given a scenario name guess the 
    Hacky - needs to be moved to some library function as quite useful'''

    SQL = '''SELECT
              SCEN_NO,
              SCEN_NAME,
              SCEN_VERSION,
              PACK_NAME,
              FOLDER_NAME,
              PROJECT_NAME
              FROM
                SNP_SCEN scen INNER JOIN SNP_PACKAGE pkg ON scen.I_PACKAGE = pkg.I_PACKAGE
                              INNER JOIN SNP_FOLDER fldr ON pkg.I_FOLDER = fldr.I_FOLDER
                              INNER JOIN SNP_PROJECT pj ON fldr.I_PROJECT = pj.I_PROJECT
            WHERE SCEN_NAME = '%s' ''' % scen_name
    
    rs = tdlib.query2obj(conn, SQL)
    if len(rs) == 0:
        return "Unknown/Unknown"
    return "%s/%s" % (rs[0].PROJECT_NAME, rs[0].FOLDER_NAME)
    

def guess_pattern(quote):
    '''based on 1000 bytes of the diff, guess the pattern this diff is

    a lot of the errors end up in similar patterns.

    >>> compile_error_str = """< LEFT OUTER JOIN CON89 ON GROUP_REPORT_CONTACTS_BV.CONTACT_ID=CON89.SOURCE_SYSTEM_CONTACT_ID 
---
> LEFT OUTER JOIN CON89 ON C5_CONTACT_ID=CON89.SOURCE_SYSTEM_CONTACT_ID"""


    '''
    pattern_list = []

    #auditflag
    if quote.find('#SWIFT_MOI.AUDIT_FLAG = 0') >= 0:
        pattern_list.append("auditflag")
    #joinerror
    if quote.find('Join error (') >=0:
        pattern_list.append('joinerror')
    rx1 = re.compile('\.(\w+?)=', re.DOTALL)


    #compile errors
    #tries to match 
    r = rx1.search(quote)
    
    if r != None:
        colname=r.groups()[0]
        rx2=re.compile('C\d+_%s' % colname)
        r = rx2.search(quote)
        if r != None:
            pattern_list.append('COMPILEERROR')

    return pattern_list






def mk_report(name, left_decompile, right_decompile,results_folder, set_left, set_right, diffable):
    '''What are the actual differences?

    What am i comparing?
    left and right.
    
        
    '''
    htmlreport = '''<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<body>
<div>
<img src="http://ukm.svc.$WELLKNOWNINSURER.com/_layouts/IMAGES/$WELLKNOWNINSURER_Branding/$WELLKNOWNINSURER_logo_withbox.gif">
</div>
'''
    
    htmlreport += "<h2>Simple report on LIVE / 11R4 comparison</h2>"
    htmlreport += datetime.datetime.today().isoformat()
    htmlreport += "<h4>We are comparing : left: %s and right : %s</h4>" % (left_decompile, right_decompile)
    htmlreport += "THere are %s records in left and %s records in right" % (len(set_left),len(set_right))
    htmlreport += "Making %s records that can be diff'd (diffable)" % len(diffable)
    htmlreport += "<li> left intersection right = %s files" % len(set_left.intersection(set_right))
    htmlreport += "<li> right intersection left = %s files" % len(set_right.intersection(set_left))

    htmlreport += "<h3>Scenarios on live but not in clean:</h3>"
    htmlreport += "We have %s Scenarios that exist on live, but no match exists in $DBCONNREF.  These will be part of the managed exceptions - scenarios that are allowed to be moved pre-compiled." %  len(set_right - set_left)
    htmlreport += '<table border="1">'

    for scen in sorted(set_right - set_left):
        scenname = scen.replace(".xml.decompiled","")
        if scenname in KNOWN_ISSUES_LIST: continue
        htmlreport += '''<tr><td>%s</td></tr>\n''' % (scenname,)
    htmlreport += '</table>'

    htmlreport += "on top of those, the below will be moved also as managed exceptions, as they are currently not soluable"
    htmlreport += '<table>'
    for f, reason in COMPLEXITY_TOO_GREAT:
        htmlreport += '''<tr><td>%s</td><td>%s</td></tr>\n''' % (f, reason)
    htmlreport += '</table>'

    htmlreport += "<h3>Scenarios on live and clean, with differences</h3>"

    ##tododo - here replace the suffix of the files - or not .. 
    files = [f for f in os.listdir(results_folder)]
    #avoid those we know have a solution
    files = [f for f in files if f.replace(".xml.diff","") not in [k[0] for k in KNOWN_ISSUES_LIST]]

    diff_files_empty = [f for f in files if os.stat(os.path.join(results_folder, f)).st_size == 0]
    diff_files_nonempty_all = [f for f in files if os.stat(os.path.join(results_folder, f)).st_size > 0]
    diff_files_nonempty = [f for f in files if os.stat(os.path.join(results_folder, f)).st_size > 13]
    ##
    

    htmlreport += "There are %s diff files that were empty, and %s that were not empty" % (
         len(diff_files_empty), len(diff_files_nonempty_all))

    htmlreport += "<h4>Non Emtpy Diff files</h4>\n"
    htmlreport += 'THere are %s files that have some difference </br>' % len(diff_files_nonempty_all)

    pattern_report = []
    main_report = '<table border="1">'
    
    for f in diff_files_nonempty:
        size = os.stat(os.path.join(results_folder, f)).st_size
        quote = open(os.path.join(results_folder, f)).read(1000).replace("\n", "<br/>")
        pattern = guess_pattern(quote)
        scen_name = f.replace(".xml.diff", "")
        if "COMPILEERROR" in pattern:
            pass
        else:
            main_report += '''<tr><td>%s<br/> %s (%s)</td>
                                  <td><font size="1">%s</font></td>
                                  <td>%s</td>
                              </tr>''' % (guess_folder(scen_name),
                                          f.replace(".xml.diff", ""), size, quote, pattern) 
        pattern_report.append([f,pattern])

    main_report += "</table>"
    
    htmlreport += """We have %s files that have some diff (ignoring  %s 13-Byte diffs), we ignored a total of %s as known "safe" issues,
                     %s as too complex for now, 
                     and of those left %s are compile errors, making %s to fix.
                     <p> I also think I have fixed %s of these (%s) since the last major run
                  """ % (len(diff_files_nonempty),
                         len(diff_files_nonempty_all) - len(diff_files_nonempty),
                         len(KNOWN_ISSUES_LIST), len(COMPLEXITY_TOO_GREAT),
                         len([p for p in pattern_report if 'COMPILEERROR' in p[1]]),
                         len(diff_files_nonempty) - len([p for p in pattern_report if 'COMPILEERROR' in p[1]]) - len(COMPLEXITY_TOO_GREAT),
                         len(SOLVED_INBETWEEN_RUNS), ",".join(SOLVED_INBETWEEN_RUNS)
                         )

    htmlreport += main_report

    htmlreport += 'The following are declared known issues <table border="1">'
    for scen,cause in KNOWN_ISSUES_LIST:
        htmlreport += '''<tr><td>%s</td><td>%s</td></tr>\n''' % (scen.replace(".xml.diff",""), cause)
    htmlreport += '</table>'

    htmlreport += "<h3>In easy to copy to excel form</h3>"
    htmlreport += '<table>'
    for f,pattern in pattern_report:
        htmlreport += '''<tr><td>%s</td><td>%s</td></tr>\n''' % (f, pattern)
    htmlreport += '</table>'
    
    diff_files_nonempty_set = set(diff_files_nonempty)
    #

    htmlreport += "<h3>Some have been reviewed and 'put aside' as too complex for the moment</h3>"
    htmlreport += '<table>'
    for f, reason in COMPLEXITY_TOO_GREAT:
        htmlreport += '''<tr><td>%s</td><td>%s</td></tr>\n''' % (f, reason)
    htmlreport += '</table>'

    htmlreport += "<h2>Commentary</h2>"
    htmlreport += COMMENTARY
    
    htmlreport += "</body></html>"




    dt = datetime.datetime.today().strftime("%Y%m%d-%H%M")
    fo = open(os.path.join(COMPARISONFLDR, 'diffreport_%s_%s.html' % (name, dt)) ,'w')
    fo.write(htmlreport)
    fo.close()
    #repeat just for dev convenience
    fo = open(os.path.join(COMPARISONFLDR, 'diffreport_%s.html' % name) ,'w')
    fo.write(htmlreport)
    fo.close()

      

if __name__ == '__main__':

    conn = tdlib.getConn(MOI_user_passwords.get_dsn_details('$DBCONNREF'))
    
    from decompile_config import * #ugly but there is a *lot*
    SUFFIX = '.xml.diff'

    KNOWN_ISSUES_LIST = [
    ('PKG_SWIFT_RECONCILATION', 'NOTRUNFOR2MTHS'),

    ('CONTRACTS', 'AUTOCOLNUMBERING_VARIES'),
    ('GROUP_CHRONICLES','AUTOCOLNUMBERING_VARIES'),
    ('GROUPS_AUD','AUTOCOLNUMBERING_VARIES'),
    ('OMX_ADDRESS','AUTOCOLNUMBERING_VARIES'),
    ('TASK_EVENTS', 'AUTOCOLNUMBERING_VARIES'),
    ('SALES_ACTIVITIES','AUTOCOLNUMBERING_VARIES'),
    ('CLAIM_ACCUMULATORS', 'AUTOCOLNUMBERING_VARIES'),
    ('COMPLAINT_FEEDBACK', 'AUTOCOLNUMBERING_VARIES'),
    ('TASK_EVENT_PROGRESSIONS', 'AUTOCOLNUMBERING_VARIES'),
    ('TAX_DUE', 'AUTOCOLNUMBERING_VARIES'),
    

    #    
    ('IMT_PARTY_ROLE_DETAILS_ORGS', 'UPPERCASEONLY'),
    ('RMTDEPENDANT_PARTY_ROLES', 'UPPERCASEONLY'),
    ('RMTDEPENDANT_PARTY_ROLE_ADDRESSES', 'UPPERCASEONLY'),
    ('RMTMEMBER_PARTY_ROLES', 'UPPERCASEONLY'),
    ('RMTMEMBER_PARTY_ROLE_ADDRESSES', 'UPPERCASEONLY'),
#    
    #
    ('MCX_CSS_INVOICES', 'ORDEREDJOIN_SYNTAX'),
    ('MCX_CSS_CLAIM_PROCEDURE_SERVS', 'ORDEREDJOIN_SYNTAX'),
    ('MCX_CSS_BASS_PATIENTS', 'ORDEREDJOIN_SYNTAX'),
    ('MCX_CSS_BASS_REGISTRATIONS', 'ORDEREDJOIN_SYNTAX'),
    ('MCX_CSS_CLAIMS', 'ORDEREDJOIN_SYNTAX'),
    ('MCX_CSS_CLAIM_DIAG_IMPAIRMENT', 'ORDEREDJOIN_SYNTAX'),
    ('MCX_CSS_CLAIM_ITEM_SETS', 'ORDEREDJOIN_SYNTAX'),
    ('MCX_CSS_CLAIM_LINES', 'ORDEREDJOIN_SYNTAX'),
    ('DOCUMENT_PACK_FULFILMENTS', 'ORDEREDJOIN_SYNTAX'),
    ('IMT_MEMBER_CROSSREFERENCE_IDS', 'ORDEREDJOIN_SYNTAX'),
    ('INTERMEDIARY_COMMISSION_HOLDS', 'ORDEREDJOIN_SYNTAX'),
    ('MARKETING_DELIVERY_PREFERENCES', 'ORDEREDJOIN_SYNTAX'),
    ('MEX_ERP_SALESMAN_DETAILS', 'ORDEREDJOIN_SYNTAX'),
    ('PROCEDURE_PRICING_VERSIONS_AUD', 'ORDEREDJOIN_SYNTAX'),
    ('PROVIDER_NETWORK_DISC_AUD', 'ORDEREDJOIN_SYNTAX'),
    ('SALES_ACTIVITIES', 'ORDEREDJOIN_SYNTAX'),
    ('USER_TEAM_CONTACTS', 'ORDEREDJOIN_SYNTAX'),
    ('CAMPAIGNS',  'ORDEREDJOIN_SYNTAX'),
    ('MEX_ERP_GROUP_TYPES',  'ORDEREDJOIN_SYNTAX'),


    
    ('BLD_CREDIT_BANDS', 'AUDITFLAG'),
    ('BLD_EQF_FEEDBACK_DATA', 'AUDITFLAG'),
    ('BLD_EQ_ADDRESS_DETAILS', 'AUDITFLAG'),
    ('BLD_EQ_COMPANY_DETAILS', 'AUDITFLAG'),
    ('BLD_EQ_CONTACT_DETAILS', 'AUDITFLAG'),
    ('BLD_OFFICER_ROLL', 'AUDITFLAG'),
    ('BLD_SIC_CODE', 'AUDITFLAG'),
    ('BLD_YP_CLASS', 'AUDITFLAG'),
    ('BLD_YP_COMPANY_STATUS', 'AUDITFLAG'),
    ('BLD_YP_GROUP', 'AUDITFLAG'),
    ('BLD_YP_PREMISES', 'AUDITFLAG'),    
    ('BLD_YP_SECTOR', 'AUDITFLAG'),


    ('MET015D', 'PKG_ORDERING_PROBLEM'),
    ('RMX001', 'PKG_ORDERING_PROBLEM'),
    ('SML106D', 'PKG_ORDERING_PROBLEM'),    
    ('SML114D', 'PKG_ORDERING_PROBLEM'),
    ('SML099D','PKG_ORDERING_PROBLEM'),

    ('USER_TEAM_DETAILS_AUD','SPECIALCASECOMPILEERROR-TRUNCATEDTABLENAME'),    
    ('SRC_BUSINESS_OBJECT_INCENTIVES', '''Links toBUSINESS_OBJECT_INCENTIVES. Two interfaces, both use same datastore, but one live scenario uses a datastrore alias when that is spelt one way, then the other uses the same alias but after spelling was corrected. It is however safe - it is an variable assignment   '''),
    ('OTX003', '''only diff is parameters of getObjectName call - produces same results in same topology '''),

    ('MEMBER_REG_CHRONICLES_AUD', '''DECOMPILE ERROR - but not picked up by regex'''),


('BUILD_W$PORS','$ is not handled in automation scripts - manual testing shows its ok'),
('GMXTBLCANCELLATIONREASONS_','Source has space on end - live scenario is altered to remove space but source code not changed so never get a match'),
('IMT_BOOKING_CANCELLATION_REASO','live scenario is truncated to 30 char but source code not changed so never get a match'),
('INTERMEDIARY_EMPS_MNGRS','Source has space on end - live scenario is altered to remove space but source code not changed so never get a match'),
('INTERMEDIARY_PRODUCTS','Source has space on end - live scenario is altered to remove space but source code not changed so never get a match'),
('NOTE_EVENTS','We have two interfaces in SWIFT MOI (folders FRD and COMMON) with same name as ONE table in SWIFT. Bad practise, but COMMON folder is safe'), 

    ('PST_JOURNAL_GEN_ACCOUNT_ENTRIES','''BAU - COntains two interfaces that are not in the right project. tried to copy over and recompile - still refuses to compile scenario. '''),
    ('TMT001M', '''BAU - Part of PREP_MOI - one off migration from 2010 - ignore '''),
    ('TMX001M', '''BAU - Part of PREP_MOI - one off migration from 2010 - ignore '''),
    ('PMT_ORGANISATION_TPS', '''BAU - Part of PREP_MOI - one off migration from 2010 - ignore '''),
    ('PMX_ORGANISATION_TPS', '''BAU - Part of PREP_MOI - one off migration from 2010 - ignore '''),
    ('SML104D_MANUAL_START', '''BAU - One off useage for BAU who can look after that '''),

    ('PKG_MOI_RECONCILATION', 'Part oF MOI_RECONCILIATION project - is this ever going to be run again? Can BAU comment?'),
    ('SWIFT_UPDATE', 'Part oF MOI_RECONCILIATION project - is this ever going to be run again? Can BAU comment? '),
    ('TMT001M', 'Ignore - is part of PREP_MOI project and will never be run again.  However it seems to run each day - can BAU comment? '),
    ('TMX001M', 'Ignore - is part of PREP_MOI project and will never be run again.  However it seems to run each day - can BAU comment? '),

    ]        

    SOLVED_INBETWEEN_RUNS = [
                             ]

    COMPLEXITY_TOO_GREAT = [
                            ('USER_TEAM_DETAILS_AUD', '''The C17_ generated column truncates the column name when it would normally throw compilation problem.  Has this ever worked? '''),
                            ('MPX001','''No source but a large number of unusual mismappings.   '''),

                            

]
    COMMENTARY = '''
Summary
=======

As of 3 Jan. we have fixed, identified as safe all but four sources - these will have to remain as binaries for now and
be manually added to any new deployment.

However I have now introduced a "too hard" category - ones that have proven intractable to fixing, and
will for now be part of the "moved as complete scenarios" approach.  4 exist in this category.


Next Steps
----------

1. Package the scenarios that need to stay as compiled scenarios, and provide instructions on how to deploy

2. Flush into TFS and provide a TFS tag for current production ODI

3. branch off from that tag, and create an IDW release branch

4. From same tag create the 12R2 branches

5. merge BICC, and other development branches into the STABLE-DEV-NON_PROGRAM branch

6. Repeat for Erwin, Cognos and UV


Stage 2
-------

Outstanding issues that *may* have an impact

1. Force_scen_version problem
   In some cases a command is forced to use a given version of a scenario - this is the ODI equivalent of DLL dependancy.

   
    
Patterns of safe scenarios
--------------------------

There are a number of "patterns" to the diffs we see between our scenarios and live.
In some cases these patterns are "safe" - that is they have no effect on the final compiled object's ability to work and so can be
allowed to remain un-fixed.

An example is RMTDEPENDANT_PARTY_ROLES which has a difference between itself and live of using different case - NULL vs null.  This is quite safe to leave without fixing
for an exact match.

The below is a list of the mismatched scenarios 

In one case we have to consider the problem "managed".  For some reason compiling the same source code multiple times will result in different outcomes.
this ia the compile-error pattern.
The various patterns that are safe /managed are

* NOTRUNFOR2MTHS
  This flag is objects that have not run for past two months at least.
  We have only monthly, weekly or daily running scenarios, and as such 2 months is a reasonable cut off.

* UPPERCASEONLY
  An example is RMTDEPENDANT_PARTY_ROLES which has a difference between itself and live of using different case - NULL vs null.



* ORDEREDJOIN_SYNTAX
    An ordered join will appear as ANSI standard INNER JOIN syntax when getFrom is called.
    AN unordered join will appear as WHERE x = Y after the FROM clause, when getJoin is called and the ordering of those joins is not guaranteed.
    So, if we have an interface that has out of place diffs, (ie transpositions of same code) <em>and</em> has unordered joins
    (SELECT * FROM SNP_POP_CLAUSE where I_POP = )
    then we can declare that safe

* AUDITFLAG
    In a limited set of cases we have found the incorrect use in live of a audit-flag (#SWIFT-MOI.AUDIT_FLAG) in the Equifax models - in other words those areas of live will never work right
    However the audit flag is beleived to never change and so we can consider these safe.

* COMPILE_ERROR
    We have encountered a signigifcant problem - compilation of same code on same machine produces different output in certain cases.
    We have not been able to resolve it but we can identify and prove it.
    It has a clear signature and a regex to find it is below::

     _BV -> C13_ is the signature
     '\.(\w+?)=' gives colname and  is then found in 'C\d+_%s' % colname

* AUTOCOLNUMBERING_VARIES
    When producing intermediate tables, the system will generate fake column names, such as
    C1_name
    C2_address
    however the order of production of these columns is not guaranteed.  As such it is possible to get
    C1_address
    C2_name
    This is safe as the same name is used throughout.

* PKG_ORDERING_PROBLEM
    We can see that a scenario is correctly linked, but there is no particular correct way to print that out as text (the linked list can be multiply entrant,
    plus the internal NNO ordering seems not to be consistent.
    Anyway if on inspection a package is linked correctly, we see it as safe
    NB this does NOT take into account the problem  of "Force_scen_version problem" - where a fixed version of a scenario is called from a package.
    It is unclear how we shall handle this going forward.


Force_scen_version problem
--------------------------
::

 OdiStartScen "-SCEN_NAME=PST_JOURNAL_GEN_ACCOUNT_ENTRIES" -SCEN_VERSION=1"

Here we are forcing a particular Scenario to be used in execution - but what that version is is totally broken.
I have not guarded against these problems - it is left to stage 2 


::






http://$WELLKNOWNINSURER11x714j:5000/scenariodiff/$DBCONNREF/IMT_BOOKING_CANCELLATION_REASONS/$DBCONNREF/IMT_BOOKING_CANCELLATION_REASO


    '''
    
    for left_decompile, right_decompile, results_folder, name in comparison_sets:

        set_left = set([f for f in os.listdir(left_decompile)])
        set_right = set([f for f in os.listdir(right_decompile)])
#        fo = open(os.path.join(COMPARISONFLDR, 'l_%s.txt' % name), 'w'); fo.close()
#        fo = open(os.path.join(COMPARISONFLDR,'r_%s.txt' % name), 'w'); fo.close()
        fo = None
        
#        for f in set_left-set_right:
#            open(r'C:\ODICodeForComparison\Reconcilliation\l_%s.txt' % name, 'a').write("%s\n" % f)
#        for f in set_right-set_left:
#            open(r'C:\ODICodeForComparison\Reconcilliation\r_%s.txt' % name, 'a').write("%s\n" % f)
        diffable = set_left.intersection(set_right)

        inarg = sys.argv[1:][0]

        if inarg == 'mkdiff': 
            mkbat(name, left_decompile, right_decompile, results_folder, diffable)
        elif inarg == 'mkreport':
            mk_report(name, left_decompile, right_decompile,results_folder, set_left, set_right, diffable)
        elif inarg == 'logjob':
            logjob()
        else:
            print "usage: decompile_diff_and_report.py mkdiff / mkreport "
