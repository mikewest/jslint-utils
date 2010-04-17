.PHONY:	all updatejslint ../rhinoed_jslint.js

all: updatejslint ../rhinoed_jslint.js

updatejslint:
	@curl -O http://www.JSLint.com/fulljslint.js

../rhinoed_jslint.js: fulljslint.js rhino.js
	@cat ./fulljslint.js ./rhino.js > ../rhinoed_jslint.js
