package dbfit.util;

public class Options{
	public static void reset(){
		fixedLengthStringParsing=false;
		bindSymbols=true;
	}
	private static boolean fixedLengthStringParsing=false;
	private static boolean bindSymbols=true;
	public static boolean isFixedLengthStringParsing(){
		return fixedLengthStringParsing;
	}
	public static boolean isBindSymbols(){
		return bindSymbols;
	}
	public static void setOption(String name, String value){
		String normalname=NameNormaliser.normaliseName(name);
		if ("fixedlengthstringparsing".equals(normalname)){
			fixedLengthStringParsing=Boolean.parseBoolean(value);
		}
		else if ("bindsymbols".equals(normalname)){
			bindSymbols=Boolean.parseBoolean(value);
		}
		else throw new IllegalArgumentException("Unsupported option"+normalname);
	}
	
}