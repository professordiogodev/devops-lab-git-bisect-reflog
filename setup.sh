#!/usr/bin/env bash
# Creates the Clipstr repository with 40 commits in ./sandbox/clipstr (re-run to start over).
set -euo pipefail
cd "$(dirname "$0")"
rm -rf sandbox; mkdir -p sandbox/clipstr; cd sandbox/clipstr
git init -q -b main; git config commit.gpgsign false
git config user.name "$(git config --global user.name 2>/dev/null || echo You)"; git config user.email "$(git config --global user.email 2>/dev/null || echo you@example.com)"
as() { local n="$1"; shift; GIT_AUTHOR_NAME="$n" GIT_AUTHOR_EMAIL="x@clipstr.dev" GIT_COMMITTER_NAME="$n" GIT_COMMITTER_EMAIL="x@clipstr.dev" "$@"; }

cat > shorten.py <<'P'
import hashlib

def make_code(url):
    digest = hashlib.sha256(url.encode()).hexdigest()
    return digest[:6]
P
cat > test.sh <<'T'
#!/usr/bin/env bash
# Exit 0 = good, non-zero = bad. This is the test suite of the project.
cd "$(dirname "$0")"
python3 - <<'PY'
from shorten import make_code
code = make_code("https://example.com")
assert len(code) == 6, f"short codes must be 6 characters, got {len(code)}"
assert make_code("https://example.com") == code, "codes must be deterministic"
print("all tests passed")
PY
T
chmod +x test.sh
git add -A; as "Maya Santos" git commit -q -m "Clipstr baseline with tests"

msgs=("Add /stats endpoint" "Document environment variables" "Add health check" "Log request ids" "Handle empty urls" "Add favicon route" "Bump fastapi" "Add CORS settings" "Tidy imports" "Add redirect counter"
      "Cache hot codes" "Add admin page skeleton" "Rename helper functions" "Add readme badges" "Fix typo in error text" "Add rate limit config" "Split router into modules" "Add structured logging" "Add metrics endpoint" "Update dependencies"
      "Add QR code stub" "Improve error messages" "Add request timeout" "Move settings to env" "Add pagination to stats" "Add retry helper" "Refactor code generation for readability" "Add dark mode css" "Add unit test for redirects" "Speed up startup"
      "Add health details" "Clean up logging" "Add stats export" "Add feature flags" "Document the API" "Add alias stub" "Tidy README" "Add Dockerfile hints" "Bump uvicorn")
i=0
for m in "${msgs[@]}"; do
  i=$((i+1))
  f="mod_$((i%6)).py"
  printf 'def feature_%d():\n    return "%s"\n\n' "$i" "$m" >> "$f"
  if [ "$m" = "Refactor code generation for readability" ]; then
    cat > shorten.py <<'P'
import hashlib

def make_code(url):
    h = hashlib.sha256(url.encode())
    return h.hexdigest()[:7]
P
    git add -A; as "Tomas Costa" git commit -q -m "$m"; git update-ref refs/lab/culprit "$(git rev-parse HEAD)"
  else
    git add -A; as "$([ $((i%2)) = 0 ] && echo 'Priya Nair' || echo 'Tomas Costa')" git commit -q -m "$m"
  fi
done

# a fix that lives on develop together with unfinished work (for the cherry-pick part)
git switch -q -c develop
echo "WIP premium" > premium.md; git add -A; git commit -q -m "WIP: premium tier, do not release"
printf 'def clean(url):\n    return url.strip()\n' > clean.py; git add -A; git commit -q -m "fix: strip whitespace from submitted urls"
echo "WIP invoices" >> premium.md; git add -A; git commit -q -m "WIP: invoices, do not release"
git switch -q main; git switch -q -c release/1.0; git switch -q main
echo "Ready: $(pwd)"; git log --oneline | wc -l | xargs echo "commits on main:"
