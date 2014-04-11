ODI-SCM Technical Manual
========================

The Configuration (INI) File
----------------------------

The ODI-SCM command line commands are controlled by environment variables. These environment variables are loaded from, and saved to, the configuration file.

The configuration file in use by the ODI-SCM command line commands is always specified by the environment variable ODI_SCM_INI. This variable though is not frequently accessed by the commands. Instead, the environment should be loaded (the environment variables set) from the configuration file using the command "OdiScmEnvSet". This command must always be invoked in the current shell (CMD.EXE) environemt, using CALL, for the "OdiScmEnvSet" command to have any useful effect.

The configuration file is updated, currently, only by the ODI-SCM commands that perform source code downloads, from the SCM system, (the *OdiScmGet* 
process) and import the source code into the ODI repository (the generated output of the *OdiScmGet* process).

So, the configuration file is really the persisted environment for the ODI-SCM command system. This, together with the ODI-SCM metadata that is maintained in ODI respository forms the complete system configuration.

+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|Section Name      |Key Name                       |Key Description                     |Example Values                                               |
+==================+===============================+====================================+=============================================================+
|OracleDI          |Admin Pass                     |Password of the database user with  |``xe``                                                       |
|                  |                               |DBA privileges. Used when creating  |                                                             |
|                  |                               |database users when creating ODI    |                                                             |
|                  |                               |repositories.                       |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Admin User                     |User name of the database user with |``system``                                                   |
|                  |                               |DBA privileges. Used when creating  |                                                             |
|                  |                               |database users when creating ODI    |                                                             |
|                  |                               |repositories.                       |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Common                         |Path of ODI 11g common libraries    |``C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.common``    |
|                  |                               |directory.                          |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Encoded Pass                   |Encoded password of the ODI user.   |``fJyaPZ,YfyDCeWogjrmEZOr``                                  |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Home                           |Path of ODI home directory.         |``C:\OraHome_1\oracledi`` 10g                                |
|                  |                               |                                    |``C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi\agent`` 11g |
|                  |                               |This is the directory containing the|                                                             |
|                  |                               |``bin`` directory that contains the |                                                             |
|                  |                               |startcmd.bat script                 |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Java Home                      |Path of the JDK to be used with ODI.|``C:\Program Files\Java\jdk1.6.0_45``                        |
|                  |                               |This is the directory containing the|                                                             |
|                  |                               |``bin`` directory containing the    |                                                             |
|                  |                               |``java.exe`` binary.                |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Oracle Home                    |Path of the Oracle Home for the ODI |``C:\oracle\product\11.1.1\Oracle_ODI_1``                    |
|                  |                               |installation. This is normally the  |                                                             |
|                  |                               |parent directory of the ODI Home    |                                                             |
|                  |                               |directory. This path is used to find|                                                             |
|                  |                               |additional resources such as Java   |                                                             |
|                  |                               |class archives (JAR) files and the  |                                                             |
|                  |                               |standard ODI demo files for the some|                                                             |
|                  |                               |of the ODI-SCM demos. This entry is |                                                             |
|                  |                               |required only when running the fast-|                                                             |
|                  |                               |forward of ODI-SCM demos that use   |                                                             |
|                  |                               |the standard ODI demo Hypersonic SQL|                                                             |
|                  |                               |databases.                          |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Pass                           |Unencoded password of the ODI user. |``SUNOPSIS``                                                 |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Repository ID                  |ID number of the master and work    |``100``                                                      |
|                  |                               |repository. Used by operations that |                                                             |
|                  |                               |create an ODI repository, such as   |                                                             |
|                  |                               |the AutoRebuild process.            |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |SDK                            |Path of the ODI 11g SDK root        |``C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.sdk``       |
|                  |                               |directory.                          |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Driver                    |Class name of the JDBC driver used  |``oracle.jdbc.driver.OracleDriver``                          |
|                  |                               |to connect to the ODI repository.   |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Encoded Pass              |Encoded password of the ODI master  |``gofpxBz5aa37kmG6I3eLyhVkiscy``                             |
|                  |                               |respository database user/owner.    |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Pass                      |Unencoded password of the ODI master|``odirepofordemo2``                                          |
|                  |                               |repository database user/owner.     |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu URL                       |JDBC URL of the ODI master          |``jdbc:oracle:thin:@localhost:1521:xe``                      |
|                  |                               |repository.                         |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu User                      |Name of the ODI master repository   |``odirepofordemo2``                                          |
|                  |                               |database user/owner.                |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Work Rep                  |Name of the ODI work repository     |``WORKREP``                                                  |
|                  |                               |attached to the master repository.  |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |User                           |User name of the ODI user.          |``SUPERVISOR``                                               |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Version                        |Version number of ODI.              |``11.1.1.6.4``                                               |
|                  |                               |Currently only the major version    |                                                             |
|                  |                               |number is significant to ODI-SCM.   |``10.``                                                      | 
|                  |                               |solution.                           |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|SCM System        |Branch URL                     |The least significant part of the   |``$/MyTFSProject/Master/SubProj1``                           |
|                  |                               |SCM URL. Typically, for TFS this is |                                                             |
|                  |                               |the Project and branch/folder path  |``OSSApps/MyApp``                                            |
|                  |                               |and for SVN this is the path within |                                                             |
|                  |                               |the root of the repository.         |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Global User Name               |A user name to use to logon to the  |``somedomain\anotheruser``                                   |
|                  |                               |SCM system instead of the default   |                                                             |
|                  |                               |user. For SVN the *default user* is |                                                             |
|                  |                               |the cached user, previously used to |                                                             |
|                  |                               |access the SVN repository. For TFS  |                                                             |
|                  |                               |the *default user* is the currently |                                                             |
|                  |                               |logged in Windows user.             |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Global User Password           |The password of the user specified  |``thesecretstring``                                          |
|                  |                               |in the Global User Name key, if     |                                                             |
|                  |                               |any.                                |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |System URL                     |The most significant part of the SCM|``http://mytfsvr:1234/tfs``                                  |
|                  |                               |URL. Typically, for TFS this is the |                                                             |
|                  |                               |server and Team Project Collection, |``file:///C:/OdiScmWalkThrough/SvnRepoRoot``                 |
|                  |                               |and for SVN this is the repository  |                                                             |
|                  |                               |root URL.                           |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Type Name                      |The name of the type of SCM system. |``SVN``                                                      |
|                  |                               |temporary/working files.            |                                                             |
|                  |                               |Must be set to SVN or TFS.          |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Working Copy Root              |The root directory of the SVN       |``C:/OdiScmWalkThrough/Repo2WorkingCopy``                    |
|                  |                               |working copy / TFS workspace.       |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |OracleDI Working Copy Root     |The root directory, relative to the |``src/oracledi``                                             |
|                  |                               |working copy root directory, of the |                                                             |
|                  |                               |ODI code.                           |                                                             |
|                  |                               |Must be within the working copy     |                                                             |
|                  |                               |directory tree. I.e. avoid using    |                                                             |
|                  |                               |".." in this path.                  |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Working Root                   |The working directory where the     |``C:/OdiScmWalkThrough/Temp2``                               |
|                  |                               |ODI-SCM export mechanism can create |                                                             |
|                  |                               |temporary/working files.            |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Workspace Name                 |The Team Foundation (Server, TFS)   |``myworkspace1``                                             |
|                  |                               |workspace name of the working copy. |                                                             |
|                  |                               |temporary/working files. Currently  |                                                             |
|                  |                               |used only by the OdiScmAutoRebuild  |                                                             |
|                  |                               |process to destroy and recreate the |                                                             |
|                  |                               |TFS workspace for the working copy. |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|Tools             |FitNesse Class Name            |The Java class name of the entry    |``fitnesse.FitNesse``          (for DbFit 1.1)               |
|                  |                               |point to FitNesse. Used to execute  |                                                             |
|                  |                               |ODI unit tests built with DbFit and |                                                             |
|                  |                               |other FIT/SLIM fixtures via the     |``fitnesseMain.FitNesseMain``  (for DbFit 2.x)               |
|                  |                               |FitNesse engine.                    |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |FitNesse Home                  |The home/installation diretory of   |``C:\dbfit-complete-2.1.0``                                  |
|                  |                               |FitNesse.                           |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |FitNesse Java Home             |Path of the JVM (JRE or JDK) to be  |``C:\Program Files\Java\jdk1.6.0_45``                        |
|                  |                               |used with FitNesse. This is the     |                                                             |
|                  |                               |directory containing the ``bin``    |                                                             |
|                  |                               |directory containing the            |                                                             |
|                  |                               |``java.exe`` binary.                |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Jisql Additional Classpath     |Additional Java class directories   |``C:\MyApp\bin;D:\AppLib\tools.jar;D:\AppLib\classes.zip``   |
|                  |                               |and/or archives required for        |                                                             |
|                  |                               |ODI-SCM operations against the ODI  |                                                             |
|                  |                               |repository.                         |                                                             |
|                  |                               |                                    |                                                             |
|                  |                               |No longer used, in general.         |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Jisql Home                     |Path of the Jisql home directory.   |``C:\Jisql\jisql-2.0.11``                                    |
|                  |                               |This is the directory containing the|                                                             |
|                  |                               |``runit.bat`` script and the ``lib``|                                                             |
|                  |                               |directory.                          |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Jisql Java Home                |Path of the JVM (JRE or JDK) home   |``C:\Program Files\Java\jdk1.6.0_45``                        |
|                  |                               |directory to use with Jisql.        |                                                             |
|                  |                               |This is the directory containing the|                                                             |
|                  |                               |``bin`` directory containing the    |                                                             |
|                  |                               |``java.exe`` binary.                |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Oracle Home                    |Path of the Oracle client home      |``C:\oraclexe\app\oracle\product\11.2.0\server``             |
|                  |                               |directory. This is the the directory|                                                             |
|                  |                               |containing the ``bin`` directory    |                                                             |
|                  |                               |containing the ``imp.exe`` and      |                                                             |
|                  |                               |``exp.exe`` binaries.               |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |UnxUtils Home                  |Path of the UnxUtils distribution   |``C:\UnxUtils``                                              |
|                  |                               |home directory. This is the         |                                                             |
|                  |                               |directory containing the ``bin`` and|                                                             |
|                  |                               |``usr`` directories.                |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|Generate          |Build Test Scope               |Determines whether an incremental   |``incremental``                                              |
|                  |                               |or full set of unit test executions |                                                             |
|                  |                               |are generated, to be executed after |                                                             |
|                  |                               |the completion of the build process.|                                                             |
|                  |                               |Valid values are ``incremental`` and|                                                             |
|                  |                               |``full``.                           |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Export Ref Phys Arch Only      |Controls whether ODI-SCM export     |``No``                                                       |
|                  |                               |operations (export and flush) will  |                                                             |
|                  |                               |export non *reference* Topology     |                                                             |
|                  |                               |objects. For more on this subject   |                                                             |
|                  |                               |see the *Reference Topology*        |                                                             |
|                  |                               |section in the ODI-SCM Technical    |                                                             |
|                  |                               |Manual. Valid values are ``Yes`` and|                                                             |
|                  |                               |``No``.                             |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Export Cleans ImportRep Objects|Controls whether the ODI-SCM export |``Yes``                                                      |
|                  |                               |will remove SnpMImportRep and       |                                                             |
|                  |                               |SnpImportRep objects from ODI object|                                                             |
|                  |                               |source files. Removing these allows |                                                             |
|                  |                               |ODI-SCM to populate a repository    |                                                             |
|                  |                               |from source object files where the  |                                                             |
|                  |                               |repository is not the original      |                                                             |
|                  |                               |repository having the repository's  |                                                             |
|                  |                               |ID. The operation is normally       |                                                             |
|                  |                               |blocked by the ODI import API but   |                                                             |
|                  |                               |ODI-SCM makes this operation safe.  |                                                             |
|                  |                               |Not applicable to ODI 10g.          |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |OracleDI Context               |The code of the ODI context used to |``GLOBAL``                                                   |
|                  |                               |execute ODI-SCM operations, such as |                                                             |
|                  |                               |flushing out code or configuring the|                                                             |
|                  |                               |components.                         |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Output Tag                     |The character string used as part of|``DemoEnvironment2``                                         |
|                  |                               |the names of the directories and    |                                                             |
|                  |                               |files generated by the OdiScmGet    |                                                             |
|                  |                               |process. If empty, then a tag       |                                                             |
|                  |                               |composed of the current date and    |                                                             |
|                  |                               |is used.                            |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Import Object Batch Size Max   |The maximum number of ODI object    |``200``                                                      |
|                  |                               |source files imported in a single   |                                                             |
|                  |                               |import operation.                   |                                                             |
|                  |                               |*Massive* import performance gains  |                                                             |
|                  |                               |can be achieved by specifying a     |                                                             |
|                  |                               |value for this option. Valid values |                                                             |
|                  |                               |are positive integers. A value of   |                                                             |
|                  |                               |``1`` means *no optimisation*.      |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Import Resets Flush Control    |Controls whether the ODI-SCM import |``Yes``                                                      |
|                  |                               |process updates the ODI-SCM *flush  |                                                             |
|                  |                               |control* metadata. Valid values are |                                                             |
|                  |                               |``Yes`` and ``No``.                 |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Scenario Export Markers        |A sstring of one or more object     |``SMILEYS.SMILEY_2,MYMARKERS.MARKER17``                      |
|                  |                               |markers used to indicate which      |                                                             |
|                  |                               |source objects may have their       |                                                             |
|                  |                               |Scenarios exported to the file      |                                                             |
|                  |                               |system, and hence available to check|                                                             |
|                  |                               |into the source code control system |                                                             |
|                  |                               |rather than being removed from the  |                                                             |
|                  |                               |export file created for the source  |                                                             |
|                  |                               |object.                             |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Scenario Source Markers        |A string of one or more object      |``SMILEYS.SMILEY_2,PRIORITIES.PRIORITY_1``                   |
|                  |                               |markers used to indicate which      |                                                             |
|                  |                               |source objects should have a        |                                                             |
|                  |                               |Scenario generated, by ODI-SCM,     |                                                             |
|                  |                               |after being imported into the ODI   |                                                             |
|                  |                               |repository. The format of a marker  |                                                             |
|                  |                               |in the list of markers is:          |                                                             |
|                  |                               |*<Marker Group Code>.<Marker Code>* |                                                             |
|                  |                               |Markers in the list are separated by|                                                             |
|                  |                               |comma (``,``) characters.           |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|Test              |ODI Standards Script           |An optional path and name of a SQL  |``C:\Scripts\DemoODINamingStandardTest.sql``                 |
|                  |                               |script used to check the ODI code,  |                                                             |
|                  |                               |in the repository, for naming,      |                                                             |
|                  |                               |design, etc, standards violations.  |                                                             |
|                  |                               |If specified this script will be run|                                                             |
|                  |                               |as part of the ODI-SCM generated ODI|                                                             |
|                  |                               |imports. The author of the script   |                                                             |
|                  |                               |can choose to simply highlight the  |                                                             |
|                  |                               |issues, or cause a failure in the   |                                                             |
|                  |                               |imports, by coding the script       |                                                             |
|                  |                               |appropriately.                      |                                                             |
|                  |                               |Applies only to incremental builds  |                                                             |
|                  |                               |only. I.e. not to the initial build |                                                             |
|                  |                               |of an empty repositroy.             |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |FitNesse Output Format         |The output format of FitNesse tests.|``text``                                                     |
|                  |                               |Valid values are ``html`` and       |                                                             |
|                  |                               |``text``. ``html`` format is useful |                                                             |
|                  |                               |for debugging test failures but     |                                                             |
|                  |                               |``text`` format is required for the |                                                             |
|                  |                               |correct detection of test failures  |                                                             |
|                  |                               |whilst running post build tests.    |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |FitNesse Port                  |The TCP port that FitNesse will use |``8086``                                                     |
|                  |                               |for its test runner processes, such |                                                             |
|                  |                               |as fit.FitServer or the SLiM test   |                                                             |
|                  |                               |runner.                             |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |FitNesse Root Page Root        |The path of the root FitNesse page. |``C:\MyWorkingCopy\FitNesseRoot``                            |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |FitNesse Root Page Name        |The name of the root FitNesse page. |``FitNesseRoot``                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |FitNesse Unit Test Root Page   |The parent page path of the ODI     |``MyProject.EtL.UnitTests``                                  |
|                  |Name                           |object unit test FitNesse pages.    |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |OracleDI Context               |The code of the ODI context used to |``GLOBAL``                                                   |
|                  |                               |execute post build tests.           |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|Import Controls   |OracleDI Imported Revision     |Tracks the highest revision number, |``123``                                                      |
|                  |                               |from the SCM system, that has been  |                                                             |
|                  |                               |imported into the ODI repository.   |                                                             |
|                  |                               |This entry is updated by ODI-SCM    |                                                             |
|                  |                               |generated ODI import scripts.       |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Working Copy Revision          |Tracks the highest revision number, |``123``                                                      |
|                  |                               |from the SCM system, that has been  |                                                             |
|                  |                               |applied to the working copy.        |                                                             |
|                  |                               |This entry is updated by the        |                                                             |
|                  |                               |OdiScmGet process.                  |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|Notify            |User Name                      |Tracks the highest revision number, |``Mark Matten``                                              |
|                  |                               |from the SCM system, that has been  |                                                             |
|                  |                               |imported into the ODI repository.   |                                                             |
|                  |                               |This entry is updated by ODI-SCM    |                                                             |
|                  |                               |generated ODI import scripts.       |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Email Address                  |The email address used to notify the|``mattenm@odietamo.org.uk``                                  |
|                  |                               |user of the completion (success or  |                                                             |
|                  |                               |failure) of build processes.        |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |SMTP Server                    |The host name or IP addresss of an  |``mail.yourdomain.co.uk``                                    |
|                  |                               |SMTP server used to send email      |                                                             |
|                  |                               |notifications.                      |                                                             |
|                  +-------------------------------+------------------------------------+-------------------------------------------------------------+
|                  |On Build Status                |Whether to send a notification on   |``both``                                                     |
|                  |                               |build *success*, build *failure*,   |                                                             |
|                  |                               |*both* or *neither*.                |                                                             |
|                  |                               |Valid values are ``success``,       |                                                             |
|                  |                               |``failure``, ``both`` and           |                                                             |
|                  |                               |``neither``.                        |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+
|Misc              |Resources Root                 |Path of the directory used for      |``C:\OdiScmResources``                                       |
|                  |                               |miscellaneous resource files.       |                                                             |
+------------------+-------------------------------+------------------------------------+-------------------------------------------------------------+

A example configuration file with all sections and keys listed::

	[OracleDI]
	Admin Pass=xe
	Admin User=system
	;Version=10.1.3.5.6_02
	;Home=C:\oracledi
	;Java Home=C:\Java\jdk1.5.0_22
	;For ODI10g, Common and SDK are not used.
	;Common=
	;SDK=
	;For ODI11g, enable Common and SDK.
	Common=C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.common
	SDK=C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.sdk
	Encoded Pass=fJyaPZ,YfyDCeWogjrmEZOr
	Home=C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi\agent
	Java Home=C:\Program Files\Java\jdk1.6.0_45
	Oracle Home=C:\oracle\product\11.1.1\Oracle_ODI_1
	Pass=SUNOPSIS
	Repository ID=200
	Secu Driver=oracle.jdbc.driver.OracleDriver
	Secu Encoded Pass=gofpxBz5aa37kmG6I3eLyhVkiscy
	Secu Pass=odirepofordemo2
	Secu URL=jdbc:oracle:thin:@localhost:1521:xe
	Secu User=odirepofordemo2
	Secu Work Rep=WORKREP
	User=SUPERVISOR
	Version=11.1.1.6.4

	[SCM System]
	Branch URL=.
	Global User Name=
	Global User Password=
	System URL=file:///C:/OdiScmWalkThrough/SvnRepoRoot
	Type Name=SVN
	Working Copy Root=C:/OdiScmWalkThrough/Repo2WorkingCopy
	Working Root=C:/OdiScmWalkThrough/Temp2
	;Workspace Name is for TFS, only, and only used by repository rebuilds.
	Workspace Name=

	[Tools]
	FitNesse Java Home=C:\Program Files\Java\jdk1.6.0_45
	FitNesse Home=C:\dbfit-complete-2.0.0-rc5
	Jisql Additional Classpath=
	Jisql Home=C:\Jisql\jisql-2.0.11
	Jisql Java Home=C:\Program Files\Java\jdk1.6.0_45
	Oracle Home=C:\oraclexe\app\oracle\product\11.2.0\server
	UnxUtils Home=C:\UnxUtils

	[Generate]
	Export Ref Phys Arch Only=No
	Export Cleans ImportRep Objects=Yes
	Import Object Batch Size Max=100
	Import Resets Flush Control=Yes
	OracleDI Context=GLOBAL
	Output Tag=DemoEnvironment2
	Scenario Source Markers=ODISCM.HAS_SCENARIO

	[Test]
	ODI Standards Script=
	; "html" or "text".
	FitNesse Output Format=text
	FitNesse Port=8086
	FitNesse Root Page Root=C:/OdiScmWalkThrough/Repo1WorkingCopy/SvnRepoRoot
	FitNesse Root Page Name=FitNesseRoot
	FitNesse Unit Test Root Page Name=OdiScmDemo
	OracleDI Context=GLOBAL

	[Notify]
	User Name=
	Email Address=
	SMTP Server=

	[Misc]
	Resources Root=

The *Get* Process
-----------------

The OdiScmGet command is the command that updates the working copy, from the SCM system, *and* generates the scripts to update the ODI repository with the new/changed files from the *Get* operation.

Dealing with Conflicts
~~~~~~~~~~~~~~~~~~~~~~

Details of how to handle conflicts between *your* code and incoming code from the *Get* process - coming very soon!

Details of how to handle *check in* conflicts - coming very soon!

The *Flush* Process
-------------------

The ODI repository *flush* is the process that exports additions and changes, made to the ODI repository (either via the ODI UI, or the ODI 11g SDK) to the working copy so that the new/changed code can be added and checked in to the SCM system.

The *flush* process is invoked either from the command prompt, using the ``OdiScmFlushRepository`` command, or from the ODI *Designer* UI, by executing the Scenario::

	ODI-SCM (project) -> COMMON (folder) -> Packages -> OSUTL_FLUSH_REPOSITORY -> Scenarios -> OSUTL_FLUSH_REPOSITORY Version 001

Note: you might see the version number ``1`` instead of ``001`` depending upon the version of ODI you're using.

Reference Topology
------------------

Details coming soon!

Build Import Performance
------------------------

ODI's ``startcmd.bat`` / ``OdiImportObject`` interface is extremely slow when used to import a large number of granular (small) ODI object source files. This is *partially* because of the overhead of starting up a JVM for each import operation. But, the main performance impediment is ``OdiImportObject`` itself. The size of the data file being imported does not appear to be a major contributor to the time it takes the import operation to complete. We can only think there must be some kind of global repository integrity validation step that occurs for each import.

The main weapon we have to improve performance is batching of ODI object source files into a larger import source file. Batching is controlled via the configuration file entry ``Import Object Batch Size Max`` in the section ``[Generate]``.

We have experienced **massive** performance boosts by specifying a value for this parameter. On a Windows XP desktop PC, with 3GB of RAM, Intel i5 CPU, we've seen our imports, of around 11,000 source files, go *from around 20 hours to under one hour*!

Configuring Your SVN Client
---------------------------

If you're using Subversion, not TFS, with ODI-SCM, then you will need to prevent SVN from automatically *merging* changes in ODI object source files. We do not want to let SVN merge changes, coming from the SVN repository into the working copy, with changes made to the ODI object source file, via the ODI UI (and exported via ODI-SCM).

This is because SVN will perform a textual merge of the two sets of changes and produce a new merged (text) file. Although the ODI object source files, produced by ODI-SCM, are text (XML) files the textual merge performed by SVN is not guaranteed to produce a usable/coherent ODI object source file.

So when we prevent SVN from doing this SVN will highlight any conflicts between theirs (the incoming changes from the SVN repository) and ours (the code we've exported from our ODI repository) at the source file level.

How we deal with any conflicts that we come across is discussed in another section.

To tell SVN not to automatically merge ODI object source files, we tell SVN to treat these file types as binary file types. SVN will not attempt to merge changes for binary files (because the results are unlikely to be useful). We tell SVN to treat the ODI source object files as binary by assigning each file the SVN property ``svn:mime-type`` and a property value of ``application/octet-stream``. This property is assigned to the file when the file is first created in SVN repository.

The SVN Configuraton File
~~~~~~~~~~~~~~~~~~~~~~~~~

The SVN configuration file, named ``config``, is created by SVN the first time that the SVN command line client (svn.exe) is run. On Windows systems it exists in a directory called ``Subversion`` that is located in ``AppData`` directory of the user's profile directory. The user's profile directory has different locations depending upon the version of Windows being used.

E.g. on a Windows 7 machine, the config file might be::

	C:\Users\Mark Matten\AppData\Roaming\Subversion\config

E.g. on a Windows XP machine, the config file might be::

	C:\Documents and Settings\mattenm\AppData\Roaming\Subversion\config

For more information on this subject see the SVN book, online at http://svnbook.red-bean.com/en/1.7/svn.advanced.confarea.html.

To enable to automatic property assignment, ensure that in the ``[miscellany]`` section of the configuration file ensure that the entry ``enable-auto-props`` is set to ``yes``. I.e.::

	enable-auto-props = yes

In the ``[auto-props]`` section of the configuration file add an entry, for each of the ODI object types that are exportable by ODI-SCM. You can copy and paste the following into your configuration file::

*.SnpTechno = svn:mime-type=application/octet-stream
*.SnpConnect = svn:mime-type=application/octet-stream
*.SnpPschema = svn:mime-type=application/octet-stream
*.SnpLschema = svn:mime-type=application/octet-stream
*.SnpContext = svn:mime-type=application/octet-stream
*.SnpProject = svn:mime-type=application/octet-stream
*.SnpFolder = svn:mime-type=application/octet-stream
*.SnpTrt = svn:mime-type=application/octet-stream
*.SnpPackage = svn:mime-type=application/octet-stream
*.SnpPop = svn:mime-type=application/octet-stream
*.SnpVar = svn:mime-type=application/octet-stream
*.SnpUfunc = svn:mime-type=application/octet-stream
*.SnpSequence = svn:mime-type=application/octet-stream
*.SnpGrpState = svn:mime-type=application/octet-stream
*.SnpModFolder = svn:mime-type=application/octet-stream
*.SnpModel = svn:mime-type=application/octet-stream
*.SnpSubModel = svn:mime-type=application/octet-stream
*.SnpTable = svn:mime-type=application/octet-stream