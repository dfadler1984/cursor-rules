# Slash Commands Pre-Test Discovery

**Purpose**: Analyze external patterns and prepare for slash commands experiment  
**Generated**: 2025-10-15

---

## 0.5.1: Taskmaster/Spec-Kit Patterns Review

### Source Documents

**Primary**: `docs/projects/ai-workflow-integration/erd.md`  

### Taskmaster Pattern

**Key Characteristics**:

- Uses slash commands for task operations (`/task`, `/complete`, `/status`)
- Structured prompts force specific workflows
- Explicit state transitions (vs implicit routing)

**Core Hypothesis** (from ERD):

> "Explicit commands create forcing functions that intent routing lacks."

**Forcing Function Mechanism**:

- Slash command: User types `/commit` → **unambiguous** tool invocation
- Intent routing: User types "save this work" → keyword matching needed, **may miss**

**Advantages**:

1. **Zero ambiguity**: Command either matches or doesn't (no fuzzy matching)
2. **Explicit invocation**: User knows a tool is being called
3. **Clear errors**: Command not recognized → obvious failure (vs silent skip)

**Comparison to Our Patterns**:

- **Current**: `intent-routing.mdc` uses keywords (implicit detection)
- **Taskmaster**: Uses `/task` commands (explicit invocation)
- **Difference**: Explicit commands require no interpretation

### Spec-Kit Pattern

**Key Characteristics**:

- Uses `/spec`, `/plan`, `/analyze` commands
- Commands have **required arguments** (can't proceed without them)
- Explicit safety gates built into command structure

**Forcing Function Mechanism**:

- Required arguments: Can't proceed without all params
- Our rules: Many optional params, relying on consent prompts

**Comparison to Our Dry-Run**:

- Similar to `dry-run.mdc` (explicit prefix `DRY RUN:`)
- But `/spec` is **terser** and more **discoverable**
- Integration: Could use `/dry-run commit` instead of prefix

**Advantages**:

1. **Completeness checking**: Missing params caught at invocation
2. **Discovery**: `/help` can list available commands
3. **Consistency**: All tools use same command pattern

### Key Insights from External Patterns

**Pattern 1: Explicit > Implicit**

- Slash commands eliminate keyword ambiguity
- User intent is **declared**, not inferred
- No routing logic needed (direct mapping)

**Pattern 2: Required Args > Optional Args**

- Spec-kit requires arguments at invocation
- Prevents incomplete requests ("commit this" with no message)
- Reduces back-and-forth for missing info

**Pattern 3: Discoverability**

- `/help` → lists all commands
- Command prompts teach users about options
- Self-documenting interface

**Pattern 4: Forcing Functions**

- Command not used → clear violation
- vs keyword not detected → silent failure
- Makes compliance binary (used or not used)

---

## 0.5.2: Git Operations to Target

### Risk-Based Prioritization

**HIGH-RISK** (mandatory slash commands):

1. **Commits** (`/commit`)

   - Risk: Non-conventional commits break tooling
   - Current violations: 26% (74% compliance)
   - Script: `.cursor/scripts/git-commit.sh`
   - Reason: Affects changelog, versioning, CI

2. **Pull Requests** (`/pr`, `/pr-update`)

   - Risk: Incomplete PRs, missing descriptions
   - Current violations: Unknown (not measured)
   - Scripts: `pr-create.sh`, `pr-update.sh`
   - Reason: High-visibility, team coordination

3. **Branch Creation** (`/branch`)

   - Risk: Non-compliant branch names break tooling
   - Current violations: 39% (61% compliance)
   - Script: `.cursor/scripts/git-branch-name.sh`
   - Reason: Affects PR routing, ownership tracking

4. **Force Push** (`/push-force`)
   - Risk: Data loss, team disruption
   - Current violations: Unknown (infrequent operation)
   - Script: None (should require confirmation)
   - Reason: Irreversible, affects others

**MEDIUM-RISK** (suggested but optional): 5. **Merge Operations** (`/merge`)

- Risk: Merge conflicts, lost work
- Script: None (git merge is standard)
- Strategy: Suggest `/merge`, allow raw git

6. **Rebase** (`/rebase`)
   - Risk: History rewriting, conflicts
   - Script: None (git rebase is standard)
   - Strategy: Suggest `/rebase`, require confirmation

**LOW-RISK** (no slash command needed): 7. **Read-only operations**

- `git status`, `git log`, `git diff`, `git show`
- Risk: None (read-only)
- Strategy: Allow raw git, no interception

### Target Selection for Testing

**Phase 1 (Baseline — current intent routing)**:

- Commit operations (varied phrasing)
- PR operations (direct and indirect)
- Branch creation (with and without keywords)

**Phase 2 (Slash commands enabled)**:

- Same operations using slash commands
- Test enforcement: What happens without slash command?
- Test routing accuracy: Commands recognized?

**Phase 3 (Hybrid approach)**:

- Mixed usage: some users use slash commands, some don't
- Fallback behavior: Does script-first still work?

### Expected Improvements by Operation

| Operation   | Baseline Compliance | With Slash Commands | Improvement Target |
| ----------- | ------------------- | ------------------- | ------------------ |
| Commits     | 74%                 | >95%                | +21 points         |
| Branches    | 61%                 | >95%                | +34 points         |
| PRs         | Unknown (~70%?)     | >95%                | +25 points         |
| **Overall** | **70%**             | **>95%**            | **+25 points**     |

---

## 0.5.3: Slash Command Rule Structure

### Rule File Structure

**File**: `.cursor/rules/git-slash-commands.mdc`  
**Strategy**: Create new rule (don't modify existing git-usage)

```markdown
---
description: Mandatory slash commands for Git operations
alwaysApply: true
lastReviewed: 2025-10-15
healthScore:
  content: green
  usability: green
  maintenance: green
---

# Git Slash Commands (Mandatory)

## High-Risk Operations (Mandatory Commands)

Before executing ANY of these git operations, check if user provided slash command:

### Command Map

- `/commit` → `.cursor/scripts/git-commit.sh`
  - Prompts: type, scope (optional), description
  - Output: Conventional commit message
- `/pr` → `.cursor/scripts/pr-create.sh`
  - Prompts: title, body (optional), base branch
  - Output: PR URL and number
- `/branch` → `.cursor/scripts/git-branch-name.sh`
  - Prompts: task, type (optional), feature (optional)
  - Output: Suggested or created branch name
- `/pr-update` → `.cursor/scripts/pr-update.sh`
  - Prompts: PR number or branch, changes
  - Output: Updated PR confirmation

### Enforcement Protocol

**Detection**: User requests commit/PR/branch without slash command

**Response** (3-step):

1. **Detect operation type** (commit, PR, branch, push --force)
2. **Prompt for command**:
```

Use `/<command>` for this operation:

- `/commit` for commits
- `/pr` for pull requests
- `/branch` for branch creation

Proceed with slash command, or manual?

```
3. **Handle response**:
- "manual" or "no" → Fall back to script-first protocol
- `/<command>` → Execute immediately (no additional routing)
- Consent phrase → Ask once more for command or manual

### Medium-Risk Operations (Suggested)

Suggest but don't require slash commands:

- `/status` → `git status --porcelain=v1`
- `/diff` → `git diff --stat`
- `/log` → `git log --oneline -n 10`

**Enforcement**: Suggest command in status update, allow raw git

### Low-Risk Operations (Unrestricted)

No interception for read-only ops:
- `git status`, `git log`, `git diff`, `git show`, etc.

## Rationale

- **Unambiguous**: `/commit` can't be misinterpreted
- **Explicit**: User sees tool invocation
- **Discoverable**: Prompts teach available commands
- **Forcing function**: Can't be skipped by clever phrasing
- **Scalable**: Easy to add new commands

## Examples

**User**: `/commit`
```

Type: [feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert]
Scope (optional):
Description:

```

**User**: "commit these changes"
```

Use `/commit` for conventional commits.

Proceed with slash command, or manual?

```

**User**: `/pr`
```

Title:
Body (optional - press Enter for template):
Base branch (default: main):

```

## Integration

See `intent-routing.mdc` for slash command detection patterns.
```

### Intent Routing Integration

**Add to `.cursor/rules/intent-routing.mdc`**:

```markdown
## Slash commands

- `/plan <topic>` → route to `spec-driven.mdc` (plan/specify)
- `/tasks` → route to `project-lifecycle.mdc` (Task List Process)
- `/pr` → route to `git-slash-commands.mdc` → `pr-create.sh`
- `/commit` → route to `git-slash-commands.mdc` → `git-commit.sh`
- `/branch` → route to `git-slash-commands.mdc` → `git-branch-name.sh`

**Priority**: Slash commands take precedence over keyword routing
```

### Alternative: Lightweight Integration

**Option**: Don't create separate rule; add to existing `assistant-git-usage.mdc`

**Pros**:

- Single source of truth for git operations
- No new rule to maintain
- Natural extension of script-first policy

**Cons**:

- Makes git-usage rule larger
- Mixes two concepts (script-first + slash commands)
- Harder to A/B test independently

**Recommendation**: Create separate rule for testing; merge later if successful

---

## 0.5.4: Integration Points with Intent Routing

### Current Intent Routing Architecture

**File**: `.cursor/rules/intent-routing.mdc`  
**Pattern**: Triggers → Rules → Behavior

**Trigger Types**:

1. Exact phrases (highest priority)
2. Composite signals (recent plan + consent phrase)
3. Keyword fallback (word-boundary intent words)
4. File/context signals
5. Fuzzy matching (medium confidence)

### Slash Command Integration Strategy

**Priority Level**: **Highest** (above exact phrases)

**Rationale**:

- Slash commands are explicit user intent
- No ambiguity → no need for fuzzy matching
- Should route directly without intermediate steps

**Detection Pattern**:

```markdown
## Slash commands (highest priority)

**Detection**: Message starts with `/` followed by command name

**Pattern**: `^\/(\w+)\s*(.*)$`

- Group 1: command name (e.g., "commit", "pr", "branch")
- Group 2: arguments (optional)

**Commands**:

- `/commit [args]` → route to `git-slash-commands.mdc` → `git-commit.sh`
- `/pr [args]` → route to `git-slash-commands.mdc` → `pr-create.sh`
- `/branch [args]` → route to `git-slash-commands.mdc` → `git-branch-name.sh`
- `/plan <topic>` → route to `spec-driven.mdc`
- `/tasks` → route to `project-lifecycle.mdc`

**On match**:

1. Route to command-specific rule/script immediately
2. Skip keyword detection and intent classification
3. No consent needed (explicit user command)

**On no match**:

1. Continue to exact phrase triggers
2. Then composite signals
3. Then keyword fallback
```

### Decision Tree Update

**New Flow**:

```
User message received
├─ 1. Starts with `/` ? (NEW)
│   ├─ Yes → Match command → Route directly → Execute
│   └─ No → Continue to existing flow
├─ 2. Exact phrase trigger? (e.g., "DRY RUN:")
│   ├─ Yes → Attach rule → Apply behavior
│   └─ No → Continue
├─ 3. Composite consent-after-plan?
│   ├─ Yes → Route to implementation
│   └─ No → Continue
├─ 4. Keyword fallback
│   └─ Continue with existing logic
```

### Backward Compatibility

**Existing keyword routing still works**:

- Users can still say "commit these changes"
- Slash command prompt will be shown
- On "manual", falls back to script-first protocol

**No breaking changes**:

- All existing intents still route correctly
- Slash commands are additive, not replacing
- Gradual adoption path

### Command Help System

**Add `/help` command**:

```markdown
- `/help` → Lists all available slash commands

**Output**:
```

Available slash commands:

Git Operations:

- `/commit` — Create conventional commit
- `/pr` — Create pull request
- `/branch` — Create/suggest branch name
- `/pr-update` — Update existing PR

Planning:

- `/plan <topic>` — Create specification
- `/tasks` — Manage task list

Utilities:

- `/help` — Show this list

```

```

**Integration point**: Add to `capabilities.mdc` → Discovery section

### Consent Handling

**Slash commands bypass consent for the initial operation**:

- `/commit` → Directly prompts for commit details (no "Proceed?" gate)
- Rationale: User explicitly requested the action

**Consent still required for**:

- Tool category switches after slash command
- Follow-up operations not covered by original command
- External operations (network, filesystem beyond git)

**Example**:

```
User: /commit
Assistant: [Prompts for type/scope/description]
User: [Provides details]
Assistant: [Commits directly without "Proceed?"]
```

vs

```
User: /commit and push
Assistant: I'll create the commit first.
[Prompts for commit details, commits]
Ready to push. Proceed? [Consent required for second operation]
```

---

## Summary for Execution

### External Patterns Reviewed

- ✅ Taskmaster: Slash commands for task operations
- ✅ Spec-kit: Required arguments, explicit commands
- ✅ Key insight: Explicit > Implicit for forcing functions
- ✅ Hypothesis: Slash commands eliminate routing ambiguity

### Git Operations Target

- ✅ High-risk: commit, PR, branch, force push (mandatory)
- ✅ Medium-risk: merge, rebase (suggested)
- ✅ Low-risk: read-only ops (no interception)
- ✅ Expected improvement: +25 percentage points overall

### Rule Structure Drafted

- ✅ New file: `git-slash-commands.mdc`
- ✅ Always-apply: true (highest priority)
- ✅ Enforcement protocol: 3-step (detect → prompt → handle)
- ✅ Command map: 4 high-risk operations
- ✅ Rationale documented

### Intent Routing Integration

- ✅ Priority: Slash commands highest (above exact phrases)
- ✅ Detection: `^\/(\w+)\s*(.*)$` pattern
- ✅ Flow: Direct route → Skip keyword detection
- ✅ Backward compat: Existing routing still works
- ✅ Help system: `/help` lists commands
- ✅ Consent: Bypassed for explicit commands

### Ready to Execute?

**YES** — All pre-test discovery complete. Can proceed to implementation whenever ready.

### Estimated Effort (from test plan)

- Phase 1 (Baseline): 3-4 hours (50 trials)
- Phase 2 (Implementation): 2 hours (rule creation)
- Phase 3 (Testing): 3-4 hours (50 trials)
- Phase 4 (Comparison): 1 hour (analysis)
- **Total**: 2 days

### Dependencies

- ✅ H1 fix applied (git-usage → alwaysApply: true)
- ✅ Baseline metrics available (70% overall compliance)
- ⚠️ H1 validation pending (need 20-30 commits)
- ✅ Test plan exists (`tests/experiment-slash-commands.md`)

### Integration with H1 and H3

**Layered approach** (if all succeed):

1. H1: Always-apply (rules always in context)
2. H3: Visible output (query execution transparent)
3. Slash commands: Explicit invocation (no routing ambiguity)
4. **Combined target**: >95% compliance

**If H1 succeeds but H3/slash-commands pending**:

- H1 alone targets: 90% compliance
- Slash commands add: +5-10 points (eliminate remaining keyword misses)

### Risk Analysis

**Risk 1**: User friction (learning curve)

- Mitigation: Prompts teach commands; fallback to manual still works

**Risk 2**: Command proliferation

- Mitigation: Start with 4 high-risk ops; expand gradually

**Risk 3**: Breaking existing workflows

- Mitigation: Backward compatible; keyword routing still works

**Risk 4**: Maintenance burden

- Mitigation: Command map in one place; easy to add/remove

### Next Step

**Decision point**: Execute now or wait for H1 validation?

**Option A**: Execute slash commands test now (parallel to H1 validation)

- Pro: More data points sooner
- Con: Can't isolate H1 vs slash command effects

**Option B**: Wait for H1 validation, then test slash commands

- Pro: Clean separation of improvements
- Con: Adds 2-4 weeks to timeline

**Recommendation**: Option B (sequential testing for clean attribution)
