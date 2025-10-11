## Relevant Files

- `docs/projects/workflows/erd.md` - Canonical ERD (Lite)
- `.cursor/rules/` - Existing rules to reference and integrate

### Notes

- TDD-first; add failing spec, implement, refactor when adding runnable helpers.
- Keep workflows modular and opt-in; avoid conflicts with existing rules.

## Tasks

- [ ] 1.0 Define candidate workflows and scope (priority: high)

  - [ ] 1.1 List top 3–4 workflows (ERD→Tasks, Small Fix via TDD, PR with Changesets, Self-Improvement Logs)
  - [ ] 1.2 Write short entry/exit criteria for each
  - [ ] 1.3 Identify overlaps/conflicts with existing rules

- [ ] 2.0 Draft workflow checklists (priority: high) (depends on: 1.0)

  - [ ] 2.1 Create concise checklist for ERD→Tasks
  - [ ] 2.2 Create concise checklist for Small Fix via TDD
  - [ ] 2.3 Create concise checklist for PR with Changesets
  - [ ] 2.4 Create concise checklist for Self-Improvement Logs (see `docs/projects/assistant-self-improvement/`)

- [ ] 3.0 Integrate with rules and templates (priority: medium) (depends on: 2.0)

  - [ ] 3.1 Cross-link relevant rules and templates
  - [ ] 3.2 Add minimal templates where missing (docs-first)
  - [ ] 3.3 Ensure acceptance bundle compatibility

- [ ] 4.0 Validate and iterate (priority: medium) (depends on: 3.0)
  - [ ] 4.1 Apply one workflow to a small change; record outcomes
  - [ ] 4.2 Adjust wording and gates based on results
  - [ ] 4.3 Propose adoption guidance in README
- [ ] Add backlink: umbrella — `docs/projects/project-lifecycle-docs-hygiene/erd.md`
