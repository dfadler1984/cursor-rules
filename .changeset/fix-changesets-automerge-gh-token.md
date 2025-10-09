---
"cursor-rules": patch
---

ci: fix Changesets auto-merge by exporting GH_TOKEN and using github.token

This ensures the `enable-pull-request-automerge` action's gh CLI has the
required token and reliably enables auto-merge on Changesets release PRs.
