SELECT DISTINCT -- Because of multi column constraints/indices.
       'ALTER TABLE ' || TRIM(childdb) || '.' || TRIM(childtable) || ' DROP CONSTRAINT ' || TRIM(indexname)
  FROM dbc.all_ri_children
 WHERE indexname IS NOT NULL
   AND childdb = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP JOIN INDEX ' || TRIM(databasename) || '.' || TRIM(tablename)
  FROM dbc.tables
 WHERE tablekind = 'I'
   AND databasename = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP TABLE ' || TRIM(databasename) || '.' || TRIM(tablename)
  FROM dbc.tables
 WHERE (
       tablekind = 'T' -- Regular table.
    OR tablekind = 'O' -- No Primary Index table.
       )
   AND databasename = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP VIEW ' || TRIM(databasename) || '.' || TRIM(tablename)
  FROM dbc.tables
 WHERE tablekind = 'V'
   AND databasename = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP PROCEDURE ' || TRIM(databasename) || '.' || TRIM(tablename)
  FROM dbc.tables
 WHERE (
       tablekind = 'P'
    OR tablekind = 'E'
       )
   AND databasename = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP TYPE ' || TRIM(databasename) || '.' || TRIM(tablename)
  FROM dbc.tables
 WHERE tablekind = 'U'
   AND databasename = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP FUNCTION ' || TRIM(databasename) || '.' || TRIM(tablename)
  FROM dbc.tables
 WHERE (
       tablekind = 'R' -- Table function.
    OR tablekind = 'F' -- Scalar UDF.
    OR tablekind = 'A' -- Aggregate UDF.
       )
   AND databasename = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP MACRO ' || TRIM(databasename) || '.' || TRIM(tablename)
  FROM dbc.tables
 WHERE tablekind = 'M'
   AND databasename = '<OdiScmPhysicalSchemaName>'
/