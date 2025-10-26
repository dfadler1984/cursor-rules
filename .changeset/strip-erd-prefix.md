---
"cursor-rules": patch
---

Strip repetitive "Engineering Requirements Document" prefix from project titles

- Improves projects README scannability by removing ~40 chars of redundant text per row
- Added clean_title() function to strip common prefixes
- Added test coverage for title cleaning
- Regenerated projects README with cleaned titles (~3,800 chars removed)
