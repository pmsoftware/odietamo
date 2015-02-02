--
-- Query used to construct DDL statements to drop unnamed foreign key constraints.
--
SELECT TRIM(childdb) || '.' || TRIM(childtable)
    || ',' || TRIM(childkeycolumn)
    || ',' || TRIM(parentdb) || '.' || TRIM(parenttable)
    || ',' || TRIM(parentkeycolumn)
  FROM dbc.all_ri_children
 WHERE indexname IS NULL
   AND childdb = '<OdiScmPhysicalSchemaName>'
 ORDER
    BY childdb
     , childtable
     , parentdb
     , parenttable
     , childkeycolumn
     , parentkeycolumn
<OdiScmGenerateSqlStatementDelimiter>
