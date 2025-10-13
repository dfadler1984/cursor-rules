# Scripts — Setup and Usage

## Environment Setup

### Required: GitHub Token

GitHub automation scripts (`pr-create.sh`, `pr-update.sh`, `checks-status.sh`) require a GitHub token for API access.

**Setup:**
```bash
# Add to your ~/.zprofile or ~/.bash_profile:
export GH_TOKEN="ghp_your_token_here"
```

**Token requirements:**
- Classic token: `repo` scope
- Fine-grained token: Repository access + `Contents: Read/Write`, `Pull requests: Read/Write`, `Metadata: Read`

**Get a token:**
1. Visit: https://github.com/settings/tokens
2. Generate new token (classic) with `repo` scope
3. Add to profile as shown above

### Optional: Development Tools

**For linting:**
```bash
brew install shellcheck  # macOS
```

**For enhanced output:**
- `jq` — JSON parsing (improves pr-create/checks-status output)
- `column` — Table formatting (used by .lib.sh print_table)

Scripts degrade gracefully when these are absent.

## Usage

### GitHub Automation

```bash
# Create a pull request
.cursor/scripts/pr-create.sh --title "My PR" --body "Description"

# Update PR title
.cursor/scripts/pr-update.sh --pr 123 --title "New Title"

# Check CI status
.cursor/scripts/checks-status.sh --pr 123
```

### Validation

```bash
# Validate help documentation
.cursor/scripts/help-validate.sh

# Check for network usage (informational)
.cursor/scripts/network-guard.sh

# Validate strict mode compliance
.cursor/scripts/error-validate.sh

# Lint shell scripts
.cursor/scripts/shellcheck-run.sh
```

### Testing

```bash
# Run all tests
.cursor/scripts/tests/run.sh

# Run specific tests
.cursor/scripts/tests/run.sh -k pr-create -v

# Run single test file
.cursor/scripts/tests/run.sh /path/to/test.sh
```

## Architecture

See [shell-and-script-tooling ERD](../../docs/projects/shell-and-script-tooling/erd.md) for:
- Cross-cutting decisions (D1-D6)
- Portability policy
- Test isolation approach
- Exit code catalog

## Troubleshooting

**"GH_TOKEN is required"**
- Add `export GH_TOKEN="your_token"` to your shell profile
- Source the profile: `source ~/.zprofile` or `source ~/.bash_profile`

**"Bad credentials" (401)**
- Token may be expired or lack required scopes
- Regenerate token with `repo` scope

**Test failures after running suite**
- Known issue: test runner leaks environment variables (D6)
- Workaround: `source ~/.zprofile` to restore env
- Fix in progress: Phase 5 tasks (subshell isolation)

