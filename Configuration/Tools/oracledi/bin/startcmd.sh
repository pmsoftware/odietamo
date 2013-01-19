#!/bin/sh
if [ "$1" = "-help" ] || [ "$1" =  "--help" ] || [ "$1" =  "-h" ]; then
    echo
    echo "(c) Copyright Oracle.  All rights reserved."
    echo
    echo "PRODUCT"
    echo "  Oracle Data Integrator"
    echo
    echo "FILENAME"
    echo "  startcmd.sh"
    echo
    echo "DESCRIPTION"
    echo "  Starts a Oracle Data Integrator command. See Oracle Data Integrator documentation for the detailed"
    echo "  syntax."
    echo
    echo "SYNTAX"
    echo "  . startcmd.sh <command_name> [<command_parameter>]*"
    echo
    echo "PREREQUISITES"
    echo "  Some commands require a repository connection."
    echo "  The REPOSITORY CONNECTION INFORMATION section of odiparams.sh "
    echo "  should be completed before running this script."
    echo
else
    if [ "$ODI_HOME" = "" ]; then
        ODI_HOME=..
        export ODI_HOME
    fi
    . $ODI_HOME/bin/odiparams.sh

    echo "OracleDI: Starting Command : $@ ..."
    for a in SnpsImportObject SnpsExportObject SnpsReinitializeSeq SnpsExportScen SnpsGenerateAllScen SnpsDeleteScen SnpsImportScen SnpsPingAgent SnpsPurgeLog SnpsReverseGetMetaData SnpsReverseResetTable SnpsReverseSetMetaData SnpsStartScen SnpsWaitForChildSession OdiImportObject OdiExportObject OdiReinitializeSeq OdiExportScen OdiGenerateAllScen OdiDeleteScen OdiImportScen OdiPingAgent OdiPurgeLog OdiReverseGetMetaData OdiReverseResetTable OdiReverseSetMetaData OdiStartScen OdiWaitForChildSession
    do
        if [ "x$a" = "x$1" ];
        then
            $ODI_JAVA_START com.sunopsis.dwg.tools."$@" -SECURITY_DRIVER=$ODI_SECU_DRIVER -SECURITY_URL=$ODI_SECU_URL -SECURITY_USER=$ODI_SECU_USER -SECURITY_PWD=$ODI_SECU_ENCODED_PASS -USER=$ODI_USER -PASSWORD=$ODI_ENCODED_PASS -WORK_REP_NAME=$ODI_SECU_WORK_REP
            exit $?
        fi
    done
    $ODI_JAVA_START com.sunopsis.dwg.tools."$@"
    exit $?
fi