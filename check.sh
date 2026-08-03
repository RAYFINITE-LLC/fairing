#!/bin/sh
# hand-finished: mechanical checks for machine-generated tells.
# Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy. MIT.
#
# Usage:  ./check.sh <directory> [--include-comments]
# Exits non-zero on any finding, so it drops into CI without ceremony.
#
# Point it at BUILT OUTPUT, not source. Comments and script bodies are never
# rendered, so a source-level count is misleading in both directions.

set -eu

DIR="${1:-}"
INCLUDE_COMMENTS="${2:-}"

if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
  echo "usage: $0 <built-output-directory> [--include-comments]" >&2
  exit 2
fi

FILLER='leverage|utilize|delve|seamless|elevate|unleash|revolutioniz|tapestry|testament to|fast-paced world|in conclusion|it is worth noting|at the end of the day|navigating the complexities'

# Paths listed in .hand-finished-ignore (one substring per line, # for comments)
# are skipped. Use it for files that legitimately quote the patterns: changelogs,
# style guides, vendored content, before/after documentation.
IGNORE_FILE="$DIR/.hand-finished-ignore"
[ -f "$IGNORE_FILE" ] || IGNORE_FILE=".hand-finished-ignore"

ignored() {
  [ -f "$IGNORE_FILE" ] || return 1
  while IFS= read -r pat; do
    case "$pat" in ''|\#*) continue ;; esac
    case "$1" in *"$pat"*) return 0 ;; esac
  done < "$IGNORE_FILE"
  return 1
}

findings=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

# Strip HTML comments and <script>/<style> bodies so we test what a reader sees.
# python3 is used when available; without it we fall back to raw text and say so.
prepare() {
  src="$1"; out="$2"
  case "$INCLUDE_COMMENTS" in
    --include-comments) cp "$src" "$out"; return ;;
  esac
  case "$src" in
    *.html|*.htm|*.xml|*.svg)
      if command -v python3 >/dev/null 2>&1; then
        python3 - "$src" "$out" <<'PY'
import re, sys
raw = open(sys.argv[1], encoding="utf-8", errors="replace").read()
raw = re.sub(r"<!--.*?-->", " ", raw, flags=re.S)
raw = re.sub(r"<(script|style)\b[^>]*>.*?</\1>", " ", raw, flags=re.S | re.I)
open(sys.argv[2], "w", encoding="utf-8").write(raw)
PY
      else
        cp "$src" "$out"
      fi
      ;;
    *) cp "$src" "$out" ;;
  esac
}

if ! command -v python3 >/dev/null 2>&1; then
  echo "note: python3 not found, so HTML comments and scripts are NOT stripped."
  echo "      Expect false positives from commented-out markup."
  echo
fi

echo "hand-finished: checking $DIR"
echo

# ---- 1. Dashes -------------------------------------------------------------
# -E is required. The GNU \| alternation spelling finds NOTHING on BSD grep
# (macOS) and exits clean on every file, so the check would always pass.
echo "[1/2] em dash and separator en dash"
hits=0
for f in $(find "$DIR" -type f \( -name '*.html' -o -name '*.htm' -o -name '*.md' -o -name '*.txt' -o -name '*.json' -o -name '*.xml' \) 2>/dev/null); do
  ignored "$f" && continue
  prepare "$f" "$tmp/x"
  if grep -qE '—|–' "$tmp/x" 2>/dev/null; then
    n=$(grep -oE '—|–' "$tmp/x" | wc -l | tr -d ' ')
    printf '  %-58s %s\n' "$f" "$n"
    hits=$((hits + n))
  fi
done
if [ "$hits" -gt 0 ]; then
  echo "  FAIL: $hits occurrence(s) in rendered content"
  findings=$((findings + 1))
else
  echo "  pass"
fi
echo

# ---- 2. Filler vocabulary --------------------------------------------------
echo "[2/2] filler vocabulary"
fhits=0
for f in $(find "$DIR" -type f \( -name '*.html' -o -name '*.htm' -o -name '*.md' -o -name '*.txt' \) 2>/dev/null); do
  ignored "$f" && continue
  prepare "$f" "$tmp/x"
  words=$(grep -oiE "$FILLER" "$tmp/x" 2>/dev/null | sort -u | tr '\n' ' ' || true)
  if [ -n "$words" ]; then
    printf '  %-58s %s\n' "$f" "$words"
    fhits=$((fhits + 1))
  fi
done
if [ "$fhits" -gt 0 ]; then
  echo "  FAIL: filler found in $fhits file(s)"
  findings=$((findings + 1))
else
  echo "  pass"
fi
echo

if [ "$findings" -gt 0 ]; then
  echo "hand-finished: $findings check(s) failed."
  echo "See STANDARD.md for what to write instead."
  exit 1
fi

echo "hand-finished: clean."
echo "The greps are the easy half. Now read it aloud."
exit 0
