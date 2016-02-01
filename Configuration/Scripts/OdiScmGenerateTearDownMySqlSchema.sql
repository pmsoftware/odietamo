SELECT CONCAT('ALTER TABLE <OdiScmSchemaSelect>', table_name, ' DROP FOREIGN KEY ', constraint_name)
  FROM information_schema.referential_constraints
<OdiScmConstraintPhysicalSchemaFilter>
<OdiScmGenerateSqlStatementDelimiter>

SELECT CONCAT('DROP TABLE <OdiScmSchemaSelect>', table_name)
  FROM information_schema.tables
<OdiScmPhysicalSchemaFilter>
<OdiScmGenerateSqlStatementDelimiter>

SELECT CONCAT('DROP VIEW <OdiScmSchemaSelect>', table_name)
  FROM information_schema.views
<OdiScmPhysicalSchemaFilter>
<OdiScmGenerateSqlStatementDelimiter>
