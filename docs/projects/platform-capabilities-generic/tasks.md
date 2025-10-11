## Relevant Files

- `.cursor/rules/cursor-platform-capabilities.mdc`
- `.cursor/rules/platform-capabilities.mdc` (new)
- `.cursor/rules/front-matter.mdc`
- `.cursor/rules/rule-maintenance.mdc`

## Tasks

- [ ] 1.0 Draft ERD for genericization (this file and ERD)
  - [ ] 1.1 Confirm scope and acceptance criteria
- [ ] 2.0 Create generic rule `.cursor/rules/platform-capabilities.mdc`
  - [ ] 2.1 Write front matter per `front-matter.mdc` (alwaysApply: false)
  - [ ] 2.2 Add guidance: official docs as source of truth; cite every capability; defer if uncertain; reconcile conflicts
- [ ] 3.0 Deprecate `cursor-platform-capabilities.mdc` to a pointer
  - [ ] 3.1 Keep unique Cursor-only notes (if any) with citations
- [ ] 4.0 Update cross-references across rules/docs to generic rule
  - [ ] 4.1 Search for references to `cursor-platform-capabilities.mdc` and update
- [ ] 5.0 Validate and announce
  - [ ] 5.1 Run `.cursor/scripts/rules-validate.sh` and fix issues
  - [ ] 5.2 Update `CHANGELOG.md` (Unreleased → Added/Changed)
  - [ ] 5.3 Optional: README note on genericization

### Notes

- Keep attachments minimal; rely on intent routing to attach when discussing platform capabilities
- Update `lastReviewed` only when substantive changes occur
