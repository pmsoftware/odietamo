SELECT table_name || ':'
  FROM user_tables
 WHERE table_name
   NOT
  LIKE '%SESS%'
   AND table_name
   NOT '%SCEN_TASK%'
<OdiScmGenerateSqlStatementDelimiter>
