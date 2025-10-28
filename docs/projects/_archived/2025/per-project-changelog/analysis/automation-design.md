# Automatic Changelog Generation - Design

## Architecture

### Data Flow

```
1. Parse Sources → 2. Categorize → 3. Format → 4. Output/Append
```

### Components

**1. Source Parsers** (pure functions)

- `parse_tasks_md()` - Extract phases, tasks, decisions, scope changes
- `parse_git_log()` - Extract conventional commits
- `parse_erd()` - Extract status changes

**2. Categorizer** (pure function)

- `categorize_changes()` - Map detected items to changelog categories
  - Task descriptions → Added/Changed/Fixed based on keywords
  - Decisions → Decisions category
  - Scope changes → Changed/Removed
  - Commits → Map by type (feat→Added, fix→Fixed, etc.)

**3. Entry Formatter** (pure function)

- `format_changelog_entry()` - Generate markdown from categorized data
  - Phase name from tasks or date
  - Summary from phase header or first task
  - Category sections (Added, Changed, Decisions, Removed, Fixed)

**4. Appender** (impure - file I/O)

- `append_to_changelog()` - Insert entry into CHANGELOG.md
  - Find [Unreleased] section
  - Insert new dated section below it
  - Preserve existing content

## Categorization Rules

### Task Description → Category Mapping

**Keywords → Added**:

- Create, Add, Implement, Build, Generate, Initialize, Introduce

**Keywords → Changed**:

- Update, Modify, Refactor, Convert, Migrate, Reorganize, Enhance

**Keywords → Fixed**:

- Fix, Correct, Resolve, Repair

**Keywords → Removed**:

- Remove, Delete, Deprecate, Archive

**Keywords → Decisions**:

- D1:, D2:, Decision:, Decided, Chose

### Commit Type → Category Mapping

- `feat:` → Added
- `fix:` → Fixed
- `refactor:` → Changed
- `perf:` → Changed
- `docs:` → Changed (or separate Docs category)
- `test:` → Added (if new tests)
- `chore:` → Changed
- `build:` → Changed
- `ci:` → Changed

### Special Markers

**Scope Changes** (→ Changed or Removed):

- "Migrated to X" → Changed
- "Superseded by X" → Removed
- "Deferred to X" → Changed or Carryovers note

## Phase Detection Logic

### Completed Phase

**Pattern**: `## Phase N: Name (X hours) ✅ COMPLETE`

**Extract**:

- Phase number: N
- Phase name: "Name"
- All completed parent tasks under that phase

**Generate**:

```markdown
## [Phase N: Name] - YYYY-MM-DD

### Summary

[First completed parent task description or derived from phase name]

### Added

- [Tasks with Create/Add/Implement keywords]

### Changed

- [Tasks with Update/Modify/Refactor keywords]

### Decisions

- [Tasks or notes with D1:, Decision: markers]
```

### In-Progress Phase

Skip or optionally add to [Unreleased] section

## Date Detection

### Auto-detect --since date

1. Check CHANGELOG.md for last dated entry
2. Extract date from last `## [Phase X] - YYYY-MM-DD`
3. Fall back to ERD `created` date from front matter
4. User can override with `--since`

## Example Output

Given tasks.md with:

```
## Phase 1: Setup (COMPLETE)
- [x] 1.0 Create project structure
- [x] 2.0 Add build scripts
```

And git commits:

```
feat(changelog): add template
fix(validation): correct phase detection
```

Generate:

```markdown
## [Phase 1: Setup] - 2025-10-27

### Summary

Completed project setup and build configuration.

### Added

- Created project structure
- Added build scripts

### Fixed

- Corrected phase detection in validation

---
```

## Implementation Strategy

### Phase 1: Pure Parsing (TDD)

1. Write tests for parse functions
2. Implement parsers to make tests pass
3. Test with fixtures

### Phase 2: Categorization (TDD)

1. Write tests for categorize_changes()
2. Implement keyword matching
3. Test with sample data

### Phase 3: Formatting (TDD)

1. Write tests for format_changelog_entry()
2. Implement markdown generation
3. Test output format

### Phase 4: File Operations

1. Test append_to_changelog() with temp files
2. Implement safe insertion (backup, validation)
3. Test all three modes (dry-run, interactive, auto)

## Edge Cases

- Empty phases (no tasks completed)
- Phases without descriptions
- Mixed completion states
- Multiple phases completed at once
- No git commits in range
- Malformed task markdown

## Success Criteria

- Detects 90%+ of meaningful changes from tasks.md
- Correctly maps task keywords to categories
- Generates valid markdown
- Doesn't corrupt existing CHANGELOG.md
- Interactive mode allows editing before append
- Dry-run shows preview without modification
