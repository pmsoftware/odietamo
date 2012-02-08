package dbfit.util;

import java.util.*;
public class TypeNormaliserFactory {
	private static Map<Class,TypeNormaliser> normalisers= new HashMap<Class,TypeNormaliser>();
	public static void setNormaliser(Class targetClass,TypeNormaliser normaliser){
		normalisers.put(targetClass, normaliser);
	}
	public static TypeNormaliser getNormaliser(Class targetClass){
		return normalisers.get(targetClass);
	}
}
