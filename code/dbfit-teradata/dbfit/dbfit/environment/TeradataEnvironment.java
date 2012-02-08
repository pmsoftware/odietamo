package dbfit.environment;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Clob;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.Iterator;

import dbfit.util.DbParameterAccessor;
import dbfit.util.NameNormaliser;
import dbfit.util.SqlTimestampParseDelegate;
import dbfit.util.TypeNormaliser;
import dbfit.util.TypeNormaliserFactory;

public class TeradataEnvironment extends AbstractDbEnvironment {

	public static class TeradataClobNormaliser implements TypeNormaliser {

		 private static final int MAX_CLOB_LENGTH=10000;
		 
		 public Object normalise(Object o) throws SQLException {
			if (o==null) return null;					
			if (!(o instanceof java.sql.Clob)){
				throw new UnsupportedOperationException("TeradataClobNormaliser cannot work with " + o.getClass());
			}
			Clob clob=(Clob) o;
			if (clob.length()>MAX_CLOB_LENGTH) throw new UnsupportedOperationException("Clobs larger than "+MAX_CLOB_LENGTH+"bytes are not supported by DBFIT");
			String buffer = clob.getSubString(1,(int)clob.length());
			return buffer;
		 }
	}
	
	public TeradataEnvironment() {
		TypeNormaliserFactory.setNormaliser(java.sql.Clob.class,new TeradataClobNormaliser());
	}
		  
    public boolean supportsOuputOnInsert(){
    	return false;
    }
	protected String getDriverClassName() {
		return "com.teradata.jdbc.TeraDriver";
	}
	protected String getConnectionString(String dataSource)
    {
        return "jdbc:teradata://"+dataSource;
	}
	protected String getConnectionString(String dataSource, String dataBase)
    {
        return "jdbc:teradata://"+dataSource+"/DATABASE="+dataBase;
        //return "jdbc:teradata://"+dataSource+"/TMODE=ANSI,DATABASE="+dataBase;
	}
	
	private static String paramNamePattern = ":([A-Za-z0-9_]+)";
	private static Pattern paramsNames = Pattern.compile(":([A-Za-z0-9_]+)");
	
	public Pattern getParameterPattern(){
		return paramsNames;
	}
	
	protected String parseCommandText(String commandText) {
		commandText = commandText.replaceAll(paramNamePattern, "?");
		return super.parseCommandText(commandText);
	}
	
    public Map<String, DbParameterAccessor> getAllProcedureParameters(String procName) throws SQLException
    {
    	System.out.println("TeradataEnvironment: getAllProcedureParameters: tableOrViewName: "+procName);
    	
		String[] qualifiers = NameNormaliser.normaliseName(procName).split("\\.");
		
		String cols="CASE WHEN TRIM(columnname) = 'RETURN0' AND spparametertype = 'O' ";
		cols = cols + "THEN '' ";
		cols = cols + "ELSE TRIM(columnname) ";
		cols = cols + "END AS columnname, ";
		cols = cols + "CASE ";
		cols = cols + "WHEN c.columntype IN ('CF') THEN 'CHAR' ";
		cols = cols + "WHEN c.columntype IN ('CV') THEN 'VARCHAR' ";
		cols = cols + "WHEN c.columntype IN ('CO') THEN 'CLOB' ";		
		cols = cols + "WHEN c.columntype IN ('I8') THEN 'LONG' ";
		cols = cols + "WHEN c.columntype IN ('I') THEN 'INTEGER' ";
		cols = cols + "WHEN c.columntype IN ('I2') THEN 'SMALLINT' ";
		cols = cols + "WHEN c.columntype IN ('I1') THEN 'BYTEINT' ";
		cols = cols + "WHEN c.columntype IN ('D') THEN 'DECIMAL' ";
		cols = cols + "WHEN c.columntype IN ('D') THEN 'DOUBLE' ";
		cols = cols + "WHEN c.columntype IN ('DA') THEN 'DATE' ";
		cols = cols + "WHEN c.columntype IN ('TS') THEN 'TIMESTAMP' ";
		cols = cols + "WHEN c.columntype IN ('TI') THEN 'TIME' ";
		cols = cols + "WHEN c.columntype IN ('BF') THEN 'BINARY' ";
		cols = cols + "WHEN c.columntype IN ('BV') THEN 'VARBINARY' ";
		cols = cols + "END AS colmntype, ";
		cols = cols + "columnlength, ";
		cols = cols + "CASE spparametertype WHEN 'I' THEN 'IN' WHEN 'O' THEN 'OUT' WHEN 'B' THEN 'IN/OUT' ";
		cols = cols + "END AS paramdirection";		
		
		String qry = "SELECT " + cols + "  FROM dbc.columns c " + "WHERE ";
		if (qualifiers.length==2) {
			qry += "c.databasename=? and c.tablename=?";
		} else {
			qry += "c.databasename=user AND c.tablename=?";
		}
	
		qry+=" order by c.columnid";
		
		// WHAT THE HELL IS THIS FOR!? ********************
		/*
		if (qualifiers.length==2){
			String[] newQualifiers=new String[6];
			newQualifiers[0]=qualifiers[0];
			newQualifiers[1]=qualifiers[1];
			newQualifiers[2]=qualifiers[0];
			newQualifiers[3]=qualifiers[1];
			newQualifiers[4]=qualifiers[0];
			newQualifiers[5]=qualifiers[1];
			qualifiers=newQualifiers;
		}
		else if (qualifiers.length==1){
			String[] newQualifiers=new String[2];
			newQualifiers[0]=qualifiers[0];
			newQualifiers[1]=qualifiers[0];
			qualifiers=newQualifiers;		
		}	
		*/
			
		return readIntoParams(qualifiers, qry);
	}
    public Map<String, DbParameterAccessor> getAllColumns(String tableOrViewName) throws SQLException
    {
		System.out.println("TeradataEnvironment: getAllColumns: tableOrViewName: "+tableOrViewName);
    	
    	String[] qualifiers = NameNormaliser.normaliseName(tableOrViewName).split("\\.");
		
		String cols="columnname, CASE ";
		cols = cols + "WHEN c.columntype IN ('CF') THEN 'CHAR' ";
		cols = cols + "WHEN c.columntype IN ('CV') THEN 'VARCHAR' ";
		cols = cols + "WHEN c.columntype IN ('CO') THEN 'CLOB' ";
		cols = cols + "WHEN c.columntype IN ('I8') THEN 'LONG' ";
		cols = cols + "WHEN c.columntype IN ('I') THEN 'INTEGER' ";
		cols = cols + "WHEN c.columntype IN ('I2') THEN 'SMALLINT' ";
		cols = cols + "WHEN c.columntype IN ('I1') THEN 'BYTEINT' ";
		cols = cols + "WHEN c.columntype IN ('D') THEN 'DECIMAL' ";
		cols = cols + "WHEN c.columntype IN ('F') THEN 'DOUBLE' ";
		cols = cols + "WHEN c.columntype IN ('DA') THEN 'DATE' ";
		cols = cols + "WHEN c.columntype IN ('TS') THEN 'TIMESTAMP' ";
		cols = cols + "WHEN c.columntype IN ('TI') THEN 'TIME' ";
		cols = cols + "WHEN c.columntype IN ('BF') THEN 'BINARY' ";
		cols = cols + "WHEN c.columntype IN ('BV') THEN 'VARBINARY' ";
		cols = cols + "END AS columntype, ";
		cols = cols + "columnlength, ";
		cols = cols + "'IN' AS paramdirection";

		String qry = "SELECT " + cols + " FROM dbc.columns c " +
				"WHERE ";
		if (qualifiers.length==2) {
			qry += "c.databasename=? and c.tablename=?";
		} else {
			qry += "c.databasename=user AND c.tablename=?";
		}
		qry+=" order by c.columnid ";
		return readIntoParams(qualifiers, qry);
	}

	private Map<String, DbParameterAccessor> readIntoParams(String[] queryParameters, String query)
		throws SQLException{
		System.out.println("TeradataEnvironment: readIntoParams: query: "+query);
		for (int i=0; i<queryParameters.length; i++) {
			System.out.println("TeradataEnvironment: readIntoParams: queryParameters["+i+"]: "+queryParameters[i]);
		}
		CallableStatement dc=currentConnection.prepareCall(query);
		for (int i = 0; i < queryParameters.length; i++) {
			System.out.println("TeradataEnvironment: readIntoParams: Setting value for parameter: "+i);			
			dc.setString(i+1,queryParameters[i].toUpperCase());
		}
		ResultSet rs=dc.executeQuery();
		Map<String, DbParameterAccessor>
			allParams = new HashMap<String, DbParameterAccessor>();
		int position=0;
		while (rs.next()) {
			String paramName=rs.getString(1);	
			System.out.println("TeradataEnvironment: readIntoParams: paramName: "+paramName+", has length: "+paramName.length());
			if (paramName==null) {
				System.out.println("TeradataEnvironment: readIntoParams: paramName==null");
				paramName=""; // Function return values get empty parameter names.
			}
			if (paramName.equals("")) {
				System.out.println("TeradataEnvironment: readIntoParams: paramName==\"\"");
				paramName=""; // Function return values get empty parameter names.
			}
			String dataType = rs.getString(2);
			System.out.println("TeradataEnvironment: readIntoParams: dataType: "+dataType);
			String direction = rs.getString(4);
			System.out.println("TeradataEnvironment: readIntoParams: direction: "+direction);
			int paramDirection;
			System.out.println("TeradataEnvironment: readIntoParams: +paramName.trim().toUpperCase()+: +"+paramName.trim().toUpperCase()+"+");
			if (paramName.trim().toUpperCase().equals("")) {
				System.out.println("TeradataEnvironment: readIntoParams: setting paramDirection to RETURN_VALUE");
				paramDirection=DbParameterAccessor.RETURN_VALUE;
			}
			else {
				System.out.println("TeradataEnvironment: readIntoParams: setting paramDirection to getParameterDirection(direction): "+getParameterDirection(direction));
				paramDirection=getParameterDirection(direction);
			}
			
			System.out.println("TeradataEnvironment: readIntoParams: creating new DbParameterAccessor for paramName: "+paramName+
					", paramDirection: "+paramDirection+
					", getSqlType: "+getSqlType(dataType)+
					", getJavaClass().getName():"+getJavaClass(dataType).getName());
			DbParameterAccessor dbp=new DbParameterAccessor (paramName,paramDirection,
					getSqlType(dataType), getJavaClass(dataType),
					paramDirection==DbParameterAccessor.RETURN_VALUE?
							-1:position++);			
			allParams.put(NameNormaliser.normaliseName(paramName),
				dbp);
		}
		System.out.println("TeradataEnvironment: readIntoParams: returning");
		return allParams;
	}

	// List interface has sequential search, so using list instead of array to map types
	private static List<String> stringTypes = Arrays.asList(new String[] { "VARCHAR","CHAR" });
	private static List<String> clobTypes = Arrays.asList(new String[] { "CLOB" });	
	private static List<String> longTypes = Arrays.asList(new String[]{ "LONG" });
	private static List<String> intTypes = Arrays.asList(new String[] { "INTEGER" });
	private static List<String> byteTypes = Arrays.asList(new String[]{ "BYTEINT" });
	private static List<String> shortTypes = Arrays.asList(new String[]{ "SMALLINT" });
	private static List<String> decimalTypes = Arrays.asList(new String[] { "DECIMAL" });
	private static List<String> doubleTypes = Arrays.asList(new String[]{ "DOUBLE","FLOAT" });
	private static List<String> dateTypes = Arrays.asList(new String[] { "DATE" });
	private static List<String> timestampTypes=Arrays.asList(new String[]{ "TIMESTAMP" });
	private static List<String> timeTypes=Arrays.asList(new String[]{ "TIME" });
	private static List<String> binaryTypes=Arrays.asList(new String[]{ "BINARY" });
	private static List<String> varBinaryTypes=Arrays.asList(new String[]{ "VARBINARY" });

	private static String normaliseTypeName(String dataType) {
		dataType = dataType.toUpperCase().trim();
		int idx = dataType.indexOf(" ");
		if (idx >= 0) dataType = dataType.substring(0, idx);
		idx = dataType.indexOf("(");
		if (idx >= 0) dataType = dataType.substring(0, idx);
		return dataType;
	}
	private static int getSqlType(String dataType) {
		//todo:strip everything from first blank
		dataType = normaliseTypeName(dataType);
		
		System.out.println("TeradataEnvironment: getSqlType: received data type: " + dataType);
		
		if (stringTypes.contains(dataType) ) return java.sql.Types.VARCHAR;
		if (clobTypes.contains(dataType) ) return java.sql.Types.CLOB;		
		if (longTypes.contains(dataType) ) return java.sql.Types.BIGINT;
		if (intTypes.contains(dataType) ) return java.sql.Types.INTEGER;
		//if (byteTypes.contains(dataType) ) return java.sql.Types.TINYINT;
		if (byteTypes.contains(dataType) ) return java.sql.Types.INTEGER;
		//if (shortTypes.contains(dataType) ) return java.sql.Types.SMALLINT;
		if (shortTypes.contains(dataType) ) return java.sql.Types.INTEGER;
		if (decimalTypes.contains(dataType) )return java.sql.Types.NUMERIC;
		if (doubleTypes.contains(dataType) ) return java.sql.Types.DOUBLE;
		if (dateTypes.contains(dataType) ) return java.sql.Types.DATE;
		if (timestampTypes.contains(dataType)) return java.sql.Types.TIMESTAMP;
		if (timeTypes.contains(dataType)) return java.sql.Types.TIME;
		if (binaryTypes.contains(dataType)) return java.sql.Types.BINARY;
		if (varBinaryTypes.contains(dataType)) return java.sql.Types.VARBINARY;
				
		throw new UnsupportedOperationException("TeradataEnvironment: Type " + dataType + " is not supported");
	}
	public Class<?> getJavaClass(String dataType) {
		
		System.out.println("TeradataEnvironment: getJavaClass: received data type: " + dataType);
		
		dataType = normaliseTypeName(dataType);
		
		// Be sure to align the returned Class types with those returned
		// by ResultSetMetaData.getColumnTypeName.
		
		if (stringTypes.contains(dataType))		return String.class;
		//if (clobTypes.contains(dataType))		return String.class;
		if (clobTypes.contains(dataType))		return java.sql.Clob.class;
		if (longTypes.contains(dataType))		return Long.class;
		if (intTypes.contains(dataType))		return Integer.class;
		//if (byteTypes.contains(dataType))		return Byte.class;
		if (byteTypes.contains(dataType))		return Integer.class;
		//if (shortTypes.contains(dataType))		return Short.class;
		if (shortTypes.contains(dataType))		return Integer.class;
		if (doubleTypes.contains(dataType))		return Double.class;
		if (decimalTypes.contains(dataType))	return BigDecimal.class;
		if (dateTypes.contains(dataType))		return java.sql.Date.class;
		if (timestampTypes.contains(dataType))	return java.sql.Timestamp.class;
		if (timeTypes.contains(dataType))		return java.sql.Time.class;
		
		//Iterator i = byteTypes.iterator();
	    //while (i.hasNext()) {
	    //  System.out.println("TeradataEnvironment: getJavaClass: byteTypes: "+i.next());
	    //}
	    
		throw new UnsupportedOperationException("TeradataEnvironment: Type " + dataType + " is not supported");
	}
	private static int getParameterDirection(String direction) {
		if ("IN".equals(direction)) return DbParameterAccessor.INPUT;
		if ("OUT".equals(direction)) return DbParameterAccessor.OUTPUT;
		if ("IN/OUT".equals(direction)) return DbParameterAccessor.INPUT_OUTPUT;
		//todo return val
		throw new UnsupportedOperationException("TeradataEnvironment: Direction " + direction + " is not supported");
	}
	
    public String buildInsertCommand(String tableName, DbParameterAccessor[] accessors)
    {
        System.out.println("TeradataEnvironment: buildInsertCommand");
    	StringBuilder sb = new StringBuilder("insert into ");
        sb.append(tableName).append("(");
        String comma = "";
        String retComma = "";

        StringBuilder values = new StringBuilder();
        StringBuilder retNames = new StringBuilder();
        StringBuilder retValues = new StringBuilder();

        for (DbParameterAccessor accessor : accessors)
        {
            if (accessor.getDirection()==DbParameterAccessor.INPUT)
            {
                sb.append(comma);
                values.append(comma);
                sb.append(accessor.getName());
                //values.append(":").append(accessor.getName());
                values.append("?");
                comma = ",";
            }
            else
            {
                retNames.append(retComma);
                retValues.append(retComma);
                retNames.append(accessor.getName());
                //retValues.append(":").append(accessor.getName());
                retValues.append("?");
                retComma = ",";
            }
        }
        sb.append(") values (");
        sb.append(values);
        sb.append(")");
        System.out.println("TeradataEnvironment: buildInsertCommand: sb.toString(): "+sb.toString());
        return sb.toString();
    }
}