---
---

# Engineering Requirements Document — Artifact Migration System

Mode: Full

Scope note: Define a safe, repeatable system to migrate repository artifacts between directories (e.g., moving `assistant-logs/` under `docs/assistant-learning-logs/`) while automatically updating in-repo references, relevant configuration, and verifying integrity. Includes manifest format, CLI behavior, rewrite rules, safety rails, and acceptance.

## 1. Introduction/Overview

Changing where artifacts live (logs, specs, plans, tasks, images) often breaks links and implicit conventions. This ERD specifies a migration system that plans and applies file moves, rewrites in-repo references (Markdown links and code-reference filepaths), updates configuration (e.g., `.cursor/config.json`), and verifies integrity. It supports dry-run planning by default, idempotent re-runs, and Git-aware moves to preserve history.

Initial slice: migrate `assistant-logs/` → `docs/assistant-learning-logs/` with automatic link and config updates.

## 2. Goals/Objectives

- Provide a manifest-driven migration with a deterministic plan (dry-run first)
- Move files using `git mv` where possible; create parent directories as needed
- Rewrite in-repo references:
  - Markdown links (example): `[text] (relative/path)` and `![alt] (relative/path)`
  - Code-reference blocks: ```startLine:endLine:filepath
- Update configuration keys that encode paths (e.g., `logDir`) with safe fallbacks
- Verify zero broken links and that moved targets exist; produce a migration report
- Be idempotent, portable, and minimally dependent on external tooling

## 3. User Stories

- As a repo maintainer, I can change artifact directories without breaking references.
- As a contributor, I can preview all moves and rewrites before anything changes.
- As a tooling integrator, I can rely on stable, updated paths and verified cross-links after migrations.

## 4. Functional Requirements

1. Manifest format (YAML) defines changes in a single source of truth.
   - Keys: `version`, `changes[].name`, `changes[].config`, `changes[].moves[]`, `changes[].rewrite`.
   - `moves[]`: `from` (glob or explicit), `to` (directory or explicit path).
   - `config`: file path → `{ set: { key: value } }` updates (e.g., `.cursor/config.json: { set: { logDir: "./docs/assistant-learning-logs/" } }`).
   - `rewrite.include`/`rewrite.exclude`: glob lists for content rewrites.
2. Dry-run mode (default) builds and prints a deterministic plan:
   - File moves with source→dest map; per-file rewrite counts; config deltas.
   - Human-readable summary and optional JSON output.
3. Apply mode executes the plan:
   - Use `git mv` for tracked files when available; fallback to copy+delete when necessary (opt-out via `--no-git-mv`).
   - Create destination parents if missing; preserve file permissions.
4. Reference rewrites (idempotent):
   - Markdown links: rewrite only relative paths; skip `http(s)://`, `mailto:`, and `#` anchors.

- Images: apply same rules to `![alt] (...)`.
- Code-reference blocks used in this repo: blocks that start with ```startLine:endLine:filepath should update only the `filepath` portion.
- Optional cautious pass for inline backticked paths, gated by an allowlist of directories.

5. Config updates:
   - Update `.cursor/config.json` keys that encode directories (e.g., `logDir`).
   - Maintain documented fallback behavior (e.g., local fallback directory remains valid).
6. Verification pass (post-apply):
   - Re-scan to ensure zero broken Markdown links and that all code-reference `filepath`s exist.
   - Confirm moved files now exist at destinations and sources are removed (unless symlink/stub mode).
   - Emit a report with counts (moved files, rewrites by type, broken links found=0).
7. Idempotence:
   - Re-running with the same manifest should be a no-op (no duplicate rewrites; skip already-moved files).
8. Exclusions:
   - Always skip `.git/**`, `node_modules/**`, lockfiles, binaries, and user-configured globs.
9. CLI contract:
   - Flags: `--manifest <path>`, `--dry-run` (default), `--apply`, `--no-git-mv`, `--report <path>`, `--format json|text`.
   - Exit codes: `0` success/clean; `1` verification failure; `2` usage/config error.
10. Reporting:

- Write a migration report (text or JSON) summarizing plan/applied changes and verification results.

11. Optional compatibility aids:

- `--leave-symlinks` or `--leave-stubs` to ease external consumer transitions (time-bounded).

Example manifest:

```yaml
version: 1
changes:
  - name: "Move assistant logs under docs"
    config:
      .cursor/config.json:
        set:
          logDir: "./docs/assistant-learning-logs/"
    moves:
      - from: "assistant-logs/**/*.md"
        to: "docs/assistant-learning-logs/"
    rewrite:
      include: ["**/*.md", "**/*.mdc"]
      exclude:
        ["docs/grok-descriptions/raw/**", "docs/grok-descriptions/chunks/**"]
```

## 5. Non-Functional Requirements

- Reliability: Migrations either apply cleanly or fail with a report; verification prevents silent drift.
- Performance: On this repo, dry-run ≤ 5s and apply ≤ 20s typical.
- Safety/Security: Never rewrite absolute URLs, mailto links, or anchors. Avoid touching non-text/binary files.
- Portability: No heavy dependencies; prefer Node or shell + git; works offline.
- Observability: Report includes counts, skipped items, and verification summary.

## 6. Architecture/Design

- Planning pipeline:
  1. Build move map from manifest (expand globs; detect conflicts).
  2. Build link graph by scanning included files for Markdown links and code-reference blocks.
  3. Compute rewrite operations using the move map (pure function; deterministic).
- Apply pipeline:
  - Perform `git mv` (or copy+delete) according to move map.
  - Apply buffered rewrites per file; write atomically.
  - Run verification scanners; emit report; set exit code accordingly.
- Effects boundaries: file I/O and git are isolated; planning and rewrite mapping are pure and unit-testable.
- Git integration: prefer `git mv` to retain history; commit separately with a conventional message.
- Compatibility: optional symlink/stub emitters for grace periods.

## 7. Data Model and Storage

- Manifest: YAML file checked into the repo (e.g., `scripts/migrations/2025-10-02-artifact-migration.yml`).
- Reports: optional JSON/text report written to `./tmp/` or a user-specified path.
- State: rely on Git history and the manifest for audit; no separate DB/state required.

## 8. API/Contracts

- CLI usage (example):

```bash
node scripts/migrate-artifacts.js --manifest scripts/migrations/2025-10-02-artifact-migration.yml --dry-run --format text
```

```bash
node scripts/migrate-artifacts.js --manifest scripts/migrations/2025-10-02-artifact-migration.yml --apply --report tmp/migration-report.json --format json
```

- Output (JSON mode):
  - `{ plan: { moves: [...], rewrites: {...}, config: {...} }, applied: {...}, verify: { brokenLinks: 0, missingFiles: 0 } }`

## 9. Integrations/Dependencies

- Deterministic outputs: maintains valid cross-links across Specs/Plans/Tasks.
- Assistant Learning Protocol (optional): emit a concise learning log entry after a successful migration (disabled by default; consent-gated).
- CI (optional): a job can run `--dry-run` on PRs to surface broken links before merge.

## 10. Edge Cases and Constraints

- Inline path mentions without link syntax are excluded by default; enable via allowlist.
- Code-reference blocks with missing files: verification should flag and fail.
- Renames that change case only may be problematic on case-insensitive filesystems; detect and warn.
- Move conflicts (two sources to one dest) must be rejected unless explicitly mapped.
- External consumers of old paths (outside repo) are out of scope unless `--leave-symlinks` is used.

## 11. Testing & Acceptance

Acceptance Criteria:

- Dry-run prints a deterministic plan: N moves, M rewrites, config deltas.
- Apply mode results in:
  - 0 broken Markdown links and 0 missing code-reference filepaths
  - 100% of planned moves applied; sources removed or symlinked if enabled
  - `.cursor/config.json` reflects the new `logDir`
- Re-running with the same manifest yields no changes (idempotent)

Test Plan:

- Create an example manifest for `assistant-logs/` → `docs/assistant-learning-logs/`.
- Run `--dry-run` and capture counts; verify plan contents match expectations.
- Run `--apply` in a feature branch; verify links and references with the scanner; inspect report.
- Intentionally break a link to ensure verification fails with exit code `1`.

## 12. Rollout & Ops

- Flag: `artifact-migration` (advisory; used in docs and PRs)
- Owner: rules-maintainers
- Process:
  1. Author manifest; run `--dry-run` and share plan.
  2. Apply in feature branch; commit with a single conventional commit.
  3. Open PR; optional CI `--dry-run` verification.
  4. Merge; optionally leave symlinks for a time-boxed period.

## 13. Success Metrics

- 0 broken links post-migration on main
- 100% of planned moves applied; idempotent re-run yields no changes
- End-to-end runtime ≤ 60s on this repo

## 14. Open Questions

- Do we want default `--leave-symlinks` for one release window?
- Are there additional artifact classes to cover now (images, diagrams)?
- Preferred implementation language (Node vs shell) and script location?
- Should we store reports under `docs/assistant-learning-logs/` for easy review?
