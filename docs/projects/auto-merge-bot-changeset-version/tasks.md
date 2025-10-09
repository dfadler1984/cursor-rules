## Tasks — ERD: Auto‑merge Changesets Version PRs

## Relevant Files

- `docs/projects/auto-merge-bot-changeset-version/erd.md`
- `.github/workflows/changesets-auto-merge.yml`

## Todo

- [x] 1.0 Draft ERD (Lite) for auto‑merge of Changesets Version PRs
- [x] 2.0 Implement workflow: dual triggers + strict filter + dispatch
  - Title starts with "Version Packages" OR head starts with `changeset-release/`
  - Author is `github-actions[bot]`
- [x] 2.1 Create new workflow file `.github/workflows/changesets-auto-merge.yml`
- [x] 2.2 Remove event-name guards; keep only scoped `if:` conditions
- [x] 2.3 Keep `workflow_dispatch` with optional `pr` input
- [x] 3.0 Manual dispatch resolver uses `github.rest.pulls.list`; fail clearly if none
- [x] 3.1 Input validation: if `pr` supplied, ensure it’s numeric and open
- [x] 4.0 Permissions/settings: `pull-requests: write`, enable repo Auto‑merge, require checks
- [x] 5.0 Observability: log targeted PR and matched condition
- [x] 9.0 Add Changeset (patch) describing the workflow replacement

## Post merge

- [ ] 6.0 Validate on a live Version Packages PR (auto‑merge banner; merges after checks)
- [ ] 6.1 Backfill: run manual dispatch with `pr=<current release PR>`
- [ ] 6.2 Confirm merge occurs automatically after required checks pass
- [ ] 7.0 Document runbook and link from README/rules
- [ ] 8.0 Delete obsolete auto‑merge workflows after validation
- [ ] 10.0 Update ERD section(s) with final workflow path/name and screenshots/links
