# Handoff Document — Collaboration Options (Standalone)

**Created:** 2025-10-23  
**For:** New chat session  
**Project:** `collaboration-options`

## Overview

Quick documentation project to clarify `.github/` boundaries and collaboration surfaces while keeping the repo as source of truth.

### Project: Collaboration Options (Lite)

- **Goal:** Document when to use dedicated PR templates vs `docs/` placement
- **Complexity:** Very Low (4 tasks, 1 already complete)
- **Deliverable:** Clear guidance on `.github/` configuration-only boundaries

## Why This Is Standalone

- **No dependencies:** Doesn't block or depend on other projects
- **Isolated scope:** Only touches `.github/` boundaries and template placement
- **Quick win:** Can finish in single focused session

## Key Files to Review

- [`docs/projects/collaboration-options/erd.md`](./erd.md) — Requirements (Lite mode)
- [`.cursor/rules/github-config-only.mdc`](../../../../../.cursor/rules/github-config-only.mdc) — `.github/` boundaries rule
- [`.github/`](../../../../../.github/) — Current configuration structure

## Current State

**Completed:**

- [x] 1.0 Draft ERD skeleton with boundaries and templates

**Remaining:**

- [ ] 2.0 Add examples of dedicated PR templates
- [ ] 3.0 Link ERD from README and progress doc
- [ ] 4.0 Confirm preferred remote sync provider(s) and enablement criteria

## Acceptance Criteria

- [ ] `.github/` boundaries documented (what belongs, what doesn't)
- [ ] Examples provided for dedicated PR template placement
- [ ] Guidance for when to use dedicated templates vs `docs/` placement
- [ ] Cross-references added to README
- [ ] Remote sync options documented (optional, explicitly gated)

## Suggested Approach

### Step 1: Document `.github/` Boundaries (30 min)

1. **Read existing rule:** `.cursor/rules/github-config-only.mdc`
2. **Clarify in ERD:** What goes in `.github/` (workflows, CODEOWNERS, generic templates)
3. **Clarify what doesn't:** Feature-specific docs, process checklists, playbooks

### Step 2: Add PR Template Examples (15 min)

4. **Document pattern:** `.github/PULL_REQUEST_TEMPLATE/<feature>.md` for opt-in
5. **Add example:** Show how feature-specific template would be structured
6. **Contrast with generic:** Explain when to use dedicated vs generic template

### Step 3: Remote Sync Options (15 min)

7. **Document providers:** Google Docs, Confluence (explicitly opt-in)
8. **Enablement criteria:** Requires credentials, explicit config
9. **Default behavior:** Local artifacts remain canonical (repo is source of truth)

### Step 4: Cross-Reference (10 min)

10. **Link from README:** Add to projects list
11. **Update progress docs:** If split-progress exists, add reference

**Total estimated effort:** ~1 hour focused work

## Risk Notes

- **Very low risk:** Documentation-only, no code changes
- **Watch for:** Template sprawl (prefer opt-in templates to avoid clutter)

## Related Projects

- **Dependencies:** None
- **Related rule:** `github-config-only.mdc` (reinforces boundaries)
- **Cross-references:** `split-progress` (collaboration surface discussion)

## Starting the Session

### Opening Prompt Template

```
I'm working on the collaboration-options project (standalone, quick win).

Context:
- Read: docs/projects/collaboration-options/HANDOFF.md
- Project: docs/projects/collaboration-options/

This is a simple documentation task to clarify .github/ boundaries and PR template usage.

Let's review the ERD and complete the remaining 3 tasks.
```

## Questions to Resolve

1. **PR templates:** Should we create actual example templates, or just document the pattern?
2. **Remote sync:** Which providers to document? (Google Docs, Confluence, others?)
3. **Enablement:** What level of detail for remote sync setup? (Brief pointer vs full guide)

## Success Metrics

- Clear distinction between `.github/` (config) and `docs/` (feature docs)
- Actionable examples for when to use dedicated PR templates
- Remote sync options documented with explicit opt-in requirement

## Anti-Patterns to Avoid

- **Don't:** Add feature-specific sections to generic PR template
- **Don't:** Store product docs or playbooks in `.github/`
- **Don't:** Auto-enable remote sync without explicit consent

## Follow-Up Actions

After completion:

1. Validate ERD with `.cursor/scripts/erd-validate.sh docs/projects/collaboration-options/erd.md`
2. Mark project complete with `.cursor/scripts/project-complete.sh collaboration-options`
3. Update project status in README

---

**Next Steps:** Start new chat, paste opening prompt template, review ERD + tasks, complete in ~1 hour.
