# sample-feature Plan

## Steps

- Draft initial spec and plan
- Create tasks with single active sub-task policy

## Acceptance Bundle

```json
{
  "targets": [
    "docs/specs/sample-feature-spec.md",
    "docs/plans/sample-feature-plan.md"
  ],
  "exactChange": "Create valid sample trio for validator",
  "successCriteria": ["Validator passes on sample trio"],
  "runInstructions": [
    ".cursor/scripts/validate-artifacts.sh --paths docs/specs/sample-feature-spec.md,docs/plans/sample-feature-plan.md"
  ],
  "ownerSpecs": []
}
```

## Risks

- None for sample

[Links: Spec](../specs/sample-feature-spec.md)
