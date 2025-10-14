## Tasks — Script Refinement (Optional Polish)

**Parent project:** [shell-and-script-tooling](../shell-and-script-tooling/erd.md)

## Relevant Files

- `docs/projects/script-refinement/erd.md`
- `.cursor/scripts/checks-status.sh` (257 lines, extraction candidate)
- `.cursor/scripts/rules-validate-format.sh` (226 lines, split candidate)
- `.cursor/scripts/rules-validate.sh` (orchestrator, would need update if 2.0 completes)

## Context

**Why this is a separate project:**

This work was deferred from shell-and-script-tooling (Task 20.4, 20.5) as optional polish. Infrastructure is complete; these are refinement opportunities with diminishing returns.

**What's already done in parent:**

- ✅ D1-D6 infrastructure complete
- ✅ 3 major orchestrators complete (839 lines reduced)
- ✅ 9 focused alternatives created
- ✅ Enforcement rule active
- ✅ All tests passing (56/56)

## Todo

### Phase 1: checks-status Extraction

- [ ] 1.0 Extract checks-status.sh into 3 focused scripts
  - [ ] 1.1 Create `checks-fetch.sh` (~100 lines)
    - Fetch GitHub check runs via API
    - Output JSON only
    - Flags: --pr, --owner, --repo, --format json
  - [ ] 1.2 Create `checks-format.sh` (~80 lines)
    - Accept JSON input (stdin or file)
    - Format for display (table, list, etc.)
    - Flags: --format table|list|json
  - [ ] 1.3 Create `checks-wait.sh` (~80 lines)
    - Polling wrapper for checks-fetch
    - Flags: --timeout, --interval, --pr
    - Uses checks-fetch internally
  - [ ] 1.4 Add tests for each new script (TDD)
    - checks-fetch: API call mocking, JSON output
    - checks-format: formatting variants
    - checks-wait: polling logic, timeout handling
  - [ ] 1.5 Update checks-status.sh to orchestrator (~60 lines)
    - Call focused scripts based on flags
    - Maintain backward compatibility
  - [ ] 1.6 Verify all checks-status tests pass
  - [ ] 1.7 Backup original as checks-status-legacy.sh

### Phase 2: rules-validate-format Split

- [ ] 2.0 Split rules-validate-format.sh into 2 focused scripts
  - [ ] 2.1 Create `rules-validate-csv.sh` (~100 lines)
    - Validate CSV spacing in globs/overrides
    - Validate boolean casing in alwaysApply
    - Auto-fix capability
  - [ ] 2.2 Create `rules-validate-structure.sh` (~120 lines)
    - Validate embedded front matter
    - Validate duplicate headers
    - Check deprecated references
  - [ ] 2.3 Add tests for each new script (TDD)
  - [ ] 2.4 Update rules-validate.sh orchestrator
    - Call rules-validate-csv + rules-validate-structure
    - Remove rules-validate-format from orchestrator
  - [ ] 2.5 Deprecate rules-validate-format.sh
    - Add notice recommending focused alternatives
  - [ ] 2.6 Verify all rules-validate tests still pass
  - [ ] 2.7 Backup original as rules-validate-format-legacy.sh

### Phase 3: Documentation & Cleanup

- [ ] 3.0 Update documentation
  - [ ] 3.1 Update docs/scripts/README.md with new scripts
  - [ ] 3.2 Update shell-and-script-tooling/MIGRATION-GUIDE.md
  - [ ] 3.3 Document composition patterns
- [ ] 4.0 Final validation
  - [ ] 4.1 All tests passing
  - [ ] 4.2 All validators passing
  - [ ] 4.3 No Unix Philosophy violations > 200 lines

## Success Metrics

- **Lines reduced:** ~450 additional (checks-status + rules-validate-format)
- **Violations eliminated:** 2 (down to 0 violations > 200 lines)
- **Scripts created:** 5 new focused scripts
- **Tests:** All passing, comprehensive coverage

## Notes

**Estimated effort:** 5-6 hours

**Can be deferred indefinitely** - parent project complete, enforcement rule prevents new violations, focused alternatives already available for most use cases.

**Priority:** P3 - Optional polish work
