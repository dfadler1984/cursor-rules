---
status: completed
completed: 2025-10-06
owner: rules-maintainers
---

# Engineering Requirements Document — Skip Changeset Opt-In (Lite)

Links: `.cursor/scripts/pr-create.sh` | `docs/projects/_archived/2025/skip-changeset-opt-in/tasks.md`

## 1. Introduction/Overview

Make the `skip-changeset` label opt-in instead of default; require an explicit flag when creating PRs.

## 2. Goals/Objectives

- Add `--docs-only` (alias) and/or `--label skip-changeset` flags to opt-in
- Support multiple `--label <name>` flags; `--docs-only` maps to `--label skip-changeset`
- Document behavior in README and PR-create project

## 3. Functional Requirements

- Default: no labels are applied
- If any label flags are present, after PR creation call the Issues API to add labels to the created PR (issue number)
- For `--docs-only`, add `skip-changeset` label; for generic `--label`, add provided label(s)
- Preserve existing behavior for all other options
- Tests cover presence/absence of intended labels and alias behavior

## 4. Acceptance Criteria

- Default PRs do not include `skip-changeset`
- Flagged PRs include the specified label(s) (`--docs-only` adds `skip-changeset`)
- Dry-run path emits a labels section indicating which label(s) would be added
- README updated with examples for `--docs-only` and `--label`

## 5. Risks/Edge Cases

- `jq` needed to extract PR number for labeling; require only when labeling is requested
- Missing label permissions or non-existent labels should fail gracefully with a clear error
- Network/API failures when labeling: report non-zero exit, print compare URL from create step if applicable
