---
"cursor-rules": minor
---

Restore repository health score to 100/100 and add auto-updating health badge

**Health Score Improvements:**
- Document 20 missing scripts in capabilities.mdc (Documentation: 0→100/100)
- Fix test colocation issues (Test Quality: 60→100/100)
- Overall health score: 52/100 → 100/100

**New Features:**
- Badge generator script with comprehensive tests (18/18 passing)
- GitHub Action workflow to auto-update badge on push to main
- Health badge displayed in root README
- Color-coded by score: red (<70), yellow (70-89), green (90-100)
