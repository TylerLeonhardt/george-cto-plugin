#!/usr/bin/env bash
set -euo pipefail

# dispatch.sh — Dispatch a Team Lead with culture injection via ahpx
# Usage: dispatch.sh <session-name> <project-dir> <task-description> [--server <server>]
#
# Example:
#   dispatch.sh fix-auth /path/to/project "Fix the authentication bug in login.ts"
#   dispatch.sh add-tests /path/to/project "Add unit tests for the user service" --server dev-2

SESSION="${1:?Usage: dispatch.sh <session-name> <project-dir> <task> [--server <server>]}"
PROJECT_DIR="${2:?Usage: dispatch.sh <session-name> <project-dir> <task> [--server <server>]}"
TASK="${3:?Usage: dispatch.sh <session-name> <project-dir> <task> [--server <server>]}"
shift 3

SERVER_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --server)
      SERVER_ARGS=(--server "$2")
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CULTURE_FILE="${SCRIPT_DIR}/../references/team-lead-culture.md"

if ! command -v ahpx &>/dev/null; then
  echo "Error: ahpx is not installed. Run: npm install -g @tylerl0706/ahpx" >&2
  exit 1
fi

if [[ ! -f "$CULTURE_FILE" ]]; then
  echo "Error: Team Lead culture file not found at $CULTURE_FILE" >&2
  exit 1
fi

CULTURE=$(cat "$CULTURE_FILE")

PROMPT="${CULTURE}

---

George (the CTO) has given you this direction:

${TASK}"

ahpx prompt -n "$SESSION" --cwd "$PROJECT_DIR" "${SERVER_ARGS[@]}" "$PROMPT"
