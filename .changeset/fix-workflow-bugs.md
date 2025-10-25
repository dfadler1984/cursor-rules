---
"cursor-rules": patch
---

Fix health badge infinite loop and auto-archive auto-merge failure

- Health badge workflow now uses path filters to prevent infinite loop
- Auto-archive workflow uses correct auto-merge action (peter-evans/enable-pull-request-automerge@v3)
- Split auto-archive labels and auto-merge into separate steps
- Added skip-changeset label to auto-archive PRs
