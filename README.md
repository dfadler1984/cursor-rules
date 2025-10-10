# Cursor Rules — Shell Scripts Suite

This repository includes a suite of standalone shell scripts to assist with rules management, Git workflows, PR creation, and repo hygiene. Scripts target macOS with bash and prefer POSIX sh where feasible.

## Unified Defaults (No Toggles)

- Slash‑commands recognized by default; phrase triggers remain supported
- Tasks support `dependencies`, `priority`, and `[P]` markers
- Assistant learning logs are always on via `.cursor/rules/assistant-learning.mdc` (with Operation and Dependency Impact)
- See commands overview: `.cursor/rules/commands.caps.mdc`
- See per‑rule capabilities: `.cursor/rules/capabilities.mdc` (links to `<rule>.caps.mdc` files)

## How to mark a project completed

1. Add front matter to the project ERD (`docs/projects/<name>/erd.md`):

   ```yaml
   ---
   status: completed
   completed: YYYY-MM-DD
   owner: <you>
   ---
   ```

2. Ensure the Project Completion Checklist is satisfied (`docs/projects/project-lifecycle/completion-checklist.template.md`).
3. Add a brief final summary using the template (`docs/projects/project-lifecycle/final-summary.template.md`).
4. Update `docs/projects/README.md`: move the project from Active to Completed. If archiving, move the project folder to `docs/projects/_archived/<YYYY>/<name>/` and update the Completed link.

## Scripts

- `.cursor/scripts/rules-list.sh`
  - List `.cursor/rules/*.mdc` with selected front matter fields
  - Flags: `--dir`, `--format table|json`, `--help`, `--version`
- `.cursor/scripts/rules-validate.sh`
  - Validate rule front matter and references; optional autofix, json output, staleness checks, and report generation
  - Flags: `--dir`, `--format json|text`, `--fail-on-missing-refs`, `--fail-on-stale`, `--autofix`, `--report`, `--report-out <path>`, `--help`
  - Examples:
    - Text (default):
      ```bash
      .cursor/scripts/rules-validate.sh
      ```
    - JSON summary:
      ```bash
      .cursor/scripts/rules-validate.sh --format json
      ```
    - Fail on missing refs:
      ```bash
      .cursor/scripts/rules-validate.sh --fail-on-missing-refs
      ```
    - Staleness strict mode (90 days):
      ```bash
      .cursor/scripts/rules-validate.sh --fail-on-stale
      ```
    - Autofix formatting-only issues:
      ```bash
      .cursor/scripts/rules-validate.sh --autofix
      ```
    - Generate review report:
      ```bash
      .cursor/scripts/rules-validate.sh --report
      # or choose an output path
      .cursor/scripts/rules-validate.sh --report-out docs/reviews/review-$(date +%F).md
      ```
- `.cursor/scripts/git-commit.sh`
  - Compose Conventional Commits; supports `--dry-run`
  - Flags: `--type`, `--scope`, `--description`, `--body`, `--footer`, `--breaking`, `--dry-run`
- `.cursor/scripts/git-branch-name.sh`
  - Suggest/validate branch names; `--apply` to rename current branch
  - Flags: `--task`, `--type`, `--feature`, `--apply`
- `.cursor/scripts/pr-create.sh`

  - Create GitHub PR via API (`curl`); requires `GITHUB_TOKEN` (non-dry-run)
  - Default behavior: prefill PR body from `.github/pull_request_template.md` (if present) or the first file in `.github/PULL_REQUEST_TEMPLATE/`
  - Flags: `--title`, `--body`, `--base`, `--head`, `--owner`, `--repo`, `--dry-run`
  - Template flags: `--no-template` (disable), `--template <path>` (select file), `--body-append <text>` (append under `## Context`), `--replace-body` (bypass template; set body exactly)
  - Heuristic: if `--body` begins with `## Summary`, the script auto-switches to replace mode to avoid duplication
  - Labeling (opt-in): `--label <name>` (repeatable) to add labels after PR creation. Use `--docs-only` as a convenience alias for `--label skip-changeset`.
  - Dry-run output includes a `labels` array when label flags are present.
  - Note: when template injection is active, `--body`/`--body-append` are appended under `## Context` (preserves template headings)

  - Examples:
    - Append under template (Context section):
      ```bash
      bash .cursor/scripts/pr-create.sh \
        --title "feat: add auto-merge workflow" \
        --body-append $'Summary: Enable auto-merge for bot PRs\n\nChanges:\n- Add workflow...\n' \
        --dry-run
      ```
    - Replace entire body (no template):
      ```bash
      bash .cursor/scripts/pr-create.sh \
        --title "feat: add auto-merge workflow" \
        --replace-body \
        --body $'## Summary\nOne-line summary\n\n## Changes\n- ...' \
        --dry-run
      ```
    - Heuristic replace (body starts with `## Summary`):
      ```bash
      bash .cursor/scripts/pr-create.sh \
        --title "feat: add auto-merge workflow" \
        --body $'## Summary\nOne-line summary' \
        --dry-run
      ```

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

## Docs

- Assistant Learning Protocol (ALP): `docs/projects/assistant-learning/erd.md`
- Deterministic, Structured Outputs ERD: `docs/projects/deterministic-outputs/erd.md`
- Rule — Deterministic Outputs: `.cursor/rules/deterministic-outputs.mdc`
- Rule — Capabilities Discovery: `.cursor/rules/capabilities-discovery.mdc`
- Rule — Spec-Driven Workflow: `.cursor/rules/spec-driven.mdc`
- ERD creation rule (default: Full): `.cursor/rules/create-erd.mdc`
- Unified Workflow (Spec → Plan → Tasks → Analyze → Implement): see `.cursor/rules/spec-driven.mdc`, `.cursor/rules/create-erd.mdc`, `.cursor/rules/generate-tasks-from-erd.mdc`, `.cursor/rules/task-list-process.mdc`, `.cursor/rules/assistant-learning.mdc`.
- Artifacts/paths: `docs/projects/<feature>/erd.md`, `docs/plans/<feature>-plan.md`, `docs/projects/<feature>/tasks.md`.
- Slash-commands: `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`.
- Logs and summaries: `docs/assistant-learning-logs/` (local fallback). Weekly summary via CI.
  - Log destination: set `.cursor/config.json` `logDir` to control the primary logs directory (default `assistant-logs/`); falls back to `docs/assistant-learning-logs/` if primary is not writable.
- ERD Split Progress: `docs/projects/split-progress/erd.md`
  - Glossary: `docs/glossary.md`
  - Owner Map: `docs/owner-map.md`
  - Drawing Board ERD: `docs/projects/drawing-board/erd.md`
  - Intent Router ERD: `docs/projects/intent-router/erd.md`
  - Framework Selection ERD: `docs/projects/framework-selection/erd.md`
  - Role–Phase Mapping ERD: `docs/projects/role-phase-mapping/erd.md`
  - Git Usage ERD: `docs/projects/git-usage/erd.md`
  - Bash Script Standards ERD: `docs/projects/bash-scripts/erd.md`
  - Rule — TDD‑First (Core): `.cursor/rules/tdd-first.mdc`
  - Rule — TDD‑First (JS/TS Extension): `.cursor/rules/tdd-first-js.mdc`
  - Rule — TDD‑First (Shell Extension): `.cursor/rules/tdd-first-sh.mdc`
  - Rule — Test Quality (Core): `.cursor/rules/test-quality.mdc`
  - Rule — Test Quality (JS/TS): `.cursor/rules/test-quality-js.mdc`
  - Rule — Test Quality (Shell): `.cursor/rules/test-quality-sh.mdc`
- Archived Source ERD (reference-only): `docs/projects/rules-grok-alignment/erd.md`
- Portability ERD: `docs/projects/portability/erd.md`
- MCP Synergy ERD: `docs/projects/mcp-synergy/erd.md`
  - Roles & Intent Routing ERD: `docs/projects/roles/erd.md`
  - Capabilities Discovery ERD: `docs/projects/capabilities-discovery/erd.md`
  - Spec‑Driven Workflow (integrated): `docs/projects/ai-workflow-integration/erd.md`
  - TDD‑First ERD: `docs/projects/_archived/2025/tdd-first/erd.md`
  - Core Values ERD: `docs/projects/core-values/erd.md`
  - Productivity & Automation ERD: `docs/projects/productivity/erd.md`
  - Rule Maintenance & Validator ERD: `docs/projects/rule-maintenance/erd.md`
  - Collaboration Options ERD: `docs/projects/collaboration-options/erd.md`
  - Context Efficiency Gauge ERD: `docs/projects/context-efficiency-gauge/erd.md`

## Changelog & Versioning

- Canonical version lives in `VERSION` (single line, e.g., `1.2.3`).
- Changelog is generated in `CHANGELOG.md` via Changesets.
- No GitHub Releases are published; updates occur via a bot PR named "Version Packages".

Author workflow:

```bash
# In your feature branch
npx changeset
# Follow prompts to select bump type and write a summary
git add . && git commit -m "chore(changeset): add"
git push

# After your PR merges to main, a bot opens/updates a Version Packages PR.
# Maintainers review and merge it. That PR updates CHANGELOG.md and VERSION.
```

## CI details:

- On push to `main`, the workflow opens/updates the Version Packages PR when pending changesets exist.
- When that PR is merged, the workflow writes the computed version into `VERSION` and commits the updated `CHANGELOG.md`.

## What's New

- Deterministic outputs (Spec/Plan/Tasks) — ERD + rules + validator shell script
  - ERD: `docs/projects/deterministic-outputs/erd.md`
  - Rule: `.cursor/rules/deterministic-outputs.mdc`
  - Validator: `.cursor/scripts/validate-artifacts.sh` (+ test)
  - Smoke test: `.cursor/scripts/validate-artifacts-smoke.sh`
  - Workflow (manual): `.github/workflows/deterministic-outputs-validate.yml`
  - Sample trio: `docs/specs/sample-feature-spec.md`, `docs/plans/sample-feature-plan.md`

## Validator (Deterministic Outputs)

Run locally:

```bash
.cursor/scripts/validate-artifacts.sh --paths \
  docs/specs/sample-feature-spec.md,docs/plans/sample-feature-plan.md
```

Expected output: "Validation passed" (exit code 0). On missing sections/links, returns non‑zero with error messages.

Smoke test (default + overridden dirs):

```bash
.cursor/scripts/validate-artifacts-smoke.sh
```

## Logs — Quickstart (ALP)

- Write a minimal ALP entry (heredoc):

```bash
.cursor/scripts/alp-logger.sh write-with-fallback assistant-logs 'alp-quickstart' <<'BODY'
Timestamp: 2025-10-10T00:00:00Z
Event: Task Completed
Owner: alp-logging
What Changed: Created a minimal ALP entry via quickstart.
Next Step: Review aggregation/archival scripts.
Links: docs/assistant-learning-logs/README.md
Learning: Use standard status formats and fallback reasons.
BODY
```

- Status line format (examples):
  - Success: `ALP: Task Completed — assistant-logs/log-<ISO>-alp-quickstart.md`
  - None: `ALP: none — no-trigger`
