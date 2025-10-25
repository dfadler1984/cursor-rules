---
status: archived
owner: rules-maintainers
---

# Engineering Requirements Document — PR Create Script (Lite)

Links: `.cursor/scripts/pr-create.sh` | `docs/projects/pr-create-script/tasks.md`

## 1. Introduction/Overview

Improve `.cursor/scripts/pr-create.sh` so PR bodies can be fully provided (replace) or appended (current), with predictable outcomes.

Current behavior (verified):

- Defaults to injecting the repository PR template from `.github/pull_request_template.md` (or the first file under `.github/PULL_REQUEST_TEMPLATE/` when present).
- When a `--body` or `--body-append` is supplied with template injection enabled, the script appends that content under a new `## Context` section after the template.
- Explicit replace mode is available via `--replace-body`, which bypasses template injection and sets the body exactly to the provided content.
- Auto-replace heuristic: if the provided `--body` begins with a heading matching `^##\s+Summary`, the script automatically switches to replace mode to avoid duplicating the template.
- Safety: `json_escape` preserves Markdown while escaping JSON-delimiter characters and newlines for API payloads.

## 2. Goals/Objectives

- Document and standardize the existing replace/append behavior and flags
- Ensure Markdown bodies pass through without escaping issues (retain current `json_escape` behavior)
- Provide clear usage examples for replace vs append (including the auto-replace heuristic)
- Align docs/tasks with implemented flags instead of introducing new flag names

## 3. Functional Requirements

- Replace mode: when `--replace-body` is passed, do not inject the template; set body exactly as provided
- Append mode (default): when template is present and `--body`/`--body-append` is provided, append under a predictable `## Context` section
- Auto-replace: when `--body` starts with `## Summary`, treat as replace mode (heuristic)
- Template selection: default to `.github/pull_request_template.md`, otherwise first file under `.github/PULL_REQUEST_TEMPLATE/`; allow `--template <path>` and `--no-template`
- Exit non-zero on API errors; print compare URL as fallback

## 4. Acceptance Criteria

- Replace mode works (`--replace-body`) and is demonstrated with usage examples
- Append mode remains backward compatible and appends under `## Context`
- Auto-replace heuristic is documented and demonstrated
- README usage is updated to reflect flags and examples

## 5. Risks/Edge Cases

- Multi-line argument handling; ensure safe quoting
- GH token missing; still print compare URL
- Template content duplication (outside the script): duplicated sections inside `.github/pull_request_template.md` will be rendered twice before the `## Context` section; resolution requires deduping the template content

## 6. Flags/Interface (Reference)

- `--title <t>` (required)
- `--body <markdown>` (appended under `## Context` unless replaced)
- `--body-append <markdown>` (additional content under `## Context`)
- `--replace-body` (bypass templates; set body exactly)
- `--no-template` (disable template injection)
- `--template <path>` (choose a specific template file)
- `--base <branch>` `--head <branch>` `--owner <o>` `--repo <r>` (auto-derived; override when needed)
- `--label <name>` (repeatable) and `--docs-only` convenience alias
- `--dry-run` (prints API payload JSON)
