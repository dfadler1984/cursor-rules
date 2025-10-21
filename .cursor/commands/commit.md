# Commit Changes

Use the repository's conventional commit helper:

```bash
bash .cursor/scripts/git-commit.sh --type <feat|fix|...> --description "..."
```

## Available Types

`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

## Options

**With scope**:

```bash
--scope <scope> --description "..."
```

**With body** (multiple lines):

```bash
--body "First line" --body "Second line"
```

**Breaking change**:

```bash
--breaking "Description of breaking change"
```

## Examples

```bash
# Simple commit
bash .cursor/scripts/git-commit.sh --type feat --description "add user authentication"

# With scope
bash .cursor/scripts/git-commit.sh --type fix --scope auth --description "handle empty token"

# With body
bash .cursor/scripts/git-commit.sh --type feat --description "add TDD compliance checker" \
  --body "- Filters doc-only changes" \
  --body "- Calculates accurate compliance rate"

# Breaking change
bash .cursor/scripts/git-commit.sh --type feat --description "change API response format" \
  --breaking "Response field 'data' renamed to 'results'"
```

## See Also

- [assistant-git-usage.mdc](../rules/assistant-git-usage.mdc) - Full git workflow documentation
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message specification
