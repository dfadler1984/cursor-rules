## Tasks — ERD: Skip Changeset Opt-In (Archived)

## Relevant Files

- `.cursor/scripts/pr-create.sh`
- `docs/projects/_archived/2025/skip-changeset-opt-in/erd.md`

## Todo

- [x] 1.0 Add `--label <name>` (repeatable) and `--docs-only` alias (maps to `skip-changeset`)
- [x] 2.0 After PR creation, call Issues API to add label(s) when flags are present (require `jq` only for this path)
- [x] 3.0 Extend `--dry-run` to include a `labels` field showing intended label(s) without API calls
- [x] 4.0 Add tests: default no labels, single label, multiple labels, `--docs-only` alias
- [x] 5.0 Update README usage with examples for `--docs-only` and `--label`
