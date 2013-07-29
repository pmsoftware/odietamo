package odietamo.OdiScm;



public class CreateRepositoryTest {

	private static final String modName = "OdiScm";
	private static final String procName = modName + ": CreateRepositoryTest";
	private static final String infoMsg = modName + ": INFO: ";
	private static final String errMsg = modName + ": ERROR: ";
	private static final String warnMsg = modName + ": WARNING: ";
	
	public static void main(String[] args) {
		
		String[] TestArgs = {"SUPERVISOR","SUNOPSIS","jdbc:oracle:thin:@localhost:1521:xe","oracle.jdbc.driver.OracleDriver","odirepofordemo","odirepofordemo","1","WORKREP","system","xe"};
		CreateRepository.main(TestArgs);
	}
}
