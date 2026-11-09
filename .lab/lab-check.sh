#!/usr/bin/env bash
rc=0
[ -s culprit.txt ] && echo "- ✅ culprit.txt exists" || { echo "- ❌ culprit.txt is missing (put the short hash of the guilty commit in it)"; rc=1; }
grep -qE '^ALL CHECKS PASSED \(' SUBMISSION.md && echo "- ✅ SUBMISSION.md shows ALL CHECKS PASSED" || { echo "- ❌ paste the verify.sh output ('ALL CHECKS PASSED') into SUBMISSION.md"; rc=1; }
exit $rc
