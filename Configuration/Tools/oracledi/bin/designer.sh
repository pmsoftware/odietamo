#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  designer.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts Designer"
    echo
    echo "SYNTAX"
    echo "  . designer.sh"
    echo
else
    if [ "$ODI_HOME" = "" ]; then
        ODI_HOME=..
	export ODI_HOME
    fi
    . $ODI_HOME/bin/odiparams.sh

    echo "OracleDI: Starting Designer ..."
    $ODI_JAVA_START oracle.odi.Designer
fi