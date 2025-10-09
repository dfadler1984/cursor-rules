---
"cursor-rules": patch
---

ci: use AUTO_MERGE_TOKEN for enable-pull-request-automerge

Switch the auto-merge workflow to a PAT-backed secret so the gh CLI
and action have permission to enable auto-merge on Changesets PRs.
