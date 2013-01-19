REM #
REM # Copyright (c) 2000-2005 Oracle.  All rights reserved.
REM #
REM # PRODUCT
REM #   Oracle Data Integrator
REM #
REM # FILENAME
REM #   odiparams.bat
REM #
REM # DESCRIPTION
REM #   Configuration script. This script contains the parameters for starting 
REM #   Oracle Data Integrator modules.
REM #
REM # VARIABLES DESCRIPTION
REM #
REM # The following variables should be configured in order to run operations
REM # requiring a repository connection (startscen, agentscheduler, etc.)
REM #
REM #   ODI_SECU_DRIVER
REM #       JDBC driver used to connect the Master Repository.
REM #   ODI_SECU_URL
REM #       JDBC URL used to connect the Master Repository.
REM #   ODI_SECU_USER
REM #       Database account used to connect the Master Repository.
REM #   ODI_SECU_ENCODED_PASS
REM #       Database account password. The password must be encoded with the 
REM #       "agent encode <password>" command.
REM #   ODI_SECU_WORK_REP
REM #       Name of the Work Repository to connect. This Work Repository must
REM #       be attached to the master repository.
REM #   ODI_USER
REM #       OracleDI user used to launch a scenario.
REM #   ODI_ENCODED_PASS
REM #       OracleDI user password. The password must be encoded with the 
REM #       "agent encode <password>" command.
REM #
REM # The following variables can be changed to tune OracleDI configuration.
REM #
REM #   ODI_INIT_HEAP
REM #       Initial java machine heap size used by OracleDI modules.
REM #   ODI_MAX_HEAP
REM #       Maximum java machine heap size used by OracleDI modules.
REM #   ODI_JAVA_HOME
REM #       Installation directory of the java virtual machine used for 
REM #       OracleDI.
REM #   ODI_ADDITIONAL_JAVA_OPTIONS
REM #       Additional Java options, such as -Duser.language or -Duser.country.
REM #   ODI_ADDITIONAL_CLASSPATH
REM #       Classpath for additional classes (Windows 95/98/Me Only)
REM #   ODI_HOME
REM #       Set this environment variable separately. If it is unset, the script can
REM #       be launched only from the ./bin directory. If running the setup 
REM #       program, this variable is automatically set.
REM #
REM # Other variables should be left unchanged.
REM #

rem
rem Repository Connection Information
rem
set ODI_SECU_DRIVER=org.hsqldb.jdbcDriver
set ODI_SECU_URL=jdbc:hsqldb:hsql://localhost
set ODI_SECU_USER=sa
set ODI_SECU_ENCODED_PASS=
set ODI_SECU_WORK_REP=WORKREP
set ODI_USER=SUPERVISOR
set ODI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH 

rem
rem Java virtual machine
rem
if "%ODI_JAVA_HOME%" == "" set ODI_JAVA_HOME=%JAVA_HOME%

rem
rem Other Parameters
rem
set ODI_INIT_HEAP=32m
set ODI_MAX_HEAP=256m

rem
rem Additional Java Options 
rem
rem set ODI_ADDITIONAL_JAVA_OPTIONS="-Duser.language=en -Duser.country=us"

rem Windows 95,98, Me users only: Any package files added to the /drivers 
rem or /lib/scripting directory should be manually declared in the 
rem ODI_ADDITIONAL_CLASSPATH variable
set ODI_ADDITIONAL_CLASSPATH=


rem DO NOT EDIT BELOW THIS LINE !
rem ----------------------------------------------------------------------------

set ODI_JAVA_EXE=%ODI_JAVA_HOME%\bin\java.exe
set ODI_JAVAW_EXE=%ODI_JAVA_HOME%\bin\javaw.exe
set ODI_JAVAC_EXE=%ODI_JAVA_HOME%\bin\javac.exe

rem Testing the java virtual machine

if not exist "%ODI_JAVA_EXE%" goto NOJAVA
if not exist "%ODI_JAVAW_EXE%" goto NOJAVA
if not exist "%ODI_JAVAC_EXE%" goto NOJAVAC
goto OKJAVA

:NOJAVA
@echo The Java Virtual Machine was not found at the following location: %ODI_JAVA_HOME%
@echo The ODI_JAVA_HOME environment variable is not defined correctly.
@echo Please set this variable in odiparams.bat.
goto OKJAVA

:NOJAVAC
@echo A JDK is required to execute Web Services with OracleDI. You are currently using a JRE.
:OKJAVA

if "%ODI_HOME%" == "" set ODI_HOME=..

rem default classpath, includes OracleDI packages
set ODI_CLASSPATH=%ODI_HOME%\lib\.;%ODI_HOME%\lib\sunopsis.zip;%ODI_HOME%\lib\snpshelp.zip;%ODI_HOME%\lib\snpsws.zip;%ODI_HOME%\lib\webservices\

if not Windows_NT == %OS% GOTO WIN9X

rem Windows NT, 2000, 2003, XP
set ODI_START_TITLE="OracleDI"
rem Dynamic construction of the CLASSPATH for the drivers and scripting engines.
rem To add a new driver or scripting engine, just add the .jar or .zip file to 
rem the /drivers or /lib/scripting directory.
set ODI_CLASSPATH=%ODI_CLASSPATH%;%ODI_HOME%\drivers\.
for %%i in ("%ODI_HOME%\lib\*.zip") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\lib\%%~ni%%~xi
for %%i in ("%ODI_HOME%\lib\*.jar") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\lib\%%~ni%%~xi
for %%i in ("%ODI_HOME%\drivers\*.zip") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\drivers\%%~ni%%~xi
for %%i in ("%ODI_HOME%\drivers\*.jar") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\drivers\%%~ni%%~xi
for %%i in ("%ODI_HOME%\lib\scripting\*.zip") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\lib\scripting\%%~ni%%~xi
for %%i in ("%ODI_HOME%\lib\scripting\*.jar") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\lib\scripting\%%~ni%%~xi
for %%i in ("%ODI_HOME%\plugins\*.zip") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\plugins\%%~ni%%~xi
for %%i in ("%ODI_HOME%\plugins\*.jar") do call "%ODI_HOME%\bin\setpath.bat" %ODI_HOME%\plugins\%%~ni%%~xi
GOTO REPCONNECT

:WIN9X

rem Windows 95, 98, ME
set ODI_START_TITLE=
set ODI_CLASSPATH=%ODI_CLASSPATH%;%ODI_HOME%\lib\commons-discovery.jar;%ODI_HOME%\lib\commons-launcher.jar;%ODI_HOME%\lib\commons-logging.jar;%ODI_HOME%\lib\commons-net.jar;%ODI_HOME%\lib\jakarta-ant-optional.jar;%ODI_HOME%\lib\jaxrpc-api.jar;%ODI_HOME%\lib\jaxrpc-spi.jar;%ODI_HOME%\lib\jce1_2_2.jar;%ODI_HOME%\lib\local_policy.jar;%ODI_HOME%\lib\qname.jar;%ODI_HOME%\lib\saaj-impl.jar;%ODI_HOME%\lib\sunjce_provider.jar;%ODI_HOME%\lib\US_export_policy.jar;%ODI_HOME%\lib\wsdl4j.jar;%ODI_HOME%\lib\wsif-j2c.jar;%ODI_HOME%\lib\wsif.jar;%ODI_HOME%\lib\xercesImpl.jar;%ODI_HOME%\lib\xmlParserAPIs.jar
set ODI_CLASSPATH=%ODI_CLASSPATH%;%ODI_HOME%\drivers\.;%ODI_HOME%\drivers\snpsdb2.jar;%ODI_HOME%\drivers\jconn2.jar;%ODI_HOME%\drivers\mysql-connector-java-3.0.16-ga-bin.jar;%ODI_HOME%\drivers\postgresql-8.0.309.jdbc2ee.jar;%ODI_HOME%\drivers\ojdbc14.jar;%ODI_HOME%\drivers\jt400.zip;%ODI_HOME%\drivers\snpsxmlo.jar;%ODI_HOME%\drivers\snpsfile.jar;%ODI_HOME%\drivers\crimson.jar;%ODI_HOME%\drivers\xerces.jar;%ODI_HOME%\drivers\snpsldapo.jar
set ODI_CLASSPATH=%ODI_CLASSPATH%;%ODI_HOME%\lib\scripting\bsf.jar;%ODI_HOME%\lib\scripting\bsh-1.2b7.jar;%ODI_HOME%\lib\scripting\jython.jar;%ODI_HOME%\lib\scripting\js.jar
set ODI_CLASSPATH=%ODI_CLASSPATH%;%ODI_HOME%\plugins\.


:REPCONNECT
set ODI_CLASSPATH=%ODI_CLASSPATH%;%ODI_ADDITIONAL_CLASSPATH%;%ODI_JAVA_HOME%\lib\tools.jar
set ODI_JAVA_OPTIONS="-Djava.security.policy=server.policy"
set ODI_JAVAW_START=start %ODI_START_TITLE% "%ODI_JAVAW_EXE%" -Xms%ODI_INIT_HEAP% -Xmx%ODI_MAX_HEAP% -classpath "%ODI_CLASSPATH%" %ODI_JAVA_OPTIONS% %ODI_ADDITIONAL_JAVA_OPTIONS% 
set ODI_JAVA_START="%ODI_JAVA_EXE%" -Xms%ODI_INIT_HEAP% -Xmx%ODI_MAX_HEAP% -classpath "%ODI_CLASSPATH%" %ODI_JAVA_OPTIONS% %ODI_ADDITIONAL_JAVA_OPTIONS% 
set ODI_REPOSITORY_PARAMS="-SECU_DRIVER=%ODI_SECU_DRIVER%" "-SECU_URL=%ODI_SECU_URL%" "-SECU_USER=%ODI_SECU_USER%" "-SECU_PASS=%ODI_SECU_ENCODED_PASS%" "-WORK_REPOSITORY=%ODI_SECU_WORK_REP%" "-ODI_USER=%ODI_USER%" "-ODI_PASS=%ODI_ENCODED_PASS%"