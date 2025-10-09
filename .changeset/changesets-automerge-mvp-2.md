---
"cursor-rules": patch
---

Refine Changesets auto-merge to MVP: `workflow_run` (Changesets) + optional manual dispatch.

- Enable Auto-merge after the Changesets workflow completes successfully
- Keep `workflow_dispatch pr=<number>` for backfill on existing release PRs
- Single job resolves the target PR (title/head + bot) and enables Auto-merge (squash)


