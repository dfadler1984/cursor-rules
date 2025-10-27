# Audit Checklist

Reusable checklist for auditing archived projects.

---

## Project: `<slug>`

**Audited**: YYYY-MM-DD  
**Auditor**: [Name/Assistant]  
**Location**: `docs/projects/_archived/YYYY/<slug>/`

---

## 1. Task Completion

- [ ] All required (non-optional) tasks are checked
- [ ] Optional tasks are handled:
  - [ ] Completed (checked), OR
  - [ ] In `## Carryovers` section, OR
  - [ ] Explicitly deferred with rationale
- [ ] No half-checked parent tasks (if parent checked, all children must be checked or moved to carryovers)

**Notes**:

---

## 2. Artifact Migration

### Rules

- [ ] Rule files mentioned in tasks exist in `.cursor/rules/`
- [ ] Or: explicitly marked as skipped/deferred in tasks


**Actual locations**: (verify in `.cursor/rules/`)

**Gaps**: (any missing?)

### Scripts

- [ ] Script files mentioned in tasks exist in `.cursor/scripts/`
- [ ] Or: explicitly marked as skipped/deferred in tasks


**Actual locations**: (verify in `.cursor/scripts/`)

**Gaps**: (any missing?)

### Documentation

- [ ] Documentation artifacts exist in expected `docs/` locations
- [ ] Or: explicitly marked as skipped/deferred


**Actual locations**: (verify paths)

**Gaps**: (any missing?)

### Tests

- [ ] Tests colocated with implementations
- [ ] Or: explicitly deferred with rationale


**Actual locations**: (verify colocation)

**Gaps**: (any missing?)

---

## 3. Archival Artifacts

- [ ] `COMPLETION-SUMMARY.md` exists
- [ ] `README.md` shows completion status
- [ ] `erd.md` updated with completion date and outcome

**Notes**:

---

## 4. Cross-References

- [ ] Rules reference correct file paths (no broken links to moved files)
- [ ] Scripts exist where referenced in rules/docs
- [ ] No broken internal links in project docs

**Broken references found**: (list any)

---

## 5. Findings Summary

**Total findings**: [count]

**Categories**:

- Incomplete tasks: [count]
- Missing migrations: [count]
- Missing archival artifacts: [count]
- Broken references: [count]

**Severity**:

- Critical (missing implementations): [count]
- Moderate (incomplete documentation): [count]
- Minor (formatting/links): [count]

---

## 6. Remediation Plan

**Immediate fixes needed**:

1. [Action item]

**Deferred to carryovers**:

1. [Action item]

**No action needed**:

- [Rationale]

---

## Template Usage

1. Copy this template for each project audit
2. Fill in project-specific details
3. Work through checklist systematically
4. Document findings in `findings/` if substantial
