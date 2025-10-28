---
"cursor-rules": patch
---

Fix automated PR queue backup with two improvements:

1. Use AUTO_MERGE_TOKEN for PR creation (PRs created with GITHUB_TOKEN don't trigger CI workflows)
2. Add idempotent PR creation (check-then-update pattern prevents duplicate PRs)

