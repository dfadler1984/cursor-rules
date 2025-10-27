# Scalability Analysis: AlwaysApply vs Conditional Rules

**Purpose**: Analyze context cost and identify scalable enforcement patterns  
**Generated**: 2025-10-15

---

## 0.6.1: Context Cost Calculation

### Current State (as of 2025-10-15)

**Total Rules**: 57 files in `.cursor/rules/`

**AlwaysApply Rules**: 19

- 00-assistant-laws.mdc
- assistant-behavior.mdc
- assistant-git-usage.mdc (CHANGED from false → true on 2025-10-15)
- capabilities.mdc
- code-style.mdc
- cursor-platform-capabilities.mdc
- dependencies.mdc
- direct-answers.mdc
- favor-tooling.mdc
- github-api-usage.mdc
- github-config-only.mdc
- global-defaults.mdc
- intent-routing.mdc
- scope-check.mdc
- script-execution.mdc
- security.mdc
- self-improve.mdc
- tdd-first.mdc (core TDD rule, always-apply)
- user-intent.mdc

**Conditional Rules**: 25 (alwaysApply: false)


**Capabilities files** (no alwaysApply field): 13

- `*.caps.mdc` files
- These are agent-requested, not always-apply

### Estimated Token Counts

**Methodology**: Based on typical rule file sizes

**Small rules** (50-100 lines): ~500-1000 tokens each

- Examples: dry-run.mdc, five-whys.mdc, direct-answers.caps.mdc

**Medium rules** (100-200 lines): ~1000-2000 tokens each

- Examples: create-erd.mdc, generate-tasks-from-erd.mdc, project-lifecycle.mdc

**Large rules** (200-300 lines): ~2000-3000 tokens each

- Examples: assistant-behavior.mdc, assistant-git-usage.mdc, tdd-first.mdc

**Very large rules** (>300 lines): ~3000-5000 tokens each

- Examples: intent-routing.mdc, capabilities.mdc

### Current Always-Apply Token Load

**Breakdown by size**:

| Size Category | Count  | Avg Tokens | Total Tokens |
| ------------- | ------ | ---------- | ------------ |
| Small         | 5      | 750        | 3,750        |
| Medium        | 8      | 1,500      | 12,000       |
| Large         | 4      | 2,500      | 10,000       |
| Very Large    | 2      | 4,000      | 8,000        |
| **Total**     | **19** | **~1,778** | **33,750**   |

**Current always-apply load**: ~34k tokens per conversation

---

## 0.6.2: Projected Impact of Making All Conditional Rules Always-Apply

### Scenario: All 25 Conditional → AlwaysApply

**Conditional Rules by Size**:

| Size Category | Count  | Avg Tokens | Total Tokens |
| ------------- | ------ | ---------- | ------------ |
| Small         | 10     | 750        | 7,500        |
| Medium        | 12     | 1,500      | 18,000       |
| Large         | 3      | 2,500      | 7,500        |
| **Total**     | **25** | **~1,320** | **33,000**   |

### Combined Context Load

**Current state**:

- Always-apply: 19 rules = ~34k tokens
- Conditional: 25 rules = 0 tokens (not loaded)
- **Total active**: ~34k tokens

**If all conditional → always-apply**:

- Always-apply: 44 rules = ~67k tokens
- Conditional: 0 rules = 0 tokens
- **Total active**: ~67k tokens

**Increase**: +33k tokens (~97% increase)

### Context Window Impact

**Cursor context window** (typical): ~200k tokens

- User message: ~500 tokens
- File context (open files): ~10k-20k tokens
- Chat history: ~10k-30k tokens
- Rules: 67k tokens (with all always-apply)
- **Total used**: ~88k-118k tokens

**Remaining for responses**: ~82k-112k tokens

**Assessment**: Still within limits, but...

### Practical Concerns

**1. Startup Latency**

- More rules → longer initial processing
- Every conversation pays the 67k token cost upfront
- Even for simple queries ("What's in this file?")

**2. Relevance Dilution**

- 44 rules loaded → Many irrelevant for given task
- Example: Loading `test-quality-sh.mdc` when working on docs
- Noise-to-signal ratio increases

**3. Maintenance Burden**

- 44 rules all active → All must be conflict-free
- Contradictions between rules more likely
- Harder to reason about precedence

**4. Cost Scaling**

- Context tokens are processed every turn
- 67k tokens × N turns × $per-token
- Significant cost multiplier for long sessions

**5. Cognitive Load**

- Assistant must "consider" 44 rules for every response
- More decision points → slower reasoning
- Increased chance of rule conflicts

---

## 0.6.3: Why AlwaysApply Doesn't Scale

### Core Problem: Context Budget is Finite

**Trade-off**: Rules vs. Code Context

- More rules loaded → Less room for code/files
- Example: 67k rules leaves ~130k for code
- That's ~4-5 large files (30k tokens each)

**User Impact**:

- "Why can't you see all these files I have open?"
- Answer: Rules are consuming the context

### Linear Scaling, Exponential Complexity

**Adding one always-apply rule**:

- Cost: +1.5k-3k tokens (linear)
- Interactions: Must check against 43 other rules (exponential)
- Conflicts: Precedence, contradictions, overlaps

**Example Conflict**:

- `tdd-first.mdc`: "Always write tests first"
- `refactoring.mdc`: "Ensure tests pass before refactor"
- `test-quality.mdc`: "Tests must assert owner behavior"
- **All loaded, all active, all "must" language**
- Which takes precedence? What if they contradict?

### Conditional Rules Exist for Good Reason

**Not every rule is always relevant**:

- `test-plan-template.mdc` → Only when creating test plans
- `changelog.mdc` → Only during releases/PRs
- `workspace-security.mdc` → Only when auditing `.vscode/tasks.json`

**Loading these always**:

- Wastes context budget
- Adds irrelevant guidance
- No benefit 95% of the time

### The Always-Apply Anti-Pattern

**Pattern**: "This rule isn't working → make it always-apply"

**Why it's tempting**:

- Immediate fix for conditional attachment failures
- Works for individual rules

**Why it doesn't scale**:

- Doesn't address root cause (routing accuracy)
- Creates context bloat
- Unsustainable for 25+ rules

**Example cascade**:

1. `assistant-git-usage` violations → make always-apply ✓ (works)
2. `tdd-first-js` violations → make always-apply? (works, but +34k → 37k)
3. `testing.mdc` violations → make always-apply? (37k → 40k)
4. `project-lifecycle` violations → make always-apply? (40k → 43k)
5. ...continue for 25 rules → 67k tokens

**Outcome**: All rules loaded, but no scalable solution discovered

---

## 0.6.4: Patterns That DO Scale

### Pattern 1: Script-Based Validation ✅

**Example**: `rules-validate.sh`, `compliance-dashboard.sh`

**Advantages**:

- Zero context cost (runs externally)
- Deterministic (same input → same output)
- Composable (can combine checkers)
- Measurable (quantitative results)

**Scalability**: O(1) context cost regardless of rules validated

**Use cases**:

- Front matter validation
- Cross-reference checking
- Compliance measurement
- CI/CD gates

### Pattern 2: Progressive Attachment ✅

**Definition**: Attach minimal rule first, load details on-demand

**Example**:

- Always-apply: `tdd-checklist.mdc` (5 bullet points, 500 tokens)
- Agent-requested: `tdd-first.mdc` (full guide, 2500 tokens)

**Flow**:

1. User starts implementation
2. Minimal TDD checklist attached (500 tokens)
3. If user asks "How do I test X?" → attach full guide (2500 tokens)
4. Otherwise: checklist sufficient, 2000 tokens saved

**Scalability**: O(1) base cost + O(n) for n requested details

**Use cases**:

- TDD guidance (checklist → full methodology)
- Testing rules (basic → language-specific)
- Project lifecycle (summary → detailed workflow)

### Pattern 3: Intent Routing with Minimal Rules ✅

**Definition**: Attach small, focused rules via accurate routing

**Example**:

- Trigger: "create ERD" → attach `create-erd.caps.mdc` (1000 tokens)
- Not: Attach `create-erd.mdc` (full 2500 token guide)

**Key**: Routing accuracy must be high (>95%)

**Scalability**: O(log n) or O(1) if routing is accurate

**Use cases**:

- ERD creation (trigger-based)
- Task generation (trigger-based)
- Guidance requests (intent-classified)

### Pattern 4: Linter Integration ✅

**Definition**: Move enforcement to dedicated tools (ESLint, ShellCheck, etc.)

**Example**:

- Don't load `imports.mdc` (1500 tokens) always
- Instead: ESLint rule for import order (0 context cost)
- CI fails if imports wrong

**Advantages**:

- Zero context cost
- Faster feedback (editor integration)
- Deterministic enforcement
- Language-specific best practices

**Scalability**: O(0) context cost

**Use cases**:

- Import organization
- Code style
- Shell script standards
- Test quality (some aspects)

### Pattern 5: Slash Commands ✅ (Proposed)

**Definition**: Explicit user invocation bypasses routing

**Example**:

- Always-apply: `slash-commands.mdc` (2000 tokens)
- Conditional: `git-usage`, `pr-creation`, etc. (0 tokens, unused)

**Flow**:

1. User types `/commit`
2. Command map routes to `git-commit.sh`
3. No need to load full `assistant-git-usage.mdc`

**Scalability**: O(1) for command map, O(0) for individual operation rules

**Use cases**:

- Git operations
- Planning/spec commands
- Task management

### Pattern 6: Tool Constraints ✅

**Definition**: Eliminate alternatives via platform/tooling restrictions

**Example**:

- `github-api-usage.mdc`: "GitHub CLI (`gh`) is not installed"
- Enforcement: Platform constraint (tool unavailable)
- Result: Assistant can't use wrong tool

**Advantages**:

- Zero context cost for enforcement
- No room for interpretation
- Fails fast if violated

**Scalability**: O(0) context cost

**Use cases**:

- Tooling mandates (use X, not Y)
- Platform constraints
- Security restrictions

---

## Scalability Summary Table

| Pattern                   | Context Cost | Accuracy | Scalability  | Best For                  |
| ------------------------- | ------------ | -------- | ------------ | ------------------------- |
| AlwaysApply               | High (O(n))  | 100%     | ❌ Poor      | Critical, universal rules |
| Script validation         | Zero (O(0))  | 100%     | ✅ Excellent | Measurable standards      |
| Progressive attachment    | Low (O(1+n)) | Variable | ✅ Good      | Tiered guidance           |
| Intent routing (accurate) | Med (O(log)) | Variable | ✅ Good      | Context-specific rules    |
| Linter integration        | Zero (O(0))  | 100%     | ✅ Excellent | Code style, formatting    |
| Slash commands            | Low (O(1))   | 100%     | ✅ Good      | Explicit operations       |
| Tool constraints          | Zero (O(0))  | 100%     | ✅ Excellent | Platform restrictions     |

---

## Recommendations by Rule Category

### Critical Rules (Always-Apply OK)

**Keep always-apply** (19 current + git-usage fix = 20):

- Assistant laws, behavior, consent gates
- TDD core, scope-check, security
- Intent routing, capabilities
- ~40k tokens total

**Rationale**: Universal, high-impact, foundational

### High-Priority Conditional Rules (Improve Routing)

**Do NOT make always-apply**:

- `tdd-first-js`, `tdd-first-sh` → Progressive attachment (minimal checklist always-apply)
- `testing.mdc`, `test-quality-*` → File-triggered + progressive
- `refactoring.mdc` → Intent routing + checklist

**Target**: >95% routing accuracy via improved triggers

### Medium-Priority Conditional Rules (Intent Routing)

**Keep conditional, improve routing**:

- `create-erd`, `generate-tasks-from-erd` → Phrase triggers
- `spec-driven`, `guidance-first` → Intent classification
- `project-lifecycle` → Path patterns

**Strategy**: Fuzzy matching + confirmation prompts

### Low-Priority Conditional Rules (On-Demand)

**Keep conditional, agent-requested only**:

- `front-matter`, `rule-creation`, `rule-maintenance` → Manual or script-based
- `test-plan-template` → Rarely used
- `five-whys`, `dry-run` → Explicit triggers only

**Strategy**: User explicitly requests or rare context

---

## Decision Framework

**When to make always-apply**:

- ✅ Rule is universal (applies to all contexts)
- ✅ Violations have high impact (data loss, security, team disruption)
- ✅ Rule is foundational (other rules depend on it)
- ✅ Total always-apply count stays <25 rules (~50k tokens)

**When to use alternative patterns**:

- ❌ Rule is context-specific (only relevant in certain situations)
- ❌ Rule is large (>2000 tokens) and only sometimes needed
- ❌ Rule can be enforced externally (linter, script, tool constraint)
- ❌ Making it always-apply would exceed context budget

---

## Conclusion

**AlwaysApply works for ~20 critical rules but doesn't scale to 44.**

**Key insight**: The investigation initially focused on "make git-usage always-apply" (correct for that rule), but that's not a generalizable solution for 25 conditional rules.

**Scalable approach**:

1. Keep ~20 critical rules always-apply (~40k tokens)
2. Use progressive attachment for tiered guidance
3. Improve intent routing accuracy (>95% target)
4. Implement slash commands for explicit operations
5. Move style/format to linters
6. Use scripts for validation/measurement

**Expected outcome**:

- Context cost: ~40k-50k (sustainable)
- Compliance: >90% overall (via multiple patterns)
- Maintainability: High (each rule has appropriate enforcement)
- Scalability: Can grow to 50-100 rules without context bloat

---

## Next Steps

**Completed**:

- ✅ 0.6.1: Context cost calculated (19 always → 34k tokens; 44 always → 67k tokens)
- ✅ 0.6.2: Impact estimated (+97% context increase, practical concerns documented)
- ✅ 0.6.3: Scaling problems documented (finite budget, linear cost, exponential complexity)
- ✅ 0.6.4: Scalable patterns identified (6 patterns with O(0) to O(log n) cost)

**Ready to proceed to**:

- Review tasks (R.1, R.2) to validate test plans and learn from premature completion
- Then Phase 6A validation (monitor git-usage improvement over 20-30 commits)
