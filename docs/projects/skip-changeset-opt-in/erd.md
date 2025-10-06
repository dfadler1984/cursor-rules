---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Skip Changeset Opt-In (Lite)

Links: `.cursor/scripts/pr-create.sh` | `docs/projects/skip-changeset-opt-in/tasks.md`

## 1. Introduction/Overview

Make the `skip-changeset` label opt-in instead of default; require an explicit flag when creating PRs.

## 2. Goals/Objectives

- Add `--docs-only` or `--label skip-changeset` flag to opt-in
- Remove default auto-labeling behavior
- Document behavior in README and PR-create project

## 3. Functional Requirements

- If the flag is present, add the label via the API; otherwise, do not
- Preserve existing behavior for all other options
- Tests cover presence/absence of the label

## 4. Acceptance Criteria

- Default PRs do not include `skip-changeset`
- Flagged PRs include the label
- README updated with examples
