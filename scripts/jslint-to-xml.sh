#!/bin/bash

###########################################################################
#
#   CONFIG
#   ------

# The path (relative to this script file) to the JSLint script:
JSLINT=./run-jslint.sh

# The base of the test name that will be reported in Hudson:
TEST_BASENAME="org.mikewest.static"

###########################################################################
#
#   SCRIPT (no touchies)
#   --------------------
#
SCRIPTPATH=`dirname ${0}`
JSLINT="${SCRIPTPATH}/${JSLINT}"

if [ -a "${1}" ] && [ -d "${2}" ]; then
    TEMP=`mktemp -t jslintreport.XXXXXX` || {
        echo "FATAL: Couldn't create temp file for reports"
        exit 1
    }

    LINTEE=$1
    REPORT_ROOT=$2

    # @TODO:    Extract these into some sort of nice function
    LINTEE_TYPE=`echo ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\2#'`
    LINTEE_BASENAME=`basename ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\1#'`

    TEST_BASENAME="${TEST_BASENAME}.jslint.${LINTEE_TYPE}.${LINTEE_BASENAME}"
    REPORT_FILENAME="${REPORT_ROOT}/${TEST_BASENAME}.xml"

    LINT_TIME=`{ time ${JSLINT} "${LINTEE}" 2>&1 1> "${TEMP}"; } 2>&1 | grep real | sed 's#.*m\(.*\)s#\1#'`
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
