#!/usr/bin/env bash
# Simulates a tired developer: three commits on a branch, then a reset --hard that throws them away.
set -euo pipefail
cd "$(dirname "$0")/sandbox/clipstr"
git switch -q main
git switch -q -c premium
echo "tiers: free, pro" > tiers.md;       git add -A; git commit -q -m "Add premium tier: plans"
echo "limits: pro=10000" >> tiers.md;     git add -A; git commit -q -m "Add premium tier: limits"
echo "invoices: monthly" > invoices.md;   git add -A; git commit -q -m "Add premium tier: invoices"
echo "Three commits of work on branch 'premium'. Now: a tired developer runs the wrong command..."
git reset -q --hard main
git switch -q main
echo "git reset --hard main  <- done. The branch 'premium' points at main again."
echo "Where did the three commits go?"
