#!/bin/bash

###########################################################################
#
#   CONFIG
#   ------

# The path (relative to this script file) to the Rhino JAR:
RHINO=../lib/js.jar

# The path (relative to this script file) to the JSLint JS:
RHINO_JSLINT=../lib/rhinoed_jslint.js
NODE_JSLINT=../lib/node_jslint.js

###########################################################################
#
#   SCRIPT (no touchies)
#   --------------------
#
SCRIPTPATH=`dirname ${0}`
RHINO="${SCRIPTPATH}/${RHINO}"
RHINO_JSLINT="${SCRIPTPATH}/${RHINO_JSLINT}"
NODE_JSLINT="${SCRIPTPATH}/${NODE_JSLINT}"

if [ -a "$1" ]; then
    LINTEE=$1
    LINTEE_TYPE=`echo ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\2#'`
    LINTEE_BASENAME=`basename ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\1#'`

    if [ "${LINTEE_TYPE}" == "css" ]; then
        #
        #   For CSS files, prepend `@charset "UTF-8";`, write to a temp file
        #   and parse _that_ file rather than the original.  This is much simpler
        #   than stripping out the charset from each file when minimizing.
        #
        TOPARSE=`mktemp -t csslintreport.XXXXXX` || {
            echo "FATAL: Couldn't create temp file for reports"
            exit 1
        }
        awk -v PREPEND='@charset "UTF-8";' 'BEGIN {print PREPEND}{print}' ${LINTEE} > ${TOPARSE}
        TODISPLAY=$LINTEE
    else
        TOPARSE=$LINTEE
        TODISPLAY=$LINTEE
    fi

    if [ -n "`which node`" ]; then
        node ${NODE_JSLINT} "${TOPARSE}" "${TODISPLAY}"
    else
        java -jar ${RHINO} ${RHINO_JSLINT} "${TOPARSE}" "${TODISPLAY}"
    fi
else
    echo "Usage: ${0} <file to lint>"
    exit 1
fi
