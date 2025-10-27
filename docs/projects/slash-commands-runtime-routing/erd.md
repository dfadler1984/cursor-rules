---
status: completed
owner: repo-maintainers
created: 2025-10-16
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Slash Commands Runtime Routing

Mode: Lite

## 1. Introduction/Overview

**Hypothesis**: Explicit slash commands would create stronger forcing function than intent routing.

**Outcome**: ❌ **NOT VIABLE** — Platform constraint discovered.

## Status

✅ **INVESTIGATION COMPLETE** — Determined approach not viable due to Cursor platform behavior.

**Key Finding:**

- Cursor intercepts `/` prefix for prompt templates before messages reach assistant
- Runtime routing via slash commands incompatible with Cursor's design
- Time saved: One real usage attempt (30 seconds) found design mismatch

**Parent Investigation**: [rules-enforcement-investigation](../rules-enforcement-investigation/)

## Conclusion

Project closed as not viable. Slash command approach abandoned in favor of intent routing optimization (see: [routing-optimization](../routing-optimization/)).

## References

- See: [`README.md`](./README.md) — Full investigation details
- Related: [assistant-self-testing-limits](../assistant-self-testing-limits/) — Testing methodology insights
