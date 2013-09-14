package odietamo.OdiScm;

import fit.*;

import java.io.*;
import java.util.*;

/**
 * LineGatherer is a Runnable that eats lines from a BufferedReader
 * and jams them into a queue.  It continues to read until the BufferedReader
 * returns EOF or error.
 */
class LineGatherer implements Runnable {
	
  private LinkedList lines;
  private BufferedReader reader;
  private boolean done = false;

  public LineGatherer(BufferedReader reader) {
    this.lines = new LinkedList();
    this.reader = reader;
  }

  public void run() {
    try {
      String line;
      while ((line = reader.readLine()) != null) {
        lines.addLast(line);
      }
    } catch (IOException e) {
      lines.addLast("Exception:" + e.getMessage() + "\n");
    }
    done = true;
  }

  /**
   * readLine reads a line from the queue.  It will wait about a second for
   * a line to show up, otherwise it returns null.
   */
  public String readLine() throws Exception {
    for (int i = 0; i < 10 && lines.isEmpty() && !done; i++)
      Thread.sleep(100);
    if (lines.isEmpty())
      return null;
    else {
      String line =  (String) lines.removeFirst();
      return line;
    }
  }

  public String[] getLines() {
    return (String[]) lines.toArray(new String[0]);
  }
}

/**
 * A FIT test fixture that provides shell-like behaviour to a FIT table.
 * It allows you to run commands, and compare the exit status to an expected value.
 *
 * The table rows are executed in order, from top to bottom.
 *
 * @author Mark Matten (based upon CommandLineFixture by Robert C. Martin).
 */

public class OsCommandLineFixture extends ActionFixture {
  /**
   * CommandProcess is record of the interesting variables that describe
   * a running process.
   */
  class CommandProcess {
    public LineGatherer stdoutGatherer;
    public LineGatherer stderrGatherer;
    public Parse commandCell;
    public Parse resultCell;
    public int ExpectedExitStatus;
    public int ExitStatus;
    public boolean ExitStatusSpecValid;
    public Process process;
  }

  private HashMap commandProcessMap = new HashMap();

  private int CommandId = 0;
  
  /**
   * Private function -- ignore.
   */
  public void doTable(Parse table) {
	//System.out.println("OdiCommandLineFixture: doTable: starts");
    startTable();
    super.doTable(table);
    endTable();
	//System.out.println("OdiCommandLineFixture: doTable: ends");    
  }

  private void startTable() {
		//System.out.println("OdiCommandLineFixture: startTable: starts/ends");
  }

  private void endTable() {
	//System.out.println("OdiCommandLineFixture: endTable: starts");
    Set CommandIds = commandProcessMap.keySet();
    for (Iterator iterator = CommandIds.iterator(); iterator.hasNext();) {
      Integer CommandId = (Integer) iterator.next();
      //System.out.println("OdiCommandLineFixture: endTable: processing interator == " + CommandId);
      CommandProcess p = getCommandProcess(CommandId);
      flushProcess(p);
      if (p.ExitStatusSpecValid) {
    	  //System.out.println("OdiCommandLineFixture: endTable: exit status spec is valid");
    	  //System.out.println("OdiCommandLineFixture: endTable: expected exit status == " + p.ExpectedExitStatus);
    	  //System.out.println("OdiCommandLineFixture: endTable: actual exit status == " + p.ExitStatus);
    	  if (p.ExitStatus == p.ExpectedExitStatus) {
    		  right(p.resultCell);
    	  }
    	  else {
    		  wrong(p.resultCell);
    	  }
      }
      else {
    	  //System.out.println("OdiCommandLineFixture: endTable: exit status spec is NOT valid");
    	  wrong(p.resultCell);
      }
    }
	//System.out.println("OdiCommandLineFixture: endTable: ends");
  }

  private void flushProcess(CommandProcess p) {
	//System.out.println("OdiCommandLineFixture: flushProcess: starts");
    //p.commandCell.at(0).addToBody("</pre>");
	p.commandCell.addToBody("</pre>");
	p.commandCell.addToBody("[stdout:]");
    flush(p.stdoutGatherer, p.commandCell);
    p.commandCell.addToBody("[stderr:]");
    flush(p.stderrGatherer, p.commandCell);    
    try {
      int status = p.process.exitValue();
      //p.commandCell.addToBody("<hr/>" + label("terminated with exit value " + status));
      p.resultCell.addToBody("<hr/>" + label("terminated with exit value " + status));
      p.ExitStatus = status;
    } catch (Exception e) {
      terminateProcess(p);
      //p.commandCell.addToBody("<hr/>" + label("forcibly terminated"));
      p.resultCell.addToBody("<hr/>" + label("forcibly terminated"));
    }
    try {
    	// Close the output and error streams.
		p.process.getInputStream().close();
		p.process.getErrorStream().close();
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}   
    //System.out.println("OdiCommandLineFixture: flushProcess: ends");
  }

  private void terminateProcess(CommandProcess p) {
	//System.out.println("OdiCommandLineFixture: terminateProcess: starts");
    p.process.destroy();
    try {
      p.process.waitFor();
    } catch (InterruptedException e1) {
    }
    //System.out.println("OdiCommandLineFixture: terminateProcess: ends");
  }

  private CommandProcess doSpawn(Parse commandCell, Parse resultCell) throws IOException {
	//System.out.println("OdiCommandLineFixture: doSpawn: starts");
    String command = commandCell.text();

    CommandProcess p = new CommandProcess();
    p.process = execute(command);
    p.stdoutGatherer = makeGatherer(p.process.getInputStream());
    p.stderrGatherer = makeGatherer(p.process.getErrorStream());
    p.commandCell = cells.at(1);
    p.resultCell = cells.at(2);
    
    p.ExitStatusSpecValid = true;
    try {
    	Integer.parseInt(p.resultCell.text());
    }
    catch (NumberFormatException nfe) {
    	p.resultCell.addToBody("Invalid integer specified for expected exit status");
    	p.ExitStatusSpecValid = false;
    }

    if (p.ExitStatusSpecValid) {
    	p.ExpectedExitStatus = Integer.parseInt(p.resultCell.text());
    }

    Integer CmdId = CommandId++;
    //System.out.println("OdiCommandLineFixture: doSpawn: Creating command entry with id of " + CmdId);
    //System.out.println("OdiCommandLineFixture: doSpawn: Creating command entry with command of " + p.commandCell.text());
    //System.out.println("OdiCommandLineFixture: doSpawn: Creating command entry with expected result of " + p.resultCell.text());    
    commandProcessMap.put(CmdId, p);
    commandCell.addToBody("<hr><pre>");
    //System.out.println("OdiCommandLineFixture: doSpawn: OdiCommandLineFixture: doSpawn: ends");
    return p;
  }

  /**
   * Execute and wait for a command to complete.  This command has the same
   * syntax as spawn, except that it pauses execution of the table in order to
   * wait for the command to complete.
   * @see spawn()
   */
  public void command() {
	//System.out.println("OdiCommandLineFixture: command: starts");
    Parse commandCell = cells.at(1);
    Parse resultCell = cells.at(2);
    try {
      CommandProcess p = doSpawn(commandCell, resultCell);
      // Close the output (stdin - yes, funny name for it!) stream for the process, otherwise
      // the process can hang.
      p.process.getOutputStream().close();
      if (p != null) p.process.waitFor();
      
      //synchronized (p.process) {
    	//  if (p != null) p.process.wait(10000);
      //}   
    } catch (Exception e) {
      exception(commandCell, e);
    }
    //System.out.println("OdiCommandLineFixture: command: ends");
  }

  private LineGatherer makeGatherer(InputStream s) {
	//System.out.println("OdiCommandLineFixture: makeGatherer: starts");
    LineGatherer gatherer = new LineGatherer(new BufferedReader(new InputStreamReader(s)));
    new Thread(gatherer).start();
    //System.out.println("OdiCommandLineFixture: makeGatherer: ends");
    return gatherer;
  }

  private Process execute(String command) throws IOException {
	//System.out.println("OdiCommandLineFixture: execute: starts");
    Process p = Runtime.getRuntime().exec(command);
    //System.out.println("OdiCommandLineFixture: execute: ends");
    return p;
  }

  private CommandProcess getCommandProcess(Integer CommandId) {
	//System.out.println("OdiCommandLineFixture: getCommandProcess: starts");
    CommandProcess p = (CommandProcess) commandProcessMap.get(CommandId);
    //System.out.println("OdiCommandLineFixture: getCommandProcess: ends");
    return p;
  }

  private void flush(LineGatherer gatherer, Parse commandCell) {
	//System.out.println("OdiCommandLineFixture: flush: starts");
    String line;
    try {
      while ((line = gatherer.readLine()) != null) {
        commandCell.addToBody(line + "\n");
      }
    } catch (Exception e) {
      exception(commandCell, e);
    }
    //System.out.println("OdiCommandLineFixture: flush: ends");
  }
}