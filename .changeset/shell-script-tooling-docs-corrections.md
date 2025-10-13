---
"cursor-rules": patch
---

# Fix shell-and-script-tooling documentation accuracy

## Documentation Corrections

Corrected script counts and project status across shell-and-script-tooling documentation to match actual implementation.

### Script Count Corrections

- Fixed script count from 36 to 37 throughout all documentation
- Added setup-remote.sh to documented scripts (dependency checking utility)
- Updated network usage from 4 to 5 scripts (added setup-remote.sh)
- Corrected test count from 52 to 46 (consistent across all docs)

### Files Updated

**shell-and-script-tooling project:**

- `docs/projects/shell-and-script-tooling/erd.md` - All count references corrected
- `docs/projects/shell-and-script-tooling/tasks.md` - Added Task 19.0 (source project reconciliation), corrected counts
- `docs/projects/shell-and-script-tooling/PROGRESS.md` - Updated compliance dashboard and counts
- `.changeset/shell-script-tooling-complete.md` - Updated to reflect accurate counts

**tests-github-deletion project:**

- `docs/projects/tests-github-deletion/erd.md` - Marked completed (2025-10-13), added resolution summary
- `docs/projects/tests-github-deletion/tasks.md` - Marked all tasks complete, added resolution summary

### New Content

- Added Task 19.0: Source project task reconciliation (8 subtasks for aligning individual project tasks)
- Added "Known Issues & Documentation Notes" section documenting decisions (e.g., .shellcheckrc not needed)
- Documented that tests-github-deletion project is resolved and ready for archival

### Verification

All validators still pass with corrected counts:

- `help-validate.sh`: 37 scripts validated ✅
- `error-validate.sh`: 37 scripts validated, 0 warnings ✅
- Full test suite: 46/46 tests passing ✅
