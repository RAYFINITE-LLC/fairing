#!/bin/sh
# fairing: catch a rewritten heading that quietly changed what is being claimed.
# Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy. MIT.
#
# Usage:  ./verify-scope-kept.sh [dir]
#
# Rewriting a heading is normal. Dropping a QUALIFIER while you do it is not:
# "visible from space" and "visible from space with the naked eye" are different
# claims, and only one of them is false.
#
# This does NOT compare wording. Rephrasing is fine and expected. It compares
# scope-bearing tokens only: negations, universals, quantities, and the named
# qualifiers that decide whether a claim is true.

set -eu
DIR="${1:-.}"
command -v python3 >/dev/null 2>&1 || { echo "error: python3 required" >&2; exit 2; }

python3 - "$DIR" <<'PY'
import re, sys, glob, pathlib

root = sys.argv[1]

# Tokens that change WHAT is claimed rather than how it is worded.
SCOPE = r"""only|all|every|everyone|everybody|everything|each|none|nobody|no|not|
            never|always|most|any|anyone|average|typical|
            naked\s+eye|unaided|with(?:out)?\s+aid|per|exactly|
            at\s+least|at\s+most|more\s+than|less\s+than|
            \d+(?:\.\d+)?(?:\s*(?:percent|%|billion|million|thousand|hours?|days?|years?|glasses|seconds?))?"""
RX = re.compile(r"\b(?:" + SCOPE + r")\b", re.I | re.X)

def scope(s):
    return {m.group(0).lower().strip() for m in RX.finditer(s)}

bad = 0
checked = 0
for f in sorted(glob.glob(f"{root}/**/*.html", recursive=True)):
    t = pathlib.Path(f).read_text(errors="replace")
    cr = re.search(r'"claimReviewed"\s*:\s*"([^"]*)"', t)
    ti = re.search(r"<title>(.*?)</title>", t, re.S)
    if not cr or not ti:
        continue
    checked += 1
    claim, title = cr.group(1), re.sub(r"\s*\|.*$", "", ti.group(1)).strip()
    missing = scope(claim) - scope(title)
    if missing:
        bad += 1
        print(f"  SCOPE DROPPED: {f}")
        print(f"      claim: {claim}")
        print(f"      title: {title}")
        print(f"      title omits: {', '.join(sorted(missing))}")

print()
print(f"checked {checked} page(s) with a claimReviewed")
if bad:
    print(f"FAIL: {bad} title(s) omit a qualifier their own claim depends on.")
    print("Rephrasing is fine. Dropping a qualifier changes the claim.")
    sys.exit(1)
print("clean: every title carries the scope its claim carries.")
PY
