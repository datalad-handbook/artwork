all: cheatsheet

cheatsheet: code/svglinkify/svglinkify.py pdf/datalad-cheatsheet.pdf src/datalad-cheatsheet_p1_plain.svg
	cp pdf/datalad-cheatsheet.pdf src

code/svglinkify/svglinkify.py:
	git submodule update --init code/svglinkify

clean:
	rm -rf pdf

# append second page SVG as additional prerequisite once
# available
pdf/datalad-cheatsheet.pdf: pdf/datalad-cheatsheet_p1.pdf
	pdftk $^ cat output $@

pdf/%.pdf: code/svglinkify/svglinkify.py src/%.svg
	mkdir -p pdf
	code/render-pdf.sh src/$*.svg $@

# convert all texts to paths for browser-independent preview in handbook
src/datalad-cheatsheet_p1_plain.svg: src/datalad-cheatsheet_p1.svg
	inkscape $^ --export-plain-svg=$@ --export-text-to-path

.PHONY: all cheatsheet clean
