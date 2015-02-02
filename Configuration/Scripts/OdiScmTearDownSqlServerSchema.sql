SELECT 'ALTER TABLE ' + s.name + '.' + t.name + ' DROP CONSTRAINT ' + f.name
  FROM sys.tables t
 INNER
  JOIN sys.schemas s
    ON t.schema_id = s.schema_id
 INNER
  JOIN sys.foreign_keys f
    ON t.object_id = f.parent_object_id
 WHERE s.name = '<OdiScmPhysicalSchemaName>'
<OdiScmGenerateSqlStatementDelimiter>

SELECT 'DROP TABLE ' + s.name + '.' + t.name
  FROM sys.tables t
 INNER
  JOIN sys.schemas s
    ON t.schema_id = s.schema_id
 WHERE s.name = '<OdiScmPhysicalSchemaName>'
<OdiScmGenerateSqlStatementDelimiter>

SELECT 'DROP VIEW ' + s.name + '.' + t.name
  FROM sys.views t
 INNER
  JOIN sys.schemas s
    ON t.schema_id = s.schema_id
 WHERE s.name = '<OdiScmPhysicalSchemaName>'
<OdiScmGenerateSqlStatementDelimiter>

SELECT 'DROP PROCEDURE ' + s.name + '.' + t.name
  FROM sys.procedures t
 INNER
  JOIN sys.schemas s
    ON t.schema_id = s.schema_id
 WHERE s.name = '<OdiScmPhysicalSchemaName>'
<OdiScmGenerateSqlStatementDelimiter>
