#!/bin/sh
# Render one cheatsheet SVG to PDF with the correct fonts.
#
# Two jobs the bare `svglinkify in.svg out.pdf` call cannot do alone:
#   1. Run the font preflight and FAIL LOUDLY before rendering, so a
#      missing font never silently substitutes (overflowing boxes).
#   2. Point Inkscape at a fontconfig that knows the Latin Modern name
#      aliases (the Homebrew Inkscape.app bundles its own fontconfig and
#      ignores ~/.config/fontconfig).
#
# Usage: render-pdf.sh <input.svg> <output.pdf>

set -eu

[ "$#" -eq 2 ] || { echo "usage: $0 <input.svg> <output.pdf>" >&2; exit 2; }
in="$1"; out="$2"

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
alias_conf="$repo/code/fontconfig/61-cheatsheet-aliases.conf"

# --- locate Inkscape's bundled fontconfig (macOS Homebrew cask) --------
ink=$(command -v inkscape || true)
[ -n "$ink" ] || { echo "FATAL: inkscape not found" >&2; exit 2; }
app_bin=$(grep -oE "/[^']+/MacOS/inkscape" "$ink" 2>/dev/null || true)
if [ -n "$app_bin" ]; then
    res=$(dirname "$(dirname "$app_bin")")/Resources
    app_fonts_conf="$res/etc/fonts/fonts.conf"
else
    app_fonts_conf=""   # Linux: system fontconfig already reads ~/.config
fi

# --- build a fontconfig that layers our aliases over the base config ---
override=$(mktemp /tmp/cheatsheet-fonts.XXXXXX.conf)
trap 'rm -f "$override"' EXIT
{
    echo '<?xml version="1.0"?>'
    echo '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">'
    echo '<fontconfig>'
    [ -n "$app_fonts_conf" ] && echo "  <include ignore_missing=\"yes\">$app_fonts_conf</include>"
    echo "  <include ignore_missing=\"no\">$alias_conf</include>"
    echo '</fontconfig>'
} > "$override"
FONTCONFIG_FILE="$override"
export FONTCONFIG_FILE

# --- preflight: loud failure on any substitution ----------------------
"$here/check-fonts.sh" "$in"

# --- render -----------------------------------------------------------
python3 "$repo/code/svglinkify/svglinkify.py" "$in" "$out"
