## Tasks — Rules Enforcement & Effectiveness Investigation

## Relevant Files

- `docs/projects/rules-enforcement-investigation/erd.md` — Canonical ERD
- `docs/projects/rules-enforcement-investigation/discovery.md` — Comprehensive rules analysis
- `docs/projects/rules-enforcement-investigation/tests/` — Detailed test plans directory (NEW)
  - `README.md` — Test plans index and execution guide
  - `hypothesis-1-conditional-attachment.md` — Always-apply test
  - `hypothesis-2-send-gate-enforcement.md` — Gate visibility/blocking test
  - `hypothesis-3-query-protocol-visibility.md` — Query output test
  - `experiment-slash-commands.md` — Slash command forcing function test
  - `measurement-framework.md` — Automated compliance monitoring
- `docs/projects/ai-workflow-integration/erd.md` — Taskmaster/spec-kit analysis
- `.cursor/rules/capabilities.mdc` — Script inventory (alwaysApply: true)
- `.cursor/rules/assistant-behavior.mdc` — Compliance-first send gate
- `.cursor/rules/assistant-git-usage.mdc` — Script-first default

## Phase 1: Baseline Documentation

- [x] 1.0 Document recent rule violations (priority: high)

  - [x] 1.1 Catalog violations from 2025-10-11 session:
    - Script-first: used `git commit --amend` instead of `git-commit.sh`
    - Script-first: used `git push -f` instead of checking for `pr-update.sh`
    - Consent-first: multiple amend/push cycles without asking
  - [x] 1.2 For each violation, note:
    - Which rule was violated
    - What the rule status was (`alwaysApply` true/false)
    - What should have happened vs what did happen
  - [x] 1.3 Identify pattern: rules present in context but not consulted before action
  - [x] 1.4 Created comprehensive discovery document analyzing 15+ rules for enforcement patterns

## Phase 2: Experimental Tests

- [x] 2.0 Create detailed test plans for all hypotheses and experiments (priority: high)

  - [x] 2.1 Created comprehensive test plan for Hypothesis 1 (Conditional Attachment)
  - [x] 2.2 Created comprehensive test plan for Hypothesis 2 (Send Gate Enforcement)
  - [x] 2.3 Created comprehensive test plan for Hypothesis 3 (Query Protocol Visibility)
  - [x] 2.4 Created comprehensive test plan for Slash Commands Experiment
  - [x] 2.5 Created Measurement Framework implementation plan
  - [x] 2.6 Created test plans index with execution guide and success criteria

- [ ] 2.7 Execute experiments per test plans (priority: high)

  - [ ] 2.7.1 Build measurement framework and establish baseline
  - [ ] 2.7.2 Run Hypothesis 1 test (Conditional Attachment)
  - [ ] 2.7.3 Run Hypothesis 3 test (Query Visibility)
  - [ ] 2.7.4 Run Hypothesis 2 test (Send Gate Enforcement)
  - [ ] 2.7.5 Run Slash Commands Experiment

- [ ] 3.0 Experiment 2: Slash Command Requirement (priority: high)

  - [ ] 3.1 Design minimal slash command for commits: `/commit`
  - [ ] 3.2 Add rule: "Git commits must use `/commit` command, which routes to git-commit.sh"
  - [ ] 3.3 Test: Request "commit these changes" (without slash command)
  - [ ] 3.4 Observe: Does assistant suggest `/commit` first or proceed directly?
  - [ ] 3.5 Record: Whether slash command was suggested/required
  - [ ] 3.6 Compare: vs intent routing approach

- [ ] 4.0 Experiment 3: Pre-Send Gate Self-Check (priority: medium)

  - [ ] 4.1 Add explicit self-check template to send gate:
    ```
    Before sending:
    - [ ] Scripts: Checked capabilities.mdc? (Y/N)
    - [ ] If Y: Which script was found?
    - [ ] If N: Why not?
    ```
  - [ ] 4.2 Test: Request any git operation
  - [ ] 4.3 Observe: Does assistant show the checklist in response?
  - [ ] 4.4 Measure: Does visible checklist improve compliance?

## Phase 3: External Pattern Analysis

- [ ] 5.0 Analyze taskmaster patterns (priority: high)

  - [ ] 5.1 Review `docs/projects/ai-workflow-integration/erd.md` section on taskmaster
  - [ ] 5.2 Extract: How are slash commands structured?
  - [ ] 5.3 Extract: What makes commands mandatory vs optional?
  - [ ] 5.4 Document: Key differences from our intent routing

- [ ] 6.0 Analyze spec-kit patterns (priority: high)

  - [ ] 6.1 Review `docs/projects/ai-workflow-integration/erd.md` section on spec-kit
  - [ ] 6.2 Extract: `/analyze` gate behavior (explicit safety check)
  - [ ] 6.3 Extract: Required vs optional command parameters
  - [ ] 6.4 Document: How commands create forcing functions

- [ ] 7.0 Comparative analysis (priority: medium) (depends on: 5.0, 6.0)

  - [ ] 7.1 Compare: Slash commands vs intent routing for adherence
  - [ ] 7.2 Identify: What structural elements improve compliance?
  - [ ] 7.3 List: Advantages/disadvantages of each approach
  - [ ] 7.4 Recommend: Which approach(es) to adopt for high-risk operations

## Phase 4: Measurement & Validation

- [ ] 8.0 Create compliance measurement tools (priority: medium)

  - [ ] 8.1 Script: Parse commands from this session
  - [ ] 8.2 Script: Check each git command against capabilities.mdc
  - [ ] 8.3 Report: % of git ops using repo scripts
  - [ ] 8.4 Report: % of commands preceded by consent request

- [ ] 9.0 Propose structural improvements (priority: high) (depends on: 2.0, 3.0, 5.0, 6.0)

  - [ ] 9.1 Draft: Specific rule structure changes
  - [ ] 9.2 Draft: Slash command gating for git operations
  - [ ] 9.3 Draft: Measurement hooks for ongoing validation
  - [ ] 9.4 Rationale: Why each change should improve compliance

## Phase 5: Implementation & Testing

- [ ] 10.0 Implement recommendations (priority: medium) (depends on: 9.0)

  - [ ] 10.1 Apply structural changes to affected rules
  - [ ] 10.2 Add slash commands if recommended
  - [ ] 10.3 Update send gate with measurement hooks
  - [ ] 10.4 Document changes and rationale

- [ ] 11.0 Validation testing (priority: high) (depends on: 10.0)

  - [ ] 11.1 Test: Request git commit after changes
  - [ ] 11.2 Test: Request PR creation after changes
  - [ ] 11.3 Test: Request rule update after changes
  - [ ] 11.4 Measure: Compliance rate vs baseline
  - [ ] 11.5 Document: What worked, what didn't, why

## Open Questions to Track

- Q1: Are rules constraints or reference material? (Experiment 1 tests this)
- Q2: Do slash commands create forcing functions? (Experiment 2 tests this)
- Q3: Can send gates be self-enforcing? (Experiment 3 tests this)
- Q4: What makes taskmaster/spec-kit effective? (Phase 3 answers this)
- Q5: How do we measure compliance objectively? (Phase 4 answers this)

## Success Criteria

- [ ] At least 3 experiments run with documented results
- [ ] Taskmaster/spec-kit patterns analyzed and documented
- [ ] Concrete recommendations proposed with rationale
- [ ] Recommendations tested in real workflow
- [ ] Final report documenting findings and outcomes

## Notes

- This is a meta-investigation: we're studying the effectiveness of the rules system itself
- Observer effect is unavoidable; document it when it occurs
- Focus on observable behavior, not speculation about internal processing
- Negative results (experiments that fail) are valuable data
