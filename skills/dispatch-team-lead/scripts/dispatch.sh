#!/usr/bin/env bash
set -euo pipefail

# dispatch.sh — Dispatch a Team Lead with culture injection
# Usage: dispatch.sh <agent> <session-name> <project-dir> <task-description>
#
# Example:
#   dispatch.sh copilot fix-auth /path/to/project "Fix the authentication bug in login.ts"
#   dispatch.sh claude add-tests /path/to/project "Add unit tests for the user service"

AGENT="${1:?Usage: dispatch.sh <agent> <session-name> <project-dir> <task>}"
SESSION="${2:?Usage: dispatch.sh <agent> <session-name> <project-dir> <task>}"
PROJECT_DIR="${3:?Usage: dispatch.sh <agent> <session-name> <project-dir> <task>}"
TASK="${4:?Usage: dispatch.sh <agent> <session-name> <project-dir> <task>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CULTURE_FILE="${SCRIPT_DIR}/../references/team-lead-culture.md"

if ! command -v acpx &>/dev/null; then
  echo "Error: acpx is not installed. Run: npm install -g acpx" >&2
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

acpx "$AGENT" -s "$SESSION" --approve-all --cwd "$PROJECT_DIR" exec "$PROMPT"
