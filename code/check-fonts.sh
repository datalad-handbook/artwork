#!/bin/sh
# Font-availability preflight for the DataLad cheatsheet build.
#
# Inkscape silently substitutes missing fonts (e.g. Verdana/DejaVu for
# Latin Modern Sans), producing a PDF whose text overflows its boxes.
# This check extracts every font-family the SVG requests, asks
# fontconfig (the same resolver Inkscape uses) whether each resolves to
# the real family, and FAILS LOUDLY if any would be substituted.
#
# Usage: check-fonts.sh <file.svg> [file2.svg ...]

set -eu

if [ "$#" -eq 0 ]; then
    echo "usage: $0 <file.svg> [...]" >&2
    exit 2
fi

command -v fc-match >/dev/null 2>&1 || {
    echo "FATAL: fc-match (fontconfig) not found; cannot verify fonts." >&2
    exit 2
}

# Generic CSS families that legitimately resolve to a system default.
is_generic() {
    case "$1" in
        sans-serif|serif|monospace|cursive|fantasy|system-ui) return 0 ;;
        *) return 1 ;;
    esac
}

# Determine the system's substitution fallback: whatever a family that
# cannot possibly exist resolves to. Any requested family that resolves
# to this same fallback (without being it) was silently substituted.
fallback=$(fc-match --format '%{family}' \
    "NoSuchFont-zzz-$$-does-not-exist" 2>/dev/null || true)

missing=""
checked=""

for svg in "$@"; do
    [ -f "$svg" ] || { echo "FATAL: no such SVG: $svg" >&2; exit 2; }

    fams=$(grep -oE "font-family:[^;\"}]*" "$svg" \
        | sed "s/font-family://; s/^[[:space:]]*//; s/[[:space:]]*$//" \
        | tr -d "'\"" | sort -u)

    for fam in $(printf '%s\n' "$fams" | tr ' ' '\037'); do
        fam=$(printf '%s' "$fam" | tr '\037' ' ')
        [ -z "$fam" ] && continue
        is_generic "$fam" && continue
        case " $checked " in *" $fam "*) continue ;; esac
        checked="$checked $fam"

        ret=$(fc-match --format '%{family}' "$fam" 2>/dev/null || true)
        # Substituted if it resolved to the generic fallback while not
        # actually being that fallback family itself.
        if [ "$ret" = "$fallback" ] && [ "$fam" != "$fallback" ]; then
            printf '  [MISS] %-30s -> %s\n' "$fam" "$ret"
            missing="$missing|$fam"
        else
            printf '  [ ok ] %-30s -> %s\n' "$fam" "$ret"
        fi
    done
done

if [ -n "$missing" ]; then
    echo
    echo '############################################################'
    echo '##  FONT CHECK FAILED — missing fonts will be SUBSTITUTED  ##'
    echo '##  The rendered cheatsheet will look wrong (overflowing   ##'
    echo '##  boxes, mismatched metrics). Install these fonts:       ##'
    echo '############################################################'
    printf '%s\n' "$missing" | tr '|' '\n' | grep -v '^$' | sed 's/^/    - /'
    echo
    exit 1
fi

echo "All requested fonts are available (no substitution)."
