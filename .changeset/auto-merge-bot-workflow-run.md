---
"cursor-rules": patch
---

Improve Changesets auto-merge reliability by reacting to the release workflow completion.

- Add `workflow_run` trigger for the `Changesets` workflow (types: completed)
- On success, find the open “Version Packages” PR and enable Auto-merge
- Keep manual `workflow_dispatch` for backfill


