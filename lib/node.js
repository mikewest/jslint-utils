// v8.js
// 2009-09-11: Based on Douglas Crockford's Rhino edition
//
// I've made a few changes, specifically the ability to parse
// one file, while displaying the name of another.
//

/*global JSLINT */
/*jslint rhino: true, strict: false, onevar: false, white: false, browser: true,
 laxbreak: true, undef: true, nomen: false, eqeqeq: true, plusplus: false, bitwise: true,regexp: true, newcap: true, immed: true */

(function ( argv ) {
    var e, i, input, fileToParse, fileToDisplay, defaults,
        sys = require( "sys" ),
        fs  = require( "fs" );
        
    argv.shift();   // drop "node"
    argv.shift();   // drop this script's name

    if ( !argv[ 0 ] ) {
        sys.puts("Usage: jslint.js file.js [realfilename.js]");
        process.exit( 1 );
    }
    
    fileToParse     = argv[ 0 ];
    fileToDisplay   = argv[ 1 ] ? argv[ 1 ] : argv[ 0 ];

    input = fs.readFile( fileToParse, function ( err, data ) {
        if ( err || !data ) {
            sys.puts("jslint: Couldn't open file '" + fileToParse + "'.");
            process.exit(1);
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

        if ( !JSLINT( data.toString(), defaults ) ) {
            for ( i = 0, numErrors = JSLINT.errors.length; i < numErrors; i += 1 ) {
                e = JSLINT.errors[ i ];
                if ( e ) {
                    sys.puts(
                        '[' + fileToDisplay + '] Lint at line ' + e.line + ' character ' +
                        e.character + ': ' + e.reason
                    );
                    sys.puts(
                        ( e.evidence || '' ).replace( /^\s+|\s+$/, "" )
                    );
                }
            }
            process.exit( 2 );
        } else {
            sys.puts("jslint: No problems found in " + fileToDisplay);
            process.exit( 0 );
        }
    } );
}( process.ARGV ) );
