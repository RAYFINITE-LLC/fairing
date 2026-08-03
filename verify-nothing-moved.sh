#!/bin/sh
# fairing: prove a copy edit changed punctuation and nothing else.
# Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy. MIT.
#
# Usage:  ./verify-nothing-moved.sh <git-ref> [dir]
#   e.g.  ./verify-nothing-moved.sh origin/main public
#
# Compares the WORD STREAM of every tracked HTML file against a git ref,
# ignoring punctuation, tags, comments and script bodies. Any word added,
# removed or reordered is a meaning change and fails.
#
# Run this BEFORE you commit a bulk copy edit, not after someone asks.

set -eu
REF="${1:-}"
DIR="${2:-.}"
[ -n "$REF" ] || { echo "usage: $0 <git-ref> [dir]" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "error: python3 required" >&2; exit 2; }

python3 - "$REF" "$DIR" <<'PY'
import re, subprocess, sys, pathlib, difflib
ref, root = sys.argv[1], sys.argv[2]

def words(html):
    h = re.sub(r"<!--.*?-->", " ", html, flags=re.S)
    h = re.sub(r"<(script|style)\b[^>]*>.*?</\1>", " ", h, flags=re.S | re.I)
    h = re.sub(r"&mdash;|&ndash;|&#8212;|&#8211;|&#x2014;|&#x2013;", " ", h, flags=re.I)
    h = re.sub(r"<[^>]+>", " ", h)
    h = re.sub(r"[^\w\s]", " ", h)
    return re.sub(r"\s+", " ", h).strip().lower().split()

listed = subprocess.run(["git", "ls-files", root], capture_output=True, text=True).stdout.split()
files = [f for f in listed if f.endswith((".html", ".htm"))]
if not files:
    print(f"error: no tracked HTML under {root}", file=sys.stderr); sys.exit(2)

bad = 0
for f in sorted(files):
    old = subprocess.run(["git", "show", f"{ref}:{f}"], capture_output=True, text=True)
    if old.returncode != 0:
        print(f"  new file (no baseline): {f}"); continue
    a, b = words(old.stdout), words(pathlib.Path(f).read_text(errors="replace"))
    if a == b:
        continue
    bad += 1
    print(f"  MEANING MOVED: {f}  ({len(a)} -> {len(b)} words)")
    for d in list(difflib.unified_diff(a, b, lineterm="", n=0))[:12]:
        if d.startswith(("+", "-")) and not d.startswith(("++", "--")):
            print(f"      {d}")

print()
print(f"checked {len(files)} file(s) against {ref}")
if bad:
    print(f"FAIL: {bad} file(s) changed more than punctuation.")
    print("A copy edit must not add, drop or reorder a word. Read each diff above.")
    sys.exit(1)
print("clean: punctuation only, no word added, dropped or reordered.")
PY
