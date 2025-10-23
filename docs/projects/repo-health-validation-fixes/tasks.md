## Relevant Files

- `docs/projects/repo-health-validation-fixes/erd.md` — Project ERD
- `.cursor/rules/capabilities.mdc` — Main documentation file to update
- `.cursor/rules/script-execution.mdc` — Fixed broken reference
- `.cursor/scripts/deep-rule-and-command-validate.sh` — Validation orchestrator
- `.cursor/scripts/capabilities-sync.sh` — Helper for documenting scripts
- `.cursor/scripts/test-colocation-validate.sh` — Test colocation validator

### Notes

- Baseline health score: 52/100 (target: 90+/100)
- Main issue: 20/59 scripts undocumented in capabilities.mdc
- Evidence-based completion: re-run deep validator after each fix

## Tasks

- [ ] 1.0 Document missing scripts in capabilities.mdc (priority: high)

  - [ ] 1.1 Review capabilities-sync.sh output and categorize scripts
  - [ ] 1.2 Add compliance measurement tools (check-branch-names, check-script-usage, check-tdd-compliance, compliance-dashboard)
  - [ ] 1.3 Add context efficiency tools (context-efficiency-format, context-efficiency-gauge, context-efficiency-score)
  - [ ] 1.4 Add PR tools (pr-label, pr-labels, pr-changeset-sync, pr-create-simple)
  - [ ] 1.5 Add rules validators (rules-autofix, rules-validate-format, rules-validate-frontmatter, rules-validate-refs, rules-validate-staleness)
  - [ ] 1.6 Add utility scripts (git-context, project-docs-organize, setup-remote, validate-investigation-structure)
  - [ ] 1.7 Skip internal helpers (.lib-net.sh) — document decision in project notes
  - [ ] 1.8 Run capabilities-sync.sh --check to verify all documented

- [ ] 2.0 Fix test colocation issues (priority: medium) (depends on: 1.0)

  - [ ] 2.1 Run test-colocation-validate.sh to identify specific violations
  - [ ] 2.2 Review violations and determine root cause
  - [ ] 2.3 Fix colocation issues (move tests or update validator expectations)
  - [ ] 2.4 Re-run validator to confirm all passing

- [ ] 3.0 Validate and verify health score (priority: high) (depends on: 1.0, 2.0)
  - [ ] 3.1 Run deep-rule-and-command-validate.sh and capture output
  - [ ] 3.2 Verify Documentation score improved (0/100 → 95+/100)
  - [ ] 3.3 Verify Test Quality score improved (60/100 → 100/100)
  - [ ] 3.4 Verify Overall Health score ≥ 90/100
  - [ ] 3.5 Document final scores in project README or findings
