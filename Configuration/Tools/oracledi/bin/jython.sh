#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  jython.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts a Jython Console. See Oracle Data Integrator documentation for Jython"
    echo "  information."
    echo
    echo "SYNTAX AND PARAMETERS"
    echo
    ARGS="--help"
else
    ARGS="$@"
    echo "OracleDI: Starting Jython ..."
fi
if [ "$ODI_HOME" = "" ]; then
    ODI_HOME=..
    export ODI_HOME
fi

. $ODI_HOME/bin/odiparams.sh
$ODI_JAVA_START org.python.util.jython -Dpython.home=$ODI_HOME/lib/scripting $ARGS
