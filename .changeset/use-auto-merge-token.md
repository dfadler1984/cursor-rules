---
"cursor-rules": patch
---

Use a PAT-backed secret for enabling PR auto-merge.

- Update `.github/workflows/changesets-auto-merge.yml` to use `secrets.AUTO_MERGE_TOKEN` instead of `secrets.GITHUB_TOKEN` to avoid GraphQL permission errors when enabling auto-merge.
