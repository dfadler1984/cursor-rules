---
"cursor-rules": patch
---

Reorganize investigation documentation structure

- refactor: Reorganized rules-enforcement-investigation from 40 files in 5 directories to 10 purpose-driven folders
- feat: Created 3 sub-projects (h2-send-gate-investigation, h3-query-visibility, slash-commands-runtime-routing)
- feat: Added coordination.md to track sub-projects
- feat: Created investigation-docs-structure project with reusable structure standard
- docs: Gap #11 documented - investigation documentation structure not defined

Structure changes: findings/, decisions/, guides/, protocols/, sessions/, test-results/, analysis subfolders, _archived/. All files preserved via git mv.
