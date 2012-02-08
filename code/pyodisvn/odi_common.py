#odi common stuff
class PyODIError(Exception):
    ''' '''
    pass



def objsql_from_objname(objname, objtype, extras):
    '''A common idiom seems to be to want to get back the defitnions of a
    object from its ID or from just a name.
    Errr ----
    actually there is a dispatching need '''
    #I want to use the SNP Objectfs, but each constructir expects I_pop which is what I am looking for 
    #PROJECT
    mapper = {
     'SnpProject': '''SELECT I_PROJECT as ID, PROJECT_NAME as NAME FROM SNP_PROJECT WHERE UPPER(PROJECT_NAME) = '%(objname)s' ''',

     'SnpTrt': '''SELECT I_TRT as ID, TRT_NAME as NAME
                     FROM SNP_TRT trt 
                     INNER JOIN  SNP_PROJECT pj 
                                 ON trt.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(trt.TRT_NAME) = '%(objname)s' ''',

    'SnpTable': '''SELECT I_TABLE as ID, TABLE_NAME as NAME
                    FROM SNP_TABLE tbl INNER JOIN SNP_MODEL mdl ON tbl.I_MOD = mdl.I_MOD
                WHERE 
                MOD_NAME = '%(mod_name)s'
                AND 
                UPPER(tbl.TABLE_NAME)
                = '%(objname)s'
                ''',     

    'SnpPop': '''SELECT I_POP as ID, POP_NAME as NAME
                     FROM SNP_POP pop 
                     INNER JOIN  SNP_FOLDER fldr 
                                 ON pop.I_FOLDER = fldr.I_FOLDER

                    INNER JOIN SNP_PROJECT pj
                                 ON fldr.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(pop.POP_NAME) = '%(objname)s' ''',
     
    'SnpPackage': '''SELECT I_PACKAGE as ID, PACK_NAME as NAME
                     FROM SNP_PACKAGE pkg 
                     INNER JOIN  SNP_FOLDER fldr 
                                 ON pkg.I_FOLDER = fldr.I_FOLDER
                     INNER JOIN SNP_PROJECT pj
                                 ON fldr.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(pkg.PACK_NAME) = '%(objname)s'
                          ''',

    'SnpVar':  '''SELECT I_VAR as ID, VAR_NAME as NAME
                     FROM SNP_VAR var 
                     INNER JOIN SNP_PROJECT pj
                                 ON var.I_PROJECT = pj.I_PROJECT
                     WHERE 
                          pj.PROJECT_NAME = '%(project_name)s'
                     AND 
                          UPPER(var.VAR_NAME) = '%(objname)s'
                          ''',    
        }

    try:
        sql_tmpl = mapper[objtype]
    except KeyError, e:
        raise e
        
    d = {'objname':objname.upper(),}
    d.update(extras)

    return sql_tmpl % d         


tobefixedlatermapper = {'SnpConnect':('SNP_CONNECT','I_CONNECT', 'CONNECT_NAME'),
          'SnpLschema':('SNP_LSCHEMA','I_LSCHEMA', ''),
          'SnpProject':('SNP_PROJECT','I_PROJECT','PROJECT_NAME'),
          'SnpPackage':('SNP_PACKAGE','I_PACKAGE','PACK_NAME'),
          'SnpFolder':('SNP_FOLDER','I_FOLDER','FOLDER_NAME'),
          'SnpPop':('SNP_POP','I_POP','POP_NAME'),
          'SnpJoin':('SNP_JOIN','I_JOIN','CONCAT(PK_SCHEMA, PK_TABLE_NAME)'),
          'SnpTable':('SNP_TABLE','I_TABLE','TABLE_NAME'),
          'SnpTrt':('SNP_TRT','I_TRT','TRT_NAME'),

#          'SnpObjState',
#          'SnpSequence',
          'SnpVar':('SNP_VAR','I_VAR','VAR_NAME'),
          'SnpModel':('SNP_MODEL','I_MOD','MOD_NAME'),
#           'SnpGrpState'          

          }


lookup = {
#extension used by mark, desc, source table, col holding source ID,  column holding name
    
'.SnpLschema':   ['LOGICALSCHEMAS', 'SNP_LSCHEMA','I_LSCHEMA', ''],
'.SnpConnect':   ['DATASERVERS','SNP_CONNECT','I_CONNECT', 'CONNECT_NAME'],
'.SnpPschema':   ['PHYSICALSCHEMAS','','',''],
'.SnpContext':   ['CONTEXTS', '','',''], 
'.SnpModel':     ['MODEL',  'SNP_MODEL','I_MOD','MOD_NAME'],
'.SnpSubModel':  ['SUBMODEL','','',''], 
'.SnpTable':     ['TABLE',  'SNP_TABLE','I_TABLE','TABLE_NAME'],
'.SnpProject':   ['PROJECT', 'SNP_PROJECT','I_PROJECT','PROJECT_NAME'],
'.SnpPackage':   ['PACKAGE', 'SNP_PACKAGE','I_PACKAGE','PACK_NAME'],
'.SnpPop':       ['POP', 'SNP_POP','I_POP','POP_NAME'],
'.SnpGrpState':  ['GROUPSTATE', '','',''],
'.SnpVar':       ['GLOBALVAR', 'SNP_VAR','I_VAR','VAR_NAME']
'.SnpModFolder': ['MODFOLDER','','',''],
'.SnpSequence':  ['SEQUENCE','','',''],
'.SnpUfunc':     ['USERFUNCTION','','',''],
'.SnpFolder':    ['FOLDER','','',''],
'.SnpTrt':       ['TRT', 'SNP_TRT','I_TRT','TRT_NAME'],
'.SnpObjState':  ['OBJECTSTATE', '','',''],
'.SnpTechno':    ['TechNumber','','',''],
'.SnpLang':      ['LANG','','',''],
'.SnpJoin':      ['SNP_JOIN','I_JOIN','CONCAT(PK_SCHEMA, PK_TABLE_NAME)'],
}

def get_by_colid(lookup):
    ''' '''
    d = {}
    for extn in lookup:
        idcol = lookup[extn][2]
        d[idcol] = lookup[extn]

    return d

lookup_by_idcol = get_by_colid(lookup)
