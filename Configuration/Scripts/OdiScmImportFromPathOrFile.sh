#!/bin/ksh

# *************************************************************
SetDateTimeStrings () {
# *************************************************************
	#
	# Define unique file name suffixes.
	#
	typeset FN="SetDateTimeStrings"
	typeset IM="$FN: INFO:"
	typeset EM="$FN: ERROR:"
	YYYYMMDD=$(date +%Y%m%d)
	HHMMSS=$(date +%H%M%S)
	return 0
}
# *************************************************************
ImportObject () {
# *************************************************************
	typeset FN="ImportObject"
	typeset IM="$FN: INFO:"
	typeset EM="$FN: ERROR:"

	echo "$IM starts"
	echo "$IM importing non-container type object from file <$1>"
	echo "$IM datetime is $(date +%d/%m/%Y) $(date +%H:%M:%S)"
	cd $ODI_BIN_DIR

	./startcmd.sh OdiImportObject -FILE_NAME=$1 -IMPORT_MODE=SYNONYM_INSERT_UPDATE -WORK_REP_NAME=WORKREP
	if [ $? -gt 0 ]
	then
		echo "$EM cannot import file <$1>"
		ERROROCCURED=TRUE
		return 1
	fi
	echo "$IM ends"
	return 0
}
# *************************************************************
ImportContainerObject () {
# *************************************************************
	typeset FN="ImportContainerObject"
	typeset IM="$FN: INFO:"
	typeset EM="$FN: ERROR:"

	echo "$IM starts"
	echo "$IM importing container type object from file <$1>"
	echo "$IM datetime is $(date +%d/%m/%Y) $(date +%H:%M:%S)"
	cd $ODI_BIN_DIR

	#
	# We try update first so that if there's nothing to update the operation is fairly quick.
	#
	echo "$IM trying SYNONYNM_UPDATE import mode"
	./startcmd.sh OdiImportObject -FILE_NAME=$1 -IMPORT_MODE=SYNONYM_UPDATE
	if [ $? -gt 0 ]
	then
		echo "$EM cannot import file <$1>"
		ERROROCCURED=TRUE
		return 1
	fi
	#
	# The insert should do nothing and return exit status of 0 if the object already exists.
	#
	echo "$IM trying SYNONYM_INSERT import mode"
	./startcmd.bat OdiImportObject -FILE_NAME=$1 -IMPORT_MODE=SYNONYM_INSERT
	if [ $? -gt 0 ]
	then
		echo "$EM cannot import file <$1>"
		ERROROCCURED=TRUE
		return 1
	fi
	echo "$IM ends"
	return 0
}

#
# Entry point.
#
PROG="OdiImportFromFileOrPath.sh"
IM="$PROG: INFO:"
EM="$PROG: ERROR:"

echo "$IM starts"

if [ "$1" = "" ]
then
	echo "$EM no argument for code directory root parameter supplied"
	echo "$IM usage: $PROG <ODI source code root directory> <ODI bin directory> [ODI source code object list file]"
	exit 1
fi

if [ "$2" = "" ]
then
	echo "$EM no argument for ODI bin directory parameter supplied"
	echo "$IM usage: $PROG <ODI source code root directory> <ODI bin directory> [ODI source code object list file]"
	exit 2
fi

IMPORT_DIR=$1

if [ ! -d "$IMPORT_DIR" ]
then
	echo "$EM import directory root <$IMPORT_DIR> does not exist"
	exit 3
fi

ODI_BIN_DIR=$2

if [ ! -d "$ODI_BIN_DIR" ]
then
	echo "$EM ODI bin directory <$ODI_BIN_DIR> does not exist"
	exit 3
fi

if [ ! -x "$ODI_BIN_DIR/startcmd.sh" ]
then
	echo "$EM ODI bin directory <$ODI_BIN_DIR> is invalid"
	echo "$EM it does not contain an executable 'startcmd.sh' shell script"
	exit 3
fi

if [ "$3" = "" ]
then
	#
	# Generate the list of files to import.
	#
	echo "$IM no object override list file passed. Looking for files at <$1>"
	OBJLISTDIR=/tmp/MOI/Logs
	mkdir $OBJLISTDIR >/dev/null 2>&1
	SetDateTimeStrings
	OBJLISTFILE=$OBJLISTDIR/OdiImportFromPathOrFile_FilesToImport_${YYYYMMDD}_${HHMMSS}.txt

	#
	# Master Repository objects first.
	#
	find "$IMPORT_DIR" -name '*.SnpTechno' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpConnect' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpPschema' >>$OBJLISTFILE 2>/dev/null
	#
	# SnpContext before SnpLschema because the SnpLschema files, not the
	# SnpConext files contain the SnpContext/SnpLschema/SnpPschema mappings
	# in our solution.
	#
	find "$IMPORT_DIR" -name '*.SnpContext' >>$OBJLISTFILE 2>/dev/null
	#
	# SnpContext before SnpLschema because the SnpLschema files, not the
	# SnpConext files contain the SnpContext/SnpLschema/SnpPschema mappings
	# in our solution.
	#
	find "$IMPORT_DIR" . -name '*.SnpLschema' >>$OBJLISTFILE 2>/dev/null
	#
	# Work Repository objects last.
	#
	#
	# Marker Groups can be global (used by model objects) or project specific
	# (used by project objects) so we need to do SnpProject objects (Projects)
	# first then the Marker Groups.
	#
	find "$IMPORT_DIR" -name '*.SnpProject' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpGrpState' >>$OBJLISTFILE 2>/dev/null
	#
	# We import all SnpTrt objects (Procedure/Knowledge Modules) here because
	# Models can rem use Knowledge Modules. As we're importing all of the SnpTrt
	# objects so we need to import the SnpProject (for Procedures and Knowledge Modules)
	# and SnpFolder objects (for Procedures) first. We also import the SnpVar (Variables)
	# at this point as they could be used in Knowledge Modules (even though they're loosely
	# coupled. I.e. there's not foreign key relationship in the repository data model).
	#
	find "$IMPORT_DIR" -name '*.SnpFolder' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpVar' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.Ufunc' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpTrt' >>$OBJLISTFILE 2>/dev/null
	#
	# Now the models.
	#
	find "$IMPORT_DIR" -name '*.SnpModFolder' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpModel' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpSubModel' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpTable' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpJoin' >>$OBJLISTFILE 2>/dev/null
	#
	# The the rest of the project contents.
	#
	find "$IMPORT_DIR" -name '*.SnpSequence' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpPop' >>$OBJLISTFILE 2>/dev/null
	find "$IMPORT_DIR" -name '*.SnpPackage' >>$OBJLISTFILE 2>/dev/null
	#
	# Finally Object/Marker relationships.
	#
	find "$IMPORT_DIR" -name '*.SnpObjState' >>$OBJLISTFILE 2>/dev/null
else
	#
	# We've been passed a file of objects to import.
	# This can be used to manually restart the import operation.
	#
	echo "$IM object override list file passed. Using file <$3>"
	if [ ! -r "$3" ]
	then
		echo "$EM object list file <$3> does not exist"
		exit 3
	fi
	OBJLISTFILE="$3"
fi

ERROROCCURED=N

cat $OBJLISTFILE | while read LINE
do
	IMPORTFILENOPATH=$(basename $LINE)
	IMPORTFILEPATH=$(dirname $LINE)
	IMPORTFILENAME=$(echo $IMPORTFILENOPATH | cut -f 1 -d.)
	IMPORTFILEEXT=$(echo $IMPORTFILENOPATH | cut -f 2 -d.)
	IMPORTFILENAME2=$(echo $IMPORTFILENOPATH | cut -f 3 -d.)
	IMPORTFILEEXT2=$(echo $IMPORTFILENOPATH | cut -f 4 -d.)
	
	if [ "$IMPORTFILEEXT2" = "" ]
	then
		echo "$IM importing file <$IMPORTFILENAME.$IMPORTFILEEXT> from path <$IMPORTFILEPATH>"
	else
		echo "$IM importing file <$IMPORTFILENAME.$IMPORTFILEEXT.$IMPORTFILENAME2.$IMPORTFILEEXT2> from path <$IMPORTFILEPATH>"
	fi

	if [ "$IMPORTFILEEXT2" = "" ]
	then
		case $IMPORTFILEEXT in
			SnpConnect|SnpModFolder|SnpModel|SnpSubModel|SnpProject|SnpFolder)
				CONTAINEROBJTYPE=TRUE
				;;
			*)
				CONTAINEROBJTYPE=FALSE
				;;
		esac
	else
		case $IMPORTFILEEXT2 in
			SnpConnect|SnpModFolder|SnpModel|SnpSubModel|SnpProject|SnpFolder)
				CONTAINEROBJTYPE=TRUE
				;;
			*)
				CONTAINEROBJTYPE=FALSE
				;;
		esac
	fi

	ERROROCCURED=FALSE

	if [ $CONTAINEROBJTYPE = TRUE ]
	then
		echo "$IM object type is a container"
		if [ "$IMPORTFILEEXT2" = "" ]
		then
			ImportContainerObject $IMPORTFILEPATH/$IMPORTFILENAME.$IMPORTFILEEXT
			if [ $? -ne 0 ]
			then
				ERROROCCURED=TRUE
			fi
		else
			ImportContainerObject $IMPORTFILEPATH/$IMPORTFILENAME.$IMPORTFILEEXT.$IMPORTFILENAME2.$IMPORTFILEEXT2
			if [ $? -ne 0 ]
			then
				ERROROCCURED=TRUE
			fi
		fi
	else
		echo "$IM object type is not a container"
		if [ "$IMPORTFILEEXT2" = "" ]
		then
			ImportObject $IMPORTFILEPATH/$IMPORTFILENAME.$IMPORTFILEEXT
			if [ $? -ne 0 ]
			then
				ERROROCCURED=TRUE
			fi
		else
			ImportObject $IMPORTFILEPATH/$IMPORTFILENAME.$IMPORTFILEEXT.$IMPORTFILENAME.$IMPORTFILEEXT
			if [ $? -ne 0 ]
			then
				ERROROCCURED=TRUE
			fi
		fi
	fi
	
	if [ $ERROROCCURED = TRUE ]
	then
		#
		# Abort the script immediately.
		#
		exit 1
	fi
done

echo "$IM successfully completed import of Work Repository objects"
echo "$IM successfully completed import process"
echo "$IM ends"
exit 0

# *************************************************************
# **                    S U B R O U T I N E S                **
# *************************************************************

