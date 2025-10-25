---
"cursor-rules": patch
---

Replace manual validation with auto-fix workflow for projects README

- New workflow `projects-readme-update.yml` auto-generates README on main
- New workflow `projects-readme-auto-merge.yml` enables auto-merge on generated PRs  
- Modified `projects-readme-validate.yml` to PR-only validation
- Follows repo patterns (health-badge, changesets) for zero-touch maintenance
- Eliminates manual regeneration step, reduces rule context
