---
"cursor-rules": patch
---

Fix automated PR queue backup by using AUTO_MERGE_TOKEN for PR creation. PRs created with GITHUB_TOKEN don't trigger CI workflows, preventing auto-merge from completing.

