Final Summary — Auto‑merge Changesets Version PRs

- Workflow: .github/workflows/changesets-auto-merge.yml
- Token: AUTO_MERGE_TOKEN env secret mapped to GH_TOKEN
- Triggers: workflow_run (Changesets) + workflow_dispatch
- Validation: auto‑merge enabled; merges after required checks
