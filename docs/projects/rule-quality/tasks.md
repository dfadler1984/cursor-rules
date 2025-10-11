## Tasks — ERD: Rule Quality & Consolidation

## Relevant Files

- `docs/projects/rule-quality/erd.md`
- `docs/projects/rule-quality/discussions.md`
- `.cursor/rules/front-matter.mdc`
- `.cursor/rules/rule-maintenance.mdc`
- `.cursor/rules/rule-quality.mdc`

## Todo

- [x] 1.0 Draft ERD and Discussions capturing consolidation/validation workflow
- [x] 2.0 Add tasks.md and link project from projects index
- [x] 3.0 Create `global-defaults.mdc` and update cross-links
- [x] 4.0 Merge testing family into `testing.mdc`; keep `testing.caps.mdc`
- [x] 4.1 Fold `critical-thinking.mdc` into `direct-answers.mdc`; add deprecation header + pointer
- [x] 4.2 Fold `task-list-process.mdc` into `project-lifecycle.mdc` (decide thin stub vs removal); update cross-links
- [x] 4.3 Fold `capabilities-discovery.mdc` into `capabilities.mdc` (Discovery section); add deprecation header + pointer
- [x] 5.0 Add validation script (front matter, links, globs breadth, duplication, caps pairing)
- [x] 5.1 Link hygiene sweep and redirects after consolidations (fix internal references; update "See also")
- [x] 5.2 Update `.cursor/rules/capabilities.mdc` to reflect new structure (moved up from optional)
- [x] 5.3 Enforce renames via `.cursor/scripts/links-check.sh` and `.cursor/scripts/rules-validate.sh`; no manual matrix
- [x] 6.0 Add routing sanity prompts/tests; verify minimal attachments
- [x] 7.0 Run validator, fix findings, and re-run
- [x] 7.1 Update `lastReviewed` and re-check `healthScore` for all edited rules
- [x] 8.0 Announce consolidation plan and set monthly/quarterly review cadence
- [x] 9.0 (moved to 5.2): update `capabilities.mdc` after consolidation

## Caps Consolidation

- [x] C1. Inventory `.caps.mdc` and finalize keep/remove list (with rationale)
- [x] C2. Remove low‑value `.caps.mdc` files; add “Quick Reference” subsection to main rules where helpful
- [x] C3. Update `capabilities.mdc` to catalog main rules; note quick refs for kept caps
- [x] C4. Run links/validator; fix references to removed caps; re-run
- [x] C5. Update `lastReviewed` on changed rules; adjust `healthScore` if scope changed

## Notes

- Validator tests relocated to `.cursor/scripts/` for colocation with `rules-validate.sh`.
