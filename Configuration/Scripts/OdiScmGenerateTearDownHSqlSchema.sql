SELECT 'DROP TABLE ' <OdiScmSchemaSelect> || '."' || table_name || '" CASCADE'
  FROM information_schema.tables
<OdiScmPhysicalSchemaFilter>
/

SELECT 'DROP VIEW ' <OdiScmSchemaSelect> || '."' || table_name || '" CASCADE'
  FROM information_schema.views
<OdiScmPhysicalSchemaFilter>
/