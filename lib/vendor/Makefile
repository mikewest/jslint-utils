.PHONY:	all updatejslint ../rhinoed_jslint.js ../node_jslint.js

all: updatejslint ../rhinoed_jslint.js ../node_jslint.js

fork:	updateforkedjslint ../rhinoed_jslint.js ../node_jslint.js

updateforkedjslint:
	@curl -O http://github.com/mikewest/jslint/raw/master/fulljslint.js

updatejslint:
	@curl -O http://www.JSLint.com/fulljslint.js

../rhinoed_jslint.js: fulljslint.js ../rhino.js
	@cat ./fulljslint.js ../rhino.js > ../rhinoed_jslint.js

../node_jslint.js: fulljslint.js ../node.js
	@cat ./fulljslint.js ../node.js > ../node_jslint.js
