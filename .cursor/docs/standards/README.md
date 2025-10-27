# Shell Script Standards

**Purpose**: Active standards for all shell scripts in `.cursor/scripts/`  
**Source**: Extracted from archived shell-and-script-tooling project  
**Status**: Currently enforced via validators

---

## Standards (D1-D6)

### [D3: Exit Code Standards](./shell-exit-codes.md)

Standardized exit codes for all shell scripts:
- `EXIT_USAGE=2` — Usage error (missing args, invalid flags)
- `EXIT_CONFIG=3` — Configuration error
- `EXIT_DEPENDENCY=4` — Dependency missing
- `EXIT_NETWORK=5` — Network failure
- `EXIT_TIMEOUT=6` — Timeout
- `EXIT_INTERNAL=20` — Internal error

**Enforcement**: `.cursor/scripts/error-validate.sh`

### [D4: Network Policy](./shell-network-policy.md)

Test isolation requirements:
- Tests MUST use seams/fixtures (never live network)
- Production scripts CAN make network calls when needed
- Fixtures in `.cursor/scripts/tests/fixtures/`

**Enforcement**: `.cursor/scripts/network-guard.sh`

---

## Migration Guide

For detailed patterns on adopting these standards in new/existing scripts:


Covers:
- How to add help documentation (D1)
- Implementing strict mode (D2)
- Using exit code constants (D3)
- Network seams for tests (D4)
- Dependency portability (D5)
- Test isolation patterns (D6)

---

## Other Standards (in .lib.sh)

**D1**: Help/Version minimums
- Flags: `-h|--help`, `--version` required
- Sections: Usage, Options, Examples, Exit Codes
- Enforcement: `.cursor/scripts/help-validate.sh`

**D2**: Strict mode baseline
- `set -Eeuo pipefail`, sane IFS, ERR trap
- Helper: `enable_strict_mode()` in `.lib.sh`
- Enforcement: `.cursor/scripts/error-validate.sh`

**D5**: Dependency portability
- Required: `bash` (≥4.0), `git`
- Optional: `jq`, `column`, `shellcheck` (graceful degradation)
- Helper: `have_cmd()` in `.lib.sh`

**D6**: Test isolation
- Subshell isolation prevents env leakage
- Tests clean up temporary files

---

## Validation

Run all validators:
```bash
# Help documentation
.cursor/scripts/help-validate.sh

# Strict mode + exit codes
.cursor/scripts/error-validate.sh

# Network policy
.cursor/scripts/network-guard.sh
```

---

## Historical Reference

These standards originated from the **shell-and-script-tooling** project (completed 2025-10-13, archived). The project established D1-D6 as cross-cutting decisions and achieved 100% adoption across all scripts.

**Full historical context**: `docs/projects/_archived/2025/shell-and-script-tooling/final-summary.md`

---

**Status**: Active standards, currently enforced  
**Adoption**: 100% (47 validated scripts compliant)  
**Last Updated**: 2025-10-24 (extracted from archived project)

