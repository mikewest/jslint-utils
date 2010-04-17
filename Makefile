.PHONY:	all jslint csslint hudson cleanreports jsxml cssxml

SRC_ROOT=./test/src
REPORT_ROOT=./test/reports

all:	jslint csslint

jslint:
	@find $(SRC_ROOT) -name '*.js' -exec ./scripts/run-jslint.sh {} \;

csslint:
	@find $(SRC_ROOT) -name '*.css' -exec ./scripts/run-jslint.sh {} \;

hudson:	cleanreports jsxml cssxml

cleanreports:
	rm -rf $(REPORT_ROOT)

jsxml:
	@find $(SRC_ROOT) -name '*.js' -exec ./scripts/jslint-to-xml.sh {} $(REPORT_ROOT) \;

cssxml:
	@find $(SRC_ROOT) -name '*.css' -exec ./scripts/jslint-to-xml.sh {} $(REPORT_ROOT) \;
