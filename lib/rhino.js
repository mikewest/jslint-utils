// rhino.js
// 2009-09-11: Based on Douglas Crockford's Rhino edition
//
// I've made a few changes, specifically the ability to parse
// one file, while displaying the name of another.
//

/*global JSLINT */
/*jslint rhino: true, strict: false, onevar: false, white: false, browser: true,
 laxbreak: true, undef: true, nomen: false, eqeqeq: true, plusplus: false, bitwise: true,regexp: true, newcap: true, immed: true */

(function (a) {
    var e, i, input, fileToParse, fileToDisplay, defaults;
    if (!a[0]) {
        print("Usage: jslint.js file.js [realfilename.js]");
        quit(1);
    }
    fileToParse     = a[ 0 ];
    fileToDisplay   = a[ 1 ] ? a[ 1 ] : a[ 0 ];
    input = readFile( fileToParse );
    if (!input) {
        print("jslint: Couldn't open file '" + fileToParse + "'.");
        quit(1);
    }
    defaults = {
        bitwise:    true,   //  Allow bitwise operators
        browser:    true,   //  Assume a browser ( http://www.JSLint.com/lint.html#browser )
        css:        true,   //  Tolerate CSS workarounds ( http://www.JSLint.com/lint.html#css )
        eqeqeq:     true,   //  Require `===` && `!==`
        immed:      true,   //  Immediate invocations must be wrapped in parens.
        laxbreak:   true,   //  Tolerate "sloppy" line breaks
        newcap:     true,   //  Require initial caps for constructors ( http://www.JSLint.com/lint.html#new )
        nomen:      false,  //  Allow dangling `_` in identifiers
        onevar:     false,  //  Allow multiple `var` statements.
        plusplus:   false,  //  Allow `++` and `--`
        regexp:     true,   //  Disallow `.` and `[^...]` in regex
        strict:     false,  //  Don't require `use strict;`
        undef:      true,   //  Disallow undeclared variables ( http://www.JSLint.com/lint.html#undefined )
        white:      false   //  Don't apply strict whitespace rules
    };

    if (!JSLINT(input, defaults)) {
        for (i = 0; i < JSLINT.errors.length; i += 1) {
            e = JSLINT.errors[i];
            if (e) {
                print('[' + fileToDisplay + '] Lint at line ' + e.line + ' character ' +
                        e.character + ': ' + e.reason);
                print((e.evidence || '').
                        replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1"));
                print('');
            }
        }
        quit(2);
    } else {
        print("jslint: No problems found in " + fileToDisplay);
        quit();
    }
}(arguments));
