#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  agent.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts an agent. See Oracle Data Integrator documentation for the detailed"
    echo "  syntax."
    echo
    echo "SYNTAX"
    echo "  . agent.sh [-port=<port>] [-name=<agent name>] [-v=<trace level>]"
    echo
else
    if [ "$ODI_HOME" = "" ]; then
        ODI_HOME=..
        export ODI_HOME
    fi
    . $ODI_HOME/bin/odiparams.sh

    $ODI_JAVA_START oracle.odi.Agent "$@"
fi