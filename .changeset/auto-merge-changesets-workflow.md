---
"cursor-rules": patch
---

Enable auto-merge for Changesets release PRs via GitHub Actions.

- Add `.github/workflows/auto-merge-changesets.yml` using `peter-evans/enable-pull-request-automerge@v3`
- Auto-enables PR auto-merge for titles starting with "Version Packages" after required checks pass
- Requires repo setting "Allow auto-merge" and branch protection checks


