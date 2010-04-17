#!/bin/bash

###########################################################################
#
#   CONFIG
#   ------

# The path (relative to this script file) to the Rhino JAR:
RHINO=../lib/js.jar

# The path (relative to this script file) to the JSLint JS:
JSLINT=../lib/rhinoed_jslint.js

# The base of the test name that will be reported in Hudson:
TEST_BASENAME="org.mikewest.static"

###########################################################################
#
#   SCRIPT (no touchies)
#   --------------------
#
SCRIPTPATH=`dirname ${0}`
RHINO="${SCRIPTPATH}/${RHINO}"
JSLINT="${SCRIPTPATH}/${JSLINT}"

if [ -a "${1}" ] && [ -d "${2}" ]; then

    TEMP=`mktemp -t jslintreport.XXXXXX` || {
        echo "FATAL: Couldn't create temp file for reports"
        exit 1
    }

    LINTEE=$1
    REPORT_ROOT=$2
    LINTEE_TYPE=`echo ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\2#'`
    LINTEE_BASENAME=`basename ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\1#'`
    TEST_BASENAME="${TEST_BASENAME}.jslint.${LINTEE_TYPE}.${LINTEE_BASENAME}"
    REPORT_FILENAME="${REPORT_ROOT}/${TEST_BASENAME}.xml"
    mkdir -p $REPORT_ROOT || {
        echo "FATAL: Couldn't create directory for reports"
        exit 1
    }

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

    LINT_TIME=`{ time java -jar ${RHINO} ${JSLINT} "${TOPARSE}" "${TODISPLAY}" 2>&1 1> "${TEMP}"; } 2>&1 | grep real | sed 's#.*m\(.*\)s#\1#'`
    LINT_RESULTS=$(<"${TEMP}")

    WAS_FAILURE=`cat "${TEMP}" | grep -v 'No problems found in'`
    rm ${TEMP}
    
    if [ "---${WAS_FAILURE}---" != "------" ]; then
        echo "<testsuite failures='1' time='${LINT_TIME}' errors='1' tests='1' skipped='0' name='${TEST_BASENAME}'>" > $REPORT_FILENAME
        echo "  <testcase time='${LINT_TIME}' name='testJSLint' classname='${TEST_BASENAME}'>" >> $REPORT_FILENAME
        echo "    <error message='${LINTEE_BASENAME} failed JSLint.'><![CDATA[${LINT_RESULTS}]]></error>" >> $REPORT_FILENAME
        echo "  </testcase>" >> $REPORT_FILENAME
        echo "</testsuite>" >> $REPORT_FILENAME
    else
        echo "<testsuite failures='0' time='${LINT_TIME}' errors='0' tests='1' skipped='0' name='${TEST_BASENAME}'>" > $REPORT_FILENAME
        echo "  <testcase time='${LINT_TIME}' name='testJSLint' classname='${TEST_BASENAME}'>" >> $REPORT_FILENAME
        echo "  </testcase>" >> $REPORT_FILENAME
        echo "</testsuite>" >> $REPORT_FILENAME
    fi
else
    echo "Usage: ${0} <file to lint> <path to reports>"
    exit 1
fi
