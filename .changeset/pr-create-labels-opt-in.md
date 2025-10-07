---
"cursor-rules": minor
---

feat(pr-create): add --label and --docs-only flags

- Dry-run now includes a `labels` array when label flags are present
- After successful PR creation, labels are added via the Issues API
- Tests cover default/no labels, multiple labels, and `--docs-only` alias
- ERD/tasks updated under `docs/projects/skip-changeset-opt-in`
