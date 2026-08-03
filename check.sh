#!/bin/sh
# fairing: mechanical checks for machine-generated tells.
# Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy. MIT.
#
# Usage:  ./check.sh <directory> [--include-comments]
# Exits non-zero on any finding, so it drops into CI without ceremony.
#
# Point it at BUILT OUTPUT, not source. Comments and script bodies are never
# rendered, so a source-level count is misleading in both directions.

set -eu
export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=UTF-8

DIR="${1:-}"
INCLUDE_COMMENTS="${2:-}"

if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
  echo "usage: $0 <built-output-directory> [--include-comments]" >&2
  exit 2
fi

FILLER='leverage|utilize|delve|seamless|elevate|unleash|revolutioniz|tapestry|testament to|fast-paced world|in conclusion|it is worth noting|at the end of the day|navigating the complexities'

# Paths listed in .fairing-ignore (one substring per line, # for comments)
# are skipped. Use it for files that legitimately quote the patterns: changelogs,
# style guides, vendored content, before/after documentation.
IGNORE_FILE="$DIR/.fairing-ignore"
[ -f "$IGNORE_FILE" ] || IGNORE_FILE=".fairing-ignore"

# A too-broad ignore pattern would silently disable the whole gate, which is the
# failure this tool exists to prevent. Refuse to run instead.
if [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r pat || [ -n "$pat" ]; do
    pat=$(printf '%s' "$pat" | tr -d '\r')
    case "$pat" in ''|\#*) continue ;; esac
    case "$pat" in
      .|/|.md|.html|.htm|.txt|.json|.xml)
        echo "error: ignore pattern '$pat' in $IGNORE_FILE would match everything." >&2
        echo "       That silently disables the gate. Use a specific path." >&2
        exit 2 ;;
    esac
  done < "$IGNORE_FILE"
fi

ignored() {
  [ -f "$IGNORE_FILE" ] || return 1
  while IFS= read -r pat || [ -n "$pat" ]; do
    pat=$(printf '%s' "$pat" | tr -d '\r')
    case "$pat" in ''|\#*) continue ;; esac
    case "$1" in *"$pat"*) return 0 ;; esac
  done < "$IGNORE_FILE"
  return 1
}

findings=0
scanned=0
skipped=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

# Strip HTML comments and <script>/<style> bodies so we test what a reader sees.
# JSON-LD is deliberately KEPT: crawlers read it, so it is user-facing.
prepare() {
  src="$1"; out="$2"
  case "$INCLUDE_COMMENTS" in
    --include-comments) cp "$src" "$out"; return ;;
  esac
  case "$src" in
    *.html|*.htm|*.xml|*.svg)
      if command -v python3 >/dev/null 2>&1; then
        python3 - "$src" "$out" <<'PYEOF'
import re, sys
raw = open(sys.argv[1], encoding="utf-8", errors="replace").read()
raw = re.sub(r"<!--.*?-->", " ", raw, flags=re.S)
# Decode dash entities. A reader sees &mdash; as an em dash; a checker that only
# looks for the literal character reports clean while the page is not.
for ent in (r"&mdash;", r"&#8212;", r"&#x2014;"):
    raw = re.sub(ent, "\u2014", raw, flags=re.I)
for ent in (r"&ndash;", r"&#8211;", r"&#x2013;"):
    raw = re.sub(ent, "\u2013", raw, flags=re.I)
# Keep application/ld+json: a crawler reads it, so it is user-facing.
def drop(m):
    return " " if "ld+json" not in (m.group(0)[:200].lower()) else m.group(0)
raw = re.sub(r"<(script|style)\b[^>]*>.*?</\1>", drop, raw, flags=re.S | re.I)
open(sys.argv[2], "w", encoding="utf-8").write(raw)
PYEOF
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

echo "fairing: checking $DIR"
echo

# -L follows symlinked files and directories. Without it a dist/ that symlinks
# its pages elsewhere is never scanned and reports clean.
# Piping into `while read` avoids word-splitting on paths containing spaces,
# which silently skipped dirty files in an earlier version of this script.
list_files() {
  find -L "$DIR" -type f \( -name '*.html' -o -name '*.htm' -o -name '*.md' \
    -o -name '*.txt' -o -name '*.json' -o -name '*.xml' -o -name '*.svg' \) 2>/dev/null
}

# ---- 1. Dashes -------------------------------------------------------------
echo "[1/2] em dash and separator en dash (literal and entity-encoded)"
hits=0
list_files | while IFS= read -r f; do
  if ignored "$f"; then echo "skip" >> "$tmp/skips"; continue; fi
  echo "x" >> "$tmp/scanned"
  prepare "$f" "$tmp/x"
  set +e
  n=$(grep -oEi '—|–|&mdash;|&ndash;|&#8212;|&#8211;|&#x2014;|&#x2013;' "$tmp/x" 2>/dev/null | wc -l | tr -d ' ')
  rc=$?
  set -e
  if [ "$rc" -gt 1 ]; then
    printf '  %-58s GREP ERROR rc=%s\n' "$f" "$rc"
    echo "1" >> "$tmp/dash"
  elif [ "${n:-0}" -gt 0 ]; then
    printf '  %-58s %s\n' "$f" "$n"
    echo "$n" >> "$tmp/dash"
  fi
done
if [ -f "$tmp/dash" ]; then
  total=$(awk '{s+=$1} END{print s+0}' "$tmp/dash")
  echo "  FAIL: $total occurrence(s) in rendered content"
  findings=$((findings + 1))
else
  echo "  pass"
fi
echo

# ---- 2. Filler vocabulary --------------------------------------------------
echo "[2/2] filler vocabulary (advisory)"
list_files | while IFS= read -r f; do
  case "$f" in *.json|*.xml|*.svg) continue ;; esac
  ignored "$f" && continue
  prepare "$f" "$tmp/x"
  set +e
  words=$(grep -oiE "$FILLER" "$tmp/x" 2>/dev/null | sort -u | tr '\n' ' ')
  set -e
  if [ -n "$words" ]; then
    printf '  %-58s %s\n' "$f" "$words"
    echo "1" >> "$tmp/filler"
  fi
done
if [ -f "$tmp/filler" ]; then
  echo "  NOTE: filler candidates in $(wc -l < "$tmp/filler" | tr -d ' ') file(s). Read them; do not bulk-replace."
  echo "        This check is ADVISORY and does not fail the build. A word list cannot"
  echo "        tell filler from correct usage: \"a platform deciding what to elevate\""
  echo "        is the literal verb, not padding. A gate that cries wolf gets bypassed,"
  echo "        and then nobody looks at the one that matters."
else
  echo "  pass"
fi
echo

scanned=$([ -f "$tmp/scanned" ] && wc -l < "$tmp/scanned" | tr -d ' ' || echo 0)
skipped=$([ -f "$tmp/skips" ] && wc -l < "$tmp/skips" | tr -d ' ' || echo 0)
echo "scanned $scanned file(s), $skipped ignored."

# Pointing CI at the wrong path must not look like success.
if [ "$scanned" -eq 0 ]; then
  echo "error: no files scanned. Wrong directory, or everything is ignored." >&2
  exit 2
fi

if [ "$findings" -gt 0 ]; then
  echo "fairing: $findings check(s) failed."
  echo "See STANDARD.md for what to write instead."
  exit 1
fi

echo "fairing: clean."
echo "The greps are the easy half. Now read it aloud."
exit 0
