SELECT 'DROP TABLE ' || table_schema || '.' || table_name
  FROM information_schema.tables
<OdiScmPhysicalSchemaFilter>
/

SELECT 'DROP VIEW ' || table_schema || '.' || table_name
  FROM information_schema.views
<OdiScmPhysicalSchemaFilter>
/