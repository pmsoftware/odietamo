package dbfit.util;

import java.sql.ResultSetMetaData;
import java.sql.SQLException;

/**
 * minimal meta-data about a result-set column. 
 * @see DataTable
 */
public class DataColumn {
	private String name;
	private String javaClassName;
	private String dbTypeName;
	public DataColumn(String name, String javaClassName, String dbTypeName) {
		System.out.println("DataColumn: DataColumn(String, String, String");
		this.name = name;
		this.javaClassName = javaClassName;
		this.dbTypeName = dbTypeName;
		System.out.println("DataColumn: name: "+name+", javaClassName: "+javaClassName+", dbTypeName: "+dbTypeName);
	}
	public DataColumn(ResultSetMetaData r, int columnIndex) throws SQLException{
		System.out.println("DataColumn: DataColumn(ResultSetMetaData, int)");
		this.name=r.getColumnName(columnIndex);
		this.javaClassName=r.getColumnClassName(columnIndex);
		this.dbTypeName=r.getColumnTypeName(columnIndex);
		System.out.println("DataColumn: name: "+this.name+", javaClassName: "+this.javaClassName+", dbTypeName: "+this.dbTypeName);		
	}
	public String getDbTypeName() {
		return dbTypeName;
	}
	public String getJavaClassName() {
		return javaClassName;
	}
	public String getName() {
		return name;
	}
}
