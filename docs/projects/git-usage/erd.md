---
status: active
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Git Usage via MCP (Lite)

Mode: Lite


Links: `.cursor/rules/git-usage.mdc` | `docs/projects/git-usage/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Define safe, consistent Git flows with MCP-backed operations (commits/PRs/branches), local fallbacks, and pre-commit/test gates.

## 2. Goals/Objectives

- Conventional branch naming and commit messages
- MCP-first for commits/PRs; local fallback with clear prompts
- Enforce lint/test gates before commit

## 3. Functional Requirements

- Branches: `<login>/<type>-<feature>`
- Commits: Conventional headers; include test results summary
- PRs: Include spec diff/links; reference issues when configured
- Gates: run relevant tests/lint; block on failures

## 4. Acceptance Criteria

- Examples for new branch, commit, PR with MCP and local flows
- Gate descriptions and expected prompts documented

## 5. Risks/Edge Cases

- MCP auth/rate limits; degrade gracefully and print next steps
- Repository policies (protected branches); prompt for alternatives

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and split-progress doc

## 7. Testing

- Dry-run: Compose a commit and PR body with placeholders; verify prompts

---

Owner: rules-maintainers

Last updated: 2025-10-02
