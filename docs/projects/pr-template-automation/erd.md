---
status: completed
completed: 2025-10-04
owner: rules-maintainers
---

# Engineering Requirements Document — PR Template Automation

Mode: Lite

## 1. Introduction/Overview

Ensure PRs created via scripts/API include the repository’s PR template by default, matching GitHub UI behavior and improving review quality.

## 2. Goals/Objectives

- Auto-apply `.github/pull_request_template.md` (or first file in `.github/PULL_REQUEST_TEMPLATE/`) when using the PR creation script.
- Provide flags to opt-out or select a specific template.
- Preserve .github boundaries: keep the template generic and config-only.

## 3. Functional Requirements

1. Script Behavior

   - Default: prefill PR body with template contents.
   - `--no-template`: disable template injection.
   - `--template <path>`: use a specific template file.
   - `--body-append <text>`: append additional context under a `## Context` section.

2. Template Discovery

   - Prefer `.github/pull_request_template.md`.
   - Fallback to the first file under `.github/PULL_REQUEST_TEMPLATE/` (sorted by name).

3. Rules Update
   - Update `github-api-usage.caps` to require template injection by default for script-created PRs.
   - Document flags and fallbacks.

## 4. Non-Functional Requirements

- No external dependencies; bash-only.
- Backwards-compatible; existing calls work without flags.
- Clear failure messages when template file is missing/read fails.

## 5. Acceptance

- Creating a PR with the script includes the template body by default.
- Passing `--no-template` creates a PR without injecting the template.
- Passing `--template` uses that file.
- Passing `--body-append` appends under `## Context`.

## 6. Open Questions

- Should we allow environment override (e.g., `PR_TEMPLATE_PATH`)?
- Should we support multiple named templates via conventional filenames?
