# Rules Enforcement & Effectiveness Investigation

**For current status, progress, and next steps**: See [`tasks.md`](tasks.md)

---

## Navigation

### 🚀 Quick Start (5 minutes)

**New to this project?** Start here:

1. Read the **Quick Summary** section below (what was found, what was fixed)
2. Read [`findings.md`](findings.md) for outcomes and 5 rule gaps discovered
3. View baseline: `bash .cursor/scripts/compliance-dashboard.sh --limit 100`

### 📊 Understanding Results (10 minutes)

**Want to understand the metrics?**

- [`BASELINE-REPORT.md`](BASELINE-REPORT.md) — Measured compliance scores (68% overall)
- Review what improved and what needs attention

### 🔬 Deep Dive (1-2 hours)

**Want comprehensive technical details?**

- [`discovery.md`](discovery.md) — Full analysis of 15+ rules, 6 enforcement patterns, structural improvements
- Sections 10-11 contain the meta-test results that proved the root cause

### 📋 Implementation Reference

**Executing or tracking work?**

- [`tasks.md`](tasks.md) — Phase checklists, status, and carryovers for follow-up work
- [`erd.md`](erd.md) — Original requirements and investigation approach
- [`tests/`](tests/) — 7 detailed test plans (H0, H1 executed; H2, H3, slash commands deferred)

---

## Project Overview

**Problem**: Assistant violated script-first and consent-first rules despite proper rule configuration.

**Objective**: Investigate how Cursor rules are processed, identify why violations occur, and discover scalable enforcement patterns for 25+ conditional rules.

**Status**: One fix applied (`git-usage` → `alwaysApply: true`) but not validated. Core research questions remain unanswered.

**What's Actually Complete**:

- ✅ Measurement framework built
- ✅ Baseline metrics established (68% overall)
- ✅ Meta-test proved rules CAN work
- ✅ One fix applied (not validated)

**What's NOT Complete**:

- ❌ Fix validation (need 20-30 commits of usage)
- ❌ H2: Pre-send gate enforcement investigation
- ❌ H3: Query visibility investigation
- ❌ Slash commands experiment
- ❌ Scalable patterns for 25 conditional rules
- ❌ 6 rule improvements discovered during investigation

---

## Project Documents

### Core Deliverables

**[findings.md](findings.md)** — Project outcomes and retrospective

- Root cause, fix, and validation
- Research questions answered/deferred
- 6 rule gaps discovered during investigation
- Meta-lessons about the investigation itself

**[BASELINE-REPORT.md](BASELINE-REPORT.md)** — Compliance measurements

- Overall: 68% (target: >90%)
- Script usage: 71%, TDD: 72%, Branch naming: 62%
- Post-fix baseline for future validation

**[ci-integration-guide.md](ci-integration-guide.md)** — CI integration guide

- GitHub Actions examples
- Threshold recommendations (4 phases)
- Troubleshooting and monitoring

### Planning & Execution

**[erd.md](erd.md)** — Engineering requirements

- Research questions and investigation approach
- Acceptance criteria and success metrics
- Test plan structure and timeline

**[tasks.md](tasks.md)** — Execution tracking

- **PRIMARY STATUS DOCUMENT** — See this for current progress
- Discovery tasks to understand current state
- Review checkpoints for validation gates
- Phase checklists (6A-6D) with detailed status
- Rule improvements from investigation findings

### Analysis & Research

**[discovery.md](discovery.md)** — Deep technical analysis

- Analysis of 15+ rules for enforcement patterns
- 6 enforcement patterns (strong → weak)
- Meta-test methodology and results
- Structural improvement proposals

**[tests/](tests/)** — Test plan library

- 7 detailed test plans with procedures
- H0 (meta-test) executed ✅
- H1 (conditional attachment) confirmed ✅
- H2, H3, slash commands: see tasks.md for execution status

---

## Quick Actions

### View Current Compliance

```bash
bash .cursor/scripts/compliance-dashboard.sh --limit 100
```

### Run Specific Checks

```bash
bash .cursor/scripts/check-script-usage.sh --limit 100
bash .cursor/scripts/check-tdd-compliance.sh --limit 100
bash .cursor/scripts/check-branch-names.sh
```

### Execute Deferred Tests

See `tests/` directory for detailed test plans:

- H2: Send gate enforcement investigation
- H3: Query visibility improvements
- Slash commands experiment

Each test plan includes implementation checklist and success criteria.

---

## Status

**Project Status**: ✅ ACTIVE — MONITORING  
**Current Phase**: 6A/6B (H1 Validation + H2/H3 Monitoring)  
**Completion**: ~50% (Discovery, Review, Rule Improvements, Phase 6C complete; H1/H2/H3 monitoring)  
**Fixes Applied**:

- H1: `assistant-git-usage.mdc` → `alwaysApply: true` (validation in progress, currently 96%)
- H2: `assistant-behavior.mdc` → visible gate output (monitoring in progress)
- H3: visible query output ("Checked capabilities.mdc...") (monitoring in progress)

**What's Complete**:

- ✅ All Discovery work (0.1-0.6): Analysis of 25 conditional rules, scalability study, pre-test prep
- ✅ All Review work (R.1-R.2): Test plans validated, premature completion root causes analyzed
- ✅ All Rule Improvements (15.0-20.0): 6 improvements applied to 4 rule files
- ✅ Phase 6C: Slash commands runtime routing wrong (design mismatch); prompt templates unexplored; testing paradox validated
- ✅ New project created: assistant-self-testing-limits (testing paradox + platform constraints)
- ✅ Meta-findings: Gaps #7, #8, #9, #10 documented during investigation

**Next Steps**:

1. Continue H1 validation (accumulate 12-22 more commits for 20-30 total)
2. Measure sustained compliance: baseline 74% → current 96% → target >90%
3. Continue H2/H3 monitoring passively
4. Synthesize findings and create decision tree
5. Final summary after validation period

**Key Insights**:

- AlwaysApply works for ~20 critical rules but doesn't scale to 44 (+97% context cost)
- Slash commands not viable: Cursor's `/` is for prompt templates, not runtime routing (per [Cursor 1.6 docs](https://cursor.com/changelog/1-6))
- Testing paradox validated: One real usage attempt found platform constraint that 50 test trials would have missed
- H1 at 96% compliance likely sufficient without additional enforcement patterns
