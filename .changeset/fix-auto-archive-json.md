---
"cursor-rules": patch
---

Fix auto-archive workflow JSON output format

- Fixed multiline JSON output to use heredoc format for GITHUB_OUTPUT
- Follows GitHub Actions best practices for multiline values
- Unblocks automatic archival of completed projects
