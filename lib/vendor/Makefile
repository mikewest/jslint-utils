.PHONY:	all updatejslint updateforkedjslint updatejshint updatecsslint ../rhinoed_lint.js

all: updatejslint updatejshint updatecsslint ../node_lint.js ../rhinoed_lint.js

updateforkedjslint:
	@curl -o jslint.js http://github.com/mikewest/jslint/raw/master/fulljslint.js

updatejslint:
	@curl -O http://www.JSLint.com/jslint.js

updatejshint:
	@curl -O https://raw.github.com/jshint/jshint/master/jshint.js
	@cp jshint.js ../jshint.js

updatecsslint:
	@curl -O https://raw.github.com/stubbornella/csslint/master/release/csslint.js
	@cp jshint.js ../jshint.js

../rhinoed_lint.js:
	@curl -o ../jshint-rhino.js https://raw.github.com/jshint/jshint/master/env/jshint-rhino.js
	@curl -o ../csslint-rhino.js https://raw.github.com/stubbornella/csslint/master/release/csslint-rhino.js
