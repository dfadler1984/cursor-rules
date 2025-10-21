## Tasks — Rules & Documentation Quality Detection

**Status**: ACTIVE | Phase: Phase 1 | 0% Complete

---

## Phase 1: Duplicate Detection (~4 hours)

**Goal**: Create script to detect exact duplicate content blocks in rules

- [ ] 1.0 Duplicate detection script

  - [ ] 1.1 Create `rules-duplicates.sh` skeleton with flags (`--min-lines`, `--scope`, `--format`)
  - [ ] 1.2 Implement exact line matching algorithm (MD5 fingerprinting of N-line blocks)
  - [ ] 1.3 Add output formatting (text and JSON modes)
  - [ ] 1.4 Add scope filtering (rules only, docs only, or both)
  - [ ] 1.5 Handle edge cases (code blocks, front matter, quotes)

- [ ] 1.6 Testing suite

  - [ ] 1.7 Create test fixtures with known duplicates
  - [ ] 1.8 Write shell tests via `.cursor/scripts/tests/run.sh` harness
  - [ ] 1.9 Test edge cases (whitespace, similar-but-not-duplicate)
  - [ ] 1.10 Validate exit codes (0 = clean, 1 = duplicates found)

- [ ] 1.11 Documentation and integration
  - [ ] 1.12 Add usage documentation in script header (help text)
  - [ ] 1.13 Add examples to `docs/scripts/README.md`
  - [ ] 1.14 Create CI workflow step (`.github/workflows/quality-check.yml`)
  - [ ] 1.15 Test locally on current repo (baseline run)

**Acceptance**:

- Script detects ≥3 consecutive identical lines across files
- Reports file paths and line numbers
- Runs in <5 seconds on current repo
- CI fails when duplicates found
- Test coverage: 5+ test cases with fixtures

---

## Phase 2: Conflict Detection (~3 hours)

**Goal**: Detect contradictory guidance patterns across rules/docs

- [ ] 2.0 Conflict detection script

  - [ ] 2.1 Create `rules-conflicts.sh` with pattern matching engine
  - [ ] 2.2 Define top 10 contradiction patterns (hardcoded list)
  - [ ] 2.3 Implement grep-based pattern matching across files
  - [ ] 2.4 Add `--patterns-file` flag for custom patterns
  - [ ] 2.5 Report conflicts with context (surrounding lines)

- [ ] 2.6 Pattern library

  - [ ] 2.7 Document common contradiction patterns in script
  - [ ] 2.8 Examples: "always X" vs "never X", "must Y" vs "must not Y"
  - [ ] 2.9 Create pattern syntax guide (regex + explanation)
  - [ ] 2.10 Test patterns against current repo (baseline)

- [ ] 2.11 Testing and docs
  - [ ] 2.12 Create test fixtures with known conflicts
  - [ ] 2.13 Write shell tests for pattern matching
  - [ ] 2.14 Document pattern addition process
  - [ ] 2.15 Add CI integration

**Acceptance**:

- Detects hardcoded contradiction patterns
- Custom patterns supported via `--patterns-file`
- Reports file paths, line numbers, and matched patterns
- CI fails when conflicts found
- Test coverage: 10+ patterns tested

---

## Phase 3: Extended Reference Validation (~2 hours)

**Goal**: Extend link validation to docs/ and detect stale content

- [ ] 3.0 Reference validation extension

  - [ ] 3.1 Extend `rules-validate.sh` or create `rules-references.sh`
  - [ ] 3.2 Scan `docs/projects/*/` for broken cross-references
  - [ ] 3.3 Detect unreferenced files (no incoming links >180 days old)
  - [ ] 3.4 Flag stale `lastReviewed` dates (>90 days, existing feature)
  - [ ] 3.5 Add `--scope docs|rules|all` flag

- [ ] 3.6 Stale content detection

  - [ ] 3.7 Find files with no incoming references
  - [ ] 3.8 Cross-check with git history (last modified >180 days)
  - [ ] 3.9 Exclude intentionally standalone files (via config or pattern)
  - [ ] 3.10 Report with confidence level (certain vs. possible stale)

- [ ] 3.11 Testing and integration
  - [ ] 3.12 Create fixtures with broken links and stale files
  - [ ] 3.13 Test across rules and docs directories
  - [ ] 3.14 Validate ignore patterns work
  - [ ] 3.15 Add to CI workflow

**Acceptance**:

- Broken links detected in docs/ (not just rules/)
- Stale content flagged (no references + old modified date)
- Configurable thresholds (days since review/modification)
- CI fails on broken references
- Test coverage: broken links, stale files, ignore patterns

---

## Phase 4: Integration & Documentation (~1 hour)

**Goal**: Unify scripts, document workflow, integrate into developer experience

- [ ] 4.0 Wrapper script

  - [ ] 4.1 Create `rules-quality-check.sh --all` wrapper
  - [ ] 4.2 Run all checks in sequence (duplicates, conflicts, references)
  - [ ] 4.3 Aggregate results (combined report)
  - [ ] 4.4 Exit code: 0 only if all checks pass
  - [ ] 4.5 Add `--check <type>` to run individual checks

- [ ] 4.6 CI integration

  - [ ] 4.7 Update `.github/workflows/quality-check.yml` to use wrapper
  - [ ] 4.8 Add workflow status badge to README
  - [ ] 4.9 Configure failure notifications (GitHub Actions)
  - [ ] 4.10 Document CI behavior in `docs/scripts/README.md`

- [ ] 4.11 Developer experience

  - [ ] 4.12 Add pre-commit hook example (optional, not enforced)
  - [ ] 4.13 Document usage in `docs/scripts/README.md`
  - [ ] 4.14 Update `capabilities.mdc` with new scripts
  - [ ] 4.15 Create quick reference card (common flags/workflows)

- [ ] 4.16 Validation and rollout
  - [ ] 4.17 Run full suite on current repo (baseline quality report)
  - [ ] 4.18 Document remediation process for found issues
  - [ ] 4.19 Update project README with outcomes
  - [ ] 4.20 Mark project COMPLETE

**Acceptance**:

- Single command runs all quality checks
- CI enforces quality gates
- Documentation covers usage and remediation
- Pre-commit hook available (opt-in)
- Baseline quality report generated

---

## Dependencies

- **Phase 2 → Phase 1**: Conflict detection can start after duplicate detection structure proven
- **Phase 3 → Phase 1**: Reference validation follows similar pattern to duplicates
- **Phase 4 → Phase 1-3**: Wrapper requires all individual scripts complete

## Relevant Files

- `.cursor/scripts/rules-validate.sh` — Existing validator to extend/reference
- `.cursor/scripts/rules-list.sh` — Example of script structure
- `.cursor/scripts/tests/run.sh` — Test harness for shell scripts
- `.cursor/rules/shell-unix-philosophy.mdc` — Design principles
- `.cursor/rules/rule-maintenance.mdc` — Maintenance workflow
- `docs/scripts/README.md` — Script documentation hub

## Notes

- Start with Phase 1 (duplicates) as proof of concept
- Parallelize Phases 2-3 if desired (different concerns)
- Phase 4 is lightweight integration work
- Keep scripts <200 lines each (Unix philosophy)
- Use existing test harness for consistency
