package dbfit.fixture;
import fit.*;

import java.sql.*;
import java.util.*;

import dbfit.util.*;


public abstract class RowSetFixture extends ColumnFixture {
    
	private DataTable dt;
	//private ResultSetMetaData rsmd;
	private DataRow currentRow;
	
	private class CurrentDataRowTypeAdapter extends DbTypeAdapter {
	    public String key;
	    public CurrentDataRowTypeAdapter(String key, Class type) throws NoSuchMethodException {
	    	System.out.println("RowSetFixture$CurrentDataRowTypeAdapter: CurrentDataRowTypeAdapter()");
	        target = null;
	        method = CurrentDataRowTypeAdapter.class.getMethod("get", new Class[] {});
	        fixture = RowSetFixture.this;
	        this.type = type;
	        this.key = key;
	        System.out.println("RowSetFixture$CurrentDataRowTypeAdapter: CurrentDataRowTypeAdapter: returning");
	    }
	    public Object get() {
	           return currentRow.get(key);
	    }
	    public Object invoke() throws IllegalAccessException {
	        return get();
	    }
	}	
	private int findColumn(String name) throws Exception{
		//todo: implement non-key
		String normalisedName=NameNormaliser.normaliseName(name);
		System.out.println("RowSetFixture: findColumn: name: "+name);
		System.out.println("RowSetFixture: findColumn: normalisedName: "+normalisedName);
		for (int i=0; i<dt.getColumns().size(); i++){
			String colName=dt.getColumns().get(i).getName();
			System.out.println("RowSetFixture: findColumn: colName: "+colName);
			if (normalisedName.equals(NameNormaliser.normaliseName(colName)))
				return i;
		}
		throw new Exception("Unknown column "+normalisedName);
	}
	// if element not 0, fixture column -> result set column index
	private String[] keyColumns;
	
	protected void bind(Parse heads) {
		try {
			System.out.println("RowSetFixture: bind: heads.size(): "+heads.size());
		    columnBindings = new Binding[heads.size()];
		    keyColumns=new String[heads.size()];
		     for (int i = 0; heads != null; i++, heads = heads.more) {
	              String name=heads.text();
	              System.out.println("RowSetFixture: bind: heads.text(): "+heads.text());
	              columnBindings[i] = new SymbolAccessQueryBinding();
	              int idx=findColumn(name);
	              System.out.println("RowSetFixture: bind: idx: "+idx);
	              String columnName=dt.getColumns().get(idx).getName();
	              System.out.println("RowSetFixture: bind: columnName: "+columnName);
	              if (! name.endsWith("?"))
	            	  keyColumns[i]=columnName;
	               columnBindings[i].adapter = new CurrentDataRowTypeAdapter(
	                				columnName,
	                				getJavaClassForColumn(dt.getColumns().get(idx))
	                			);	          
	         }
		}
		catch (Exception sqle){
			System.out.println("RowSetFixture: Caught Exception");
			exception(heads,sqle);
		}
	}
	protected abstract DataTable getDataTable() throws SQLException;
	protected abstract boolean isOrdered();
	public void doRows(Parse rows)
	{
		try{
			dt=getDataTable();
			super.doRows(rows);
			addSurplusRows(rows.last());
		}
		catch (SQLException sqle){
			sqle.printStackTrace();
			exception(rows,sqle);
		}
	}
	public void doRow(Parse row) {
		try{
			if (isOrdered()) 
				currentRow=dt.findFirstUnprocessedRow();
			else
				currentRow=findMatchingRow(row);
		super.doRow(row);
		currentRow.markProcessed();
		}
		catch (NoMatchingRowFoundException e){
			row.parts.addToBody(Fixture.gray(" missing"));
			wrong(row);
		}
	}

	public DataRow findMatchingRow(Parse row) throws NoMatchingRowFoundException{
		System.out.println("RowSetFixture: findMatchingRow()");
		Parse columns=row.parts;
		Map<String,Object> keyMap=new HashMap<String,Object>();
		for (int i=0; i<keyColumns.length; i++, columns=columns.more){
			if (keyColumns[i]!=null)
			{ // bupa adds
				System.out.println("RowSetFixture: findMatchingRow: columns.text(): "+columns.text());
				try  {
					Object value=columnBindings[i].adapter.parse(columns.text());
					keyMap.put(keyColumns[i], value);
				}
				catch (Exception e){
					exception(columns,e);
				}
			} // start bupa adds
			else {
				System.out.println("RowSetFixture: findMatchingRow: keyColumns[i]== null");
			} // end bupa adds
		}
		return dt.findMatching(keyMap);
	}
	private void addSurplusRows(Parse rows){
		Parse lastRow=rows;
		for (DataRow dr: dt.getUnprocessedRows()){
			Parse newRow=new Parse("tr",null,null,null);
			lastRow.more=newRow;
			lastRow=newRow;
			try{
				currentRow=dr; // for getting
				Parse firstCell=new Parse("td",
						String.valueOf(columnBindings[0].adapter.invoke()),null,null);
				newRow.parts=firstCell;
				firstCell.addToBody(Fixture.gray(" surplus"));
				wrong(firstCell);				
				for (int i=1; i<columnBindings.length; i++){
					Parse nextCell=new Parse("td",
							String.valueOf(columnBindings[i].adapter.invoke()),null,null);
					firstCell.more=nextCell;
					firstCell=nextCell;
				}
			}
			catch (Exception e){
				exception(newRow, e);
			}
		}
	}
	protected Class getJavaClassForColumn(DataColumn col) throws ClassNotFoundException, SQLException{
		return Class.forName(col.getJavaClassName());
	}
}
