---
"cursor-rules": minor
---

Add PR description validation and root README generator project

**New Features:**
- `pr-validate-description.sh`: Validates PR descriptions after creation to prevent null/empty/template bodies
- Integrated validation into `pr-create-simple.sh` with `--no-validate` flag
- Test suite for validation script

**Documentation:**
- Root README generator project (Phase 0: Planning) with comprehensive ERD and 202 tasks
- Push command reference at `.cursor/commands/push.md`

**Improvements:**
- Prevents silent failures where PRs are created but descriptions aren't set
- Validates against null bodies, empty bodies, and template placeholders

