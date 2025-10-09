---
"cursor-rules": patch
---

Harden Changesets auto-merge enablement for release PRs.

- Switch workflow to `pull_request_target` to ensure sufficient permissions
- Add `workflow_dispatch` to enable auto-merge on an existing release PR (e.g., PR #52)
- Keeps scope limited to titles starting with "Version Packages" or `changeset-release/*`
