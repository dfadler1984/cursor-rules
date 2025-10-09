---
"cursor-rules": patch
---

Switch Changesets auto-merge to use squash method.

- Update `.github/workflows/changesets-auto-merge.yml` to `merge-method: squash` in both jobs so Version Packages PRs produce a single clean commit when merged.


