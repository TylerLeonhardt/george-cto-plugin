#!/bin/bash
# Session-end hook: Run the full test suite and typecheck as a final quality gate.
# Detects the project's package manager and test runner automatically.
#
# Compatible with both Open Plugin and Claude Code hook formats:
#   Open Plugin: { timestamp, cwd, reason }
#   Claude Code: { session_id, cwd, hook_event_name: "SessionEnd", ... }
#
# Output: stderr is visible to the agent in both systems.
#
# Intentionally omitting -e so the script keeps running even if individual
# commands fail — we want to report results from all quality gates, not bail early.
set -uo pipefail

INPUT=$(cat)

REASON=$(echo "$INPUT" | jq -r '.reason // "unknown"' 2>/dev/null || echo "unknown")
echo "📋 Session ending (reason: $REASON). Running quality gates..." >&2

FAILED=0

# Detect package manager
if [ -f "pnpm-lock.yaml" ] && command -v pnpm &>/dev/null; then
	PM="pnpm"
elif [ -f "yarn.lock" ] && command -v yarn &>/dev/null; then
	PM="yarn"
elif [ -f "bun.lockb" ] && command -v bun &>/dev/null; then
	PM="bun"
elif [ -f "package-lock.json" ] && command -v npm &>/dev/null; then
	PM="npm"
elif [ -f "Cargo.toml" ] && command -v cargo &>/dev/null; then
	PM="cargo"
elif [ -f "go.mod" ] && command -v go &>/dev/null; then
	PM="go"
elif [ -f "Makefile" ]; then
	PM="make"
else
	PM=""
fi

# Run tests based on detected ecosystem
echo "" >&2
if [ -n "$PM" ]; then
	case "$PM" in
		pnpm | yarn | npm | bun)
			# Check if a test script exists in package.json
			if [ -f "package.json" ] && jq -e '.scripts.test' package.json &>/dev/null; then
				echo "🧪 Running tests ($PM test)..." >&2
				if $PM test >&2 2>&1; then
					echo "✅ Tests passed." >&2
				else
					echo "❌ Tests failed." >&2
					FAILED=1
				fi
			else
				echo "ℹ️  No test script found in package.json — skipping tests." >&2
			fi

			# Run typecheck if a typecheck script exists
			if [ -f "package.json" ] && jq -e '.scripts.typecheck' package.json &>/dev/null; then
				echo "" >&2
				echo "🔎 Running typecheck ($PM run typecheck)..." >&2
				if $PM run typecheck >&2 2>&1; then
					echo "✅ Typecheck passed." >&2
				else
					echo "❌ Typecheck failed." >&2
					FAILED=1
				fi
			elif [ -f "tsconfig.json" ] && command -v npx &>/dev/null; then
				echo "" >&2
				echo "🔎 Running typecheck (tsc --noEmit)..." >&2
				if npx tsc --noEmit >&2 2>&1; then
					echo "✅ Typecheck passed." >&2
				else
					echo "❌ Typecheck failed." >&2
					FAILED=1
				fi
			fi
			;;
		cargo)
			echo "🧪 Running tests (cargo test)..." >&2
			if cargo test >&2 2>&1; then
				echo "✅ Tests passed." >&2
			else
				echo "❌ Tests failed." >&2
				FAILED=1
			fi
			echo "" >&2
			echo "🔎 Running clippy (cargo clippy)..." >&2
			if cargo clippy -- -D warnings >&2 2>&1; then
				echo "✅ Clippy passed." >&2
			else
				echo "❌ Clippy found issues." >&2
				FAILED=1
			fi
			;;
		go)
			echo "🧪 Running tests (go test ./...)..." >&2
			if go test ./... >&2 2>&1; then
				echo "✅ Tests passed." >&2
			else
				echo "❌ Tests failed." >&2
				FAILED=1
			fi
			echo "" >&2
			echo "🔎 Running vet (go vet ./...)..." >&2
			if go vet ./... >&2 2>&1; then
				echo "✅ Vet passed." >&2
			else
				echo "❌ Vet found issues." >&2
				FAILED=1
			fi
			;;
		make)
			if grep -q '^test:' Makefile; then
				echo "🧪 Running tests (make test)..." >&2
				if make test >&2 2>&1; then
					echo "✅ Tests passed." >&2
				else
					echo "❌ Tests failed." >&2
					FAILED=1
				fi
			else
				echo "ℹ️  No test target found in Makefile — skipping tests." >&2
			fi
			;;
	esac
else
	echo "ℹ️  No recognized project type detected — skipping quality gates." >&2
fi

# Summary
echo "" >&2
if [ "$FAILED" -eq 0 ]; then
	echo "🎉 All quality gates passed!" >&2
else
	echo "⚠️  Some quality gates failed. Please review the output above." >&2
fi

exit 0
