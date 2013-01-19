#!/bin/sh

stopdatabase()
{
    ODI_ANT_VERBOSE="-quiet -logfile /dev/null"
    if [ "$2" = "-verbose" ]; then
        ODI_ANT_VERBOSE=""
    fi
    if [ "$1" = "all" ]; then
        echo "OracleDI: Stopping Demo Environment ..."
        stopdatabase src $2
        stopdatabase trg $2
        stopdatabase repo $2
        echo "OracleDI: Demo Environment Stopped."
    elif [ "$1" = "repo" ]; then
        echo "OracleDI: Stopping Demo Repository Server ..."
        $ODI_JAVA_START -Dant.home=. org.apache.tools.ant.Main $ODI_ANT_VERBOSE -buildfile $ODI_HOME/demo/hsql/demo_repository_shutdown.xml
    elif [ "$1" = "src" ]; then
        echo "OracleDI: Stopping Demo Source Data Server ..."
        $ODI_JAVA_START -Dant.home=. org.apache.tools.ant.Main $ODI_ANT_VERBOSE -buildfile $ODI_HOME/demo/hsql/demo_src_shutdown.xml
    elif [ "$1" = "trg" ]; then
        echo "OracleDI: Stopping Demo Target Data Server ..."
        $ODI_JAVA_START -Dant.home=. org.apache.tools.ant.Main $ODI_ANT_VERBOSE -buildfile $ODI_HOME/demo/hsql/demo_trg_shutdown.xml
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
    echo "  stopdemo.sh"
    echo
    echo "DESCRIPTION"
    echo "  Stops the demonstration environment. See Oracle Data Integrator documentation"
    echo "  for more information."
    echo
    echo "SYNTAX"
    echo "  stopdemo.sh [ src | src | repo | all ] [-verbose]"
    echo "  default option list is 'all'"
    echo
else
    if [ "$ODI_HOME" = "" ]; then
        ODI_HOME=..
        export ODI_HOME
    fi
    . $ODI_HOME/bin/odiparams.sh

    if [ "`snps_lcase $1`" = "-verbose" ] || [ "`snps_lcase $2`" = "-verbose" ]; then
        P2="-verbose"
    else
        P2=""
    fi
    if [ "`snps_lcase $1`" != "" ] && [ "`snps_lcase $1`" != "-verbose" ] && [ "`snps_lcase $1`" != "all" ]; then
        P1=`snps_lcase $1`
    else
        P1="all"
    fi

    stopdatabase $P1 $P2

fi
