---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-10-23
---

# Final Summary — Platform Capabilities Generic

## Summary

Successfully generalized Cursor-specific `cursor-platform-capabilities.mdc` into vendor-agnostic `platform-capabilities.mdc` that applies to any product or platform. Created new generic rule with examples for good/bad citations, uncertainty handling, and conflict resolution. Deprecated Cursor-specific rule to lightweight pointer retaining Cursor doc links for convenience. All cross-references updated to point to generic rule.

## Impact

- **Baseline → Outcome:** Platform capabilities guidance — Cursor-specific only → Vendor-agnostic (GitHub, Vercel, AWS, any platform)
- **Rule reusability:** 1 platform → Universal (any product/platform)
- **AlwaysApply:** Cursor rule was `alwaysApply: true` → Generic rule `alwaysApply: false` (lighter attachment via intent routing)
- **Duplication prevention:** Future platforms → Reference generic rule, not create new vendor-specific rules
- **Notes:** Low-risk refactoring that enables consistent citation standards across all platform references. Paired with capabilities-rules for coordinated schema work.

## Retrospective

### What worked

- **Generic examples:** Used placeholder examples (service X, service Y) instead of specific vendors made rule truly reusable
- **Deprecation strategy:** Keeping Cursor-specific file as pointer (not deletion) preserves convenience links
- **AlwaysApply reduction:** Changing from `true` to `false` reduces attachment noise; intent routing handles when needed
- **Paired execution:** Coordinating with capabilities-rules ensured schema references aligned

### What to improve

- **Could add more examples:** Show citations for common platforms (GitHub, AWS, Vercel) as reference patterns
- **Future validation:** Consider validation that checks for missing citations when stating platform capabilities
- **README note:** Deferred optional README update about genericization

### Follow-ups

- Monitor usage to validate generic rule covers real-world platform citation needs
- Add platform-specific examples if patterns emerge
- Consider similar genericization for other vendor-specific rules if found

## Links

- ERD: `./erd.md`
- Completion Summary: `./COMPLETION-SUMMARY.md` — Detailed deliverables
- New generic rule: `.cursor/rules/platform-capabilities.mdc`
- Deprecated rule: `.cursor/rules/cursor-platform-capabilities.mdc` (now pointer)
- Paired with: [capabilities-rules](../capabilities-rules/final-summary.md)

## Credits

- Owner: rules-maintainers
- Session: 2025-10-23 (Chat 1 — Capabilities Pair)
- Deliverables: 1 new generic rule, 1 deprecated pointer, updated cross-references

