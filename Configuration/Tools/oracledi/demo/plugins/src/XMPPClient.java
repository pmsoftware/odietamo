package oracle.odi.samples.opentools.xmppclient;

import oracle.odi.sdk.opentools.IOpenToolParameter;
import oracle.odi.sdk.opentools.OpenToolAbstract;
import oracle.odi.sdk.opentools.OpenToolExecutionException;
import oracle.odi.sdk.opentools.OpenToolParameter;

import org.jivesoftware.smack.XMPPConnection;

/**
 * Open Tool to send a message via the XMPP protocol.
 * Created on 3 nov. 06<br>
 * @author Sebastien Arod
 * 
 */
public class XMPPClient extends OpenToolAbstract
{

	private static final String SEP = " "; //$NON-NLS-1$
	private IOpenToolParameter[] mParameters;

	private static final String SERVER_CODE = "-SERVER"; //$NON-NLS-1$
	private static final String PORT_CODE = "-PORT"; //$NON-NLS-1$
	private static final String SERVICE_CODE = "-SERVICE"; //$NON-NLS-1$
	private static final String LOGIN_CODE = "-LOGIN"; //$NON-NLS-1$	
	private static final String PASSWORD_CODE = "-PASSWORD"; //$NON-NLS-1$
	private static final String RECIPIENT_CODE = "-RECIPIENT"; //$NON-NLS-1$

	private static final String MESSAGE_CODE = "-MESSAGE"; //$NON-NLS-1$

	public void execute() throws OpenToolExecutionException
	{

		XMPPConnection con;
		try
		{
			con = new XMPPConnection((String)getParameterValue(SERVER_CODE), Integer.valueOf((String)getParameterValue(PORT_CODE)).intValue(), (String)getParameterValue(SERVICE_CODE));
			con.login((String)getParameterValue(LOGIN_CODE), (String)getParameterValue(PASSWORD_CODE));
			con.createChat((String)getParameterValue(RECIPIENT_CODE)).sendMessage((String)getParameterValue(MESSAGE_CODE));
		}
		catch (Throwable e)
		{
			throw new OpenToolExecutionException(e);
		}

	}

	public String getDescription()
	{
		return "Send Message via XMPP (Jabber and GoogleTalk)"; //$NON-NLS-1$
	}

	public String getIcon(int pArg0)
	{
		return "/oracle/odi/samples/opentools/xmppclient/32.gif"; //$NON-NLS-1$
	}

	public IOpenToolParameter[] getParameters()
	{
		if (mParameters == null)
		{
			mParameters = new IOpenToolParameter[] {
					new OpenToolParameter(SERVER_CODE, "Server", "XMMP Server (e.g. \"talk.google.com\" for GTalk)", true), //$NON-NLS-1$ //$NON-NLS-2$
					new OpenToolParameter(PORT_CODE, "Port", "XMMP Server Port number (e.g. 5222 for GTalk)", true), //$NON-NLS-1$ //$NON-NLS-2$
					new OpenToolParameter(SERVICE_CODE, "Service", "XMMP Service (e.g. \"gmail.com\" for GTalk)", true), //$NON-NLS-1$ //$NON-NLS-2$					
					new OpenToolParameter(LOGIN_CODE, "Login", "XMMP Login", true), //$NON-NLS-1$ //$NON-NLS-2$ 
					new OpenToolParameter(PASSWORD_CODE, "Password", "XMMP Password", true), //$NON-NLS-1$ //$NON-NLS-2$ 
					new OpenToolParameter(RECIPIENT_CODE, "Recipient", "XMMP recipient user", true), //$NON-NLS-1$ //$NON-NLS-2$
					new OpenToolParameter(MESSAGE_CODE, "Message", "Message to send to participant", true) //$NON-NLS-1$ //$NON-NLS-2$ 
			};
		}
		return mParameters;

	}

	public String getProvider()
	{
		return ""; //$NON-NLS-1$
	}

	public String getSyntax()
	{
		return defaultSyntax();
	}

	private String defaultSyntax()
	{
		String toolName = getClass().getName();
		StringBuffer buff = new StringBuffer();
		buff.append(toolName.substring(toolName.lastIndexOf('.') + 1));
				

		IOpenToolParameter[] params = getParameters();
		for (int i = 0 ; i < params.length ; i++)
		{
			buff.append(SEP);
			IOpenToolParameter parameter = params[i];
			// buff.append("-"); //$NON-NLS-1$
			buff.append(parameter.getCode());
			buff.append("="); //$NON-NLS-1$
			buff.append(parameter.getCode().substring(1).toLowerCase());
		}
		return buff.toString();
	}

	public String getVersion()
	{
		return "1.0"; //$NON-NLS-1$
	}

}
