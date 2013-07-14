package odietamo.OdiScm;

import oracle.odi.publicapi.samples.SimpleOdiInstanceHandle;
import oracle.odi.setup.AuthenticationConfiguration;
import oracle.odi.setup.IMasterRepositorySetup;
import oracle.odi.setup.IWorkRepositorySetup;
import oracle.odi.setup.RepositorySetupException;
import oracle.odi.setup.TechnologyName;
import oracle.odi.setup.support.MasterRepositorySetupImpl;
import oracle.odi.setup.support.WorkRepositorySetupImpl;
import oracle.odi.core.security.PasswordStorageConfiguration;
import oracle.odi.core.repository.WorkRepository.WorkType;
import oracle.odi.setup.JdbcProperties;

public class CreateRepository {

	private static String procName = "OdiScm";
	private static String infoMsg = procName + ": INFO: ";
	private static String errMsg = procName + ": ERROR: ";
	//private String warnMsg = procName + ": WARNING: ";
		
	public static void main(String[] args)
	{
		/*
		 * Arg  0: Supervisor User name.
		 *      1: Supervisor Password.
		 *      2: URL for both master and work repositories.
		 *      3: JDBC driver (class) for both master and work repositories.
		 *      4: DB user name for both master and work repositories.
		 *      5: DB password for both master and work repositories.
		 *      6: Internal ID to use for both master and work repositories.
		 *      7: Work repository name.
		 *      8: Oracle DBA user name.
		 *      9: Oracle DBA password.
		 */
		if (args.length != 10) {
			System.err.println(errMsg + "invalid arguments");
			System.out.println(infoMsg + "usage: CreateRepository <Supervisor User Name> <Supervisor User Password> <Master/Work DB URL> <Master/Work JDBC driver> <Master/Work DB User Name> <Master/Work DB User Name> <Master/Work Internal ID> <Work Repositroy Name> <Oracle DBA User Name> <Oracle DBA Password>");
			System.exit(1);
		}
		
		//String odiSupervisorUser = "SUPERVISOR"; //$NON-NLS-1$
		String odiSupervisorUser = args[0].replace("\"", "");
		
		//String odiSupervisorPassword = "SUNOPSIS"; //$NON-NLS-1$
		String odiSupervisorPassword = args[1].replace("\"", "");
		
		//String masterRepositoryJdbcUrl = "jdbc:oracle:thin:@localhost:1521:xe"; //$NON-NLS-1$
		String RepositoryJdbcUrl = args[2].replace("\"", "");
		
		//String masterRepositoryJdbcDriver = "oracle.jdbc.OracleDriver"; //$NON-NLS-1$
		String RepositoryJdbcDriver = args[3].replace("\"", "");
		
		//String masterRepositoryJdbcUser = "NEWODIMASTER"; //$NON-NLS-1$
		String RepositoryJdbcUserName = args[4].replace("\"", "");
		                                       
		//String masterRepositoryJdbcPassword = "NEWODIMASTER";//$NON-NLS-1$
		String RepositoryJdbcPassword = args[5].replace("\"", "");

		TechnologyName RepositoryTechnology = TechnologyName.ORACLE;
		
		int RepositoryId = 0;
		
		try {
			RepositoryId = (new Integer(args[6].replace("\"",""))).intValue();
		}
		catch (Exception e) {
			System.err.println(errMsg + "invalid repository ID specified");
			System.err.println(errMsg + "repository ID must be an integer value");
		}

		String workRepositoryName = args[7].replace("\"", "");
		String DbaUserName = args[8].replace("\"", "");
		String DbaPassword = args[9].replace("\"", "");
		
		PasswordStorageConfiguration psc = new PasswordStorageConfiguration.InternalPasswordStorageConfiguration();
		AuthenticationConfiguration authConf = AuthenticationConfiguration.createStandaloneAuthenticationConfiguration(odiSupervisorPassword.toCharArray());
		
		//TechnologyName workRepositoryTechnology = TechnologyName.ORACLE;
		//String workRepositoryJdbcUrl = "jdbc:oracle:thin:@localhost:1521:xe"; //$NON-NLS-1$
		//String workRepositoryJdbcDriver = "oracle.jdbc.OracleDriver"; //$NON-NLS-1$

		//String workRepositoryJdbcUsername = "NEWODIWORK"; //$NON-NLS-1$
		//String workRepositoryJdbcPassword = "NEWODIWORK"; //$NON-NLS-1$

		String workRepositoryPassword = "";
          
		//int workRepositoryId = 678;
		
		int ExitStatus = 0;
		
		try {
			// Create Master Repository.
			IMasterRepositorySetup masterRepositorySetup = new MasterRepositorySetupImpl();
	            
			JdbcProperties mrjp = new JdbcProperties(RepositoryJdbcUrl, RepositoryJdbcDriver, RepositoryJdbcUserName, RepositoryJdbcPassword.toCharArray());
			
			System.out.println(infoMsg + "about to start master repository creation");
			if (masterRepositorySetup.createMasterRepository(mrjp, DbaUserName, DbaPassword.toCharArray(), RepositoryId, RepositoryTechnology, false, authConf, psc)) {
				System.out.println(infoMsg + "master repository creation succeeded");
			}
			else {
				System.err.println(errMsg + "master repository creation failed");
				throw new RepositorySetupException("createMasterRepository returned false", new Throwable());
				//System.exit(1);
			}

			SimpleOdiInstanceHandle handle = SimpleOdiInstanceHandle.create(RepositoryJdbcUrl, RepositoryJdbcDriver, RepositoryJdbcUserName, RepositoryJdbcPassword, odiSupervisorUser, odiSupervisorPassword);

			try {
				// Create Work Repository.
				IWorkRepositorySetup workRepositorySetup = new WorkRepositorySetupImpl(handle.getOdiInstance());
				
				WorkType wt = WorkType.DESIGN;
				JdbcProperties wrjp = new JdbcProperties(RepositoryJdbcUrl, RepositoryJdbcDriver, RepositoryJdbcUserName, RepositoryJdbcPassword.toCharArray());
				
				System.out.println(infoMsg + "about to start work repository creation");
				if (workRepositorySetup.createWorkRepository(wt, wrjp, RepositoryId, workRepositoryName, RepositoryTechnology, false, workRepositoryPassword.toCharArray())) {
					System.out.println(errMsg + "work repository creation succeeded");
				}
				else {
					System.err.println(errMsg + "work repository creation failed");
					throw new RepositorySetupException("createMasterRepository returned false", new Throwable());
					//ExitStatus = 1;
				}
			}
	        catch (RepositorySetupException e) {
	        	System.err.println(errMsg + "work repository creation failed");
	        	throw new RepositorySetupException("createMasterRepository returned false", new Throwable());
	        	//ExitStatus = 1;
	        }
			finally {
				handle.release();
			}
		}
        catch (RepositorySetupException e) {
            e.printStackTrace();
            ExitStatus = 1;
        }
        System.exit(ExitStatus);
	}
}
