# Test Fixtures

This directory contains fixture data for testing scripts without network access.

## Purpose

Per the [Network Policy (D4)](../../../docs/standards/shell-network-policy.md), all repository tests must function without network access. Fixtures enable deterministic testing of network-dependent behaviors.

## Structure

```
fixtures/
├── github/
│   ├── pr-123.json          # Example PR response
│   ├── checks-success.json  # Check run success response
│   └── checks-failure.json  # Check run failure response
├── README.md                # This file
└── .gitkeep
```

## Usage

Scripts source `.lib-net.sh` and use `net_fixture <name>` to load fixture data:

```bash
source "$(dirname "$0")/.lib-net.sh"

# In tests or dry-run mode:
pr_data=$(net_fixture "github/pr-123.json")
```

## Adding Fixtures

1. Capture real API response (one-time, with redacted tokens)
2. Save as JSON in appropriate subdirectory
3. Redact any sensitive data (tokens, emails, internal URLs)
4. Document the fixture purpose in this README
5. Reference the fixture in relevant test files

## Fixtures Inventory

- `github/pr-123.json` — Example pull request response for PR creation tests
- `github/checks-success.json` — Successful check run response
- `github/checks-failure.json` — Failed check run response

_(Add entries as fixtures are created)_
