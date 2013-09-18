SELECT 'DROP TABLE ' + s.name + '.' + t.name
  FROM sys.tables t
 INNER
  JOIN sys.schemas s
    ON t.schema_id = s.schema_id
 WHERE s.name = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP VIEW ' + s.name + '.' + t.name
  FROM sys.views t
 INNER
  JOIN sys.schemas s
    ON t.schema_id = s.schema_id
 WHERE s.name = '<OdiScmPhysicalSchemaName>'
/

SELECT 'DROP PROCEDURE ' + s.name + '.' + t.name
  FROM sys.views t
 INNER
  JOIN sys.schemas s
    ON t.schema_id = s.schema_id
 WHERE s.name = '<OdiScmPhysicalSchemaName>'
/