#!/bin/sh

startdatabase()
{

    if [ "$1" = "all" ]; then
        echo "OracleDI: Starting Demo Environment ..."
        echo
        startdatabase src &
        sleep 5
        startdatabase trg &
        sleep 5
        startdatabase repo $2 &
        sleep 5
        echo
        echo "OracleDI: Demo Environment Started. Run './stopdemo.sh all' to stop it."
    elif [ "$1" = "repo" ]; then
        echo "OracleDI: Starting Starting Demo Repository Server ($2) ..."
        $ODI_JAVA_START org.hsqldb.Server -database $ODI_HOME/demo/hsql/demo_repository_$2
    elif [ "$1" = "src" ]; then
        echo "OracleDI: Starting Demo Source Data Server ..."
        $ODI_JAVA_START org.hsqldb.Server -database $ODI_HOME/demo/hsql/demo_src -port 20001
    elif [ "$1" = "trg" ]; then
        echo "OracleDI: Starting Demo Target Data Server ..."
        $ODI_JAVA_START org.hsqldb.Server -database $ODI_HOME/demo/hsql/demo_trg -port 20002
    else
        echo "Invalid Parameters, type startdemo.sh -help for help .."
    fi
}

snps_lcase()
{
    echo $1 | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' \
         'abcdefghijklmnopqrstuvwxyz'
}

if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  startdemo.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts the demonstration environment. See Oracle Data Integrator documentation"
    echo "  for more information."
    echo
    echo "SYNTAX"
    echo "  startdemo.sh [ src | src | repo [<language code>] | all [<language code>] ]"
    echo "  default option list is 'all en'"
    echo "  Supported language codes : en (default), fr"
    echo
else
    if [ "$ODI_HOME" = "" ]; then
        ODI_HOME=..
        export ODI_HOME
    fi
    . $ODI_HOME/bin/odiparams.sh

    P1=`snps_lcase $1`
    if [ "$P1" = "" ]; then
        P1="all"
    fi
    if [ "`snps_lcase $2`" = "fr" ]; then
        P2="fr"
    else
        P2="en"
    fi

    startdatabase $P1 $P2

fi
