#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  startscen.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts a scenario. See Oracle Data Integrator documentation for the detailed"
    echo "  syntax."
    echo
    echo "SYNTAX"
    echo "  . startscen.sh <name> <version> <context_code> [<log_level>] [-session_name=<session_name>] [-keywords=<keywords>] [-name=<agent_name>] [-v=<trace_level>] [<variable>=<value>]*"
    echo
    echo "PREREQUISITES"
    echo "  The REPOSITORY CONNECTION INFORMATION section of odiparams.sh "
    echo "  should be completed before running this script."
    echo
else
    if [ "$ODI_HOME" = "" ]; then
        ODI_HOME=..
        export ODI_HOME
    fi
    . $ODI_HOME/bin/odiparams.sh

    echo "OracleDI: Starting scenario $1 $2 in context $3 ..."
    $ODI_JAVA_START oracle.odi.Agent $ODI_REPOSITORY_PARAMS ODI_START_SCEN "$@"
fi