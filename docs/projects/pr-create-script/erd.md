---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — PR Create Script (Lite)

Links: `.cursor/scripts/pr-create.sh` | `docs/projects/pr-create-script/tasks.md`

## 1. Introduction/Overview

Improve `.cursor/scripts/pr-create.sh` so PR bodies can be fully provided (replace) or appended (current), with predictable outcomes.

## 2. Goals/Objectives

- Add `--no-template` (already supported) and a `--body-mode replace|append` option (default: append)
- Ensure Markdown bodies pass through without escaping issues
- Add tests for body modes and title-only PRs

## 3. Functional Requirements

- When `--body-mode replace`, do not inject the template; set body exactly as provided
- When `--body-mode append` and template is present, append under a predictable heading (Context)
- Exit non-zero on API errors; print compare URL as fallback

## 4. Acceptance Criteria

- Body replace mode works and is covered by tests
- Append mode remains backward compatible
- Docs updated in README usage section

## 5. Risks/Edge Cases

- Multi-line argument handling; ensure safe quoting
- GH token missing; still print compare URL
