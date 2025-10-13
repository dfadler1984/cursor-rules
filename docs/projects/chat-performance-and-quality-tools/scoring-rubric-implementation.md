# Context Efficiency Gauge — Scoring Rubric Implementation

## Purpose

This document specifies the concrete implementation of the Context Efficiency Gauge scoring algorithm, mapping heuristic inputs to scores (1-5 scale) and generating recommendations.

## Input Parameters

```typescript
interface GaugeInputs {
  scopeConcrete: boolean; // Is the task scope narrow and concrete?
  rulesCount: number; // Number of rules attached to the chat
  clarificationLoops: number; // Number of clarification/ambiguity rounds
  userIssues: string[]; // User-reported issues (e.g., "latency", "quality")
}
```

## Scoring Algorithm

### Step 1: Compute Base Score

Start with a base score of 5 (lean) and decrement based on signals:

```typescript
function computeBaseScore(inputs: GaugeInputs): number {
  let score = 5;

  // Scope check
  if (!inputs.scopeConcrete) {
    score -= 2; // Vague scope is a major penalty
  }

  // Rules attached
  if (inputs.rulesCount >= 13) {
    score -= 2;
  } else if (inputs.rulesCount >= 9) {
    score -= 1;
  } else if (inputs.rulesCount >= 6) {
    score -= 0.5;
  }

  // Clarification loops
  if (inputs.clarificationLoops >= 5) {
    score -= 2;
  } else if (inputs.clarificationLoops >= 4) {
    score -= 1;
  } else if (inputs.clarificationLoops >= 2) {
    score -= 0.5;
  }

  // User-reported issues
  const severeIssues = inputs.userIssues.filter(
    (i) =>
      i.includes("latency") || i.includes("quality") || i.includes("truncated")
  );
  if (severeIssues.length >= 2) {
    score -= 1;
  } else if (severeIssues.length >= 1) {
    score -= 0.5;
  }

  // Clamp to 1-5 range
  return Math.max(1, Math.min(5, Math.round(score)));
}
```

### Step 2: Map Score to Label

```typescript
function getLabel(score: number): "lean" | "ok" | "bloated" {
  if (score >= 4) return "lean";
  if (score >= 3) return "ok";
  return "bloated";
}
```

### Step 3: Generate Rationale

```typescript
function getRationale(inputs: GaugeInputs, score: number): string {
  const parts: string[] = [];

  if (inputs.scopeConcrete) {
    parts.push('narrow scope');
  } else {
    parts.push('vague scope');
  }

  if (inputs.rulesCount === 0) {
    parts.push('no rules');
  } else if (inputs.rulesCount <= 2) {
    parts.push('minimal rules');
  } else if (inputs.rulesCount <= 5) {
    parts.push(`${inputs.rulesCount} rules`);
  } else if (inputs.rulesCount <= 8) {
    parts.push(`${inputs.rulesCount} rules (moderate)');
  } else {
    parts.push(`${inputs.rulesCount} rules (high)');
  }

  if (inputs.clarificationLoops === 0) {
    parts.push('no loops');
  } else if (inputs.clarificationLoops === 1) {
    parts.push('1 clarification');
  } else if (inputs.clarificationLoops >= 4) {
    parts.push(`${inputs.clarificationLoops} clarifications (high)');
  } else {
    parts.push(`${inputs.clarificationLoops} clarifications`);
  }

  if (inputs.userIssues.length > 0) {
    parts.push(`issues: ${inputs.userIssues.join(', ')}`);
  } else {
    parts.push('no issues');
  }

  return parts.join(', ');
}
```

## Recommendation Logic

```typescript
interface Recommendation {
  action: "continue" | "consider-new-chat" | "new-chat";
  reason: string;
}

function getRecommendation(inputs: GaugeInputs, score: number): Recommendation {
  // Strong recommendation for new chat
  if (score <= 2) {
    return {
      action: "new-chat",
      reason: "Score 1-2: context is bloated; start new chat with narrow scope",
    };
  }

  // Check signal count for score 3
  if (score === 3) {
    const signals = [
      !inputs.scopeConcrete,
      inputs.rulesCount >= 9,
      inputs.clarificationLoops >= 4,
      inputs.userIssues.length >= 2,
    ];
    const trueSignals = signals.filter(Boolean).length;

    if (trueSignals >= 2) {
      return {
        action: "consider-new-chat",
        reason:
          "Score 3 + ≥2 signals: consider summarizing or starting new chat",
      };
    }
  }

  // Continue in current chat
  return {
    action: "continue",
    reason:
      score >= 4
        ? "Score 4-5: context is lean; continue here"
        : "Score 3: context is ok; continue here",
  };
}
```

## Complete Scoring Function

```typescript
interface GaugeResult {
  score: number;
  label: "lean" | "ok" | "bloated";
  rationale: string;
  recommendation: Recommendation;
}

export function scoreEfficiency(inputs: GaugeInputs): GaugeResult {
  const score = computeBaseScore(inputs);
  const label = getLabel(score);
  const rationale = getRationale(inputs, score);
  const recommendation = getRecommendation(inputs, score);

  return { score, label, rationale, recommendation };
}
```

## Calibration Examples

### Example 1: Lean (Score 5)

```typescript
const input = {
  scopeConcrete: true,
  rulesCount: 2,
  clarificationLoops: 0,
  userIssues: [],
};
// Result: { score: 5, label: 'lean', recommendation: { action: 'continue' } }
```

### Example 2: OK (Score 4)

```typescript
const input = {
  scopeConcrete: true,
  rulesCount: 4,
  clarificationLoops: 1,
  userIssues: [],
};
// Result: { score: 4, label: 'lean', recommendation: { action: 'continue' } }
```

### Example 3: OK (Score 3)

```typescript
const input = {
  scopeConcrete: true,
  rulesCount: 7,
  clarificationLoops: 2,
  userIssues: ["minor latency"],
};
// Result: { score: 3, label: 'ok', recommendation: { action: 'continue' } }
```

### Example 4: Bloated (Score 2) with signal trigger

```typescript
const input = {
  scopeConcrete: false,
  rulesCount: 10,
  clarificationLoops: 4,
  userIssues: ["latency", "quality issues"],
};
// Result: { score: 2, label: 'bloated', recommendation: { action: 'new-chat' } }
```

### Example 5: Bloated (Score 1)

```typescript
const input = {
  scopeConcrete: false,
  rulesCount: 15,
  clarificationLoops: 6,
  userIssues: ["severe latency", "response truncated", "quality degraded"],
};
// Result: { score: 1, label: 'bloated', recommendation: { action: 'new-chat' } }
```

## Signal Definitions

### Scope Concreteness

A scope is considered **concrete** if:

- Target files/paths are explicitly named
- The exact change is stated (imperative, one sentence)
- Success criteria are measurable

A scope is **vague** if:

- Target is ambiguous or missing ("improve the system", "make it better")
- Change is open-ended ("add features", "refactor things")
- Success criteria are absent or qualitative only

### Rules Count

Count all rules attached to the current chat session:

- Always-applied rules (from workspace config)
- Agent-requested rules (via `@rule-name` or semantic routing)
- Manually attached rules (user explicitly invoked)

### Clarification Loops

Count instances where:

- Assistant asks for clarification on scope/target/criteria
- User provides additional context after initial request
- Assistant requests consent or confirmation due to ambiguity

Do NOT count:

- TDD-mandated confirmations (pre-edit gate)
- Consent gates for commands (one-shot consent)
- Progress updates or status checks

### User Issues

Track user-reported concerns:

- **Latency**: "slow", "taking too long", "performance issues"
- **Quality**: "incorrect", "not what I asked", "missing details"
- **Truncation**: "response cut off", "incomplete", "seems truncated"

## Testing Strategy

### Unit Tests

- Test `computeBaseScore` with boundary inputs (0 rules, 0 loops, etc.)
- Test `getLabel` mapping for all scores 1-5
- Test `getRationale` output formatting
- Test `getRecommendation` for all score ranges and signal combinations

### Integration Tests

- Test complete `scoreEfficiency` with calibration examples
- Verify output format matches specification
- Test edge cases (negative inputs, extreme values)

### Manual Validation

- Score real chat transcripts (at least 10 samples)
- Compare computed scores with manual assessments
- Adjust weights/thresholds if systematic discrepancies found

## Notes

- This is a **heuristic tool**, not a precise measurement. Scores should guide decisions but not dictate them rigidly.
- The algorithm is intentionally simple and transparent; avoid complex ML or opaque scoring.
- Thresholds (rules count ranges, loop counts) may need calibration based on observed usage patterns.
- Future enhancements: integrate with quantitative headroom calculator when token estimation is available.
