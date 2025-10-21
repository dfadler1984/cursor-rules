# Pattern: Missing Rules vs Violated Rules

**Date**: 2025-10-20  
**Discovery**: During investigation about rule violations, discovered a rule violation caused by missing rule

---

## The Pattern

**Two types of compliance issues**:

### Type 1: Rules Exist But Are Violated

**Example: TDD (Before Investigation)**
- ✅ Rules exist: `tdd-first-js.mdc`, `tdd-first-sh.mdc`
- ✅ Globs work: Rules load when editing code
- ⚠️ 17% non-compliance (actually 8% after measurement fix)
- ❓ **Question**: Why violated when loaded?

**Investigation revealed**:
- Real compliance: 92% (measurement error corrected)
- One missing test (setup-remote.sh)
- NOT a widespread "rules ignored" problem

---

### Type 2: Rules Missing (Can't Be Followed)

**Example: Investigation Structure (This Session)**
- ❌ NO rule exists in `.cursor/rules/`
- ❌ Guidance only in separate project (`investigation-docs-structure/`)
- ❌ Can't load automatically (no globs, no triggers)
- ⚠️ Result: Violated structure by creating 12 files in root

**Root cause**:
- Rule CAN'T be followed if it doesn't exist
- Guidance exists but isn't accessible during work
- Similar to TDD having no globs (rule wouldn't load)

**Fix applied**:
- ✅ Created `investigation-structure.mdc` with globs
- ✅ Rule now loads when working on `docs/projects/**/*.md`
- ✅ Provides pre-file-creation checklist

---

## Key Distinction

| Aspect | Type 1: Violated | Type 2: Missing |
|--------|------------------|-----------------|
| **Rule exists?** | ✅ Yes | ❌ No |
| **Can load?** | ✅ Yes (globs/triggers) | ❌ No mechanism to load |
| **Compliance issue** | Agent ignores loaded rule | Agent can't follow non-existent rule |
| **Investigation** | Why ignored? | Why missing? |
| **Solution** | Improve enforcement (alwaysApply/external/routing) | **Create the rule first** |

---

## Discovery Process

### How We Found Type 2 (Missing Rule)

**1. User observation**: "Seems like you created a lot of files and it feels like you didn't follow the structure"

**2. Agent checked**: "Does structure guidance exist?"
- ✅ Found: `investigation-docs-structure/structure-standard.md`
- ✅ Has clear guidance (folders, naming, thresholds)

**3. Agent should have realized**: "This guidance should be a rule file!"
- ❌ But didn't create one or propose creating one
- ❌ Instead proceeded to violate the structure

**4. User insight**: "Seems like we need to create the rule file and we learned that we need to tell you to create a rule file when you discover that we could benefit from rules"

**5. Root cause identified**: NO `.cursor/rules/investigation-structure.mdc` exists

---

## When to Create vs When to Enforce

### Decision Framework

**When discovering guidance or patterns**:

```
1. Check: Does rule file exist in .cursor/rules/?
   ├─ YES → Type 1 problem (rule exists but violated)
   │   └─ Investigate why violated
   │       ├─ Measurement error?
   │       ├─ Rule unclear?
   │       ├─ Conflicting rules?
   │       └─ Habit/oversight?
   │
   └─ NO → Type 2 problem (rule missing)
       └─ CREATE RULE FIRST
           ├─ Extract guidance from project docs
           ├─ Create .cursor/rules/<name>.mdc
           ├─ Set appropriate globs/triggers
           └─ THEN enforcement becomes possible
```

---

## Self-Improve Pattern (Violated)

**self-improve.mdc says**: "When you notice patterns or observe rule gaps during work, flag them and propose improvements"

**I should have**:
1. ✅ Noticed: investigation-docs-structure has guidance
2. ❌ **Flagged**: "This should be a rule file in .cursor/rules/"
3. ❌ **Proposed**: "Should I create investigation-structure.mdc?"
4. ✅ After user approval: Create the rule

**What I actually did**:
1. ✅ Read the structure standard
2. ❌ Didn't flag that rule was missing
3. ❌ Proceeded to violate structure
4. ✅ User caught it: "you didn't follow the structure"

---

## Lessons Learned

### Lesson 1: Check for Rule File First

**Before following guidance** from a project doc:
1. Check: Is this in `.cursor/rules/`?
2. If NO: **Create rule or propose creating it**
3. If YES: Then investigate compliance

**Don't**: 
- Read guidance from project doc
- Try to follow it manually
- Violate it anyway because it's not in rules/

---

### Lesson 2: Pattern Observation → Rule Creation

**self-improve.mdc guidance** needs clarification:

**Current**: "Observe patterns → propose rule updates"

**Should add**: "Discover useful guidance in project docs → propose extracting to rule file"

**Triggers for rule creation**:
- Guidance in project docs that should apply repo-wide
- Structure standards that should enforce during work
- Patterns observed 3+ times
- **NEW**: Project documentation that should be accessible during work

---

### Lesson 3: Investigation About Violations Can Violate

**The irony**: 
- Investigating rule enforcement
- Discovering structure gaps
- **Violating structure in same investigation**

**The value**:
- Perfect test case (fresh violation to study)
- Same pattern as what we're investigating
- Meta-findings are first-class investigation data

**The lesson**:
- Apply findings to own process during investigation
- Meta-consistency matters
- Gaps discovered during work are investigation evidence

---

## Scripts & CI Guards (User Request)

### Proposed Scripts

**1. `validate-investigation-structure.sh <project-path>`**
- Check root file count (threshold: ≤7, warn >7, fail >10)
- Validate expected folders exist (when project has >15 files)
- Report misplaced files (analysis in root, sessions in root, etc.)
- Suggest reorganization

**2. `suggest-file-location.sh [--file-name <name>] [--content-type <type>]`**
- Interactive: asks category (analysis/findings/sessions/etc.)
- Suggests correct folder
- Can be used before file creation

**3. `check-root-proliferation.sh`**
- Scans all `docs/projects/*/`
- Reports projects with >7 root files
- Lists candidates for reorganization

---

### Proposed CI Guards

**1. Pre-commit hook** (local):
```bash
# In .git/hooks/pre-commit
# Check if investigation project root exceeds threshold
for project in docs/projects/*/; do
  root_files=$(ls "$project"/*.md 2>/dev/null | wc -l)
  if [[ $root_files -gt 7 ]]; then
    echo "⚠️  Warning: $project has $root_files files in root (threshold: 7)"
    echo "   Consider reorganizing per investigation-structure.mdc"
  fi
done
```

**2. CI check** (GitHub Actions):
```yaml
- name: Validate Investigation Structure
  run: |
    bash .cursor/scripts/validate-investigation-structure.sh \
      docs/projects/rules-enforcement-investigation
```

**Fail if**: >10 files in root OR missing expected folders when project has >15 files total

---

## Action Items

### Immediate (This PR)

- [x] Reorganize 12 files to correct folders
- [x] Create investigation-structure.mdc rule
- [x] Document Gap #11 structure violation
- [x] Document pattern (missing vs violated rules)
- [ ] Push to update PR

### Short-Term (Follow-up)

- [ ] Create `validate-investigation-structure.sh` script
- [ ] Add to CI workflow
- [ ] Update self-improve.mdc: clarify rule creation triggers
- [ ] Test rule loads correctly (create file in docs/projects/, verify rule attaches)

### Medium-Term (Future)

- [ ] Create file placement helper script
- [ ] Add pre-commit hook for root proliferation
- [ ] Create root proliferation checker (scan all projects)
- [ ] Document in capabilities.mdc

---

## Success Criteria

**Rule creation successful** when:
1. ✅ investigation-structure.mdc exists in .cursor/rules/
2. ✅ Has globs: `docs/projects/**/*.md`
3. ✅ Loads when working on investigation projects
4. ✅ Provides actionable pre-file-creation checklist
5. ⏸️ Tested: Create file, verify rule attaches and guides placement

**Scripts/CI successful** when:
1. ⏸️ Validator detects root proliferation
2. ⏸️ CI blocks PRs with >10 root files
3. ⏸️ Pre-commit warns about threshold violations

---

**Status**: Rule created, structure fixed, pattern documented  
**Next**: Scripts and CI guards to prevent future violations  
**Meta-lesson**: Distinguish "rule missing" from "rule violated" - create before enforcing

