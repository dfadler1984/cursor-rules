# Shell Script Network Policy (D4)

**Purpose**: Test isolation - tests must never make live network calls  
**Source**: Extracted from shell-and-script-tooling + networkless-scripts projects  
**Enforcement**: Tests use seams/fixtures, production scripts can make network calls when needed

---

## Policy

### Tests MUST Be Networkless

**All test files** (`*.test.sh`) must use seams and fixtures, never make live API calls:

```bash
#!/usr/bin/env bash
# test-script.test.sh

# Use seams to inject fixture data
export CURL_CMD=cat
export JQ_CMD=jq

# Tests never hit network
result=$(bash script-under-test.sh)
```

### Production Scripts CAN Use Network

**Production scripts** may make network calls when that's their primary purpose:

**Network-using scripts** (legitimate):
- `pr-create.sh` — GitHub API (create pull requests)
- `pr-update.sh` — GitHub API (update pull requests)
- `checks-status.sh` — GitHub API (check run status)
- `changesets-automerge-dispatch.sh` — GitHub API (workflow dispatch)
- `setup-remote.sh` — Dependency checking

---

## Implementation

### Test Seams (.lib-net.sh)

Tests source `.lib-net.sh` for networkless helpers:

```bash
# shellcheck disable=SC1091
source "$(dirname "$0")/.lib-net.sh"

# Load fixture data instead of making network call
pr_data=$(net_fixture "github/pr-123.json")
```

### Guard Tests

Verify scripts respect seams and don't bypass to live network:

```bash
# Set CURL_BIN to false to ensure script doesn't bypass seam
export CURL_BIN=false

# Run script - should use seam, not real curl
result=$(bash script.sh)

# If script tries to use real curl, it will fail
```

### Fixtures Location

Test fixture data lives in `.cursor/scripts/tests/fixtures/`:

```
fixtures/
├── github/
│   ├── pr-123.json          # Example PR response
│   ├── checks-success.json  # Check run success
│   └── checks-failure.json  # Check run failure
└── README.md
```

---

## Validation

**Check compliance**:
```bash
# Verify tests don't make network calls
.cursor/scripts/network-guard.sh
```

**Expected**: 
- Tests: 0 network calls
- Production: 5 scripts legitimately use network (informational mode)

---

## Examples

### Production Script with Network

```bash
#!/usr/bin/env bash
# pr-create.sh - Legitimately uses GitHub API

# Make real API call in production
response=$(curl -sS -H "Authorization: token $GH_TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/pulls" \
  -d "$payload")
```

### Test for Network Script

```bash
#!/usr/bin/env bash
# pr-create.test.sh - Uses fixtures, not real API

# Inject fixture via seam
export CURL_CMD="cat $(dirname "$0")/tests/fixtures/github/pr-123.json"

# Test uses fixture, never hits GitHub API
result=$(bash pr-create.sh --title "test")

# Assert against fixture data
echo "$result" | grep -q '"number": 123'
```

---

## Related

**D3**: Exit code standards (`.cursor/docs/standards/shell-exit-codes.md`)  
**Test fixtures**: `.cursor/scripts/tests/fixtures/README.md`  
**.lib-net.sh**: Network test helpers (`.cursor/scripts/.lib-net.sh`)

---

**Origin**: networkless-scripts + shell-and-script-tooling projects (archived 2025-10-13)  
**Status**: Active policy, enforced by network-guard.sh  
**Adoption**: 100% test isolation (tests never hit network)

