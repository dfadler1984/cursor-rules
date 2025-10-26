# Projects README Generator

Automates generation of `docs/projects/README.md` by scanning project directories and extracting metadata from ERD files.

## Status

**Active** — Implementation complete, ready for use

## Quick Start

```bash
# Generate with npm script
npm run generate:projects-readme

# Or run directly
./.cursor/scripts/generate-projects-readme.sh

# Dry-run (preview without writing)
./.cursor/scripts/generate-projects-readme.sh --dry-run
```

## Features

- **Automatic discovery**: Scans `docs/projects/` and lists all project directories
- **Smart exclusions**: Skips `_archived/` and `_examples/` directories
- **Metadata extraction**: Reads title, status, and owner from ERD YAML front matter
- **Flexible formatting**: Handles multiple ERD formats (YAML title field or H1 heading)
- **Task tracking**: Detects presence of `tasks.md` and shows checkmark indicator
- **Sorted output**: Alphabetically sorted by project name (case-insensitive)
- **Idempotent**: Stable output for version control

## Implementation

### Scripts

- `.cursor/scripts/generate-projects-readme.sh` — Main generator script
- `.cursor/scripts/generate-projects-readme.test.sh` — Test suite

### Tests

Run tests:

```bash
# Run with test runner
bash .cursor/scripts/tests/run.sh -k generate-projects-readme -v

# Or directly
bash .cursor/scripts/generate-projects-readme.test.sh
```

Test coverage:

- ✅ Help flag
- ✅ Dry-run mode
- ✅ Project discovery (excludes \_archived, \_examples)
- ✅ Table structure generation
- ✅ Metadata extraction from fixture files
- ✅ Handles missing erd.md gracefully

## Usage

```bash
# Default: writes to docs/projects/README.md
./.cursor/scripts/generate-projects-readme.sh

# Custom paths
./.cursor/scripts/generate-projects-readme.sh \
  --projects-dir ./docs/projects \
  --out ./docs/projects/README.md

# Preview without writing
./.cursor/scripts/generate-projects-readme.sh --dry-run
```

## Output Format

Generates a Markdown table with:

| Column  | Description                                             |
| ------- | ------------------------------------------------------- |
| Project | Title from ERD (YAML `title` field or first H1)         |
| Status  | Status from ERD YAML front matter                       |
| ERD     | Link to `erd.md` (📄) or dash (—)                       |
| Tasks   | Checkmark (✅) if `tasks.md` exists, dash (—) otherwise |

## Metadata Extraction

The script reads ERD files in this order:

1. **Title**: YAML front matter `title` field → fallback to first H1 heading → fallback to folder name
2. **Status**: YAML front matter `status` field → fallback to markdown field `**Status**:` → fallback to "unknown"
3. **Tasks**: Checks for `tasks.md` file existence

### ERD Format Requirements

**Standard Format (YAML Front Matter)** — _Preferred_

All project ERDs should use YAML front matter for metadata:

```markdown
---
status: active
owner: team-name
created: 2025-10-23
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Project Name

Mode: Lite

## 1. Introduction/Overview

...
```

**Required YAML Fields:**

- `status`: Must be `active`, `completed`, `planning`, `proposed`, or `archived` (lowercase)
- `owner`: Team or person responsible
- `created`: Date in `YYYY-MM-DD` format
- `lastUpdated`: Date in `YYYY-MM-DD` format

**Legacy Format (Markdown Fields)** — _Deprecated_

The generator supports (but discourages) markdown field format for backward compatibility:

```markdown
# Engineering Requirements Document: Project Name

**Project**: project-slug  
**Status**: ACTIVE  
**Created**: 2025-10-23  
**Owner**: team-name
```

**⚠️ This format is deprecated.** The ERD validator (`erd-validate.sh`) will fail on this format.

### Migrating Legacy ERDs

Use the migration script to convert markdown fields to YAML front matter:

```bash
# Migrate a single ERD
./.cursor/scripts/erd-migrate-frontmatter.sh docs/projects/my-project/erd.md

# Preview changes (dry-run)
./.cursor/scripts/erd-migrate-frontmatter.sh docs/projects/my-project/erd.md --dry-run

# Migrate all non-compliant ERDs
for f in docs/projects/*/erd.md; do
  bash .cursor/scripts/erd-validate.sh "$f" 2>&1 | grep -q "front matter: status" && \
    ./.cursor/scripts/erd-migrate-frontmatter.sh "$f"
done
```

### Validation

Validate ERD format compliance:

```bash
# Validate single ERD
./.cursor/scripts/erd-validate.sh docs/projects/my-project/erd.md

# Validate all project ERDs
for f in docs/projects/*/erd.md; do
  ./.cursor/scripts/erd-validate.sh "$f" || echo "FAIL: $f"
done
```

## Integration

### NPM Script

Added to `package.json`:

```json
"generate:projects-readme": ".cursor/scripts/generate-projects-readme.sh"
```

### Project Lifecycle

Consider running this script:

- Before committing project changes
- As part of project completion workflow
- Periodically to keep the index up to date

### CI Integration (Optional)

Could add a check to ensure README is current:

```bash
# Generate fresh copy and check for diff
./.cursor/scripts/generate-projects-readme.sh --out /tmp/projects-readme-new.md
diff docs/projects/README.md /tmp/projects-readme-new.md || {
  echo "ERROR: docs/projects/README.md is out of date"
  echo "Run: npm run generate:projects-readme"
  exit 1
}
```

## Design Decisions

- **POSIX shell**: No external dependencies beyond coreutils
- **Idempotent output**: Stable sorting ensures no unnecessary diffs
- **Graceful degradation**: Handles missing files, malformed YAML, and various ERD formats
- **Simple parsing**: Uses bash string manipulation and grep/sed for YAML (avoids yq dependency)

## Related Files

- `docs/projects/_archived/2025/projects-readme-generator/erd.md` — Requirements
- `docs/projects/_archived/2025/projects-readme-generator/tasks.md` — Implementation tasks
