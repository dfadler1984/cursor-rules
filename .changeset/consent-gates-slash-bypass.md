---
"cursor-rules": minor
---

Implement slash command consent bypass and session allowlist visibility

**Core consent improvements:**
- Slash commands (`/commit`, `/branch`, `/pr`, `/allowlist`) now bypass consent gate entirely
- Added `/allowlist` cursor command to display active session consent grants
- Documented grant/revoke syntax for session allowlist management
- Added natural language triggers for allowlist queries

**Impact:** Eliminates over-prompting on slash commands. Typing `/commit` is direct consent; no "Proceed?" prompt needed.

