---
"cursor-rules": patch
---

Fix PR validation placeholder detection and add missing project specs

**Bug Fixes:**

- Fixed PR validation script being too strict (flagged valid PRs with standard structure)
- Fixed undefined EXIT_DATA variable in pr-create-simple.sh
- Validation now checks for actual placeholder text, not section headers

**Documentation:**

- Added three missing project specifications (orphaned-files, rules-condensation, script-organization-by-feature)
- Regenerated projects README

**Tests:**

- Updated pr-validate-description tests to match new placeholder detection logic
- Added test case for valid PRs with standard structure
