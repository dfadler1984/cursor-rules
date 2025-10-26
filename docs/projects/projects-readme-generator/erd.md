---
status: completed
owner: rules-maintainers
completedDate: 2025-10-25
---

# Engineering Requirements Document — Projects README Generator

Mode: Lite

## 1. Introduction/Overview

Automate generation of `docs/projects/README.md` so the projects index stays current without manual edits. The generator scans `docs/projects/` (excluding `_archived/` and `_examples/`) and emits a concise, consistent README with links and statuses.

## 2. Goals/Objectives

- Keep the projects README accurate with a single command
- Standardize formatting (title, status, links) across projects
- Zero external dependencies; fast and idempotent

## 3. User Stories

- As a maintainer, I can regenerate the projects index in seconds.
- As a contributor, I can discover active projects with clear links to `erd.md` and `tasks.md`.

## 4. Functional Requirements

1. Discovery

   - Traverse `docs/projects/` and list immediate child folders representing projects.
   - Exclude `_archived/`, `_examples/`, and non-project files.

2. Metadata extraction

   - Read project title from the first top-level heading in `erd.md` when present; fallback to folder name.
   - Read `status` and optional `owner` from YAML front matter in `erd.md` when present; fallback to `unknown`.
   - Detect presence of `tasks.md`.

3. Output

   - Generate `docs/projects/README.md` with:
     - Short intro explaining the directory
     - A Markdown table with columns: Project, Status, ERD, Tasks
     - Sorted by Project (case-insensitive)
   - Idempotent output (stable ordering, consistent spacing)

4. CLI
   - Implement as a local script: `.cursor/scripts/generate-projects-readme.sh`
   - Flags: `--projects-dir` (default `docs/projects`), `--out` (default `docs/projects/README.md`), `--dry-run`

## 5. Non-Functional Requirements

- Portability: POSIX shell compatible; no external binaries beyond coreutils
- Performance: completes in < 1s on this repo
- Reliability: gracefully handles missing `erd.md`/`tasks.md` and reports counts

## 6. Architecture/Design

- Implementation: POSIX shell script that walks the directory, parses minimal YAML/Markdown with grep/sed/awk, and renders a templated README
- Tests: a companion script `.cursor/scripts/generate-projects-readme.test.sh` using fixture dirs or a dry-run against the real tree

## 7. Data Model and Storage

- Inputs: file tree under `docs/projects/`
- Output: Markdown file at `docs/projects/README.md`
- No databases or caches

## 8. API/Contracts

- Invocation example:

  ```bash
  ./.cursor/scripts/generate-projects-readme.sh \
    --projects-dir docs/projects \
    --out docs/projects/README.md
  ```

## 9. Integrations/Dependencies

- Optional: hook into project lifecycle validation to ensure README is fresh
- No network calls; local-only

## 10. Edge Cases and Constraints

- Projects missing `erd.md` or front matter → show folder name/title and `status: unknown`
- Nested project folders: only index immediate children
- Names with spaces/dashes: ensure links and table render correctly

## 11. Testing & Acceptance

- Running the script produces a README containing all non-archived, non-example projects
- Table rows include valid relative links for ERD and Tasks when present
- Stable sort order; subsequent runs with no changes result in no diff

## 12. Rollout & Ops

- Add npm script `generate:projects-readme`
- Optionally run during local release prep; no CI required

## 13. Success Metrics

- README stays current with minimal manual effort
- Fewer missed/incorrect links reported by contributors

## 14. Open Questions

- Should we include last-updated timestamps per project?
- Should archived projects be summarized with a separate link instead of excluded?
