package com.myCompany.sunopsisOpenTools;

import javax.swing.JOptionPane; /* Needed for the message box used in this example */

import com.sunopsis.sdk.opentools.ISnpsOpenTool; 					/* All Open Tool classes need these three classes  */
import com.sunopsis.sdk.opentools.ISnpsOpenToolParameter;				
import com.sunopsis.sdk.opentools.SnpsOpenToolExecutionException;    
import com.sunopsis.sdk.opentools.SnpsOpenToolAbstract;				/* The abstract class we extend for the Open Tool */
import com.sunopsis.sdk.opentools.SnpsOpenToolParameter;			/* The class we use for parameters */
/**
 * This is a simple example of an Open Tool, defining two parameters ("-TEXT" and "-TITLE") and displaying 
 * with a title and a text.
 */
public class SimpleMessageBox extends SnpsOpenToolAbstract {

	/**
	 *  Define the two parameters in a local field. This field will be passed by getParameters() to define the syntax
	 *  for the tool. 
	 */
    private static final ISnpsOpenToolParameter[] mParameters = new ISnpsOpenToolParameter[]
    {
        new SnpsOpenToolParameter("-TEXT", "Message text", "Text to show in the messagebox (Mandatory).", true),
        new SnpsOpenToolParameter("-TITLE", "Messagebox title", "Title of the messagebox.", false)
    };

	/**
	 *  Constructor for class 
	 */
    public SimpleMessageBox()
    {
        super(); 

    }

    /**
     * Executes the tool, causing the message to be displayed.
     */
    public void execute() throws SnpsOpenToolExecutionException
    {
        try
        {
        	if (getParameterValue("-TITLE") == null || getParameterValue("-TITLE").equals("")) /* title was not filled in by user */
        	{
	            JOptionPane.showMessageDialog(null, (String) getParameterValue("-TEXT"), (String) "Message", JOptionPane.INFORMATION_MESSAGE);
	        } else 
	        {
	            JOptionPane.showMessageDialog(null, (String) getParameterValue("-TEXT"), (String) getParameterValue("-TITLE"), JOptionPane.INFORMATION_MESSAGE);
            }
        }
        /* Traps any exception and throw them as SnpsOpenToolExecutionException */
        catch (IllegalArgumentException e)
        {
            throw new SnpsOpenToolExecutionException(e);
        }
    }


    /**
     * Syntax for the tool, as displayed in the Sunopsis Package window. 
     * @return A string containing the tool syntax.
     */
    public String getSyntax()
    {
        return "SimpleMessageBox \"-TEXT=<text message>\"  \"-TITLE=<window title>\"";
    }

    /**
     * Description of the Open Tool. This description is displayed when adding the Open Tool. 
     * @Returns A string containing the description.
     */
    public String getDescription()
    {
        return "This Sunopsis Open Tool displays a message box when executed.";
    }

    /**
     * Path to the 16x16 or 32x32 icon files depending on the pIconType requested.
     * @return A string containing path to the image file.
     */
    public String getIcon(int pIconType)
    {
        switch (pIconType)
        {
            case ISnpsOpenTool.SMALL_ICON: 
            	return "/com/myCompany/sunopsisOpenTools/images/SimpleMessageBox_16.gif";
            case ISnpsOpenTool.BIG_ICON: 
            	return "/com/myCompany/sunopsisOpenTools/images/SimpleMessageBox_32.gif";
            default:
            	return "";
        }
    }

    /**
     * Current version of this SimpleMessageBox Open Tool.
     * @return A string containing the current version.
     */
    public String getVersion()
    {
        return "v1.0";
    }

    /**
     * Name of the provider of this Open Tool.    
     * @return A string containing 'My Company, Inc.'
     */
    public String getProvider()
    {
        return "My Company, Inc.";
    }

    /**
     * Returns an array containing the parameters of this Open Tool.
     * @return An array of two ISnpsOpenToolParameter objects.
     */
    public ISnpsOpenToolParameter[] getParameters()
    {
        return mParameters;
    }
}
