---
"cursor-rules": patch
---

Add a reliable workflow to auto‑enable GitHub Auto‑merge for Changesets “Version Packages” PRs.

- Dual triggers (`pull_request`, `pull_request_target`) with strict scope (title/head + author)
- Manual `workflow_dispatch` to backfill enabling auto‑merge on an existing release PR
- Permissions: `pull-requests: write`, `contents: read`


