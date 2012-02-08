package dbfit.util;

import java.lang.reflect.InvocationTargetException;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import fit.Fixture;

public class DbParameterAccessor extends DbTypeAdapter {
	public static final int RETURN_VALUE=0;
	public static final int INPUT=1;
	public static final int OUTPUT=2;
	public static final int INPUT_OUTPUT=3;
	
	private int index; //index in effective sql statement (not necessarily the same as position below)
	private int direction;
	private String name;
	private int sqlType;
	private int position; //zero-based index of parameter in procedure or column in table
	public static Object normaliseValue(Object currVal) throws SQLException{
		if (currVal==null) return null;
		TypeNormaliser tn=TypeNormaliserFactory.getNormaliser(currVal.getClass());
		if (tn!=null) currVal=tn.normalise(currVal);
		return currVal;
	}
	public DbParameterAccessor(DbParameterAccessor acc) {
		System.out.println("DbParameterAccessor(DbParameterAccessor)");
		System.out.println("DbParameterAccessor: name: "+this.name+", direction: "+this.direction+", sqlType: "+this.sqlType+", position: "+this.position);
		this.name = acc.name;
		this.direction = acc.direction;
		this.sqlType = acc.sqlType;
		this.type = acc.type;
		this.position=acc.position;
	}
	public DbParameterAccessor(String name, int direction, int sqlType, Class javaType, int position) {
		System.out.println("DbParameterAccessor(String, int, int, Class, int)");
		System.out.println("DbParameterAccessor: name: "+name+", direction: "+direction+", javaType: "+javaType.getName()+", position:"+position);
		this.name = name;
		this.direction = direction;
		this.sqlType = sqlType;
		this.type = javaType;
		this.position=position;
	}
	public int getSqlType() {
		return sqlType;
	}
	/** One of the constants from this class declaring whether the param is input, output or a return value. JDBC does not have a return value
	 * parameter directions, so a new constant list had to be introduced
	 * public static final int RETURN_VALUE=0;
   	 * public static final int INPUT=1;
	 * public static final int OUTPUT=2;
	 * public static final int INPUT_OUTPUT=3;
	 */
	public int getDirection() {
		return direction;
	}
	public String getName() {
		return name;
	}
	public void setDirection(int direction){
		this.direction=direction;
	}
	//really ugly, but a hack to support mysql, because it will not execute inserts with a callable statement
	private CallableStatement convertStatementToCallable() throws SQLException{
		System.out.println("DbParameterAccessor: convertStatementToCallable()");
		if (cs == null) {
			System.out.println("DbParameterAccessor: convertStatementToCallable: cs == null");
		}
		else {
			System.out.println("DbParameterAccessor: convertStatementToCallable: cs != null");
			System.out.println("DbParameterAccessor: convertStatementToCallable: cs.getClass().getName(): "+cs.getClass().getName());
		}
		if (cs instanceof CallableStatement) {
			System.out.println("DbParameterAccessor: convertStatementToCallable: cs is instanceof CallableStatement");
			System.out.println("DbParameterAccessor: convertStatementToCallable: object cs: "+cs);
			return (CallableStatement) cs;
		}
		else {
			System.out.println("DbParameterAccessor: convertStatementToCallable: cs is NOT instanceof CallableStatement");
		}
		throw new SQLException("This operation requires a callable statement instead of "+cs.getClass().getName());
	}
	/*******************************************/
	private PreparedStatement cs;
	public void bindTo(Fixture f, PreparedStatement cs, int ind) throws SQLException {
		System.out.println("DbParameterAccessor: bindTo()");
				
		this.cs=cs;
		
		//only cast the PreparedStatement to a CallableStatement where there are OUT/INOUT/RETURN_VALUE parameters.
		//System.out.println("DbParameterAccessor: bindTo: convertStatementToCallable().getClass().getName(): "+convertStatementToCallable().getClass().getName());
		
		System.out.println("DbParameterAccessor: bindTo: cs.getClass().getName(): "+cs.getClass().getName());
		System.out.println("DbParameterAccessor: bindTo: this.cs.getClass().getName(): "+this.cs.getClass().getName());
		
		System.out.println("DbParameterAccessor: bindTo: cs instanceof CallableStatement?: "+(cs instanceof CallableStatement));
		System.out.println("DbParameterAccessor: bindTo: cs instanceof PreparedStatement?: "+(cs instanceof PreparedStatement));

		System.out.println("DbParameterAccessor: bindTo: this.cs instanceof CallableStatement?: "+(this.cs instanceof CallableStatement));
		System.out.println("DbParameterAccessor: bindTo: this.cs instanceof PreparedStatement?: "+(this.cs instanceof PreparedStatement));
		
		System.out.println("DbParameterAccessor: bindTo: object cs: "+cs);
		System.out.println("DbParameterAccessor: bindTo: object cs: "+this.cs);
		
		this.fixture=f;
		this.index=ind;	
		if (direction==DbParameterAccessor.OUTPUT || 
				direction==DbParameterAccessor.RETURN_VALUE||
				direction==DbParameterAccessor.INPUT_OUTPUT){
			System.out.println("DbParameterAccessor: bindTo: registering out param with index: "+ind+" to SQL type: "+getSqlType());
			
			System.out.println("DbParameterAccessor: bindTo: before cast, object cs: "+cs);
			//CallableStatement cs2 = (CallableStatement) cs;
			convertStatementToCallable().registerOutParameter(ind, getSqlType());
			//cs2.registerOutParameter(ind, getSqlType());
			System.out.println("DbParameterAccessor: bindTo: after cast object cs: "+cs);
			//convertStatementToCallable();
			
			//this.cs.registerOutParameter(ind, getSqlType());
		}
		else {
			System.out.println("DbParameterAccessor: bindTo: param with index: "+ind+" is not an OUTPUT/RETURN_VALUE/INPUT_OUTPUT parameter");
		}
		System.out.println("DbParameterAccessor: bindTo: returning");
	}
	
	public void set(Object value) throws Exception {
		if (direction==OUTPUT||direction==RETURN_VALUE)
			throw new UnsupportedOperationException("Trying to set value of output parameter "+name);
		
		System.out.println("DbParameterAccessor: set: this.name: "+this.name+", this.direction: "+this.direction+
				", this.sqlType: "+this.sqlType+", this.position: "+this.position+
				", this.type.getName(): "+this.type.getName());
		
		if (value == null)
			System.out.println("DbParameterAccessor: set: received a null object reference");
				
		//System.out.println("DbParameterAccessor: set: value.getName(): "+value.getClass().getName());
		//System.out.println("DbParameterAccessor: set: index: "+index+", value: "+value);
		//if ((value instanceof String) && (value=="null")
			//cs.setNull(index,0)
		//else
			/************************
			 * BUPA ADDITIONS START
			 */
		//if (value == null)
			//cs.setNull(index, sqlType);

		/*
		String valueClassName = value.getClass().getName();
		int targetJdbcType = 0; 
		if (valueClassName=="java.lang.String") targetJdbcType = java.sql.Types.VARCHAR;
		else
			if (valueClassName=="java.lang.Short") targetJdbcType = java.sql.Types.SMALLINT;
			else
				if (valueClassName=="java.lang.Integer") targetJdbcType = java.sql.Types.INTEGER;
				else
					if (valueClassName=="java.lang.Long") targetJdbcType = java.sql.Types.BIGINT;
					else
						if (valueClassName=="java.lang.Decimal") targetJdbcType = java.sql.Types.DECIMAL;
						else
							if (valueClassName=="java.sql.Date") targetJdbcType = java.sql.Types.DATE;
							else
								if (valueClassName=="java.sql.Date") targetJdbcType = java.sql.Types.DATE;
								else
									System.out.println("DbParameterAccessor: set: did not determine SQL type for valueClassName: "+valueClassName);
		System.out.println("DbParameterAccessor: set: valueClassName: "+valueClassName+", targetJdbcType: "+targetJdbcType);
		*/
			/************************
			 * BUPA ADDITIONS END
			 */
		cs.setObject(index, value, this.sqlType);
		//cs.setObject(index, value); ORIGINAL DBFIT CODE
	}	
	public Object get() throws IllegalAccessException, InvocationTargetException {
		System.out.println("DbParameterAccessor: get()");
		try{
			if (direction==INPUT)
				throw new UnsupportedOperationException("Trying to get value of input parameter "+name);			
			return normaliseValue(convertStatementToCallable().getObject(index));
		}
		catch (SQLException sqle){
			throw new InvocationTargetException(sqle);
		}
	}
	/** 
	 * Zero-based column or parameter position in a query, table or stored proc
	 */
	public int getPosition() {
		System.out.println("DbParameterAccessor: getPosition()");
		return position;
	}
	
}
