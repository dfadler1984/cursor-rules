---
"cursor-rules": patch
---

Fix health badge path filter to prevent workflow-triggered loop

- Removed `.github/workflows/**/*.yml` from path filters
- Health badge now only triggers on scripts and rules changes
- Prevents loop where workflow changes trigger badge updates
