package dbfit.util;
import java.math.BigDecimal;

public class BigDecimalParseDelegate {
		public static Object parse(String s) {
			System.out.println("BigDecimalParseDelegate: parse: s: "+s);
			return new BigDecimal(s);
		};
}
