ODI-SCM Technical Manual
========================

The Configuration (INI) File
----------------------------

The ODI-SCM command line commands are controlled by environment variables. These environment variables are loaded from, and saved to, the configuration file.

The configuration file in use by the ODI-SCM command line commands is always specified by the environment variable ODI_SCM_INI. This variable though is not frequently accessed by the commands. Instead, the environment should be loaded (the environment variables set) from the configuration file using the command "OdiScmEnvSet". This command must always be invoked in the current shell (CMD.EXE) environemt, using CALL, for the "OdiScmEnvSet" command to have any useful effect.

The configuration file is only updated, currently, only by the ODI-SCM commands that perform source code downloads, from the SCM system, (the *OdiScmGet* 
process) and import the source code into the ODI repository (the generated output of the *OdiScmGet* process).

So, the configuration file is really the persisted environment for the ODI-SCM command system. This, together with the ODI-SCM metadata that is maintained in ODI respository forms the complete system configuration.

+------------------+---------------------------+------------------------------------+-------------------------------------------------------------+
|Section Name      |Key Name                   |Key Description                     |Example Value                                                |
+==================+===========================+====================================+=============================================================+
|OracleDI          |Admin Pass                 |Password of the database user with  |``xe``                                                       |
|       I          |                           |DBA privileges. Used when creating  |                                                             |
|                  |                           |database users when creating ODI    |                                                             |
|                  |                           |repositories.                       |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Admin User                 |User name of the database user with |``system``                                                   |
|                  |                           |DBA privileges. Used when creating  |                                                             |
|                  |                           |database users when creating ODI    |                                                             |
|                  |                           |repositories.                       |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Common                     |Path of ODI 11g common libraries    |``C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.common``    |
|                  |                           |directory.                          |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Encoded Pass               |Encoded password of the ODI user.   |``fJyaPZ,YfyDCeWogjrmEZOr``                                  |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Home                       |Path of ODI home directory.         |ODI 10g: -                                                   |
|                  |                           |                                    |``C:\OraHome_1\oracledi``                                    |
|                  |                           |This is the directory containing the|                                                             |
|                  |                           |'bin' direcotry that contains the   |ODI 11g: -                                                   |
|                  |                           |startcmd.bat script                 |``C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi\agent``     |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Java Home                  |Path of the JDK to be used with ODI |``C:\Program Files\Java\jdk1.6.0_45``                        |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Pass                       |Unencoded password of the ODI user. |``SUNOPSIS``                                                 |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |SDK                        |Path of the ODI 11g SDK root        |``C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.sdk``       |
|                  |                           |directory.                          |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Driver                |Class name of the JDBC driver used  |``oracle.jdbc.driver.OracleDriver``                          |
|                  |                           |to connect to the ODI repository.   |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Encoded Pass          |Encoded password of the ODI master  |``gofpxBz5aa37kmG6I3eLyhVkiscy``                             |
|                  |                           |respository database user/owner.    |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Pass                  |Unencoded password of the ODI master|``odirepofordemo2``                                          |
|                  |                           |repository database user/owner.     |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu URL                   |JDBC URL of the ODI master          |``jdbc:oracle:thin:@localhost:1521:xe``                      |
|                  |                           |repository.                         |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu User                  |Name of the ODI master repository   |``odirepofordemo2``                                          |
|                  |                           |database user/owner.                |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Secu Work Rep              |Name of the ODI work repository     |``WORKREP``                                                  |
|                  |                           |attached to the master repository.  |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |User                       |User name of the ODI user.          |``SUPERVISOR``                                               |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Version                    |Version number of ODI.              |``11.1.1.6.4``                                               |
|                  |                           |Currently only the major version    |                                                             |
|                  |                           |number is significant to ODI-SCM.   |                                                             | 
|                  |                           |solution.                           |                                                             |
+------------------+---------------------------+------------------------------------+-------------------------------------------------------------+
|SCM System        |Branch URL                 |                                    |``SubProject1.``                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Global User Name           |                                    |``somedomain\anotheruser``                                   |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Global User Password       |                                    |``thesecretstring``                                          |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |System URL                 |                                    |``file:///C:/OdiScmWalkThrough/SvnRepoRoot``                 |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Type Name                  |                                    |``SVN``                                                      |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Working Copy Root          |                                    |``C:/OdiScmWalkThrough/Repo2WorkingCopy``                    |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Working Root               |                                    |``C:/OdiScmWalkThrough/Temp2``                               |
+------------------+---------------------------+------------------------------------+-------------------------------------------------------------+
|Tools             |Jisql Additional Classpath |                                    |                                                             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Jisql Home                 |                                    |``C:\Jisql\jisql-2.0.11``                                    |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Jisql Java Home            |                                    |``C:\Program Files\Java\jdk1.6.0_45``                        |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Oracle Home                |                                    |``C:\oraclexe\app\oracle\product\11.2.0\server``             |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |UnxUtils Home              |                                    |``C:\UnxUtils``                                              |
+------------------+---------------------------+------------------------------------+-------------------------------------------------------------+
|Generate          |Export Ref Phys Arch Only  |                                    |``No``                                                       |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Output Tag                 |                                    |``DemoEnvironment2``                                         |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Import Resets Flush Control|                                    |``Yes``                                                      |
+------------------+---------------------------+------------------------------------+-------------------------------------------------------------+
|Test              |ODI Standards Script       |                                    |``C:\Scripts\DemoODINamingStandardTest.sql``                 |
+------------------+---------------------------+------------------------------------+-------------------------------------------------------------+
|Import Controls   |OracleDI Imported Revision |                                    |``123``                                                      |
|                  +---------------------------+------------------------------------+-------------------------------------------------------------+
|                  |Working Copy Revision      |                                    |``209``                                                      |
+------------------+---------------------------+------------------------------------+-------------------------------------------------------------+

A example configuration file (borrowed from the output of demo 1) with all sections and keys listed::

	[OracleDI]
	Admin Pass=xe
	Admin User=system
	Common=C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.common
	Encoded Pass=fJyaPZ,YfyDCeWogjrmEZOr
	Home=C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi\agent
	Java Home=C:\Program Files\Java\jdk1.6.0_45
	Pass=SUNOPSIS
	SDK=C:\oracle\product\11.1.1\Oracle_ODI_1\oracledi.sdk
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

	[Tools]
	Jisql Additional Classpath=
	Jisql Home=C:\Jisql\jisql-2.0.11
	Jisql Java Home=C:\Program Files\Java\jdk1.6.0_45
	Oracle Home=C:\oraclexe\app\oracle\product\11.2.0\server
	UnxUtils Home=C:\UnxUtils

	[Generate]
	Export Ref Phys Arch Only=No
	Output Tag=DemoEnvironment2
	Import Resets Flush Control=Yes

	[Test]
	ODI Standards Script=C:\Scripts\DemoODINamingStandardTest.sql

	[Import Controls]
	OracleDI Imported Revision=123
	Working Copy Revision=209