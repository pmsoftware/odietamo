#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  restartsession.sh"
    echo
    echo "DESCRIPTION"
    echo "  Resumes a session. See Oracle Data Integrator documentation for the detailed"
    echo "  syntax."
    echo
    echo "SYNTAX"
    echo "  . restartsession.sh <session_number> [-v=<trace_level>]"
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

    echo "OracleDI: Resuming session $1 ..."
    $ODI_JAVA_START oracle.odi.Agent $ODI_REPOSITORY_PARAMS ODI_START_SESS "$@"
fi