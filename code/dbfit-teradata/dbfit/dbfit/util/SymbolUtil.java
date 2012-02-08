package dbfit.util;
/** ugly workaround for fit change in release 200807, which internally converts NULL into a string value "null";
 * for db access, we need to make a difference between NULL and "null" so this class provides a centralised
 * place for the change; for dbfit fixtures use this class to access symbols rather than directly fit.fixture
 */
public class SymbolUtil {
	private static final Object dbNull=new Object();
	public static void setSymbol(String name, Object value){		
		fit.Fixture.setSymbol(name, value==null?dbNull:value);
	}
	public static Object getSymbol(String name){
		System.out.println("SymbolUtil: getSymbol: name: "+name);
		Object value=fit.Fixture.getSymbol(name);
		System.out.println("SymbolUtil: getSymbol: value.getClass().getName(): "+value.getClass().getName());
		if (value==dbNull){
			System.out.println("SymbolUtil.getSymbol: value==dbNull, returning dbNull object");
			return null;
		}
		return value;
	}
	public static void clearSymbols(){
		fit.Fixture.ClearSymbols();
	}
}
