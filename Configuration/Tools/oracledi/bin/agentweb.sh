#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  agentweb.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts a web agent. See Oracle Data Integrator documentation for the "
    echo "  detailed syntax."
    echo
    echo "SYNTAX"
    echo "  . agentweb.sh [-PORT=<port>]  [-NAME=<agent name>] [-V=<trace level>] [-WEB_PORT=<http port>]"
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

    $ODI_JAVA_START oracle.odi.Agent $ODI_REPOSITORY_PARAMS -WEB_SERVER=1 -SCHEDULER=0 "$@"
fi