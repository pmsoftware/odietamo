package dbfit.fixture;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import dbfit.environment.DBEnvironment;
import dbfit.environment.DbEnvironmentFactory;
import dbfit.util.DbParameterAccessor;
import dbfit.util.NameNormaliser;
import dbfit.util.SymbolAccessQueryBinding;
import dbfit.util.SymbolAccessSetBinding;
import fit.Binding;
import fit.Parse;

public class ExecuteProcedure extends fit.Fixture {
	private DBEnvironment environment;
	private CallableStatement statement;
	private String procName;
	private DbParameterAccessor[] accessors;
	private Binding[] columnBindings;
	private boolean exceptionExpected=false;
    private boolean excNumberDefined=false;
    private int excNumberExpected;
	public ExecuteProcedure()
	{
		System.out.println("ExecuteProcedure: ExecuteProcedure()");
        this.environment = DbEnvironmentFactory.getDefaultEnvironment();
    }
	
	public ExecuteProcedure(DBEnvironment dbEnvironment, String procName, 
			int expectedErrorCode) {
		System.out.println("ExecuteProcedure: ExecuteProcedure(DBEnvironment, String, int)");		
		this.procName= procName;
		this.environment = dbEnvironment;		
		this.exceptionExpected=true;
		this.excNumberDefined=true;
		this.excNumberExpected=expectedErrorCode;
		System.out.println("ExecuteProcedure: ExecuteProcedure(DBEnvironment, String, int): procName: "+procName+
				", exceptionExpected: "+exceptionExpected+
				", excNumberDefined: "+excNumberDefined+
				", excNumberExpected: "+excNumberExpected);
	}
	public ExecuteProcedure(DBEnvironment dbEnvironment, String procName, 
			boolean exceptionExpected) {
		System.out.println("ExecuteProcedure: ExecuteProcedure(DBEnvironment, String, boolean)");		
		this.procName= procName;
		this.environment = dbEnvironment;		
		this.exceptionExpected=exceptionExpected;
		this.excNumberDefined=false;
		System.out.println("ExecuteProcedure: procName: "+procName+
				", exceptionExpected: "+exceptionExpected+
				", excNumberDefined: "+excNumberDefined+
				", excNumberExpected: "+excNumberExpected);		
	}
	public ExecuteProcedure(DBEnvironment dbEnvironment, String procName) {
		this(dbEnvironment,procName,false);
		System.out.println("ExecuteProcedure: ExecuteProcedure(DBEnvironment, String)");		
	}
	
	private class PositionComparator implements Comparator<DbParameterAccessor>{
		public int compare(DbParameterAccessor o1, DbParameterAccessor o2) {
			System.out.println("ExecuteProcedure$PositionComparator: compare()");
			return (int) Math.signum(o1.getPosition()-o2.getPosition());
		}
	}
	List<String> getSortedAccessorNames(DbParameterAccessor[] accessors){
		System.out.println("ExecuteProcedure: getSortedAccessorNames()");
		DbParameterAccessor[] newacc=new DbParameterAccessor[accessors.length];
		System.arraycopy(accessors, 0, newacc, 0,accessors.length);
		Arrays.sort(newacc,new PositionComparator());
		List<String> nameList=new ArrayList<String>();
		String lastName=null;
		for (DbParameterAccessor p:newacc){
			if (lastName!=p.getName()){
				lastName=p.getName();
				nameList.add(p.getName());
			}
		}
		return nameList;
	}
	private boolean containsReturnValue(DbParameterAccessor[] accessors){
		System.out.println("ExecuteProcedure: containsReturnValue()");
		for (DbParameterAccessor ac:accessors){
			if (ac.getDirection()==DbParameterAccessor.RETURN_VALUE) {
				System.out.println("ExecuteProcedure: containsReturnValue: ac.getName(): "+ac.getName());
				return true;
			}
		}
		return false;
	}
	public CallableStatement BuildCommand(String procName, DbParameterAccessor[] accessors) throws SQLException {
		
		System.out.println("ExecuteProcedure: BuildCommand: procName: "+procName);
		List<String> accessorNames=getSortedAccessorNames(accessors);
		boolean isFunction= containsReturnValue(accessors);
		
		System.out.println("ExecuteProcedure: BuildCommand: isFunction: "+isFunction);
		
		StringBuilder ins=new StringBuilder("{ ");
		if (isFunction){
			ins.append("? =");
		}		
		ins.append("call ").append(procName);
		String comma="(";
		boolean hasArguments=false;
		for (int i=(isFunction?1:0); i<accessorNames.size(); i++){
			ins.append(comma);
			ins.append("?");
			comma=",";
			hasArguments=true;
		}
		if (hasArguments) ins.append(")");
		ins.append("}");

		System.out.println("ExecuteProcedure: BuildCommand: constructed statement ins: "+ins.toString());
		
		CallableStatement cs=environment.getConnection().prepareCall(ins.toString());
		
		System.out.println("ExecuteProcedure: BuildCommand: cs.getClass().getName(): "+cs.getClass().getName());
		
		System.out.println("DbParameterAccessor: bindTo: cs instanceof CallableStatement?: "+(cs instanceof CallableStatement));
		System.out.println("DbParameterAccessor: bindTo: cs instanceof PreparedStatement?: "+(cs instanceof PreparedStatement));
		
		for (DbParameterAccessor ac:accessors){
			int realindex=accessorNames.indexOf(ac.getName());
			System.out.println("ExecuteProcedure: BuildCommand: binding: "+ac.getName()+" to: "+(realindex+1));
			ac.bindTo(this, cs, realindex+1); // jdbc params are 1-based
		}
		return cs;
	}
	
	private Parse headerRow;
	public void doTable(Parse table) {
		System.out.println("ExecuteProcedure: doTable()");
		this.headerRow=table.parts;
		super.doTable(table);
		try{
			statement.close();
		}
		catch (SQLException sqle){
			exception(headerRow,sqle);			
		}
	}
	public void doRows(Parse rows) {
		System.out.println("ExecuteProcedure: doRows()");
		// if table not defined as parameter, read from fixture argument; if still not defined, read from first row
        if ((procName==null || procName.trim().length()==0) && args.length > 0)
        {
            procName = args[0];
        }
     	if (rows!=null){
    		 executeStatementForEachRow(rows);
     	}
     	else{
     		executeUsingHeaderRow();
     	}
      }

	private void executeUsingHeaderRow() {
		System.out.println("ExecuteProcedure: executeUsingHeaderRow()");
		try{
		accessors = new DbParameterAccessor[0];
		statement= BuildCommand(procName, accessors);			
		    if (!exceptionExpected){
				statement.execute();
			}
			else {
				executeExpectingException(headerRow);//execute using header row
			}
		}
		catch (SQLException e){
			exception(headerRow,e);
			headerRow.parts.last().more=new Parse("td",e.getMessage(),null,null);
			e.printStackTrace();
		}
	}

	private void executeStatementForEachRow(Parse rows) {
		System.out.println("ExecuteProcedure: executeStatementForEachRow()");
		try {
			initParameters(rows.parts);//init parameters from the first row			
		    statement= BuildCommand(procName, accessors);
			Parse row = rows;
			while ((row = row.more) != null) {				
				runRow(row);
			}		        	
		 }
		catch (Throwable e){
			e.printStackTrace();
			exception(rows.parts,e);
		}
	}

	private void initParameters(Parse headerCells) throws SQLException {
		
		System.out.println("ExecuteProcedure: initParameters: procName: "+procName);
		
		Map<String, DbParameterAccessor> allParams=
			environment.getAllProcedureParameters(procName);
		if (allParams.isEmpty()) {
			throw new SQLException("Cannot retrieve list of parameters for "+procName + " - check spelling and access rights");
		}
		
		System.out.println("ExecuteProcedure: initParameters: getAllProcedureParameters returned "+allParams.size()+" parameters");
		System.out.println("ExecuteProcedure: initParameters: headerCells.size(): "+headerCells.size());
				
		accessors = new DbParameterAccessor[headerCells.size()];
		columnBindings=new Binding[headerCells.size()];
		
		for (int i = 0; headerCells != null; i++, headerCells = headerCells.more) {
			String name=headerCells.text();
			String paramName= NameNormaliser.normaliseName(name);
			
			System.out.println("ExecuteProcedure: initParameters: working on column index: "+i+", name: "+name+", paramName: "+paramName);
			
			accessors[i] = allParams.get(paramName);
			if (accessors[i]==null)
				throw new SQLException("Cannot find parameter for column "+i+" name=\""+paramName+"\"");
			
			boolean isOutput=headerCells.text().endsWith("?");
			System.out.println("ExecuteProcedure: isOutput: "+isOutput);

			System.out.println("ExecuteProcedure: initParameters: accessors[i].getDirection(): "+accessors[i].getDirection()); 
			
			if (accessors[i].getDirection()==DbParameterAccessor.INPUT_OUTPUT){
				System.out.println("ExecuteProcedure: initParameters: parameter "+i+" with name "+paramName+" is an INPUT_OUTPUT parameter");
				// clone, separate into input and output
				accessors[i]=new DbParameterAccessor(accessors[i]);
				accessors[i].setDirection(isOutput?DbParameterAccessor.OUTPUT:DbParameterAccessor.INPUT);
			}
			if (isOutput){
				System.out.println("ExecuteProcedure: initParameters: parameter "+i+" with name "+paramName+" is an OUTPUT parameter");
				columnBindings[i]=new SymbolAccessQueryBinding();
			}
			else{
	            // sql server quirk. if output parameter is used in an input column, then 
	            // the param should be cloned and remapped to IN/OUT
				if (accessors[i].getDirection()==DbParameterAccessor.OUTPUT){
					accessors[i]=new DbParameterAccessor(accessors[i]);
					accessors[i].setDirection(DbParameterAccessor.INPUT);
				}
				columnBindings[i]=new SymbolAccessSetBinding();
			}
        	columnBindings[i].adapter=accessors[i];
		}
		System.out.println("ExecuteProcedure: initParameters: returning");
	}
	
	private void runRow(Parse row)  throws Throwable {
		System.out.println("ExecuteProcedure: runRow()");
		System.out.println("ExecuteProcedure: runRow(): clearing parameters");
		//statement.clearParameters(); --- MM: COMMENTED OUT AS CAUSES TERADATA OUT PARAMS TO GET DE-REGISTERED.
		Parse cell = row.parts;
		//first set input params
		for(int column=0; column<accessors.length; column++,	cell = cell.more){
			System.out.println("ExecuteProcedure: runRow: checking param for type input: "+column);
			if (accessors[column].getDirection()==DbParameterAccessor.INPUT) {
				System.out.println("ExecuteProcedure: runRow: set input param: "+column+", cell.text(): "+cell.text());
				columnBindings[column].doCell(this, cell);
			}
		} 
		System.out.println("ExecuteProcedure: runRow: input params done");
		if (!exceptionExpected){
			System.out.println("ExecuteProcedure: runRow: exceptionExpected==false");
			System.out.println("ExecuteProcedure: runRow: statement.toString(): "+statement.toString());
			statement.execute();
			System.out.println("ExecuteProcedure: runRow: statement executed");
			cell = row.parts;
			//next evaluate output params
			for(int column=0; column<accessors.length; column++,	cell = cell.more){
				if (accessors[column].getDirection()==DbParameterAccessor.OUTPUT ||
						accessors[column].getDirection()==DbParameterAccessor.RETURN_VALUE
					) {
					columnBindings[column].doCell(this, cell);
				}
			}					
		}
		else {
			executeExpectingException(row);
		}
	}

	private void executeExpectingException(Parse row) {
		System.out.println("ExecuteProcedure: executeExpectingException");
		try{
			statement.execute();
			// no exception if we are here, mark whole row
			wrong(row);
		}
		catch (SQLException sqle){
			if (!excNumberDefined)
				right(row);
			else {
				int realError=environment.getExceptionCode(sqle);
				if (realError==excNumberExpected)
					right(row);
				else{
					wrong(row);
					row.parts.addToBody(fit.Fixture.gray(" got error code "+realError));
				}
			}
		}
	}
}
