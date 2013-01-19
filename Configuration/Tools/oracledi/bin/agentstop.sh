#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  agentstop.sh"
    echo
    echo "DESCRIPTION"
    echo "  Stops an agent. See Oracle Data Integrator documentation for the detailed"
    echo "  syntax."
    echo
    echo "SYNTAX"
    echo "  . agentstop.sh [-port=<port>]"
    echo
else
    if [ "$ODI_HOME" = "" ]; then
        ODI_HOME=..
        export ODI_HOME
    fi
    . $ODI_HOME/bin/odiparams.sh

    echo "OracleDI: Stopping Agent ..."
    $ODI_JAVA_START com.sunopsis.dwg.dbobj.SnpAgent "$@"
fi