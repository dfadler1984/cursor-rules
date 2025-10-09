---
"cursor-rules": patch
---

Simplify Changesets auto-merge to a minimal, reliable workflow.

- Use `workflow_run` on `Changesets` (types: completed) to enable Auto-merge
- Keep optional `workflow_dispatch pr=<number>` for backfill on existing PRs
- Single job: resolve target PR (title/head + bot) and enable Auto-merge (squash)
