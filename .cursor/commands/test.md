# Run Tests

## TDD Workflow

Follow the Red → Green → Refactor cycle:

1. **Red**: Write failing test
2. **Green**: Implement minimal code to pass
3. **Refactor**: Improve while keeping tests green

## Run Focused Tests

**For specific file**:

```bash
yarn test <path/to/file.spec.ts>
```

**For specific test**:

```bash
yarn test <path> -t "test name"
```

**Shell scripts**:

```bash
bash .cursor/scripts/tests/run.sh -k <keyword> -v
```

## Run All Tests

```bash
yarn test
```

## Coverage

```bash
yarn test --coverage
```

## Test File Colocation

Tests must be colocated with source files:

```
src/foo.ts          → src/foo.spec.ts
components/Bar.tsx  → components/Bar.spec.tsx
.cursor/scripts/x.sh → .cursor/scripts/x.test.sh
```

## Before Committing

Run tests relevant to your changes:

```bash
yarn test <changed-file.spec.ts>
```

## See Also

- [tdd-first.mdc](../rules/tdd-first.mdc) - TDD methodology
- [testing.mdc](../rules/testing.mdc) - Test structure and conventions
- [test-quality.mdc](../rules/test-quality.mdc) - Quality standards
