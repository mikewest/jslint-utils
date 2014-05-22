JSLint Utils
============

This is a set of utility files that wraps JSLint/Rhino, enabling easy
linting on the command line, and automated reporting of linting errors
via a continuous integration system like Hudson.

## Dependencies:
*  [node] npm packages
   *  [node] jshint
   *  [node] csslint

Usage
-----

You can either modify the `Makefile` directly to point to proper source and
report directories, and then run:

*   `make` to check everything with a `.js` or `.css` extension in the
    source directory, outputting errors to the command line.

*   `make jslint` or `make csslint` to lint JS or CSS, respectively,
    outputting errors to the command line

*   `make hudson` to lint JS and CSS, outputting errors in an XML format
    that Hudson can understand to the report directory

*   `make jsxml` or `make cssxml` to lint JS or CSS, respectively, outputting
    errors in XML format to the report directory

Or, if you're feeling saucy, you can use `./scripts/run-jslint.sh` to run
JSLint directly, outputting errors to the command line:

    ./scripts/run-jslint <file to lint>

And `./scripts/jslint-to-xml.sh` to run JSLint, outputting errors in XML
format to a directory you specify:

    ./scripts/jslint-to-xml.sh <file to lint> <report directory>

Enjoy!  Report bugs!

---

(You can update the version of JSLint by diving into the `./lib/vendor`
directory, and typing `make`.  Crockford updates the file silently all
the time.)
