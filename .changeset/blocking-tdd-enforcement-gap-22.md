---
"cursor-rules": minor
---

feat(behavior): add blocking TDD enforcement for file creation

Fixes Gap #22 (TDD violations on new file creation):

- Expand TDD gate scope: "editing" → "creating or editing"
- Add file pairing validation: _.sh → _.test.sh, _.ts → _.test.ts|\*.spec.ts
- Remove escape hatch: test file requirement now absolute
- Add mechanical blocking: FAIL = message blocked, must create test first

Evidence: 12 violations documented (5 with alwaysApply rules loaded)
Pattern: Gaps #18, #22 both created NEW files without tests
Root cause: TDD gate only covered edits, not creation
Solution: File pairing check in pre-send gate with no exceptions

Impact: Prevents TDD violations through mechanical enforcement (not advisory)
