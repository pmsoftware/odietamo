package odietamo.OdiScm;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class ConsolidateObjectSourceFiles {

	private static final String modName = "OdiScm";
	
	public static void main(String[] args) {

		final String procName = modName + ": ConsolidateObjectSourceFiles";
		final String infoMsg = procName + ": INFO: ";
		final String errMsg = procName + ": ERROR: ";
		final String warnMsg = procName + ": WARNING: ";
		
		if (args.length != 4) {
			System.err.println(errMsg + "invalid arguments");
			System.out.println(infoMsg + "usage: ConsolidateObjectSourceFiles <input files list file> <output directory> <output files list file> <max output batch size>");
			System.exit(1);
		}
		
		System.out.println(infoMsg + "Starts");
		
		// ODI object source file extensions - as String array.
		String[] arrStrOrderedExtensions = {
				".SnpTechno", ".SnpLang", ".SnpContext", ".SnpConnect", ".SnpPschema", ".SnpLschema"
				, ".SnpProject", ".SnpGrpState", ".SnpFolder", ".SnpVar", ".SnpUfunc", ".SnpTrt"
				, ".SnpModFolder", ".SnpModel", ".SnpSubModel", ".SnpTable", ".SnpJoin", ".SnpSequence"
				, ".SnpPop", ".SnpPackage", ".SnpObjState"
				};
		// ODI object source file extensions - as String List.		
		List<String> lstStrOrderedExtensions = new ArrayList<String>(Arrays.asList(arrStrOrderedExtensions));

		String strInputFilesListFile = args[0];
		String strOutputFilesDir = args[1];
		String strOutputFilesListFile = args[2];
		
		// Validate the output file batch size.
		int intOutputBatchSize = 1;
		
		try {   
			intOutputBatchSize = Integer.parseInt(args[3]);   
		}   
		catch(Exception e) {   
			System.err.println(errMsg + "value specified for maximum output file batch size is not an integer");
			System.exit(1);
		}   
		
		// Input source files - as String List.		
		List<String> lstStrInputFilesList = new ArrayList<String>();
		// Output source files - as String List.		
		List<String> lstStrOutputFilesList = new ArrayList<String>();		
		
		// Load the input source files list into a List.
		BufferedReader br = null;
		try {
			String strCurrentLine;
			br = new BufferedReader(new FileReader(strInputFilesListFile));
		 
			while ((strCurrentLine = br.readLine()) != null) {
				//System.out.println(strCurrentLine);
				lstStrInputFilesList.add(strCurrentLine);
			}
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		finally {
			try {
				if (br != null)
					br.close();
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		
		//
		// Iterate through the list of object types and consolidate the source files for them.
		//
		int intBatchNumber = 0;
		
		for (String strOdiObjType : lstStrOrderedExtensions) {
			
			System.out.println(infoMsg + "processing object type <" + strOdiObjType.replace(".", "") + ">");
			
			List<String> lstCurrObjFiles = new ArrayList<String>(intOutputBatchSize);
			int intCurrBatchSize = 0;
						
			// Add files of this type to our working list.
			for (String strCurrFile : lstStrInputFilesList) {
				
				if (strCurrFile.endsWith(strOdiObjType)) {
					lstCurrObjFiles.add(strCurrFile);
					intCurrBatchSize++;
				
					if (intCurrBatchSize == intOutputBatchSize) {
						// Consolidate them.
						intBatchNumber++;
						String strOutputFile = strOutputFilesDir + "\\Consolidated_" + intBatchNumber + strOdiObjType;
						lstStrOutputFilesList.add(strOutputFile);
						
						CreateConsolidatedOdiSourceFile(lstCurrObjFiles, strOutputFile);
						// Set up for the next batch.
						intCurrBatchSize = 0;
						lstCurrObjFiles.clear();
					}
				}
			}
			
			if (intCurrBatchSize != 0) {
				// Consolidate them.
				intBatchNumber++;
				String strOutputFile = strOutputFilesDir + "\\Consolidated_" + intBatchNumber + strOdiObjType;
				lstStrOutputFilesList.add(strOutputFile);
				
				CreateConsolidatedOdiSourceFile(lstCurrObjFiles, strOutputFile);
			}
		}		
		
		//
		// Write the list of consolidated output files.
		//
		FileWriter fwOutWriter = null;
		
		try {
			fwOutWriter = new FileWriter(strOutputFilesListFile);
		
			for (String strOutFile : lstStrOutputFilesList) {
				fwOutWriter.write(strOutFile + "\r\n");
			}
		
			fwOutWriter.close();
		}
		catch (Exception e) {
			System.err.println(errMsg + "writing output file <" + strOutputFilesListFile + ">");
			System.exit(1);
		}
		finally {
			try {
				if (fwOutWriter != null)
					fwOutWriter.close();
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		System.out.println(infoMsg + "finished output file names file <" + strOutputFilesListFile + ">");
		System.out.println(infoMsg + "Ends");
		System.exit(0);
	}
	
	static List<String> FileAsList(String strInFile) {
		
		List<String> lstOutList = new ArrayList<String>();
		
		BufferedReader br = null;
		
		try {
			String strCurrentLine;
			br = new BufferedReader(new FileReader(strInFile));
		 
			while ((strCurrentLine = br.readLine()) != null) {
				lstOutList.add(strCurrentLine);
			}
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		finally {
			try {
				if (br != null)
					br.close();
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		
		return lstOutList;
	}
	
	// Static method: this class isn't instantiated.
	private static void CreateConsolidatedOdiSourceFile(List<String> lstInFileNames, String strOutFileName) {
		
		final String procName = modName + ": CreateConsolidatedOdiSourceFile";
		final String infoMsg = procName + ": INFO: ";
		final String errMsg = procName + ": ERROR: ";
		final String warnMsg = procName + ": WARNING: ";
		
		System.out.println(infoMsg + "Starts");
		System.out.println(infoMsg + "passed <" + (lstInFileNames.size()) + "> files to consolidate");
		System.out.println(infoMsg + "creating consolidated ODI object source file <" + strOutFileName + ">");
		
		//
		// Create the output records list and add the headers.
		//
		List<String> lstOutRecords = new ArrayList();
		lstOutRecords.add("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>");
		lstOutRecords.add("<SunopsisExport>");
		
		//
		// Process each source file.
		//
		for (String strInFile : lstInFileNames) {
			System.out.println(infoMsg + "processing object source file <" + strInFile + ">");
			
			List<String> lstCurrFileRecs = FileAsList(strInFile);
			
			boolean blnFoundXmlDocHeader = false;
			boolean blnFoundExportHeader = false;
			boolean blnFoundAdminRepositoryVersion = false;
			boolean blnFoundSummaryHeader = false;
		
			//
			// Validate the source file's content.
			//
			if (lstCurrFileRecs.size() < 3) {
				System.err.println(errMsg + "object source file contains less records that the minimum necessary for an ODI object");
				// I'm too lazy to define something specific.
				System.exit(1);
			}
			
			if (! lstCurrFileRecs.get(0).trim().equals("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>")) {
				System.err.println(errMsg + "first record does not contain the XML document header");
				// I'm too lazy to define something specific.
				System.exit(1);
			}
			
			if (! lstCurrFileRecs.get(1).trim().equals("<SunopsisExport>")) {
				System.err.println(errMsg + "second record does not contain the <SunopsisExport> tag");
				// I'm too lazy to define something specific.
				System.exit(1);
			}
			
			//
			// Process each record of the source file.
			//
			for (int intRecIdx = 2; intRecIdx < lstCurrFileRecs.size(); intRecIdx++) {
				String strRecord = lstCurrFileRecs.get(intRecIdx);
				
				if (!(blnFoundAdminRepositoryVersion)) {
					if (strRecord.trim().startsWith("<Admin RepositoryVersion=\"")) {
						continue;
					}
				}
				
				//
				// Check every non XML / export header record for the summary header.
				//
				if (strRecord.trim().equals("<Object class=\"com.sunopsis.dwg.DwgExportSummary\">")) {
					break;
				}
				
				lstOutRecords.add(strRecord);
			}
		}
		
		//
		// Add the file trailers.
		//
		lstOutRecords.add("</SunopsisExport>");
		
		//
		// Write the file.
		//
		FileWriter fwOutWriter = null;
		
		try {
			fwOutWriter = new FileWriter(strOutFileName);
		
			for (String strOutRecord : lstOutRecords) {
				fwOutWriter.write(strOutRecord + "\r\n");
			}
		
			fwOutWriter.close();
		}
		catch (Exception e) {
			System.err.println(errMsg + "writing output file <" + strOutFileName + ">");
			System.exit(1);
		}
		finally {
			try {
				if (fwOutWriter != null)
					fwOutWriter.close();
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		System.out.println(infoMsg + "finished writing file <" + strOutFileName + ">");
	}
}