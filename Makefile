all: cheatsheet

cheatsheet: bin pdf/datalad-cheatsheet.pdf src/datalad-cheatsheet_p1_plain.svg
	cp pdf/datalad-cheatsheet.pdf src

bin: bin/svglinkify bin/svg_stack

bin/svglinkify:
	git submodule update --init code/svglinkify
	cd code/svglinkify && go build -o ../../bin/svglinkify

# put executable into bin to make clean rule apply
bin/svg_stack:
	cp code/svg_stack.py bin/svg_stack.py

clean:
	rm -rf bin pdf

# append second page SVG as additional prerequisite once
# available
pdf/datalad-cheatsheet.pdf: pdf/datalad-cheatsheet_p1.pdf
	pdftk $^ cat output $@

# potentially concatenate all SVG pages to one with svg_stack tool - append more
# files to prerequisites once available, and add src/datalad-cheatsheet_plain.svg
# to prerequisite of cheatsheet instead of src/datalad-cheatsheet_p1_plain.svg
# src/datalad-cheatsheet_plain.svg: bin/svg_stack.py src/datalad-cheatsheet_p1_plain.svg
# $< --direction=v $(filter-out $<,$^) > $@

pdf/%.pdf: bin/svglinkify src/%.svg
	mkdir -p pdf
	$^ $@

# convert all texts to paths for browser-independent preview in handbook
src/datalad-cheatsheet_p1_plain.svg: src/datalad-cheatsheet_p1.svg
	inkscape $^ --export-plain-svg=$@ --export-text-to-path

.PHONY: all cheatsheet clean
