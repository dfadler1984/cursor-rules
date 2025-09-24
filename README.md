# Cursor Rules — Shell Scripts Suite

This repository includes a suite of standalone shell scripts to assist with rules management, Git workflows, PR creation, and repo hygiene. Scripts target macOS with bash and prefer POSIX sh where feasible.

## Scripts

- `.cursor/scripts/rules-list.sh`
  - List `.cursor/rules/*.mdc` with selected front matter fields
  - Flags: `--dir`, `--format table|json`, `--help`, `--version`
- `.cursor/scripts/rules-validate.sh`
  - Validate rule front matter and references
  - Flags: `--dir`, `--fail-on-missing-refs`, `--help`, `--version`
- `.cursor/scripts/git-commit.sh`
  - Compose Conventional Commits; supports `--dry-run`
  - Flags: `--type`, `--scope`, `--description`, `--body`, `--footer`, `--breaking`, `--dry-run`
- `.cursor/scripts/git-branch-name.sh`
  - Suggest/validate branch names; `--apply` to rename current branch
  - Flags: `--task`, `--type`, `--feature`, `--apply`
- `.cursor/scripts/pr-create.sh`
  - Create GitHub PR via API (`curl`); requires `GITHUB_TOKEN` (non-dry-run)
  - Flags: `--title`, `--body`, `--base`, `--head`, `--owner`, `--repo`, `--dry-run`
- `.cursor/scripts/security-scan.sh`
  - Best-effort `npm/yarn` audit if `package.json` exists; otherwise no-op
- `.cursor/scripts/lint-workflows.sh`
  - Lint `.github/workflows` with `actionlint` if installed
- `.cursor/scripts/preflight.sh`
  - Print presence/absence of common configs and guidance

## Tests

- Harness: `bash .cursor/scripts/tests/run.sh [-k keyword] [-v]`
  - Discovers tests `.cursor/scripts/*.test.sh`
  - `-k` filters by path substring; `-v` prints test output

## Auth & dependencies

- PR creation: set `GITHUB_TOKEN` in your environment
- Optional dependencies: `jq`, `actionlint`

## Workspace Security

See `docs/workspace-security.md` for Cursor workspace trust and autorun guidance.
