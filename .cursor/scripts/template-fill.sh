#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: template-fill.sh --template <name> --project <slug> --out <path> [--vars k=v ...]

Templates live under .cursor/templates/project-lifecycle/ and are markdown files with placeholders like <Project Name>.

Supported template names:
  - final-summary
  - completion-checklist
  - retrospective

Placeholders replaced:
  - <Project Name>  (from --vars projectName="...")
  - <project>       (from --project)

Additional --vars k=v pairs can be used for custom tokens; tokens must appear as <k> in the template.
EOF
}

template=""
project=""
out=""
declare -a kv_pairs=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --template) template="$2"; shift 2;;
    --project) project="$2"; shift 2;;
    --out) out="$2"; shift 2;;
    --vars) shift; while [[ $# -gt 0 && "$1" != --* ]]; do kv_pairs+=("$1"); shift; done ;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 2;;
  esac
done

if [[ -z "$template" || -z "$project" || -z "$out" ]]; then
  usage >&2; exit 2
fi

root_dir="$(cd "$(dirname "$0")/../.." && pwd)"
tpath="$root_dir/.cursor/templates/project-lifecycle/${template}.template.md"

if [[ ! -f "$tpath" ]]; then
  echo "Template not found: $tpath" >&2
  exit 1
fi

mkdir -p "$(dirname "$out")"

content="$(cat "$tpath")"

# Built-in replacements
content="${content//<project>/$project}"

# Optional projectName for the title
projectName="$project"
for kv in "${kv_pairs[@]:-}"; do
  key="${kv%%=*}"
  val="${kv#*=}"
  if [[ "$key" == "projectName" ]]; then
    projectName="$val"
  fi
  # Replace tokens like <key>
  token="<$key>"
  content="${content//$token/$val}"
done

content="${content//<Project Name>/$projectName}"

printf "%s\n" "$content" > "$out"
echo "Wrote $out"

