---
"cursor-rules": patch
---

Remove legacy auto-merge workflow.

- Delete `.github/workflows/auto-merge-changesets.yml` to avoid duplicate runs and the deprecated `gh pr merge` path. Keep a single source of truth in `changesets-auto-merge.yml`.


