#!/bin/sh
#
# Copyright (c) 2000-2005 Oracle.  All rights reserved.
#
# PRODUCT
#   Oracle Data Integrator
#
# FILENAME
#   odiparams.sh
#
# DESCRIPTION
#   Configuration script. This script contains the parameters for starting
#   Oracle Data Integrator modules.
#
# VARIABLES DESCRIPTION
#
# The following variables should be configured in order to run operations
# requiring a repository connection (startscen, agentscheduler, etc.)
#
#   ODI_SECU_DRIVER
#       JDBC driver used to connect the Master Repository.
#   ODI_SECU_URL
#       JDBC URL used to connect the Master Repository.
#   ODI_SECU_USER
#       Database account used to connect the Master Repository.
#   ODI_SECU_ENCODED_PASS
#       Database account password. The password must be encoded with the
#       "agent encode <password>" command.
#   ODI_SECU_WORK_REP
#       Name of the Work Repository to connect. This Work Repository must
#       be attached to the master repository.
#   ODI_USER
#       OracleDI user used to launch a scenario.
#   ODI_ENCODED_PASS
#       OracleDI user password. The password must be encoded with the
#       "agent encode <password>" command.
#
# The following variables can be changed to tune OracleDI configuration.
#
#   ODI_INIT_HEAP
#       Initial java machine heap size used by OracleDI modules.
#   ODI_MAX_HEAP
#       Maximum java machine heap size used by OracleDI modules.
#   ODI_JAVA_HOME
#       Installation directory of the java virtual machine used for
#       OracleDI.
#   ODI_ADDITIONAL_JAVA_OPTIONS
#       Additional Java options, such as -Duser.language or -Duser.country.
#   ODI_ADDITIONAL_CLASSPATH
#       Classpath for additional classes (HP-UX Only)
#   ODI_HOME
#       Set this environment variable separately. If it is unset, the script can
#       be launched only from the ./bin directory. If running the setup
#       program, this variable is automatically set.
#
# Other variables should be left unchanged.
#

#
# Repository Connection Information
#
ODI_SECU_DRIVER=org.hsqldb.jdbcDriver
ODI_SECU_URL=jdbc:hsqldb:hsql://localhost
ODI_SECU_USER=sa
ODI_SECU_ENCODED_PASS=
ODI_SECU_WORK_REP=WORKREP
ODI_USER=SUPERVISOR
ODI_ENCODED_PASS=LELKIELGLJMDLKMGHEHJDBGBGFDGGH

#
# Java virtual machine
#
if [ "$ODI_JAVA_HOME" = "" ]; then
    ODI_JAVA_HOME=$JAVA_HOME
fi
#
# Other Parameters
#
ODI_INIT_HEAP=32m
ODI_MAX_HEAP=256m

#
# Additional Java Options
#
ODI_ADDITIONAL_JAVA_OPTIONS=

# HP-UX users : Any package files added to the /drivers
# or /lib/scripting directory should be manually declared in the
# ODI_ADDITIONAL_CLASSPATH variable
ODI_ADDITIONAL_CLASSPATH=


# DO NOT EDIT BELOW THIS LINE !
# ----------------------------------------------------------------------------

ODI_JAVA_EXE=$ODI_JAVA_HOME/bin/java
ODI_JAVAW_EXE=$ODI_JAVA_HOME/bin/java
ODI_JAVAC_EXE=$ODI_JAVA_HOME/bin/javac

# Testing the java virtual machine

if [ ! -x $ODI_JAVA_EXE ]; then
  echo "The Java Virtual Machine was not found at the following location: $ODI_JAVA_HOME"
  echo "The ODI_JAVA_HOME environment variable is not defined correctly."
  echo "Please set this variable in odiparams.bat."
fi

if [ ! -x $ODI_JAVAC_EXE ]; then
  echo "A JDK is required to execute Web Services with OracleDI. You are currently using a JRE."
fi

if [ "$ODI_HOME" = "" ]; then
    ODI_HOME=..
    export ODI_HOME
fi

# default classpath, includes OracleDI packages
ODI_CLASSPATH=$ODI_HOME/lib/.:$ODI_HOME/lib/sunopsis.zip:$ODI_HOME/lib/snpshelp.zip:$ODI_HOME/lib/snpsws.zip:$ODI_HOME/lib/webservices

#
# Dynamic construction of the JDBC classpath
# To use a driver, you simply have to copy it to the drivers directory and
# it is automatically added to the classpath
#
ODI_CLASSPATH=$ODI_CLASSPATH:$ODI_HOME/drivers/.
for i in $ODI_HOME/lib/*.zip; do
  ODI_CLASSPATH=$ODI_CLASSPATH:$i
done
for i in $ODI_HOME/lib/*.jar; do
  ODI_CLASSPATH=$ODI_CLASSPATH:$i
done
for i in $ODI_HOME/lib/scripting/*.zip; do
  ODI_CLASSPATH=$ODI_CLASSPATH:$i
done
for i in $ODI_HOME/lib/scripting/*.jar; do
  ODI_CLASSPATH=$ODI_CLASSPATH:$i
done
for i in $ODI_HOME/drivers/*.zip; do
  ODI_CLASSPATH=$ODI_CLASSPATH:$i
done
for i in $ODI_HOME/drivers/*.jar; do
  ODI_CLASSPATH=$ODI_CLASSPATH:$i
done
for i in $ODI_HOME/plugins/*.jar; do
  ODI_CLASSPATH=$ODI_CLASSPATH:$i
done

if [ "$ODI_CLASSPATH" = "$ODI_HOME/lib/.:$ODI_HOME/lib/sunopsis.zip:$ODI_HOME/lib/snpshelp.zip:$ODI_HOME/lib/snpsws.zip" ]; then
  ODI_CLASSPATH=$ODI_CLASSPATH:$ODI_HOME/lib/commons-discovery.jar:$ODI_HOME/lib/commons-launcher.jar:$ODI_HOME/lib/commons-logging.jar:$ODI_HOME/lib/commons-net.jar:$ODI_HOME/lib/jakarta-ant-optional.jar:$ODI_HOME/lib/jaxrpc-api.jar:$ODI_HOME/lib/jaxrpc-spi.jar:$ODI_HOME/lib/jce1_2_2.jar:$ODI_HOME/lib/local_policy.jar:$ODI_HOME/lib/qname.jar:$ODI_HOME/lib/saaj-impl.jar:$ODI_HOME/lib/sunjce_provider.jar:$ODI_HOME/lib/US_export_policy.jar:$ODI_HOME/lib/wsdl4j.jar:$ODI_HOME/lib/wsif-j2c.jar:$ODI_HOME/lib/wsif.jar:$ODI_HOME/lib/xercesImpl.jar:$ODI_HOME/lib/xmlParserAPIs.jar
  ODI_CLASSPATH=$ODI_CLASSPATH:$ODI_HOME/drivers/.:$ODI_HOME/drivers/snpsdb2.jar:$ODI_HOME/drivers/jconn2.jar:$ODI_HOME/drivers/mysql-connector-java-3.0.16-ga-bin.jar:$ODI_HOME/drivers/postgresql-8.0.309.jdbc2ee.jar:$ODI_HOME/drivers/ojdbc14.jar:$ODI_HOME/drivers/jt400.zip:$ODI_HOME/drivers/snpsxmlo.jar:$ODI_HOME/drivers/snpsfile.jar:$ODI_HOME/drivers/crimson.jar:$ODI_HOME/drivers/xerces.jar:$ODI_HOME/drivers/snpsldapo.jar
  ODI_CLASSPATH=$ODI_CLASSPATH:$ODI_HOME/lib/scripting/bsf.jar:$ODI_HOME/lib/scripting/bsh-1.2b7.jar:$ODI_HOME/lib/scripting/jython.jar:$ODI_HOME/lib/scripting/js.jar
fi

ODI_CLASSPATH=$ODI_CLASSPATH:$ODI_ADDITIONAL_CLASSPATH:$ODI_JAVA_HOME/lib/tools.jar
ODI_JAVA_OPTIONS=-Djava.security.policy=server.policy
ODI_JAVAW_START="$ODI_JAVA_EXE -Xms$ODI_INIT_HEAP -Xmx$ODI_MAX_HEAP -classpath $ODI_CLASSPATH $ODI_JAVA_OPTIONS $ODI_ADDITIONAL_JAVA_OPTIONS"
ODI_JAVA_START="$ODI_JAVA_EXE -Xms$ODI_INIT_HEAP -Xmx$ODI_MAX_HEAP -classpath $ODI_CLASSPATH $ODI_JAVA_OPTIONS $ODI_ADDITIONAL_JAVA_OPTIONS"
ODI_REPOSITORY_PARAMS="-SECU_DRIVER=$ODI_SECU_DRIVER -SECU_URL=$ODI_SECU_URL -SECU_USER=$ODI_SECU_USER -SECU_PASS=$ODI_SECU_ENCODED_PASS -WORK_REPOSITORY=$ODI_SECU_WORK_REP -ODI_USER=$ODI_USER -ODI_PASS=$ODI_ENCODED_PASS"

export ODI_HOME
export ODI_JAVA_HOME ODI_JAVA_EXE ODI_JAVAW_EXE
export ODI_CLASSPATH
export ODI_SECU_DRIVER ODI_SECU_URL ODI_SECU_USER ODI_SECU_ENCODED_PASS ODI_SECU_WORK_REP ODI_USER ODI_ENCODED_PASS
export ODI_INIT_HEAP ODI_MAX_HEAP ODI_JAVA_OPTIONS
export ODI_JAVAW_START ODI_JAVA_START ODI_REPOSITORY_PARAMS