---
"cursor-rules": minor
---

Add automated projects README generator and auto-archive action

Projects README Generator:
- Automated README generation with 3-table structure (Active/Pending/Archived)
- ERD migration and validation tooling
- Fixed 65+ project ERDs (100% validation pass rate)
- Eliminated all unknown statuses
- npm script: `npm run generate:projects-readme`

Auto-Archive Action (Phases 1-3):
- Completion detection script with 3-criteria validation
- Automatic link fixing after archival
- GitHub workflow for zero-touch project archival
- Assistant rules integration for final-summary prompting

