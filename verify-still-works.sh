#!/bin/sh
# fairing: prove a deploy did not remove something that used to work.
# Copyright RAYFINITE LLC. Author: Pradeep Singala Reddy. MIT.
#
#   ./verify-still-works.sh snapshot <base-url> <file.json>   # BEFORE deploying
#   ./verify-still-works.sh verify   <base-url> <file.json>   # AFTER deploying
#
# Snapshot records every route it can find, with status, title and body size.
# Verify re-checks all of them and fails if a route that used to work stopped
# working, or if a page lost most of its content.
#
# Written after a deploy from one repository silently removed a page served from
# a different repository into the same host project. Every check we had passed:
# the copy was clean, the links resolved, the build succeeded. Nothing compared
# the site to the site that existed a minute earlier.

set -eu
MODE="${1:-}"; BASE="${2:-}"; FILE="${3:-}"
case "$MODE" in snapshot|verify) ;; *)
  echo "usage: $0 snapshot|verify <base-url> <file.json>" >&2; exit 2 ;; esac
[ -n "$BASE" ] && [ -n "$FILE" ] || { echo "usage: $0 $MODE <base-url> <file.json>" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "error: python3 required" >&2; exit 2; }

python3 - "$MODE" "$BASE" "$FILE" <<'PY'
import json, re, sys, urllib.request, urllib.error, hashlib, os
from urllib.parse import urljoin, urlparse

mode, base, path = sys.argv[1], sys.argv[2].rstrip("/"), sys.argv[3]
HOST = urlparse(base).netloc

def get(url):
    req = urllib.request.Request(url, headers={
        "User-Agent": "fairing-verify-still-works",
        "Cache-Control": "no-cache",
    })
    try:
        with urllib.request.urlopen(req, timeout=25) as r:
            body = r.read()
            return r.status, body
    except urllib.error.HTTPError as e:
        return e.code, e.read() if e.fp else b""
    except Exception:
        return 0, b""

def title(body):
    m = re.search(rb"<title[^>]*>(.*?)</title>", body, re.S | re.I)
    return re.sub(r"\s+", " ", m.group(1).decode("utf-8", "replace")).strip()[:90] if m else ""

def discover():
    """Routes from sitemap, plus every same-host link on the homepage."""
    found = {"/"}
    st, sm = get(base + "/sitemap.xml")
    if st == 200:
        for loc in re.findall(rb"<loc>([^<]+)</loc>", sm):
            u = urlparse(loc.decode())
            if u.netloc in ("", HOST):
                found.add(u.path or "/")
    st, home = get(base + "/")
    if st == 200:
        for href in re.findall(rb'href="([^"#?]+)"', home):
            h = href.decode()
            if h.startswith(("mailto:", "tel:", "javascript:")):
                continue
            u = urlparse(urljoin(base + "/", h))
            if u.netloc == HOST and not re.search(r"\.(png|jpe?g|svg|ico|css|js|pdf|docx?|xml|txt|webp)$", u.path, re.I):
                found.add(u.path or "/")
    return sorted(found)

if mode == "snapshot":
    routes = discover()
    # Carry forward anything a previous snapshot knew about, so a route that is
    # temporarily unlinked is not quietly forgotten and then lost.
    if os.path.exists(path):
        try:
            for r in json.load(open(path))["routes"]:
                if r["path"] not in routes:
                    routes.append(r["path"])
        except Exception:
            pass
    out = []
    print(f"snapshotting {len(routes)} route(s) from {base}")
    for p in sorted(routes):
        st, body = get(base + p)
        out.append({"path": p, "status": st, "bytes": len(body), "title": title(body)})
        print(f"  {st}  {len(body):>8}  {p}")
    json.dump({"base": base, "routes": out}, open(path, "w"), indent=2)
    print(f"\nwrote {path}. Run 'verify' against the same file after deploying.")
    sys.exit(0)

# ---- verify ----
if not os.path.exists(path):
    print(f"error: {path} not found. Take a snapshot before deploying.", file=sys.stderr)
    sys.exit(2)
prev = json.load(open(path))
regressions, warnings = [], []
print(f"verifying {len(prev['routes'])} route(s) against {base}")
for r in prev["routes"]:
    st, body = get(base + r["path"])
    was, now = r["status"], st
    n_bytes = len(body)
    if was == 200 and now != 200:
        regressions.append(f"{r['path']}  was {was}, now {now}  ({r['title'] or 'no title'})")
    elif was == 200 and r["bytes"] > 2000 and n_bytes < r["bytes"] * 0.5:
        regressions.append(f"{r['path']}  lost {100 - int(100*n_bytes/r['bytes'])}% of its content ({r['bytes']} -> {n_bytes} bytes)")
    elif was == 200 and r["title"] and title(body) != r["title"]:
        warnings.append(f"{r['path']}  title changed: '{r['title']}' -> '{title(body)}'")
    print(f"  {now}  {n_bytes:>8}  {r['path']}")

print()
for w in warnings:
    print(f"  note: {w}")
if regressions:
    print(f"\nFAIL: {len(regressions)} route(s) regressed.")
    for x in regressions:
        print(f"  {x}")
    print("\nSomething that worked before this deploy does not work now.")
    sys.exit(1)
print("\nclean: every route that worked before still works.")
PY
