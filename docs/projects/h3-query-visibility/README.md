# H3: Query Visibility Investigation

**Parent**: [rules-enforcement-investigation](../rules-enforcement-investigation/)  
**Status**: MONITORING  
**Created**: 2025-10-16 (split from parent)

---

## Overview

Investigation of whether the "check capabilities.mdc" query protocol in `assistant-git-usage.mdc` is executed, and whether making query output visible improves script usage.

**Hypothesis**: Visible query output ("Checked capabilities.mdc for X: found/not found") creates transparency and improves compliance.

---

## Key Findings

**Baseline**: 0% query visibility (Test A - retrospective analysis)

**After visible output requirement**: Implementation complete, monitoring in progress

**Expected**: 0% → ~100% visibility (same pattern as H2)

---

## Documents

- **[discovery.md](discovery.md)** - Pre-test analysis and test design
- **Parent findings**: [../rules-enforcement-investigation/findings/README.md](../rules-enforcement-investigation/findings/README.md)
- **Test plan**: [../rules-enforcement-investigation/tests/hypothesis-3-query-protocol-visibility.md](../rules-enforcement-investigation/tests/hypothesis-3-query-protocol-visibility.md)
- **Test results**: [../rules-enforcement-investigation/test-results/h3/](../rules-enforcement-investigation/test-results/h3/)

---

## Contribution to Parent

**Primary finding**: Visible query execution expected to improve transparency in script selection.

**Pattern identified**: Same as H2 - explicit output creates accountability.

**Applied to**: `assistant-git-usage.mdc` + send gate - Added visible query output requirement.

---

## Status

**Current Phase**: Test C implementation complete, passive monitoring  
**Next**: Accumulate 10-20 operations for measurement  
**Expected**: Query visibility 0% → ~100%, improved script awareness

