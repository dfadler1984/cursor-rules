## Relevant Files

- `.cursor/rules/platform-capabilities.mdc` (new generic rule)
- `.cursor/rules/cursor-platform-capabilities.mdc` (deprecated to pointer)
- `.cursor/rules/capabilities.mdc` (updated reference)
- `.cursor/rules/front-matter.mdc`
- `.cursor/rules/rule-maintenance.mdc`

## Tasks

- [x] 1.0 Draft ERD for genericization (this file and ERD)
  - [x] 1.1 Confirm scope and acceptance criteria
- [x] 2.0 Create generic rule `.cursor/rules/platform-capabilities.mdc`
  - [x] 2.1 Write front matter per `front-matter.mdc` (alwaysApply: false)
  - [x] 2.2 Add guidance: official docs as source of truth; cite every capability; defer if uncertain; reconcile conflicts
- [x] 3.0 Deprecate `cursor-platform-capabilities.mdc` to a pointer
  - [x] 3.1 Keep unique Cursor-only notes (Cursor docs links) with deprecation notice
- [x] 4.0 Update cross-references across rules/docs to generic rule
  - [x] 4.1 Updated capabilities.mdc platform reference to point to generic rule
  - [x] 4.2 Archived investigation projects unchanged (historical records)
- [x] 5.0 Validate and announce
  - [x] 5.1 Run `.cursor/scripts/rules-validate.sh` → Validation passed
  - [x] 5.2 ~~Update `CHANGELOG.md`~~ → Reverted (Changesets manages CHANGELOG)
  - [x] 5.3 Optional: README note on genericization (explicitly deferred)

### Notes

- Keep attachments minimal; rely on intent routing to attach when discussing platform capabilities
- Update `lastReviewed` only when substantive changes occur
