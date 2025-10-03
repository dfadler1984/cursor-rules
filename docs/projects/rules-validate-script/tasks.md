# Tasks — erd-rules-validate-script

## Relevant Files

- `docs/projects/rules-validate-script/erd.md`
- `.cursor/scripts/rules-validate.sh` — validator script (new)
- `.github/workflows/ci.yml` — CI validation step (if present)
- `.cursor/scripts/rules-validate.spec.sh` — shell spec for validator
- `.github/workflows/rules-validate.yml` — CI workflow for validator

## Todo

- [x] 1.0 Create rules-validate.sh skeleton (POSIX, portable)
  - [x] 1.1 Add shebang and `set -euo pipefail`
  - [x] 1.2 Discover `.cursor/rules/*.mdc` with `find`
  - [x] 1.3 Print usage/help and summary
- [x] 2.0 Implement front matter checks (required fields, date regex)
  - [x] 2.1 Parse YAML front matter between `---` blocks
  - [x] 2.2 Require `description`, `lastReviewed`, and `healthScore` keys
  - [x] 2.3 Validate `lastReviewed` format `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`
- [x] 3.0 Implement CSV checks (no spaces, no brace expansion)
  - [x] 3.1 Enforce no spaces around commas in `globs`/`overrides`
  - [x] 3.2 Forbid brace expansion `{}` in CSV fields
  - [x] 3.3 Emit `path:line` diagnostics
- [x] 4.0 Implement boolean checks (alwaysApply true|false)
  - [x] 4.1 Require lowercase, unquoted `true|false`
- [x] 5.0 Implement content checks (deprecated references, ev\s+ents)
  - [x] 5.1 Flag `assistant-learning-log.mdc` references
  - [x] 5.2 Flag `ev\s+ents` typography error
- [x] 7.0 Add output formatting and non-zero exit on failures
  - [x] 7.1 Count violations and exit non-zero on >0
  - [x] 7.2 Print a final summary line
- [x] 8.0 Add CI job and optional pre-commit hook wiring
  - [x] 8.1 Add CI step to `.github/workflows/ci.yml` (if present)
  - [x] 8.2 Document local usage in `README.md`
