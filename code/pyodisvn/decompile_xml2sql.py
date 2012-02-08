#play xml
import elementtree.ElementTree as et
from elementtree.ElementTree import Element
import os

'''

>>> scen = lst_SnpScen[0]
>>> scen.steps
[[0 UTL_SCENARIO_SESSION_WRITER 11081], [1 BUILD_ADHI 11081], [10 BUILD_ORGH 11081], ...
>>> stp = scen.steps[1]
>>> stp.tasks
[[2 120 1 BUILD_ADHI INS_MLCO 11081], [3 140 1 BUILD_ADHI UPD_MLCO_GET_NEXT 11081], [4 150 1 BUILD_ADHI INS_ADHI_BADM 11081], ...
>>> tsk = stp.tasks[1]
>>> tsk.txt
'UPDATE <?=snpRef.getSchemaName("MOI_B_UKM_DATA", "D") ?>.moi_load_control\n   SET extract_to_ts = CURRENT_TIMESTAMP(0)\n WHERE table_name = \'ADDRESSES_HISTORY\'\n;'
>>>



## FILES
## decompile $DBCONNREF_MEX_ERP_SALESMAN_DETAILS.xml
>>> f = r'_meta\test\decompile\$DBCONNREF_MEX_ERP_SALESMAN_DETAILS.xml'
>>> txt = decompile_xml(scenario_xml)



'''
           
class SnpScen(object):
    def __init__(self, subelement):
        for child in subelement.getchildren():
            self.__dict__[child.attrib['name']] = child.text

    def __repr__(self):
        return "[%s %s %s]" % (self.ScenNo, self.ScenName, self.ITxtScen)

    def add_steps(self, lst_SnpScenStep):
        ''' '''
        lst_my_steps = [step for step in lst_SnpScenStep if step.ScenNo == self.ScenNo]
        self.steps = sorted(lst_my_steps, key=lambda x:int(x.Nno))        
    
class SnpExpTxt(object):
    def __init__(self, subelement):
        for child in subelement.getchildren():
            self.__dict__[child.attrib['name']] = child.text

    def __repr__(self):
        return "[%s %s...%s]" % (self.ITxt, self.Txt[:8], self.Txt[-5:])

class SnpScenStep(object):
    def __init__(self, subelement):
        for child in subelement.getchildren():
            self.__dict__[child.attrib['name']] = child.text

    def __repr__(self):
        return "[%s %s %s]" % (self.Nno, self.StepName, self.ScenNo)

    def add_task(self, lst_SnpScenTask):
        ''' '''
        try:
            lst_my_tasks = [task for task in lst_SnpScenTask if task.Nno == self.Nno]
        except:
            print lst_SnpScenTask
        self.tasks = sorted(lst_my_tasks, key=lambda x: int(x.ScenTaskNo) )
        

class SnpScenTask(object):
    def __init__(self, subelement):
        for child in subelement.getchildren():
            self.__dict__[child.attrib['name']] = child.text

    def __repr__(self):
        return "[%s %s %s %s %s %s]" % (self.ScenTaskNo, self.OrdTrt, self.Nno,
                                         self.TaskName2, self.TaskName3, self.ScenNo)

    def add_txt(self, lst_SnpScenTxt):
        '''really brute force - run thoguh all txt items, extract those that match ScenTaskNo,
            order them and store result as TXT'''
        lst_my_txt_fragments = [frag for frag in lst_SnpScenTxt if frag.ScenTaskNo == self.ScenTaskNo]

        #must order not by string order but by number order !!!!!
        ordered_frags = sorted(lst_my_txt_fragments, key=lambda x: [x.OrdType, int(x.TxtOrd)])

#        for frag in ordered_frags:
#            print "< %s %s %s %s > %s" % ( frag.ScenNo, frag.ScenTaskNo, frag.TxtOrd, frag.Nno,  frag.Txt.encode("utf-8"))

        self.txt = ''.join([frag.Txt for frag in ordered_frags])
        

class SnpScenTxt(object):
    def __init__(self, subelement):
        for child in subelement.getchildren():
            self.__dict__[child.attrib['name']] = child.text

    def __repr__(self):
        return "[%s %s %s %s...%s]" % (self.TxtOrd, self.Nno, self.ScenTaskNo, self.Txt[:8], self.Txt[-5:])


##### not used in scenarios (yet!) but from ODISVN joins
class SnpJoin(object):
    def __init__(self, subelement):
        for child in subelement.getchildren():
            self.__dict__[child.attrib['name']] = child.text


class SnpJoinCol(object):
    def __init__(self, subelement):
        for child in subelement.getchildren():
            self.__dict__[child.attrib['name']] = child.text




def clean_up_filenames(fldr):
    '''exporting from ODI leaves some cruft

    I want to rename files from ODI as below
    SCEN_ABSENCE_REASONS001.xml -> ABSENCE_REASONS.xml
    But I need to remove / force the os.rename
    '''
    for f in os.listdir(fldr):
        if f.find("SCEN_") != 0: continue
        
        newf = f.replace(" Version 001.xml", ".xml")
        newf = newf.replace("001.xml", ".xml")
        newf = newf.replace('SCEN_', '') #bitrisky
        tgtpath = os.path.join(fldr, newf)
        srcpath = os.path.join(fldr,f)
        print "move %s -> %s" % (srcpath, tgtpath)
        if os.path.isfile(tgtpath):
            os.remove(tgtpath)
        os.rename(srcpath, tgtpath)

def decompile_xml(scenario_xml):
    ''' '''
#   urgh - need to handle error rasing better 
#    try: 
    tree = et.parse(scenario_xml)
#    except Exception, e:
#        print e,  "failed to parse %s" % f_xml
#        continue

    root = tree.getroot()

    #giveing myself a hallpass to break PEP 8 in order to keep names simialr to ODI 
    lst_SnpScen = []
    lst_SnpExpTxt = []
    lst_SnpScenStep = []
    lst_SnpScenTask = []
    lst_SnpScenTxt = []

    #hacky grab everything, into useful later mutable obejcts
    for subelement in root:
        if subelement.attrib["class"] == "com.sunopsis.dwg.dbobj.SnpScen":
            lst_SnpScen.append(SnpScen(subelement))
        elif subelement.attrib["class"] == "com.sunopsis.dwg.dbobj.SnpExpTxt":
            lst_SnpExpTxt.append(SnpExpTxt(subelement))
        elif subelement.attrib["class"] == "com.sunopsis.dwg.dbobj.SnpScenStep":
            lst_SnpScenStep.append(SnpScenStep(subelement))
        elif subelement.attrib["class"] == "com.sunopsis.dwg.dbobj.SnpScenTask":
            lst_SnpScenTask.append(SnpScenTask(subelement))
        elif subelement.attrib["class"] == "com.sunopsis.dwg.dbobj.SnpScenTxt":
            lst_SnpScenTxt.append(SnpScenTxt(subelement))
        else:
            pass


    #roll up - put the text into the tasks ...
    [task.add_txt(lst_SnpScenTxt) for task in lst_SnpScenTask]
    #the tasks into steps
    [step.add_task(lst_SnpScenTask) for step in lst_SnpScenStep]
    #and steps into scenarios
    [scen.add_steps(lst_SnpScenStep) for scen in lst_SnpScen]

    scen = lst_SnpScen[0]
    concattxt = ''
    for step in scen.steps:
        for task in step.tasks:
            ## add scenTaskNo to task listing too. 
            concattxt += "\n*** %s %s/%s ***\n" % (task.OrdTrt, task.TaskName2, task.TaskName3)
            concattxt += task.txt.replace(" ?","%").replace("?","%").replace("odiRef", "snpRef").encode("utf-8")
            concattxt += "\n*** %s %s/%s ***\n" % (task.OrdTrt, task.TaskName2, task.TaskName3)
    return concattxt


    

if __name__ == '__main__':

    from decompile_config import * #ugly but there is a *lot*
    import decompile_config
    
    for f in valid_folders:
        if not os.path.isdir(f):
            os.makedirs(f)


    
    for XMLFOLDER, TGTFOLDER in src_pairs:
        clean_up_filenames(XMLFOLDER)

        print "decompiling %s to %s " % (os.path.basename(XMLFOLDER), os.path.basename(TGTFOLDER))
        scenario_xmls = os.listdir(XMLFOLDER)

        #ONLY_RUN_THESE is hack to speed up roundtrippi9ng
        if ONLY_RUN_THESE == True:
            scenario_xmls = decompile_config.since()

        ctr = 0
        print ctr,
        for f_xml in scenario_xmls:
            ctr += 1
            print "\r", ctr, 

            scenario_xml = os.path.join(XMLFOLDER, f_xml)
            if os.path.isdir(scenario_xml) is True:continue

            try:
                concattxt = decompile_xml(scenario_xml)
            except:
                print "failed to parse %s" % scenario_xml
                continue
 
            open(os.path.join(TGTFOLDER, f_xml+".decompiled"), 'w').write(concattxt)
