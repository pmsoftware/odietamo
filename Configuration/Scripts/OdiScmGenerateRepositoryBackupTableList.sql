SELECT table_name || ':'
  FROM user_tables
 WHERE table_name
   NOT
  LIKE '%SESS%'
<OdiScmGenerateSqlStatementDelimiter>
