---
"cursor-rules": patch
---

Define TDD scope boundaries, add slash command consent, and remove static command catalog

- **TDD Scope**: Narrowed tdd-first.mdc to code files only (*.ts, *.tsx, *.js, *.jsx, *.mjs, *.cjs, *.sh)
- **TDD Validation**: Added tdd-scope-check.sh script with comprehensive test suite (24 assertions passing)
- **Slash Commands**: Added explicit consent policy - /branch, /commit, /pr execute immediately without "Proceed?" prompts
- **Command Discovery**: Removed static commands.caps.mdc; created project for dynamic discovery solution

