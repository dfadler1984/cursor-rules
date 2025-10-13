## Relevant Files

- `.cursor/scripts/rules-list.sh`
- `.cursor/scripts/rules-validate.sh`
- `.cursor/scripts/git-commit.sh`
- `.cursor/scripts/git-branch-name.sh`
- `.cursor/scripts/pr-create.sh`
- `.cursor/scripts/security-scan.sh`
- `.cursor/scripts/lint-workflows.sh`
- `.cursor/scripts/preflight.sh`
- `.cursor/scripts/tests/run.sh`
- `.cursor/scripts/tests/fixtures/`
- `README.md`

### Notes

- Scripts target macOS (Darwin) with bash; prefer POSIX sh where feasible.
- Dependencies allowed: `jq`, `curl`, `actionlint` (optional, degrade gracefully).
- Auth: `GITHUB_TOKEN` for PR creation.
- Tests live under `.cursor/scripts/`.

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Tasks

- [x] 1.0 Establish shell scripts baseline (strict modes, help/version, logging)

  - [x] 1.1 Create `scripts/.lib.sh` with common helpers (log, die, json print)
  - [x] 1.2 Define standard header: `#!/usr/bin/env bash`, `set -euo pipefail`, `IFS=$'\n\t'`
  - [x] 1.3 Implement `--help` and `--version` convention (VERSION file or inline)
  - [x] 1.4 Add usage templates and consistent exit codes
  - [x] 1.5 Create `scripts/tests/run.sh` test harness (pure bash)

- [x] 2.0 Implement `rules-list.sh` (JSON/table)

  - [x] 2.1 Walk `.cursor/rules/*.mdc` (exclude non-rule templates)
  - [x] 2.2 Extract front matter via awk/sed; assemble JSON with `jq` if present
  - [x] 2.3 Support `--format json|table` (default table)
  - [x] 2.4 Table rendering with column headers; JSON prints to stdout only
  - [x] 2.5 Add tests: help flag, table default, json output, missing dir edge

- [x] 3.0 Implement `rules-validate.sh` (front matter/date/links)

  - [x] 3.1 Validate required fields: description, lastReviewed, healthScore{content,usability,maintenance}
  - [x] 3.2 Validate date format YYYY-MM-DD
  - [x] 3.3 Validate CSV fields (no spaces/braces) where present
  - [x] 3.4 Check internal references exist (files mentioned in rules)
  - [x] 3.5 Non-zero exit on any violation; print concise summary
  - [x] 3.6 Add tests: valid sample passes; invalid date/field/link fails with code

- [x] 4.0 Implement `git-commit.sh` (Conventional Commits)

  - [x] 4.1 Parse args: --type, --scope, --description, repeatable --body, --footer, --breaking
  - [x] 4.2 Validate type and length limits; assemble message
  - [x] 4.3 Run `git commit` with composed message; exit on failure
  - [x] 4.4 Add tests: message assembly, type validation, length guard

- [x] 5.0 Implement `git-branch-name.sh` (suggest/validate)

  - [x] 5.1 Derive login from origin remote or `git config user.name`
  - [x] 5.2 Validate type and format; print suggested branch
  - [x] 5.3 Optional: rename current branch when `--apply`
  - [x] 5.4 Add tests: suggestion with/without origin; validation errors

- [x] 6.0 Implement `pr-create.sh` (curl + GITHUB_TOKEN)

  - [x] 6.1 Read owner/repo from origin; read current branch as head
  - [x] 6.2 Require `GITHUB_TOKEN`; error with guidance if missing
  - [x] 6.3 Create PR via `POST /repos/{owner}/{repo}/pulls`; handle 401/403/422
  - [x] 6.4 On failure, print compare URL fallback
  - [x] 6.5 Add tests: missing token error; dry-run mode behavior

- [x] 7.0 Implement `security-scan.sh` (minimal)

  - [x] 7.1 If `package.json` exists, run `npm audit --audit-level=high` or `yarn npm audit --all`
  - [x] 7.2 Otherwise, print guidance and exit 0
  - [x] 7.3 Add tests: with/without package.json; command not found handling

- [x] 8.0 Implement `lint-workflows.sh` (actionlint)

  - [x] 8.1 If `.github/workflows` absent, no-op with note
  - [x] 8.2 If `actionlint` not installed, print install guidance and non-zero or soft-fail per flag
  - [x] 8.3 Add tests: no-op path; missing binary path

- [x] 9.0 Implement `preflight.sh`

  - [x] 9.1 Check presence/absence of common configs (jest config, scripts dir, docs)
  - [x] 9.2 Print actionable guidance for missing items
  - [x] 9.3 Add tests: prints guidance on this repo missing configs

- [x] 10.0 Documentation
  - [x] 10.1 Update `README.md` with usage examples and install notes for jq/actionlint
  - [x] 10.2 Add a quickstart section and troubleshooting

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [ ] D1 Help/Version: adopt minimum flags and section schema
- [ ] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [ ] D3 Error Semantics: align exit codes and `die` usage
- [ ] D4 Networkless: adopt `.lib-net.sh` seam where relevant

#### Adoption status

- D1: Not started —
- D2: Not started —
- D3: Not started —
- D4: Not started —
