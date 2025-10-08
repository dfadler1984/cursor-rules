## Relevant Files

- `.cursor/rules/assistant-learning.mdc` — Assistant Learning rule (authoritative)
- `.cursor/scripts/alp-logger.sh` — Logging helper (ensure availability)
- `.cursor/rules/assistant-learning.caps.mdc` — Capabilities for Assistant Learning
- `.cursor/rules/assistant-behavior.mdc` — Consent exception for auto-logs
- `docs/projects/assistant-learning-hard-gate/erd.md` — ERD reflecting auto-logging

## Tasks

- [ ] 1.0 Define hard gate triggers and evidence (priority: high)

  - [x] 1.1 Add "Hard Gates" section in assistant-learning.mdc
  - [x] 1.2 Specify required evidence and fallback path
  - [x] 1.3 Rename rule file (`logging-protocol.mdc` → `assistant-learning.mdc`)
  - [x] 1.4 Add consent exception in `assistant-behavior.mdc`
  - [x] 1.5 Update ERD for auto-logging and relative link

- [ ] 2.0 Link updates after rename (priority: high)

  - [x] 2.1 Update `README.md` references to `assistant-learning.mdc`
  - [x] 2.2 Update `docs/projects/ai-workflow-integration/erd.md`
  - [x] 2.3 Update `docs/projects/ai-workflow-integration/tasks.md`
  - [x] 2.4 Update `docs/projects/ai-workflow-integration/discussions.md`
  - [x] 2.5 Update archived reference: `docs/projects/_archived/2025/rules-validate-script/erd.md`
  - [x] 2.6 Global scan: replace remaining references to `logging-protocol.mdc`

- [ ] 3.0 Caps alignment (priority: medium)

  - [x] 3.1 Rename/create `assistant-learning.caps.mdc` (migrate from `logging-protocol.caps.mdc`)
  - [x] 3.2 Update cross-references to the caps file
  - [x] 3.3 Update `lastReviewed` in the caps file

- [ ] 4.0 Documentation (priority: low)

  - [ ] 4.1 Optional: README note on `logDir` configuration and fallback path

- [ ] 5.0 Validation (priority: high)

  - [ ] 5.1 Run `.cursor/scripts/links-check.sh` to verify links
  - [ ] 5.2 Fix any broken/moved references

- [ ] 6.0 Periodic review & archival policy (priority: medium)

- [x] 6.1 Add ERD section “Periodic Review & Archival” with >=10 logs threshold
- [x] 6.2 Document summarize → mark → archive procedure using ALP scripts
- [x] 6.3 Add notes for counting unarchived logs and capturing suggestions as tasks/rule edits
- [ ] 6.4 Optional: add a helper/alias to count unarchived logs locally

### Notes

- Keep friction low; failing path must point to exact remediation steps.
- Redact secret-like content; use redaction helper.
