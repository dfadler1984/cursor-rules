---
"cursor-rules": patch
---

Add CI staleness check for projects README

- New workflow `.github/workflows/projects-readme-validate.yml` validates that `docs/projects/README.md` is up to date
- Triggers on changes to project ERDs, tasks, or the generator script
- Fails CI if README is out of sync with clear remediation steps
- Completes projects-readme-generator project (task 4.4)
