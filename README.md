# The Datalad handbook's artwork :art:

This repository contains the sources for images used in
[the DataLad handbook](https://github.com/datalad-handbook/book).

## License

CC-BY-SA: You are free to

- **share** - copy and redistribute the material in any medium or format
- **adapt** - remix, transform, and build upon the material for any purpose, even commercially

under the following terms:

1) **Attribution** — You must give appropriate credit, provide a link to the license, and indicate
 if changes were made. You may do so in any reasonable manner, but not in any way that suggests
 the licensor endorses you or your use.

2) **ShareAlike** — If you remix, transform, or build upon the material, you must distribute your
 contributions under the same license as the original.

A number of illustrations are (adapted) open-source illustrations from
[undraw](https://undraw.co/). Please see the [LICENSE](./LICENSE) file
for details about the license they were shared under.

## Contributing to the DataLad Cheatsheet

If you are considering contributing to the DataLad Cheatsheet, you need the tool
[svglinkify](https://github.com/oxplot/svglinkify), included here as a git
submodule and run via ``make`` in the root of the repository. To contribute to
the cheatsheet, modify the corresponding ``.svg`` file and subsequently run
``make``.

### Build tools

The cheatsheet build (``make``) needs:

- **Python 3** — runs ``svglinkify`` (the submodule's ``svglinkify.py``)
- **Inkscape** (≥ 1.0) — SVG → PDF rasterization
- **qpdf** (provides ``qpdf`` and ``fix-qdf``) — ``svglinkify`` injects
  hyperlinks via a qpdf round-trip, yielding a spec-valid PDF
- **pdftk** *(optional)* — only needed to concatenate multiple pages

On macOS: ``brew install qpdf`` and ``brew install --cask inkscape``.

### Fonts

The cheatsheet SVG references specific fonts. **If any are missing,
Inkscape silently substitutes them and the rendered text overflows its
boxes.** The build runs ``code/check-fonts.sh`` as a preflight and
**fails loudly** listing any missing font before rendering.

Required font families:

| Family | Source (macOS) |
|--------|----------------|
| Inconsolata | ``brew install --cask font-inconsolata`` |
| Montserrat | ``brew install --cask font-montserrat`` *(see note)* |
| Montserrat Alternates | Google Fonts (static TTFs) |
| Latin Modern Sans (Demi Cond) | ``brew install --cask font-latin-modern`` + alias below |
| Droid Sans | Google "Droid Sans" (Apache 2.0); bundled with many JetBrains runtimes |
| DejaVu Sans | ``brew install --cask font-dejavu`` |

Notes:

- **Montserrat / Montserrat Alternates**: install the **static**
  weights (Regular/Medium/Bold). The variable-font cask registers as
  "Montserrat Thin" and Inkscape cannot match the requested weights.
- **Latin Modern Sans**: the GUST OTFs register as ``LMSans10`` /
  ``LMSansDemiCond10``, but the SVG asks for "Latin Modern Sans (Demi
  Cond)". The fontconfig aliases in
  ``code/fontconfig/61-cheatsheet-aliases.conf`` bridge the names; the
  build applies them automatically via ``code/render-pdf.sh``.

Run the preflight standalone at any time:

```
code/check-fonts.sh src/datalad-cheatsheet_p1.svg
```
