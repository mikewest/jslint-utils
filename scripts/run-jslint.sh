#!/bin/bash

# Lints a specified file, using either [Rhino][r] or [Node.js][n] as
# an engine.  You'll need to ensure that one or the other is
# installed on any machine on which you'd like to lint.
#
# Rhino is included as part of this package (`./lib/js.jar`), so that
# realy boils down to either installing Node, or Java.  Node will be
# _much_ faster...
#
# [r]: http://www.mozilla.org/rhino/
# [n]: http://nodejs.org/

# Config
# ------

# The path (relative to this script file) to the Rhino JAR:
RHINO=../lib/js.jar

# The path (relative to this script file) to the JSLint JS files for Rhino:
RHINO_JSLINT=../lib/rhinoed_jslint.js
# and Node:
NODE_JSLINT=../lib/node_jslint.js

# Script (No touchies)
# --------------------

#
# Store the current script's directory, and use it to generate paths to
# Rhino and the two JSLinting instances.
#
SCRIPTPATH=`dirname ${0}`
RHINO="${SCRIPTPATH}/${RHINO}"
RHINO_JSLINT="${SCRIPTPATH}/${RHINO_JSLINT}"
NODE_JSLINT="${SCRIPTPATH}/${NODE_JSLINT}"

#
# Write out usage information if we don't have a file to work with.
#
if [ ! -e "$1" ]; then
    echo "Usage: ${0} <file to lint>"
    exit 1
#
# Assuming we _do_ have a file, then store the filename, and parse
# out the file extension.  We'll use that in a moment to determine
# how we process the file.
#
else
    LINTEE=$1
    LINTEE_TYPE=`echo "${LINTEE}" | sed 's#\(.*\)\.\([^\.]*\)$#\2#'`

    #
    # For CSS files, prepend `@charset "UTF-8";`, write to a temp file
    # and parse _that_ file rather than the original.  This is much simpler
    # than stripping out the charset from each file when minimizing (It
    # made sense at the time, anyway...).
    #
    if [ "${LINTEE_TYPE}" == "css" ]; then
        TOPARSE=`mktemp -t csslintreport.XXXXXX` || {
            echo "FATAL: Couldn't create temp file for reports"
            exit 1
        }
        awk -v PREPEND='@charset "UTF-8";' 'BEGIN {print PREPEND}{print}' "${LINTEE}" > "${TOPARSE}"
        TODISPLAY=$LINTEE
    #
    # For everything else (that is, JavaScript, because what else is
    # there?) run against the file itself.
    #
    else
        TOPARSE=$LINTEE
        TODISPLAY=$LINTEE
    fi

    #
    # We've got all the information we need: Now we need to decide
    # which engine we use.  If `node` exists, use it.  It's amazingly
    # fast.  Much, much, much faster than Rhino.
    #
    if [ -n "`which node`" ]; then
        node "${NODE_JSLINT}" "${TOPARSE}" "${TODISPLAY}"
    #
    # Fallback to Rhino if we have to.  Even though it's ugly and
    # slow and makes babies cry.
    #
    else
        java -jar "${RHINO}" "${RHINO_JSLINT}" "${TOPARSE}" "${TODISPLAY}"
    fi
fi
