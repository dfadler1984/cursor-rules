## Relevant Files

- `.cursor/rules/logging-protocol.mdc` — ALP rule to update
- `.github/pull_request_template.md` — Checklist to update
- `.cursor/scripts/alp-logger.sh` — Logging helper (ensure availability)
- `.github/workflows/*` — Optional CI gate

## Tasks

- [ ] 1.0 Define hard gate triggers and evidence (priority: high)
  - [ ] 1.1 Add "Hard Gates" section in logging-protocol.mdc
  - [ ] 1.2 Specify required evidence and fallback path

- [ ] 2.0 Update PR template (priority: high)
  - [ ] 2.1 Add ALP checklist items and links section

- [ ] 3.0 Enforcement script/CI (priority: medium)
  - [ ] 3.1 Create a lightweight script to detect scope vs logs
  - [ ] 3.2 Optional GitHub Action job that runs the script

- [ ] 4.0 Documentation (priority: low)
  - [ ] 4.1 README: note ALP hard gate and how to comply

### Notes

- Keep friction low; failing path must point to exact remediation steps.
- Redact secret-like content; use redaction helper.
