#!/usr/local/bin/python
#! -*- coding: utf-8 -*-

import mx.ODBC.Manager

import md5 
import os
import sys
import string
import datetime
import shutil

from mikado.common.db import tdlib
import MOI_user_passwords
import ODI_objects_from_repo as odi_lib

class OdiError(Exception):
    pass


'''
set up an ODI marker and populate it, based on MArk Matten PL/SQL
Not using it cos SQUIREELL wont run PL/SQL and I am tired


idea - for each project, populate snp_grp_state, and snp_state2 with the new marker name,
then for each object, update snp_obj_state with marker/id match

for snp_obj_state, we need to keep the PK i_obj_state automincremented, and use the correct id for each obj type

3200                         -- For packages
3100                         -- For interfaces.
3600                         -- For procedures.


Loops:

  for each project
      populate snp_grp_state, and snp_state2
      for each object we want to mark
          populate snp_obj_state (increment i_obj_state)
          
      update i_grp_stete and i_state (per proejct)


So I need to know which project an object is in to set its marker...


for each project there is one and only one state and substate
SELECT I_PROJECT, gs.I_GRP_STATE, s2.I_STATE FROM snp_grp_state gs
INNER JOIN snp_state2 s2 
ON gs.I_GRP_STATE = s2.I_GRP_STATE
where GRP_STATE_CODE = 'MOI_CODE_RECONCILLIATION'




'''





#### sort of genericish code forming here - getting srcIDs and src types from names of scens

def get_src_details_from_scen_name(conn, scen_name):
    ''' use Marks moi_scen_sources, and some mapping'''

    SQL = '''SELECT * FROM moi_scen_sources
    where SCEN_NAME IN (
    '%s'
    )
    ''' % scen_name
    

    rs = tdlib.query2obj(conn, SQL)

    if len(rs) == 0:
        raise OdiError("no matching scen found")

    for row in rs:
        objtype = MAPPER[row.GENERATE_CODE][0]
        objid = row.__dict__[MAPPER[row.GENERATE_CODE][1]]

    return (scen_name, objtype, objid)

def emit_project_details_given_odi_objinstance(conn, objtypename, objinstanceid):
    '''Basically we only create scenarios for pop trt and pack so this is good enough for now. '''

    mapper = {'I': ['SNP_POP', 'I_POP'],
              'P': ['SNP_PACKAGE', 'I_PACKAGE'],
              'T': ['SNP_TRT', 'I_TRT']
              }
    tblname, colname = mapper[objtypename]
    
    SQL = ''' SELECT   p.I_PROJECT
                     , p.PROJECT_NAME
                     , f.I_FOLDER
                     , f.FOLDER_NAME
              FROM
              %s t INNER JOIN SNP_FOLDER f ON t.I_FOLDER = f.I_FOLDER
             INNER JOIN SNP_PROJECT p
                ON f.I_PROJECT = p.I_PROJECT
              where %s = %s ''' % (tblname, colname, int(objinstanceid))
    rs = tdlib.query2obj(conn, SQL)
    return (rs[0].I_PROJECT, rs[0].PROJECT_NAME, rs[0].I_FOLDER, rs[0].FOLDER_NAME,)


    
insert_marker_sql = '''        INSERT
          INTO snp_grp_state
               (
               i_grp_state                  
             , i_project                  
             , grp_state_code                
             , grp_state_name
             , grp_order_disp                   
             , tree_display
             , ind_internal                 
             , ind_multi_states                 
             , ind_auto_increment                 
             , int_version                  
             , ind_change                 
             , first_date                        
             , first_user                
             , last_user                
             , last_date                        
             , ext_version
               )  
        VALUES (
               %(i_grp_state)s
             , %(i_project)s
             , '%(markername)s'
             , '%(markername)s'
             , %(orddisplay)s               -- Order Disp, -ve surely not used.
             , 'A'                          -- Tree Display.
             , '0'                          -- Internal
             , '0'                          -- Multi states
             , 1                            -- Auto increment
             , NULL                         -- Interanl Version
             , 'I'                          -- Version
             , SYSDATE                      -- First date
             , 'SQLSCRIPT'                  -- First user
             , 'SQLSCRIPT'                  -- Last user
             , SYSDATE                      -- Last date
             , NULL                         -- External version
               );


 '''

insert_marker_2 = '''        INSERT
          INTO snp_state2
               (
               i_state                       
             , i_grp_state                   
             , state_code                    
             , state_name                   
             , state_order                   
             , in_use                        
             , show_desc                     
             , icon_res                      
             , state_datatype                
             , last_date                     
             , int_version                   
             , ind_change                    
             , first_date                    
             , first_user                    
             , last_user
               )
        VALUES (
               %(i_state)s
             , %(i_grp_state)s
             , '%(markername)s'
             , '%(markername)s'
             , %(orddisplay)s                          -- State order
             , '1'                          -- In Use
             , '1'                          -- Show Desc
             , '/markers/taskprior_3.gif'   -- Icon Res
             , 'A'                          -- State data type
             , SYSDATE                      -- Last Date
             , NULL                         -- Internal version
             , 'I'                          -- Ind Change
             , SYSDATE                      -- First Date
             , 'SQLSCRIPT'                  -- First User
             , 'SQLSCRIPT'                  -- Last User                                                              
               );            '''




insert_obj_state = '''            INSERT
              INTO snp_obj_state
                   (
                   i_obj_state
                 , i_state
                 , i_object
                 , i_instance
                 , info_text
                 , info_date
                 , info_num
                 , i_txt_memo
                 , last_date
                 , last_user
                   )
            VALUES (
                   %(i_obj_state)s
                 , %(i_state)s
                 , %(snp_type_id)s
                 , %(instance_id)s
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                   );'''

def populate_all_projects_with_marker(conn, marker_name):

    #### variales decld in PLSQL - we will need these later
    #    iGrpState       snp_grp_state.i_grp_state%TYPE;
    #    iState          snp_state2.i_state%TYPE;
    #    iObjState       snp_obj_state.i_obj_state%TYPE;
            
    rs = tdlib.query2obj(conn, '''SELECT MAX(i_grp_state) + 1000 as "i_grp_state" FROM snp_grp_state;''')
    i_grp_state = rs[0].i_grp_state

    rs = tdlib.query2obj(conn, '''    SELECT MAX(i_state) + 1000 as "i_state" FROM snp_state2; ''')
    i_state = rs[0].i_state



    rs = tdlib.query2obj(conn, "SELECT I_PROJECT, PROJECT_NAME from SNP_PROJECT ORDER by I_PROJECT")
    for row in rs:
        print "--", row.PROJECT_NAME, row.I_PROJECT, i_grp_state , i_state
        i_grp_state += 1
        i_state += 1

        d = {'orddisplay': -98
             , 'markername': marker_name
             , 'i_state' : i_state
             ,'i_grp_state' : i_grp_state
             , 'i_project': row.I_PROJECT
             }

        
        print insert_marker_sql % d
        print insert_marker_2 % d


def create_marker_on_object(conn, marker_name, i_project, snptype, snpid):
    '''Knowing the project, and the markername, I can find the i_grp_state and i_state.
    Then knowing the instance type and the instance id I can create the object_state insert
    '''

    snptypeid = MAPPER[snptype][2] # ie 3200 for SnpPackage

    SQL = """SELECT gs.I_GRP_STATE, s2.I_STATE, I_PROJECT FROM snp_grp_state gs
             INNER JOIN
             snp_state2 s2 ON gs.I_GRP_STATE = s2.I_GRP_STATE 
             where GRP_STATE_CODE = '%s'
             AND I_PROJECT = %s """ % (marker_name, int(i_project))
    
    rs = tdlib.query2obj(conn, SQL)
    i_grp_state = rs[0].I_GRP_STATE
    i_state = rs[0].I_STATE

    
    rs = tdlib.query2obj(conn, '''SELECT MAX(i_obj_state) as "i_obj_state"  FROM snp_obj_state; ''')
    i_obj_state = rs[0].i_obj_state + 1   


    d = {'i_obj_state': int(i_obj_state)
        , 'i_state' : int(i_state)
        , 'snp_type_id' : int(snptypeid)
        , 'instance_id' : int(snpid)
         
         }
         
    markerSQL =  insert_obj_state % d
    tdlib.exec_query(conn, markerSQL) #commit???
    tdlib.exec_query(conn, "COMMIT") #commit???
    
def clear_down_current_markers(conn, marker_name):
    ''' '''
    SQL = """DELETE
                 FROM snp_obj_state
                 WHERE i_state
                IN (
                   SELECT i_state
                     FROM snp_state2
                    WHERE state_code = '%s'
                      AND i_grp_state
                       IN (
                          SELECT i_grp_state
                            FROM snp_grp_state
                           WHERE grp_state_code  = '%s'
                          )
                   ) """  % (marker_name,marker_name)
    tdlib.exec_query(conn, SQL)
    
    
         

if __name__ == '__main__':

    # I shall use moi_scen_sources to decide which kbjects wil be marked to make a scenario


    MAPPER = {'I': ('SnpPop', 'I_POP', 3100),
              'P': ('SnpPackage', 'I_PACKAGE', 3200),
              'T': ('SnpTrt', 'I_TRT', 3600),
              }
    ###REALLY SORT THIS OUT
    OTHER_MAPPER = {'SnpPop':('I_POP', 3100),
              'SnpPackage':('I_PACKAGE', 3200),
              'SnpTrt':('I_TRT', 3600),
              }     

    conn = tdlib.getConn(dsn=MOI_user_passwords.DSNSTRINGS['$DBCONNREF'])
    #marker_name = 'MOI_adhoc_baseline'
    marker_name = 'MOI_CODE_RECONCILLIATION'
    

    #use this to populate the markers - again...
    ###populate_all_projects_with_marker(conn, marker_name)

    clear_down_current_markers(conn, marker_name)

    lst_which_objects_to_compile = tdlib.query2obj(conn, '''
        SELECT SCEN_NAME, 
               COALESCE(I_PACKAGE, I_POP, I_TRT) "snpid", 
               GENERATE_CODE as "snptype"
        FROM MOI_SCEN_SOURCES 
        WHERE GENERATE_CODE in ('P', 'I', 'T')''')
 
         
    
    for row in lst_which_objects_to_compile:
        if row.snpid is None: 
            print "none type for ", row.snpid, row.SCEN_NAME
            continue

        i_project, project_name, i_folder, folder_name = emit_project_details_given_odi_objinstance(conn, 
                                                                                           row.snptype, row.snpid )
        print "create marker", marker_name, i_project, row.snptype, row.snpid, row.SCEN_NAME
        create_marker_on_object(conn, marker_name, i_project, row.snptype, row.snpid)
    
