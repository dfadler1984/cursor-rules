#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: project-create.sh --name <slug> [--mode full|lite] [--owner <owner>] [--with-changelog] [--root <path>]

Create a new project directory with ERD, tasks, and README from templates.

Options:
  --name <slug>       Project slug (kebab-case, required)
  --mode <mode>       ERD mode: full (default) or lite
  --owner <owner>     Project owner (default: repo-maintainers)
  --with-changelog    Include per-project CHANGELOG.md (optional, recommended for investigations)
  --root <path>       Repository root override (defaults to detected root)
  -h, --help          Show this help

Examples:
  # Create full project
  project-create.sh --name my-project --owner my-team
  
  # Create lite project with changelog
  project-create.sh --name quick-fix --mode lite --with-changelog
  
  # Create investigation project with changelog
  project-create.sh --name complex-investigation --with-changelog
USAGE
  
  print_exit_codes
}

NAME=""
MODE="full"
OWNER="repo-maintainers"
ROOT="$ROOT_DIR"
WITH_CHANGELOG=0

while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="${2-}"; shift 2 ;;
    --mode) MODE="${2-}"; shift 2 ;;
    --owner) OWNER="${2-}"; shift 2 ;;
    --with-changelog) WITH_CHANGELOG=1; shift 1 ;;
    --root) ROOT="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$NAME" ]; then
  echo "--name is required" >&2
  usage
  exit 2
fi

# Validate slug is kebab-case
if ! echo "$NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "Error: slug must be kebab-case (lowercase, hyphens only): $NAME" >&2
  exit 1
fi

# Validate mode
if [ "$MODE" != "full" ] && [ "$MODE" != "lite" ]; then
  echo "Error: --mode must be 'full' or 'lite', got: $MODE" >&2
  exit 1
fi

PROJECT_DIR="$ROOT/docs/projects/$NAME"

# Check if project already exists
if [ -d "$PROJECT_DIR" ]; then
  echo "Error: project directory already exists: $PROJECT_DIR" >&2
  exit 1
fi

# Create project directory
mkdir -p "$PROJECT_DIR"

# Generate display name (title-case from kebab-case)
DISPLAY_NAME=$(echo "$NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) }}1')
CREATED_DATE=$(date +%Y-%m-%d)

# Generate ERD based on mode
ERD_FILE="$PROJECT_DIR/erd.md"
if [ "$MODE" = "full" ]; then
  cat > "$ERD_FILE" <<EOF
---
status: planning
owner: $OWNER
created: $CREATED_DATE
lastUpdated: $CREATED_DATE
---

# Engineering Requirements Document — $DISPLAY_NAME

## 1. Introduction/Overview

<One-paragraph overview of the problem and proposed solution.>

## 2. Goals/Objectives

- <Primary goal 1>
- <Primary goal 2>

## 3. User Stories

- As a <persona>, I want <capability> so that <benefit>

## 4. Functional Requirements

1. <Requirement 1>
2. <Requirement 2>

## 5. Non-Functional Requirements

- **Performance**: <targets>
- **Reliability**: <targets>
- **Security**: <considerations>

## 6. Architecture/Design

<High-level approach, patterns, components>

## 7. Data Model and Storage

<Schemas, migrations, retention>

## 8. API/Contracts

<Endpoints, events, contracts>

## 9. Integrations/Dependencies

- <External systems>
- <Related projects>

## 10. Edge Cases and Constraints

- <Edge case 1>
- <Constraint 1>

## 11. Testing & Acceptance

<Narrative acceptance criteria; NOT checklists>

## 12. Rollout & Ops

<Feature flags, monitoring, rollback>

## 13. Success Metrics

- <Metric 1>: <target>

## 14. Open Questions

1. <Question 1>?
2. <Question 2>?

---

Owner: $OWNER  
Created: $CREATED_DATE
EOF
else
  # Lite mode
  cat > "$ERD_FILE" <<EOF
---
status: planning
owner: $OWNER
created: $CREATED_DATE
lastUpdated: $CREATED_DATE
---

# Engineering Requirements Document — $DISPLAY_NAME (Lite)

## 1. Introduction/Overview

<1-2 paragraph overview>

## 2. Goals/Objectives

- <Goal 1>
- <Goal 2>

## 3. Functional Requirements

1. <Requirement 1>
2. <Requirement 2>

## 4. Acceptance Criteria

- <Criterion 1>
- <Criterion 2>

## 5. Risks/Edge Cases

- <Risk 1>
- <Edge case 1>

## 6. Rollout

<Owner, flag, target date>

---

Owner: $OWNER  
Created: $CREATED_DATE
EOF
fi

# Generate tasks.md
TASKS_FILE="$PROJECT_DIR/tasks.md"
cat > "$TASKS_FILE" <<EOF
# Tasks — $DISPLAY_NAME

## Relevant Files

- \`docs/projects/$NAME/erd.md\` — Requirements
- \`docs/projects/$NAME/tasks.md\` — This file

## Phase 1: <Phase Name>

- [ ] 1.0 <Parent task>
  - [ ] 1.1 <Sub-task>
  - [ ] 1.2 <Sub-task>

## Phase 2: <Phase Name>

- [ ] 2.0 <Parent task>
  - [ ] 2.1 <Sub-task>

## Notes

<Optional notes or decisions>
EOF

# Generate README.md
README_FILE="$PROJECT_DIR/README.md"
cat > "$README_FILE" <<EOF
# $DISPLAY_NAME

**Status**: Planning  
**Owner**: $OWNER

## Quick Links

- [ERD](./erd.md) — Requirements and design
- [Tasks](./tasks.md) — Execution tracking

## Overview

<One-paragraph project description>

## Related

- <Related project or doc>
EOF

# Optionally create CHANGELOG.md from template
if [ "$WITH_CHANGELOG" -eq 1 ]; then
  CHANGELOG_FILE="$PROJECT_DIR/CHANGELOG.md"
  CHANGELOG_TEMPLATE="$ROOT/.cursor/templates/project-lifecycle/CHANGELOG.template.md"
  
  if [ -f "$CHANGELOG_TEMPLATE" ]; then
    # Copy template and replace placeholders
    sed -e "s/{{PROJECT_TITLE}}/$DISPLAY_NAME/g" \
        -e "s/YYYY-MM-DD/$CREATED_DATE/g" \
        "$CHANGELOG_TEMPLATE" > "$CHANGELOG_FILE"
    
    echo "Created CHANGELOG.md from template"
  else
    echo "Warning: CHANGELOG template not found at $CHANGELOG_TEMPLATE" >&2
    echo "Skipping CHANGELOG creation" >&2
  fi
fi

echo "Project created successfully at: $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "  1. Fill in ERD sections: $ERD_FILE"
echo "  2. Add project to docs/projects/README.md under 'Active Projects'"
echo "  3. Generate tasks: See .cursor/rules/generate-tasks-from-erd.mdc"
if [ "$WITH_CHANGELOG" -eq 1 ]; then
  echo "  4. Update CHANGELOG.md at end of each session or phase transition"
fi

exit 0

