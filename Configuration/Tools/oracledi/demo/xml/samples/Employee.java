/**
  *
 * This is a sample testing the use of Sunopsis JDBC driver
 * It displays the content of an XML file and updates a value in the file.
 * Usage:
 *  java -classpath .;../../snpsxmlo.zip;../../xerces.jar Employee
 */

import java.sql.*;

public class Employee
{
	public static void main(String[] args)
	{
		try 
		{
			// Loads and registers the driver class
			System.out.println("* Registering Driver class");
			Class.forName("com.sunopsis.jdbc.driver.xml.SnpsXmlDriver");
		
			// Creates the URL to connect the employee.xml sample file
			String url = "jdbc:snps:xml?f=../xml/employee.xml";
		
			// Opens a JDBC connection to given URL
			System.out.println("* Connecting to the employee.xml file");
			Connection conn = DriverManager.getConnection(url);
		
			// Gets the Driver Version
			System.out.println("* Driver Version is " + conn.getMetaData().getDriverVersion());
		
			// Creates the statement for the SQL commands
			Statement s = conn.createStatement();
		
			// Launches a SYNCHRONIZE operation to load the xml file in the default schema in memory.
			// This command is not necessary in this case, as the xml file has already been loaded at connection time. 
			System.out.println("* Synchronizing the File with Schema");
			s.execute("SYNCHRONIZE FROM FILE");

			// Queries the schema for the data corresponding to the <person id ="xxx" salary="yyy"> XML tag content.
			System.out.println("* Executing Query");
			ResultSet EmployeeList = s.executeQuery("SELECT id, salary FROM person");
		
			// displays the list of employees along with their wages.
			// some of them have a null wage value, as this data do not exist in the XML file.
			System.out.println("\nEmployee List\n*************");
			while (EmployeeList.next())
			{
				System.out.println(EmployeeList.getString("id") + " has a salary of $" + EmployeeList.getString("salary"));
			}
				
			// Performs two update operation on the schema
			// - If a salary is Null, we set it at the value '0'
			// - We increase the salary by 100
			System.out.println("\n* Increasing all wages by $100");
			s.execute("UPDATE person SET salary = '0' WHERE salary IS NULL");
			s.execute("UPDATE person SET salary = CAST(salary AS NUMERIC) + 100");
		
			// Synchronize Schema & File Data
			System.out.println("* Synchronizing data back to file");
			s.execute("SYNCHRONIZE ALL");

			// Closing the Connection
			s.close();
			System.out.println("* Closing Connection. You may now restart to see the changes.");
			conn.close();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			System.exit(1);
		}
		System.exit(0);	
	}
}