/**
  *
 * This is a sample enabling direct queries to the Sunopsis JDBC driver
 * It is a mini querying tool enabling SQL queries to a JDBC file. 
 * Usage:
 *  java -classpath .;../../snpsxmlo.zip;../../xerces.jar XmlPlus <XML Driver JDBC URL>
 * Exemple:
 *  java -classpath .;../../snpsxmlo.zip;../../xerces.jar XmlPlus jdbc:snps:xml?f=../xml/employee.xml&re=EMPLOYEE
 *
 * Note: This program is a prototype and contains many errors and untrapped
 *       exception.
 */

import java.io.*;
import java.sql.*;

public class XmlPlus
{
	private Connection XmlJdbcConnection = null;
	
	private XmlPlus (String connectionURL)
	{
		try 
		{
			// Loads and registers the driver class
			System.out.println("Starting XML Plus");
			Class.forName("com.sunopsis.jdbc.driver.xml.SnpsXmlDriver");
					
			// Test that the URL is valid
			if (connectionURL.equals(""))
			{
				System.out.println(">> No valid URL Specified, not connected");
			}
			else
			{
				// Opens a JDBC connection to given URL
				connect(connectionURL);
			}
		}
		catch (Exception e)
		{
			System.out.println(">> Error While Starting XML Plus !");
			e.printStackTrace();
			System.exit(1);
		}
	}

	private void disconnect()
	{
		if (XmlJdbcConnection != null)
		{
			try
			{
				XmlJdbcConnection.close();
				XmlJdbcConnection = null;
			}
			catch (Exception e)
			{
				System.out.println(">> Disconnection Failed");
				e.printStackTrace();
			}
		}
	}

	private void connect(String connectionURL)
	{
		System.out.println("Connecting to URL: " + connectionURL);
		try 
		{
			XmlJdbcConnection = DriverManager.getConnection(connectionURL);
			System.out.println("Connected.\nType 'help' for the list of commands");
		}
		catch (Exception e)
		{
			System.out.println(">> Connection Failed");
			e.printStackTrace();
		}	
	}

	private void otherQuery(String query)
	{
		try
		{
			Statement s = XmlJdbcConnection.createStatement();
			s.execute(query);
			System.out.println("Done");
			s.close();
		}
		catch (Exception e)
		{
			System.out.println(">> Query Failed");
			e.printStackTrace();	
		}	
	}

	private void selectQuery(String query)
	{
		try 
		{
			Statement s = XmlJdbcConnection.createStatement();
			ResultSet rs = s.executeQuery(query);
			displayResultSet(rs);
			rs.close();
			s.close();
		}
		catch (Exception e)
		{
			System.out.println(">> Query Failed");
			e.printStackTrace();
		}	
	}

	private void displayResultSet(ResultSet rs)
	{
		try
		{
			int i;
			for (i = 1 ; i <= rs.getMetaData().getColumnCount() ; i++)
			{
				System.out.print(rs.getMetaData().getColumnLabel(i));
				if (i < rs.getMetaData().getColumnCount())
					System.out.print(";"); 
			}
			System.out.print("\n");
			while (rs.next())
			{
				for (i = 1 ; i <= rs.getMetaData().getColumnCount() ; i++)
				{
					System.out.print(rs.getString(rs.getMetaData().getColumnName(i)));
					if (i < rs.getMetaData().getColumnCount())
						System.out.print(";");
				}
				System.out.print("\n");
			}
		}
		catch (Exception e)
		{
			System.out.println(">> Error while Displaying Record Set!");
			e.printStackTrace();
		}
	}

	private void metadataQuery()
	{
		try
		{
			ResultSet tableRs = XmlJdbcConnection.getMetaData().getTables("","%","%",null);
			while (tableRs.next())
			{
				System.out.println("\nTable Name:" + tableRs.getString("TABLE_NAME") + "\n**********");
				ResultSet colRs = XmlJdbcConnection.getMetaData().getColumns("", "%", tableRs.getString("TABLE_NAME"), "%");
				displayResultSet(colRs);
				colRs.close();
			}
			tableRs.close();
		}
		catch (Exception e)
		{
			System.out.println(">> MetaData Query Failed");
			e.printStackTrace();
		}	
	}

	private void parseCommand(String s) 
	{
		if (s.equalsIgnoreCase(""))
		{
			// no order
		}
		else if (s.equalsIgnoreCase("exit") || s.equalsIgnoreCase("quit") || s.equalsIgnoreCase("bye") || s.equalsIgnoreCase("q"))
		{
			disconnect();
			System.exit(0);
		}
		else if (s.equalsIgnoreCase("help") || s.equalsIgnoreCase("h"))
		{
			showhelp();
		}		
		else if (s.toLowerCase().startsWith("connect"))
		{
			if (s.length() > 8)
			{
				connect(s.substring(8));
			}
			else
			{
				System.out.println("Invalid URL");
			}
		}
		else
		// For all other orders, check that we are connected
		{
			if (XmlJdbcConnection == null)
				System.out.println("Not connected!");
			else
			{
				if (s.equalsIgnoreCase("desc"))
				{
					metadataQuery();
				}		
				else if (s.equalsIgnoreCase("disconnect"))
				{
					disconnect();
				}			
				else if (s.toLowerCase().startsWith("select"))
				{
					selectQuery(s);
				}	
				else
				{
					otherQuery(s);	
				}
			}
		}
	}

	/**
	 * Method showhelp.
	 */
	private void showhelp() 
	{
		System.out.println("Available commands\n******************");		
		System.out.println("DESC              :\t returns the detailed description of all tables.");
		System.out.println("CONNECT <url>     :\t connects to the JDBC URL that is valid for the XML driver.");
		System.out.println("DISCONNECT        :\t disconnects the current connection.");
		System.out.println("EXIT, QUIT or BYE :\t ends the session.");
		System.out.println("SELECT, INSERT, ... all standard SQL commands are also allowed.\n");
	}
	
	public static void main(String[] args) 
	{
		try 
		{
			XmlPlus sess = new XmlPlus(args.length == 0 ? "" : args[0]);
			BufferedReader commandline= new java.io.BufferedReader (new InputStreamReader(System.in));
			
			// loop until 'exit' is met
			while (true)
			{
				System.out.print("> ");
				String s = commandline.readLine();
				sess.parseCommand(s);
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			System.exit(1);
		}
	}
}
