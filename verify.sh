#!/usr/bin/env bash
# Run with: ./verify.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"; SB="$ROOT/sandbox/clippy"
[ -d "$SB/.git" ] || { echo "Run ./setup.sh first"; exit 1; }
g() { git -C "$SB" "$@"; }
pass=0; failn=0
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }

echo "== Bisect =="
want=$(g rev-parse refs/lab/culprit 2>/dev/null | cut -c1-7)
got=$(tr -dc '0-9a-f' < "$ROOT/culprit.txt" 2>/dev/null | cut -c1-7)
check "culprit.txt names the commit that broke the tests"  test -n "$want" -a "$want" = "$got"
check "bisect session is finished (git bisect reset)"      test ! -e "$SB/.git/BISECT_START"

echo "== Rescue =="
check "the branch 'rescued' exists"                         g rev-parse --verify -q rescued
check "rescued has all three premium tier commits"          bash -c "[ \"\$(git -C '$SB' log rescued --format=%s | grep -c 'Add premium tier')\" = 3 ]"
check "rescued is based on main (nothing else dragged in)"  g merge-base --is-ancestor main rescued

echo "== Cherry-pick =="
check "release/1.0 contains the whitespace fix"             bash -c "git -C '$SB' log release/1.0 --format=%s | grep -q 'fix: strip whitespace'"
check "release/1.0 does NOT contain the WIP commits"        bash -c "! git -C '$SB' log release/1.0 --format=%s | grep -q WIP"
check "the fix on release/1.0 is a new commit (new hash)"   bash -c "a=\$(git -C '$SB' log release/1.0 --format='%H %s' | grep 'fix: strip whitespace' | cut -d' ' -f1); b=\$(git -C '$SB' log develop --format='%H %s' | grep 'fix: strip whitespace' | cut -d' ' -f1); [ -n \"\$a\" ] && [ \"\$a\" != \"\$b\" ]"
check "develop was not changed"                             bash -c "[ \"\$(git -C '$SB' log develop --format=%s | grep -c WIP)\" = 2 ]"

echo
if [ "$failn" -eq 0 ]; then echo "ALL CHECKS PASSED ($pass/$pass)"; else echo "$failn check(s) failed, $pass passed"; fi
exit "$failn"
