---
"cursor-rules": minor
---

Deactivate legacy Assistant Learning (ALP) and migrate to a new `assistant-self-improvement` project.

- Add `docs/projects/assistant-self-improvement/` with `erd.md`, `tasks.md`
- Archive ALP rules/scripts under `legacy/` (rules + `alp-*.sh` tests)
- Remove `.cursor/rules/assistant-learning*.mdc` and purge ALP references from active rules/docs
- Mark related ERDs as `status: skipped`:
  - `assistant-learning-hard-gate`, `alp-smoke`, `logging-destinations`
- Disable ALP GitHub workflows (`alp-aggregate.yml`, `alp-smoke.yml`)

Notes:
- ALP scripts are no longer available under `.cursor/scripts/`
- No CI aggregation/smoke runs for ALP


