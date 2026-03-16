#!/bin/bash
# Post-tool-use hook: Run the project's linter on files changed by edit/create tools.
# Detects the project's linter automatically (biome, eslint, etc.).
#
# Compatible with both Open Plugin and Claude Code hook formats:
#   Open Plugin: { toolName, toolArgs: { path }, toolResult }
#   Claude Code: { tool_name, tool_input: { file_path }, tool_response }
#
# Output: stderr is visible to the agent in both systems.
set -uo pipefail

INPUT=$(cat)

# Read tool name from either format (Claude Code: tool_name, Open Plugin: toolName)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .toolName // ""' 2>/dev/null || echo "")

# Only lint after edit/create (Open Plugin) or Edit/Write (Claude Code) operations
case "$TOOL_NAME" in
	edit | create | Edit | Write | write) ;;
	*) exit 0 ;;
esac

# Extract file path from either format:
#   Claude Code: tool_input.file_path
#   Open Plugin: toolArgs (string) parsed as JSON with .path
FILE_PATH=$(echo "$INPUT" | jq -r '
	.tool_input.file_path //
	((.toolArgs | if type == "string" then fromjson else . end) | .path) //
	empty
' 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ]; then
	exit 0
fi

# Only lint file types that linters typically handle
case "$FILE_PATH" in
	*.ts | *.tsx | *.js | *.jsx | *.json | *.css | *.scss | *.vue | *.svelte) ;;
	*) exit 0 ;;
esac

# Only lint if the file exists (create might have failed)
if [ ! -f "$FILE_PATH" ]; then
	exit 0
fi

echo "🔍 Running lint on $FILE_PATH..." >&2

# Detect and run the project's linter.
# Priority: biome > eslint > deno lint > none
if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
	# Biome — detect package runner
	if command -v pnpm &>/dev/null && [ -f "pnpm-lock.yaml" ]; then
		RUNNER="pnpm exec"
	elif command -v npx &>/dev/null; then
		RUNNER="npx"
	else
		echo "⚠️  Biome config found but no package runner available." >&2
		exit 0
	fi
	if $RUNNER biome check "$FILE_PATH" >&2 2>&1; then
		echo "✅ Lint passed: $FILE_PATH" >&2
	else
		echo "❌ Lint issues found in $FILE_PATH — please fix before committing." >&2
	fi
elif [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.yml" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ] || [ -f "eslint.config.ts" ]; then
	# ESLint — detect package runner
	if command -v pnpm &>/dev/null && [ -f "pnpm-lock.yaml" ]; then
		RUNNER="pnpm exec"
	elif command -v npx &>/dev/null; then
		RUNNER="npx"
	else
		echo "⚠️  ESLint config found but no package runner available." >&2
		exit 0
	fi
	if $RUNNER eslint --no-error-on-unmatched-pattern "$FILE_PATH" >&2 2>&1; then
		echo "✅ Lint passed: $FILE_PATH" >&2
	else
		echo "❌ Lint issues found in $FILE_PATH — please fix before committing." >&2
	fi
elif command -v deno &>/dev/null && [ -f "deno.json" ] || [ -f "deno.jsonc" ]; then
	if deno lint "$FILE_PATH" >&2 2>&1; then
		echo "✅ Lint passed: $FILE_PATH" >&2
	else
		echo "❌ Lint issues found in $FILE_PATH — please fix before committing." >&2
	fi
else
	echo "ℹ️  No linter detected — skipping lint for $FILE_PATH" >&2
fi

exit 0
