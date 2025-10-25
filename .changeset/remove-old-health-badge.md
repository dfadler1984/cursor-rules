---
"cursor-rules": patch
---

Remove obsolete health-badge.yml workflow

- Deleted `.github/workflows/health-badge.yml` which was replaced by PR-based approach
- Old workflow committed directly to main and was failing consistently
- New `repo-health-badge.yml` workflow remains as canonical health badge automation
