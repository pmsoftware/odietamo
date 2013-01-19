#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  agentscheduler.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts a scheduler agent. See Oracle Data Integrator documentation for the "
    echo "  detailed syntax."
    echo
    echo "SYNTAX"
    echo "  . agentscheduler.sh [-PORT=<port>]  [-NAME=<agent name>] [-V=<trace level>]"
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

    $ODI_JAVA_START oracle.odi.Agent $ODI_REPOSITORY_PARAMS "$@"
fi