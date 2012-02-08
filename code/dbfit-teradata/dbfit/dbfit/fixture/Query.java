package dbfit.fixture;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dbfit.environment.DBEnvironment;
import dbfit.environment.DbEnvironmentFactory;
import dbfit.util.DataColumn;
import dbfit.util.DataTable;
import fit.Fixture;

public class Query extends RowSetFixture {
	private DBEnvironment dbEnvironment;
	private String query;
	private boolean isOrdered;
	public Query() {
		dbEnvironment=DbEnvironmentFactory.getDefaultEnvironment();
		isOrdered=false;
	}		
	public Query (DBEnvironment environment, String query){
		this (environment, query, false);
		System.out.println("Query: constructor is Query(DBEnvironment, String)");
	}
	public Query (DBEnvironment environment, String query, boolean isOrdered){
		this.dbEnvironment=environment;
		this.query=query;
		this.isOrdered=isOrdered;
		System.out.println("Query: constructor is Query(DBEnvironment, String, boolean), Query: "+query);
	}
	public DataTable getDataTable() throws SQLException {
		System.out.println("Query: getDataTable()");
			if (query==null) query=args[0];
			if (query.startsWith("<<")) 
				return getFromSymbol();				
			PreparedStatement st=dbEnvironment.createStatementWithBoundFixtureSymbols(query);
			return new DataTable(st.executeQuery());
	}
	private DataTable getFromSymbol() throws SQLException {
		System.out.println("Query: getFromSymbol");
		Object o = dbfit.util.SymbolUtil.getSymbol(query.substring(2).trim());
		if (o instanceof ResultSet){
			return new DataTable((ResultSet) o);
		}
		else if (o instanceof DataTable){
			return (DataTable) o;
		}
		throw new UnsupportedOperationException ("Stored queries can only be used on symbols that contain result sets");
	} 
	protected boolean isOrdered() {
		return isOrdered;
	}
	@Override
	protected Class getJavaClassForColumn(DataColumn col) throws ClassNotFoundException, SQLException{
		System.out.println("Query: getJavaClassForColumn: DataColumn.getName()="+ col.getName());
		System.out.println("Query: getJavaClassForColumn: DataColumn.getJavaClassName()="+col.getJavaClassName());
		System.out.println("Query: getJavaClassForColumn: DataColumn.getDbTypeName()="+col.getDbTypeName());
		return dbEnvironment.getJavaClass(col.getDbTypeName());
	}
}
