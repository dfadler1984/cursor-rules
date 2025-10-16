# Slash Commands: Prompt Templates Exploration

**Date**: 2025-10-16  
**Status**: PROPOSED  
**Background**: After Gap #10 correction, explore whether Cursor's prompt template design could improve compliance

---

## How Cursor Slash Commands Actually Work

Per [Cursor 1.6 changelog](https://cursor.com/changelog/1-6):

1. User types `/` in Agent input
2. Dropdown shows available commands from `.cursor/commands/`
3. User selects command
4. Template content from `.cursor/commands/[command].md` sent to assistant
5. Assistant processes the template content as a message

**Key insight**: They're **reusable prompt templates**, not runtime routing

---

## Potential Approach

### Create Command Templates

**`.cursor/commands/commit.md`**:
```markdown
Use the git-commit.sh script to create a conventional commit for the currently staged changes. 

Follow the Conventional Commits format and use these options:
- `--type`: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- `--scope`: optional component name
- `--description`: short summary (≤72 chars total in header)
- `--body`: additional context (optional, can use multiple times)

Run: `bash .cursor/scripts/git-commit.sh --type <type> [--scope <scope>] --description "<desc>" [--body "<line>"]...`
```

**`.cursor/commands/pr.md`**:
```markdown
Create a pull request using the pr-create.sh script.

Use: `bash .cursor/scripts/pr-create.sh --title "..." [--body "..."]`

The script will:
- Auto-detect base branch from origin
- Use current branch as head
- Create PR via GitHub API
- Return PR URL or compare URL if API unavailable
```

**`.cursor/commands/branch.md`**:
```markdown
Create a new branch using the git-branch-name.sh script with proper naming convention.

Use: `bash .cursor/scripts/git-branch-name.sh --task <slug> [--type <type>] [--feature <name>] [--apply]`

Pattern: `<github-login>/<type>-<feature-name>-<task>`

Add `--apply` flag to create and switch to the branch immediately.
```

---

## How This Could Help

### Discoverability

**Current**: Users need to know scripts exist
- Might say "commit these changes" (relies on intent routing)
- Might not know about git-commit.sh

**With templates**: Users see `/` dropdown
- Discover available commands visually
- Templates guide them to correct script usage
- Reduces reliance on perfect intent routing

### Explicit Workflow

**Current**: Intent routing tries to detect git operations
- Can miss indirect phrases ("save this work")
- Routing accuracy ~70% baseline (96% with H1)

**With templates**: User explicitly chooses workflow
- `/commit` → always gets the right script prompt
- No routing ambiguity
- 100% accuracy when template used

### User Education

Templates serve as:
- **Documentation**: Show how to use scripts
- **Examples**: Include common options
- **Guardrails**: Remind about conventions

---

## Questions to Answer

### 1. Would users actually use them?

**Hypothesis**: If templates are well-designed and visible, users might prefer explicit commands over natural language for git operations

**Test**: Create 3-4 templates and monitor adoption
- Track: How often `/commit` used vs "commit these changes"
- Compare: Compliance when template used vs intent routing

### 2. Do templates improve compliance over H1?

**Current**: H1 (alwaysApply) at 96%

**Question**: Would templates get us closer to 100%?
- Templates make script usage explicit
- But requires user to choose template
- Might not improve over always-having-rules-in-context

### 3. Is this worth the maintenance cost?

**Cost**: 
- Create 4-6 template files
- Keep templates updated when scripts change
- User training/discovery

**Benefit**:
- Better discoverability
- Potential compliance improvement
- Explicit workflow documentation

---

## Comparison: Intent Routing vs Prompt Templates

| Aspect | Intent Routing (H1) | Prompt Templates |
|--------|---------------------|------------------|
| **User action** | Natural language | Explicit `/command` selection |
| **Discovery** | Hidden (relies on routing) | Visible (dropdown list) |
| **Routing accuracy** | 96% (with alwaysApply) | 100% (when template used) |
| **Adoption** | Automatic (always works) | Requires user to choose template |
| **Compliance when used** | 96% | Unknown (likely ~100% if template guides correctly) |
| **Maintenance** | Rule files only | Rules + template files |
| **User friction** | Low (natural language) | Medium (must select from dropdown) |

---

## Decision Framework

### Execute Prompt Template Experiment IF:

1. **H1 validation shows gaps**: If 96% drops or plateaus below 90%
2. **Discoverability valued**: Users want to know what commands are available
3. **Explicit workflows preferred**: Team prefers explicit over implicit
4. **Compliance matters more than friction**: 100% > ease of use

### SKIP Prompt Template Experiment IF:

1. **H1 sufficient**: 96% sustained over validation period
2. **User friction concern**: Team prefers natural language
3. **Maintenance cost high**: Don't want to sync templates with scripts
4. **Cost > benefit**: Marginal gain (96% → ~98%) not worth effort

---

## Proposed Next Steps (IF exploring further)

### Phase 1: Create Pilot Templates (1-2 hours)

- [ ] Create `.cursor/commands/commit.md`
- [ ] Create `.cursor/commands/pr.md`
- [ ] Create `.cursor/commands/branch.md`
- [ ] Test: Do templates work as expected?

### Phase 2: Monitor Usage (1-2 weeks)

- [ ] Track: How often templates used
- [ ] Compare: Compliance when template used vs natural language
- [ ] Survey: User preference (templates vs natural)

### Phase 3: Measure & Decide

- [ ] Calculate: Template usage rate
- [ ] Calculate: Compliance improvement (if any)
- [ ] Decide: Keep, expand, or remove

---

## Related

- [Slash Commands Decision](../slash-commands-decision.md) — Runtime routing attempt + correction
- [Platform Constraints](../../assistant-self-testing-limits/platform-constraints.md) — Design mismatch analysis
- [Cursor 1.6 Changelog](https://cursor.com/changelog/1-6) — Official slash commands documentation

---

**Status**: PROPOSED  
**Decision**: Defer until H1 validation complete  
**Fallback**: Only explore if H1 drops below 90% or discoverability becomes priority  
**Current recommendation**: Continue with H1 (alwaysApply) at 96%

