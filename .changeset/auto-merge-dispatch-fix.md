---
"cursor-rules": patch
---

Fix manual dispatch for enabling auto-merge on Changesets release PRs.

- Use `github.rest.pulls.list` in `actions/github-script@v7`
- Add guard to fail fast when no release PR is found


