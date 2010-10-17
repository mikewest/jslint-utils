#!/bin/bash

#
# Using `run-jslint.sh`, we'll generate linting results in an XML format
# that's similar enough to JUnit to trick Hudson, et al. into accepting
# them as unit test results that can be rendered after every build.
#

# Config
# ------

#
# The path (relative to this script file) to the JSLint script:
#
JSLINT=./run-jslint.sh

#
# The base of the test name that will be reported in Hudson (this will
# expand to `${TEST_BASENAME}.jslint.[TYPE].[FILENAME]`, for example
# `org.mikewest.static.jslint.js.javascriptfilename1`):
#
TEST_BASENAME="org.mikewest.static"

# SCRIPT (no touchies)
# --------------------

#
# Store the current script's directory, and use it to generate paths to
# the JSLinting script (`run-jslint.sh`).
#
SCRIPTPATH=`dirname ${0}`
JSLINT="${SCRIPTPATH}/${JSLINT}"

#
# The script expects two arguments: the file to lint, and the path in
# which report XML files should be created.  If one or the other is
# missing, print usage info, and exit.
#
if [ ! -e "${1}" ] || [ ! -d "${2}" ]; then
    echo "Usage: ${0} <file to lint> <path to reports>"
    exit 1
#
# Otherwise...
#
else
    #
    # Generate a temporary report file.  We have to do a bit of bash
    # hackery to get the data we need: this file is part of that, slightly
    # dirty, but necessary.  If we can't generate the file, exit.
    #
    TEMP=`mktemp -t jslintreport.XXXXXX` || {
        echo "FATAL: Couldn't create temp file for reports"
        exit 1
    }

    #
    # Give the script's two arguments nicer names: `LINTEE` is the file
    # to be processed, `REPORT_ROOT` is, surprisingly enough, the directory
    # into which we'll stuff reports.
    #
    LINTEE=$1
    REPORT_ROOT=$2

    #
    # Process `LINTEE` to extract the file extension and basename.  We'll
    # use both to generate the test name that's displayed in Hudson.
    #
    LINTEE_TYPE=`echo ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\2#'`
    LINTEE_BASENAME=`basename ${LINTEE} | sed 's#\(.*\)\.\([^\.]*\)$#\1#'`

    #
    # Using the extension and basename, generate a test name in the form:
    # `[BASENAME].jslint.[EXTENSION].[BASENAME]`.  We'll use this to generate
    # a report XML file of the same name (`[REPORT ROOT]/[TEST NAME].xml`):
    #
    TEST_BASENAME="${TEST_BASENAME}.jslint.${LINTEE_TYPE}.${LINTEE_BASENAME}"
    REPORT_FILENAME="${REPORT_ROOT}/${TEST_BASENAME}.xml"

    #
    # The core; this is stunningly ugly.  So, let's break it down:
    #
    # We want the result of `run-jslint.sh [LINTEE]`.  So run that command, and
    # pipe all it's output (STDOUT/STDERR) into the temporary file we created
    # earlier (`TEMP`) for processing later on.
    #
    # We also, however, want to know how long the test took to run.  That's a
    # bit of a pain in the ass.  Running the previous command through `time`
    # will output the time info we want on STDERR.  But not the same STDERR
    # as the command itself, which means it won't be in the file we've just
    # filled with data.  The solution is to wrap the entire `time` call in
    # a subshell, and to process the _list's_ STDOUT.  Grep for "real" to
    # get the wallclock time, then `sed` out the seconds.
    #
    # What a mess.
    #
    LINT_TIME=`( time ${JSLINT} "${LINTEE}" 2>&1 1> "${TEMP}"; ) 2>&1 | grep real | sed 's#.*m\(.*\)s#\1#'`
    #
    # After all that, read the tempfile back into `LINT_RESULTS`.
    #
    LINT_RESULTS=$(<"${TEMP}")

    #
    # If the tempfile contains "No problems found in", then the test passed
    # without issue.  If not, failure!  Oh, the misery!
    #
    WAS_FAILURE=`cat "${TEMP}" | grep -v 'No problems found in'`

    #
    # And now we're completely finished with the temp file.  Kill it.
    #
    rm ${TEMP}
    
    #
    # If the test failed, write out a testsuite XML block into the
    # `REPORT_FILENAME`, and dump the error messages into a CDATA field.
    #
    if [ "---${WAS_FAILURE}---" != "------" ]; then
        echo "<testsuite failures='1' time='${LINT_TIME}' errors='1' tests='1' skipped='0' name='${TEST_BASENAME}'>" > $REPORT_FILENAME
        echo "  <testcase time='${LINT_TIME}' name='testJSLint' classname='${TEST_BASENAME}'>" >> $REPORT_FILENAME
        echo "    <error message='${LINTEE_BASENAME} failed JSLint.'><![CDATA[${LINT_RESULTS}]]></error>" >> $REPORT_FILENAME
        echo "  </testcase>" >> $REPORT_FILENAME
        echo "</testsuite>" >> $REPORT_FILENAME
    #
    # Otherwise, success!  Dump a testsuite XML block into the file
    # with 0 failures, and no `error` body.
    #
    else
        echo "<testsuite failures='0' time='${LINT_TIME}' errors='0' tests='1' skipped='0' name='${TEST_BASENAME}'>" > $REPORT_FILENAME
        echo "  <testcase time='${LINT_TIME}' name='testJSLint' classname='${TEST_BASENAME}'>" >> $REPORT_FILENAME
        echo "  </testcase>" >> $REPORT_FILENAME
        echo "</testsuite>" >> $REPORT_FILENAME
    fi
fi
