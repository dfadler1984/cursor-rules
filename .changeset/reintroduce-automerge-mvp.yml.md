---
"cursor-rules": patch
---

Reintroduce Changesets auto-merge MVP using `workflow_run` + optional `workflow_dispatch`.

- Enable Auto-merge when the `Changesets` workflow completes successfully
- Keep manual `workflow_dispatch pr=<number>` for backfill on existing release PRs


