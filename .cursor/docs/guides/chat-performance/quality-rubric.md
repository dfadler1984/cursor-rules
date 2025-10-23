# Quality Rubric — Chat Response Assessment

**Purpose**: Manual checklist for evaluating chat response quality across key dimensions (factuality, specificity, actionability).

---

## Scoring Dimensions

### 1. Factuality (Accuracy & Truth)

**Definition**: Claims match sources, no hallucinations or contradictions.

**Scale (1-5):**

| Score | Label           | Criteria                                                             |
| ----- | --------------- | -------------------------------------------------------------------- |
| 5     | Highly Accurate | All claims verified, explicit sources cited, uncertainties qualified |
| 4     | Accurate        | Most claims correct, minor gaps in citations                         |
| 3     | Mostly Accurate | Some unverified claims, few contradictions                           |
| 2     | Questionable    | Multiple unverified claims or contradictions                         |
| 1     | Inaccurate      | Major hallucinations, contradicts known facts                        |

**Assessment Questions:**

- [ ] Are all technical claims verifiable?
- [ ] Are sources cited for external facts?
- [ ] Are uncertainties explicitly qualified?
- [ ] Are there contradictions with docs/code?

---

### 2. Specificity (Concrete vs Vague)

**Definition**: Concrete details, exact identifiers, measurable criteria vs vague generalities.

**Scale (1-5):**

| Score | Label               | Criteria                                                      |
| ----- | ------------------- | ------------------------------------------------------------- |
| 5     | Highly Specific     | Exact file paths, function names, line numbers, test commands |
| 4     | Specific            | Clear targets, concrete examples, measurable criteria         |
| 3     | Moderately Specific | Some specifics, some vague language                           |
| 2     | Vague               | Mostly generic advice, few concrete details                   |
| 1     | Highly Vague        | Platitudes only, no actionable specifics                      |

**Assessment Questions:**

- [ ] Are file paths and function names explicit?
- [ ] Are examples concrete (not placeholder "X" or "foo")?
- [ ] Are success criteria measurable?
- [ ] Can I execute this without clarification?

---

### 3. Actionability (Clear Next Steps)

**Definition**: Clear, executable next steps vs deferral or hand-waving.

**Scale (1-5):**

| Score | Label                 | Criteria                                                |
| ----- | --------------------- | ------------------------------------------------------- |
| 5     | Highly Actionable     | Exact commands, step-by-step instructions, no ambiguity |
| 4     | Actionable            | Clear steps, minimal clarification needed               |
| 3     | Moderately Actionable | Some steps clear, some require interpretation           |
| 2     | Unclear               | Vague suggestions, defers to "you should figure out..." |
| 1     | Not Actionable        | No clear path forward, pure deferral                    |

**Assessment Questions:**

- [ ] Can I copy-paste commands/code directly?
- [ ] Are steps ordered and numbered?
- [ ] Are next actions explicit?
- [ ] Are there "TODO" or "figure out" gaps?

---

## Complete Rubric Checklist

### Response Details

- **Date:** [YYYY-MM-DD]
- **Context:** [Brief description of request]
- **Model:** [e.g., gpt-4, claude-3-5-sonnet]

---

### Dimension Scores

**1. Factuality**

Score: [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5

Notes:

```
- Sources cited: [Yes/No]
- Uncertainties qualified: [Yes/No]
- Contradictions found: [Yes/No/Where]
- Key facts verified: [List]
```

---

**2. Specificity**

Score: [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5

Notes:

```
- File paths provided: [Yes/No]
- Function names provided: [Yes/No]
- Measurable criteria: [Yes/No]
- Concrete examples: [Yes/No]
```

---

**3. Actionability**

Score: [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5

Notes:

```
- Executable commands: [Yes/No]
- Step-by-step instructions: [Yes/No]
- Clear next action: [Yes/No]
- Deferred items: [List]
```

---

### Overall Assessment

**Total Score:** [Sum of 3 dimensions] / 15

**Quality Band:**

- 13-15: Excellent
- 10-12: Good
- 7-9: Adequate
- 4-6: Needs Improvement
- 1-3: Poor

**Summary:**

```
[1-2 sentences on overall quality and key strengths/weaknesses]
```

**Actionable Improvements:**

```
[Bulleted list of specific improvements for next iteration]
```

---

## Scoring Examples

### Example 1: High-Quality Response (14/15)

**Request:** "Add token validation to the auth middleware"

**Response:**

> "I'll add JWT token validation to `api/middleware/auth.ts`:
>
> 1. Add function `validateToken(req, res, next)`
> 2. Check `Authorization: Bearer <token>` header
> 3. Verify signature using `jsonwebtoken.verify()`
> 4. Return 401 if invalid
> 5. Test: `api/middleware/auth.test.ts` with valid/invalid/expired tokens
>
> Proceed?"

**Scores:**

- Factuality: 5/5 (Accurate JWT approach, standard headers)
- Specificity: 5/5 (Exact file, function name, library, status code)
- Actionability: 4/5 (Clear steps, minimal gap in signature verification details)

**Total: 14/15 (Excellent)**

---

### Example 2: Medium-Quality Response (8/15)

**Request:** "Make the dashboard faster"

**Response:**

> "You can improve performance by optimizing renders. Consider using memoization and avoiding unnecessary re-renders. React hooks like `useMemo` and `useCallback` can help. You should also look at the component tree and see if anything can be optimized."

**Scores:**

- Factuality: 3/5 (Correct advice but no verification of current issues)
- Specificity: 2/5 (Generic advice, no file names or components identified)
- Actionability: 3/5 (Vague suggestions, no concrete next steps)

**Total: 8/15 (Adequate, needs improvement)**

---

### Example 3: Low-Quality Response (4/15)

**Request:** "Fix the bug in the user service"

**Response:**

> "There might be an issue with the logic. You should debug it and see what's wrong. Try adding some console logs or using a debugger. Once you figure out the problem, you can fix it."

**Scores:**

- Factuality: 2/5 (No specific claims, pure generality)
- Specificity: 1/5 (No file names, no code inspection, placeholders only)
- Actionability: 1/5 (Pure deferral, no concrete help)

**Total: 4/15 (Poor, needs major improvement)**

---

## Usage Workflows

### Workflow 1: Self-Review (Before Sending)

Before sending a response, quickly self-assess:

1. **Factuality check:** Did I verify claims? Cite sources?
2. **Specificity check:** Did I name files, functions, exact commands?
3. **Actionability check:** Can user copy-paste or execute immediately?

**Target:** 4-5 in all dimensions before sending.

---

### Workflow 2: Peer Review

When reviewing another's response:

1. Fill out complete rubric checklist
2. Note specific gaps (e.g., "Missing file path on line 3")
3. Provide 2-3 concrete improvement suggestions
4. Share score and summary

---

### Workflow 3: Trend Analysis

Log scores over time (CSV or spreadsheet):

```csv
Date,Context,Factuality,Specificity,Actionability,Total,Notes
2025-10-22,Auth implementation,5,5,4,14,Excellent
2025-10-23,Performance optimization,3,2,3,8,Too vague
```

**Analyze trends:**

- Are scores improving over time?
- Which dimension is weakest?
- Which contexts yield lower scores?

---

## Integration with Other Tools

### Use with Context Efficiency Gauge

**Combined assessment:**

- **Gauge** measures context efficiency (scope, rules, loops)
- **Rubric** measures response quality (factuality, specificity, actionability)

**Example:**

- Gauge: 5/5 (lean context)
- Rubric: 14/15 (excellent quality)
- **Result:** Optimal chat (efficient + high-quality)

---

### Use with Incident Playbook

When quality degrades (rubric score <7):

1. Check gauge → if score ≤2/5, context is bloated
2. Apply incident playbook → Incident 6 (Response Quality Degraded)
3. Corrective actions:
   - Reduce context noise (new chat)
   - Tighten request specificity
   - Ask for specific output format

See: [incident-playbook.md](./incident-playbook.md)

---

## Calibration Guidelines

### Inter-Rater Reliability

When multiple reviewers score the same response:

1. Each reviewer scores independently
2. Compare scores and discuss discrepancies
3. Aim for ±1 point agreement on each dimension
4. Refine rubric criteria if systematic disagreements occur

---

### Scoring Consistency

To maintain consistent scoring:

- **Anchor responses:** Keep 3-5 reference responses (high/medium/low) with agreed scores
- **Review anchors quarterly:** Ensure they still represent quality bands
- **Calibrate new reviewers:** Have them score anchors before production reviews

---

## Quick Reference Card

```text
┌──────────────────────────────────────────────┐
│ QUALITY RUBRIC QUICK CARD                    │
├──────────────────────────────────────────────┤
│ 3 Dimensions (1-5 scale each):               │
│                                              │
│ 1. Factuality (Accuracy)                     │
│    - Claims verified?                        │
│    - Sources cited?                          │
│    - Uncertainties qualified?                │
│                                              │
│ 2. Specificity (Concrete)                    │
│    - File paths named?                       │
│    - Examples concrete?                      │
│    - Criteria measurable?                    │
│                                              │
│ 3. Actionability (Executable)                │
│    - Commands copy-pasteable?                │
│    - Steps ordered?                          │
│    - No "figure it out" gaps?                │
│                                              │
│ Target: 13-15 (Excellent)                    │
│ Minimum: 10+ (Good)                          │
└──────────────────────────────────────────────┘
```

---

## Related

- See [prompt-tightening-patterns.md](./prompt-tightening-patterns.md) for making requests more specific
- See [incident-playbook.md](./incident-playbook.md) → Incident 6 for handling quality degradation
- See [../erd.md](../erd.md) Section 4.5 for quality rubric requirements
