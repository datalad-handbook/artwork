all: cheatsheet

cheatsheet: bin pdf/datalad-cheatsheet.pdf

bin: bin/svglinkify

bin/svglinkify:
	git submodule update --init code/svglinkify
	cd code/svglinkify && go build -o ../../bin/svglinkify

clean:
	rm -rf bin pdf

# append second page SVG as additional prerequisite once
# available
pdf/datalad-cheatsheet.pdf: pdf/datalad-cheatsheet_p1.pdf
	pdftk $^ cat output $@

pdf/%.pdf: bin/svglinkify src/%.svg
	mkdir -p pdf
	$^ $@

.PHONY: all cheatsheet clean
